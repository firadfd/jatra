#!/usr/bin/env python3
"""Builds assets/geo/bd_upazilas.json: places and road links, for offline routing.

Run on a developer machine; the app only reads the result.

Inputs (see assets/geo/NOTICE.txt for sources and licences):
  --pbf        Geofabrik bangladesh-latest.osm.pbf
  --adm3       geoBoundaries BGD ADM3 *_simplified.geojson
  --upazilas   bangladesh-geocode upazilas.csv
  --districts  bangladesh-geocode districts.csv

Needs: pip install osmium scipy numpy shapely

How the links are chosen: road distance between every pair of places is
computed on the full OSM graph, then pairs are added shortest first, skipping
any pair the links so far already serve almost as well. Links are capped in
length so that a drawn route follows the corridor rather than cutting across it.
"""
import argparse
import csv
import difflib
import json
import math
import re
from collections import defaultdict

import numpy as np
import osmium
from scipy.sparse import csr_matrix
from scipy.sparse.csgraph import connected_components, dijkstra
from scipy.spatial import cKDTree
from shapely.geometry import Point, Polygon, shape
from shapely.ops import unary_union

# km/h, deliberately modest: ranks roads, is never shown.
SPEED = {
    'motorway': 80, 'trunk': 65, 'primary': 55, 'secondary': 45, 'tertiary': 35,
    'motorway_link': 40, 'trunk_link': 40, 'primary_link': 35,
    'secondary_link': 30, 'tertiary_link': 25, 'unclassified': 28,
    'residential': 20, 'living_street': 12, 'road': 20, 'service': 12,
    'track': 12,
}
FERRY_KMH = 12
# Waiting and boarding, in seconds. Keeps ferries a last resort.
FERRY_WAIT_S = 2700

MAX_LINK_KM = 70
STRETCH = 1.06
SNAP_LIMIT_KM = 12

DISTRICT_FIXES = {
    'Barisal': 'Barishal', 'Coxsbazar': "Cox's Bazar", 'Jhalakathi': 'Jhalokati',
}

FORMER = {'Barishal': 'barisal', 'Bogura': 'bogra', 'Cumilla': 'comilla',
          'Jashore': 'jessore', 'Chattogram': 'chittagong'}

# In no map source; positions are approximate, and snap to the nearest road.
APPROXIMATE = {
    ('Lakshmipur', 'Raipur'): (23.0397, 90.7683),
    ('Chattogram', 'Karnafuli'): (22.2900, 91.8600),
    ('Khagrachhari', 'Guimara'): (23.1300, 91.9200),
    ('Natore', 'Naldanga'): (24.4800, 89.0300),
    ('Patuakhali', 'Rangabali'): (21.9300, 90.4300),
    ('Sylhet', 'Osmaninagar'): (24.7900, 91.7300),
    ('Madaripur', 'Dasar'): (23.1200, 90.0700),
}

# Spellings in the upazila list that the map sources do not share.
SPELLINGS = {'Syedpur': 'Saidpur', 'Rowmari': 'Raumari', 'Fultola': 'Phultala',
             'Sadarsouth': 'Cumilla Sadar Dakshin'}

# Cities the upazila list omits because they are divided into metro thanas.
# (district, English, Bangla, lat, lng, search aliases)
CITIES = [
    ('Dhaka', 'Dhaka City', 'ঢাকা শহর', 23.7286, 90.4106, 'gulistan motijheel'),
    ('Chattogram', 'Chattogram City', 'চট্টগ্রাম শহর', 22.3350, 91.8325,
     'chittagong ctg'),
    ('Khulna', 'Khulna City', 'খুলনা শহর', 22.8158, 89.5636, ''),
    ('Rajshahi', 'Rajshahi City', 'রাজশাহী শহর', 24.3660, 88.6000, ''),
    ('Narayanganj', 'Narayanganj City', 'নারায়ণগঞ্জ শহর', 23.6238, 90.5000, ''),
    ('Gazipur', 'Gazipur City', 'গাজীপুর শহর', 24.0023, 90.4264, 'joydebpur'),
]


def norm(text):
    text = text.lower().replace('gonj', 'ganj').replace('pukur', 'pur')
    text = re.sub(r'upazila|upozila|thana|sadar|\(.*?\)|[^a-z]', '', text)
    return text.replace('oo', 'u').replace('ou', 'u').replace('sh', 's')


def metres(lat1, lng1, lat2, lng2):
    mean = math.radians((lat1 + lat2) / 2)
    dx = math.radians(lng2 - lng1) * math.cos(mean)
    dy = math.radians(lat2 - lat1)
    return math.hypot(dx, dy) * 6371000


class Reader(osmium.SimpleHandler):
    def __init__(self):
        super().__init__()
        self.ways = []
        self.named = []
        self.blocked = []

    def node(self, n):
        name = n.tags.get('name:en') or n.tags.get('name')
        if not name:
            return
        place = n.tags.get('place')
        office = 'upazila' in name.lower() and (
            'parishad' in name.lower() or 'nirbahi' in name.lower()
            or 'complex' in name.lower())
        if place in ('city', 'town', 'suburb', 'village') or office:
            self.named.append(
                (name, 'office' if office else place, n.location.lat, n.location.lon))

    def way(self, w):
        tags = w.tags
        ferry = tags.get('route') == 'ferry'
        kind = tags.get('highway')
        if not ferry and kind not in SPEED:
            return
        if tags.get('motorcycle') == 'no' or tags.get('motor_vehicle') == 'no' or (
                tags.get('access') in ('no', 'private')
                and tags.get('motorcycle') not in ('yes', 'designated', 'permissive')):
            if tags.get('bridge') or kind in ('motorway', 'trunk', 'primary'):
                self.blocked.append((tags.get('name:en') or tags.get('name') or '?',
                                     kind, dict(tags)))
            return
        try:
            refs = [(n.ref, n.lat, n.lon) for n in w.nodes]
        except osmium.InvalidLocationError:
            return
        if len(refs) >= 2:
            self.ways.append((refs, 'ferry' if ferry else kind))


def build_graph(ways):
    uses = defaultdict(int)
    for refs, _ in ways:
        for i, (ref, _, _) in enumerate(refs):
            uses[ref] += 2 if i in (0, len(refs) - 1) else 1

    index, lats, lngs = {}, [], []

    def node(ref, lat, lng):
        at = index.get(ref)
        if at is None:
            at = index[ref] = len(lats)
            lats.append(lat)
            lngs.append(lng)
        return at

    edges = {}
    for refs, kind in ways:
        ferry = kind == 'ferry'
        speed = FERRY_KMH if ferry else SPEED[kind]
        start, length = refs[0], 0.0
        for prev, cur in zip(refs, refs[1:]):
            length += metres(prev[1], prev[2], cur[1], cur[2])
            if uses[cur[0]] > 1 or cur is refs[-1]:
                a = node(*start)
                b = node(*cur)
                if a != b:
                    secs = length / (speed / 3.6) + (FERRY_WAIT_S if ferry else 0)
                    key = (min(a, b), max(a, b))
                    if key not in edges or secs < edges[key][0]:
                        edges[key] = (secs, length, ferry)
                start, length = cur, 0.0

    n = len(lats)
    pairs = np.array(list(edges.keys()), dtype=np.int64)
    values = np.array(list(edges.values()), dtype=float)
    rows = np.concatenate([pairs[:, 0], pairs[:, 1]])
    cols = np.concatenate([pairs[:, 1], pairs[:, 0]])
    secs = np.concatenate([values[:, 0], values[:, 0]])
    metre = np.concatenate([values[:, 1], values[:, 1]])
    ferry = np.concatenate([values[:, 2], values[:, 2]])
    order = np.argsort(rows * n + cols)
    keys = (rows * n + cols)[order]
    graph = csr_matrix((secs[order], (rows[order], cols[order])), shape=(n, n))
    return graph, np.array(lats), np.array(lngs), keys, metre[order], ferry[order]


def load_places(args, named):
    districts = {
        row[0]: (DISTRICT_FIXES.get(row[2], row[2]), row[3])
        for row in csv.reader(open(args.districts, encoding='utf-8'))
    }
    features = json.load(open(args.adm3, encoding='utf-8'))['features']
    polygons = [(f['properties']['shapeName'], shape(f['geometry']).buffer(0))
                for f in features]

    outlines = {}
    for d in json.load(open(args.outlines, encoding='utf-8'))['districts']:
        rings = [Polygon([(r[i], r[i + 1]) for i in range(0, len(r), 2)]).buffer(0)
                 for r in d['r'] if len(r) >= 6]
        outlines[d['en']] = unary_union(rings)

    by_district = defaultdict(list)
    for name, poly in polygons:
        owner = max(outlines, key=lambda k: outlines[k].intersection(poly).area)
        by_district[owner].append((name, poly))

    places, unmatched, how = [], [], defaultdict(int)
    for row in csv.reader(open(args.upazilas, encoding='utf-8')):
        district, district_bn = districts[row[1]]
        listed = row[2].strip()
        raw = SPELLINGS.get(listed, listed)
        en = raw.replace('gonj', 'ganj').replace('Gonj', 'Ganj')
        # "Bogra Sadar" -> "Bogura Sadar"; Sadarpur is a different place.
        en = re.sub(r'^.*?\bSadar\b', f'{district} Sadar', en)
        candidates = by_district[district]
        scored = [(difflib.SequenceMatcher(None, norm(raw), norm(n)).ratio(), n, p)
                  for n, p in candidates]
        score, _, poly = max(scored, key=lambda s: s[0]) if scored else (0, '', None)

        is_sadar = re.search(r'\bsadar\b', raw, re.I) is not None
        if is_sadar:
            # Named after the district in ADM3 ("Barisal Sadar (Kotwali)").
            sadars = [s for s in scored
                      if 'sadar' in s[1].lower() or 'kotwali' in s[1].lower()]
            if sadars:
                score, _, poly = 1.0, sadars[0][1], sadars[0][2]
        # Newer upazilas have no ADM3 shape; look across their district.
        has_shape = score >= 0.72
        area = (poly if has_shape else outlines[district]).buffer(0.02)

        lat, lng = None, None
        best, rank = None, 0
        for name, kind, nlat, nlng in named:
            if not area.contains(Point(nlng, nlat)):
                continue
            ratio = difflib.SequenceMatcher(None, norm(raw), norm(name)).ratio()
            value = {'office': 3.0, 'city': 2.4, 'town': 2.2}.get(kind, 0)
            if kind == 'office' and ratio < 0.5:
                continue
            if kind != 'office' and ratio < 0.84:
                continue
            if ratio + value > rank:
                best, rank = (nlat, nlng, kind), ratio + value
        if best:
            lat, lng = best[0], best[1]
            how[best[2]] += 1
        elif has_shape:
            point = poly.representative_point()
            lat, lng = point.y, point.x
            how['polygon'] += 1
        else:
            if (district, raw) in APPROXIMATE:
                lat, lng = APPROXIMATE[(district, raw)]
                how['approximate'] += 1
            else:
                unmatched.append(f'{district}/{raw} (best {score:.2f})')

        spelled = ' '.join(x.lower() for x in {listed, raw} if x != en)
        places.append(dict(en=en, bn=row[3].strip(), d=district, db=district_bn,
                           lat=lat, lng=lng, k=spelled.lower()))

    for district, en, bn, lat, lng, aliases in CITIES:
        db = next(v[1] for v in districts.values() if v[0] == district)
        places.append(dict(en=en, bn=bn, d=district, db=db, lat=lat, lng=lng,
                           k=aliases))

    # "Rangpur City" finds Rangpur Sadar.
    for p in places:
        if p['en'].endswith(' Sadar'):
            p['k'] = f"{p['k']} {p['d'].lower()} city".strip()
            p['k'] += f" {FORMER.get(p['d'], '')}".rstrip()

    return places, unmatched, dict(how)


def slug(place):
    make = lambda s: re.sub(r'[^a-z]+', '-', s.lower()).strip('-')
    return f"{make(place['d'])}.{make(place['en'])}"


def main():
    p = argparse.ArgumentParser()
    for name in ('pbf', 'adm3', 'upazilas', 'districts', 'outlines', 'out'):
        p.add_argument('--' + name, required=True)
    args = p.parse_args()

    reader = Reader()
    reader.apply_file(args.pbf, locations=True, idx='flex_mem')
    print(f'ways {len(reader.ways)}, named nodes {len(reader.named)}')
    print('blocked for motorcycles (named/major):')
    seen = set()
    for name, kind, tags in reader.blocked:
        if name != '?' and name not in seen:
            seen.add(name)
            print('  ', name, kind, {k: v for k, v in tags.items()
                                     if k in ('motorcycle', 'access', 'motor_vehicle',
                                              'bridge')})

    graph, lats, lngs, keys, lengths, ferries = build_graph(reader.ways)
    n = graph.shape[0]
    _, labels = connected_components(graph, directed=False)
    main_label = np.bincount(labels).argmax()
    keep = np.nonzero(labels == main_label)[0]
    print(f'graph {n} nodes, main component {keep.size}')

    places, unmatched, how = load_places(args, reader.named)
    print('location method', how)
    print(f'unmatched names ({len(unmatched)}):', unmatched)
    places = [q for q in places if q['lat'] is not None]

    # cos(mid-latitude) keeps nearest-node lookups roughly metric.
    scale = math.cos(math.radians(23.7))
    tree = cKDTree(np.c_[lats[keep] * 111.2, lngs[keep] * 111.2 * scale])
    sources = []
    for q in places:
        dist, at = tree.query([q['lat'] * 111.2, q['lng'] * 111.2 * scale])
        q['snap_km'] = float(dist)
        sources.append(keep[at])
        if dist > SNAP_LIMIT_KM:
            print(f"  far from any road: {q['d']}/{q['en']} {dist:.1f} km")

    count = len(places)
    road_m = np.full((count, count), np.inf)
    has_ferry = np.zeros((count, count), dtype=bool)
    source_array = np.array(sources)
    for i, source in enumerate(sources):
        _, pred = dijkstra(graph, directed=True, indices=source,
                           return_predecessors=True)
        reached = pred >= 0
        up = np.arange(n)
        up[reached] = pred[reached]
        at = np.searchsorted(keys, up[reached] * n + np.nonzero(reached)[0])
        length = np.zeros(n)
        ferry = np.zeros(n)
        length[reached] = lengths[at]
        ferry[reached] = ferries[at]
        # Pointer doubling sums each node's path back to the source.
        while True:
            length = length + length[up]
            ferry = ferry + ferry[up]
            next_up = up[up]
            if np.array_equal(next_up, up):
                break
            up = next_up
        road_m[i] = length[source_array]
        has_ferry[i] = ferry[source_array] > 0
        road_m[i, i] = 0
        if i % 100 == 0:
            print(f'  routed {i}/{count}', flush=True)

    road_m = np.minimum(road_m, road_m.T)

    served = np.full((count, count), np.inf)
    np.fill_diagonal(served, 0)
    pairs = [(road_m[i, j], i, j) for i in range(count) for j in range(i + 1, count)
             if road_m[i, j] <= MAX_LINK_KM * 1000]
    pairs.sort()
    links = []
    for metre, i, j in pairs:
        if served[i, j] <= metre * STRETCH:
            continue
        links.append((i, j, metre, bool(has_ferry[i, j] or has_ferry[j, i])))
        through = np.minimum(served[:, i][:, None] + metre + served[j, :][None, :],
                             served[:, j][:, None] + metre + served[i, :][None, :])
        served = np.minimum(served, through)

    finite = np.isfinite(road_m) & (road_m > 20000)
    stretch = served[finite] / road_m[finite]
    print(f'{len(links)} links; stretch mean {np.nanmean(stretch):.3f}, '
          f'p99 {np.nanpercentile(stretch, 99):.3f}, max {np.nanmax(stretch):.3f}; '
          f'unreachable pairs {np.count_nonzero(np.isinf(served))}')
    print('snap km max', max(q['snap_km'] for q in places))

    ids = [slug(q) for q in places]
    dupes = {x for x in ids if ids.count(x) > 1}
    if dupes:
        raise SystemExit(f'duplicate ids: {dupes}')

    output = {
        'source': 'See assets/geo/NOTICE.txt. Generated by '
                  'tool/build_upazila_network.py.',
        'places': [
            {'id': ids[i], 'en': q['en'], 'bn': q['bn'], 'd': q['d'], 'db': q['db'],
             'a': [round(q['lat'], 4), round(q['lng'], 4)],
             **({'k': q['k']} if q['k'] else {})}
            for i, q in enumerate(places)
        ],
        # [placeA, placeB, tenths of a km, 1 when the road uses a ferry]
        'links': [[i, j, round(m / 100), 1 if f else 0] for i, j, m, f in links],
    }
    with open(args.out, 'w', encoding='utf-8') as out:
        json.dump(output, out, ensure_ascii=False, separators=(',', ':'))

    # Kept for the accuracy report; not shipped.
    np.savez_compressed(args.out + '.check.npz', road_m=road_m, served=served,
                        ids=np.array(ids))


if __name__ == '__main__':
    main()

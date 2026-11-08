import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/numeric_input.dart';
import '../../core/widgets/jatra_widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../services/district_map.dart';
import 'route_planner_controller.dart';
import 'widgets/route_card_face.dart';

class RoutePlannerView extends GetView<RoutePlannerController> {
  const RoutePlannerView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final c = context.jatra;

    return Scaffold(
      appBar: AppBar(title: Text(l.routeTitle)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ContentColumn(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, Gap.xl),
            children: [
              JatraCard(
                child: Column(
                  children: [
                    Obx(
                      () => _DistrictPicker(
                        label: l.routeStart,
                        selected: controller.start.value,
                        onChanged: controller.setStart,
                      ),
                    ),
                    const SizedBox(height: Gap.md),
                    Obx(
                      () => _DistrictPicker(
                        label: l.routeEnd,
                        selected: controller.end.value,
                        onChanged: controller.setEnd,
                      ),
                    ),
                    const SizedBox(height: Gap.md),
                    Obx(
                      () => TextField(
                        controller: controller.distanceCtrl,
                        enabled: controller.route.value != null,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [const DecimalInputFormatter()],
                        decoration: InputDecoration(
                          labelText: l.routeDistance,
                          suffixText: controller.fmt.distanceLabel,
                          helperMaxLines: 2,
                          helperText: controller.route.value == null
                              ? null
                              : controller.isManual
                              ? l.routeEditedHelp
                              : l.routeEstimateHelp,
                        ),
                      ),
                    ),
                    Obx(
                      () => controller.isManual
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: controller.useEstimate,
                                child: Text(l.routeUseEstimate),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: Gap.md),
                    TextField(
                      controller: controller.nameCtrl,
                      decoration: InputDecoration(labelText: l.routeYourName),
                    ),
                    const SizedBox(height: Gap.md),
                    TextField(
                      controller: controller.bikeCtrl,
                      decoration: InputDecoration(
                        labelText: l.routeBikeName,
                        hintText: l.routeBikeHint,
                      ),
                    ),
                    const SizedBox(height: Gap.md),
                    const _ProfilePhotoRow(),
                  ],
                ),
              ),
              Obx(
                () => controller.route.value == null
                    ? const SizedBox.shrink()
                    : const Padding(
                        padding: EdgeInsets.only(top: Gap.md),
                        child: _StopsCard(),
                      ),
              ),
              const SizedBox(height: Gap.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(Radii.input),
                child: AspectRatio(
                  aspectRatio:
                      RouteCardFace.size.width / RouteCardFace.size.height,
                  child: FittedBox(
                    child: Obx(
                      () => RouteCardFace(
                        districts: controller.districts,
                        content: controller.content(),
                        l: l,
                        onDistrictTap: controller.route.value == null
                            ? null
                            : controller.toggleStop,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Gap.md),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => FilledButton.icon(
                    onPressed:
                        controller.route.value == null ||
                            controller.isSharing.value
                        ? null
                        : () => controller.share(l),
                    icon: const Icon(Icons.share_outlined),
                    label: Text(l.routeShare),
                  ),
                ),
              ),
              const SizedBox(height: Gap.md),
              // Required by the boundary data's licence. A credit, so not
              // translated. See assets/geo/NOTICE.txt.
              Text(
                'District boundaries: geoBoundaries, BBS and OCHA ROAP '
                '(CC BY 3.0 IGO), simplified.',
                style: AppText.caption.copyWith(color: c.textMuted),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Optional photo for the card, with its own preview.
class _ProfilePhotoRow extends GetView<RoutePlannerController> {
  const _ProfilePhotoRow();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final c = context.jatra;

    return Obx(() {
      final photo = controller.photo.value;
      return Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 48,
              height: 48,
              child: photo == null
                  ? ColoredBox(
                      color: c.border,
                      child: Icon(Icons.person_outline, color: c.textMuted),
                    )
                  : RawImage(image: photo, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: OutlinedButton(
              onPressed: () => controller.pickPhoto(l),
              child: Text(
                photo == null ? l.routeAddPhoto : l.routeChangePhoto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (photo != null)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: l.routeRemovePhoto,
              onPressed: controller.removePhoto,
            ),
        ],
      );
    });
  }
}

/// The route as an editable list. Start and end are fixed here; they change
/// through their own pickers above.
class _StopsCard extends GetView<RoutePlannerController> {
  const _StopsCard();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final c = context.jatra;

    return JatraCard(
      child: Obx(() {
        final route = controller.route.value;
        if (route == null) return const SizedBox.shrink();
        final via = route.via;
        final locale = controller.locale;
        final taken = {for (final d in route.districts) d.en};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(
              l.routeStopsTitle,
              trailing: controller.isCustomRoute.value
                  ? TextButton(
                      onPressed: controller.resetRoute,
                      child: Text(l.routeResetSuggested),
                    )
                  : null,
            ),
            const SizedBox(height: Gap.xs),
            Text(
              l.routeStopsHelp,
              style: AppText.caption.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: Gap.sm),
            _FixedStop(
              icon: Icons.trip_origin,
              name: route.districts.first.nameIn(locale),
            ),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorderItem: controller.moveStop,
              children: [
                for (var i = 0; i < via.length; i++)
                  ListTile(
                    key: ValueKey(via[i].en),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: ReorderableDragStartListener(
                      index: i,
                      child: const Icon(Icons.drag_indicator),
                    ),
                    title: Text(via[i].nameIn(locale)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: l.routeRemoveStop,
                      onPressed: () => controller.removeStop(via[i].en),
                    ),
                  ),
              ],
            ),
            if (route.districts.length > 1)
              _FixedStop(
                icon: Icons.place,
                name: route.districts.last.nameIn(locale),
              ),
            const SizedBox(height: Gap.sm),
            _DistrictPicker(
              label: l.routeAddStop,
              selected: null,
              onChanged: controller.addStop,
              exclude: taken,
            ),
          ],
        );
      }),
    );
  }
}

class _FixedStop extends StatelessWidget {
  const _FixedStop({required this.icon, required this.name});

  final IconData icon;
  final String name;

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, color: c.signal),
      title: Text(name, style: AppText.titleMd.copyWith(color: c.textPrimary)),
    );
  }
}

/// A field that opens the district search.
class _DistrictPicker extends GetView<RoutePlannerController> {
  const _DistrictPicker({
    required this.label,
    required this.selected,
    required this.onChanged,
    this.exclude = const {},
  });

  final String label;
  final String? selected;
  final ValueChanged<String?> onChanged;

  /// Districts not offered, such as ones already on the route.
  final Set<String> exclude;

  @override
  Widget build(BuildContext context) {
    final locale = controller.locale;
    final current = controller.districts.districts
        .where((d) => d.en == selected)
        .firstOrNull;

    return InkWell(
      borderRadius: BorderRadius.circular(Radii.input),
      onTap: () => _open(context),
      child: InputDecorator(
        isEmpty: current == null,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.search),
        ),
        child: Text(current?.nameIn(locale) ?? ''),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _DistrictSearchSheet(
        title: label,
        locale: controller.locale,
        districts: [
          for (final d in controller.sortedDistricts)
            if (!exclude.contains(d.en)) d,
        ],
      ),
    );
    if (picked != null) onChanged(picked);
  }
}

class _DistrictSearchSheet extends StatefulWidget {
  const _DistrictSearchSheet({
    required this.title,
    required this.locale,
    required this.districts,
  });

  final String title;
  final String locale;
  final List<District> districts;

  @override
  State<_DistrictSearchSheet> createState() => _DistrictSearchSheetState();
}

class _DistrictSearchSheetState extends State<_DistrictSearchSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final c = context.jatra;
    final media = MediaQuery.of(context);
    final results = widget.districts.where((d) => d.matches(_query)).toList();
    final otherLocale = widget.locale == 'bn' ? 'en' : 'bn';

    return Padding(
      // Keeps the results above the keyboard.
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: media.size.height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Gap.md,
                Gap.md,
                Gap.md,
                Gap.sm,
              ),
              child: TextField(
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: widget.title,
                  hintText: l.routeSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        l.routeSearchNone,
                        style: AppText.bodySm.copyWith(color: c.textMuted),
                      ),
                    )
                  : ListView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final district = results[index];
                        return ListTile(
                          title: Text(district.nameIn(widget.locale)),
                          subtitle: Text(
                            district.nameIn(otherLocale),
                            style: AppText.caption.copyWith(color: c.textMuted),
                          ),
                          onTap: () => Navigator.of(context).pop(district.en),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

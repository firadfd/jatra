import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_text.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/jatra_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/map_tile_cache.dart';

/// Offline map storage: how much of it there is, and how to get rid of it.
///
/// A cache that fills up silently with no way to see or clear it is the kind
/// of thing that makes people uninstall an app, so it gets a row of its own
/// rather than hiding behind the OS storage screen.
///
/// The copy is careful about one thing: Jatra keeps tiles it has *already*
/// drawn, and never fetches a region ahead of time. Bulk downloading is
/// against OpenStreetMap's tile usage policy, and saying so plainly is more
/// useful than an "offline maps" switch that implies otherwise.
class MapCacheSection extends StatefulWidget {
  const MapCacheSection({super.key});

  @override
  State<MapCacheSection> createState() => _MapCacheSectionState();
}

class _MapCacheSectionState extends State<MapCacheSection> {
  final _cache = Get.find<MapTileCache>();

  int? _bytes;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final bytes = await _cache.sizeBytes();
    if (mounted) setState(() => _bytes = bytes);
  }

  Future<void> _clear() async {
    setState(() => _busy = true);
    await _cache.clear();
    await _refresh();
    if (!mounted) return;

    setState(() => _busy = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(L.of(context).settingsMapCacheCleared)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final bytes = _bytes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(L.of(context).settingsMapCache),
        const SizedBox(height: Gap.sm),
        JatraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                L.of(context).settingsMapCacheBody,
                style: AppText.bodySm.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Gap.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      bytes == null
                          ? '—'
                          : L
                                .of(context)
                                .settingsMapCacheStored(Fmt.fileSize(bytes)),
                      style: AppText.bodySm.copyWith(color: c.textSecondary),
                    ),
                  ),
                  TextButton(
                    // Nothing stored is nothing to clear, and a live button
                    // that does nothing is worse than a dim one.
                    onPressed: _busy || bytes == null || bytes == 0
                        ? null
                        : _clear,
                    child: Text(L.of(context).settingsMapCacheClear),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

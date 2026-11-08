import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/app_theme.dart';
import '../../core/widgets/jatra_widgets.dart';
import '../../l10n/app_localizations.dart';
import 'ride_card_controller.dart';
import 'widgets/ride_card_face.dart';

/// Live preview above the options, with Share always in reach.
class RideCardView extends GetView<RideCardController> {
  const RideCardView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final c = context.jatra;

    return Scaffold(
      appBar: AppBar(title: Text(l.ridesCardTitle)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.notFound.value) {
          return EmptyState(
            icon: Icons.route_outlined,
            title: l.ridesNotFoundTitle,
            message: l.ridesNotFoundBody,
          );
        }

        return ContentColumn(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, Gap.xl),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Radii.input),
                child: AspectRatio(
                  aspectRatio:
                      RideCardFace.size.width / RideCardFace.size.height,
                  child: FittedBox(
                    child: Obx(
                      () => RideCardFace(
                        content: controller.content(l),
                        districts: controller.districts,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Gap.md),
              JatraCard(
                child: Column(
                  children: [
                    TextField(
                      controller: controller.fromCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(labelText: l.ridesCardFrom),
                    ),
                    const SizedBox(height: Gap.md),
                    TextField(
                      controller: controller.toCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(labelText: l.ridesCardTo),
                    ),
                    const SizedBox(height: Gap.md),
                    TextField(
                      controller: controller.usernameCtrl,
                      decoration: InputDecoration(
                        labelText: l.ridesCardUsername,
                      ),
                    ),
                    const SizedBox(height: Gap.md),
                    TextField(
                      controller: controller.bikeCtrl,
                      decoration: InputDecoration(labelText: l.ridesCardBike),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Gap.md),
              JatraCard(
                child: Obx(() {
                  final hasPhoto = controller.photo.value != null;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => controller.pickPhoto(l),
                          icon: const Icon(Icons.image_outlined),
                          label: Text(
                            hasPhoto
                                ? l.ridesCardChangePhoto
                                : l.ridesCardPhoto,
                          ),
                        ),
                      ),
                      if (hasPhoto)
                        TextButton(
                          onPressed: controller.removePhoto,
                          child: Text(l.ridesCardRemovePhoto),
                        )
                      else ...[
                        const SizedBox(height: Gap.sm),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: controller.showRoute.value,
                          onChanged: (v) => controller.showRoute.value = v,
                          title: Text(l.ridesCardShowRoute),
                          subtitle: Text(
                            l.ridesCardRouteExplain,
                            style: AppText.bodySm.copyWith(color: c.textMuted),
                          ),
                        ),
                      ],
                    ],
                  );
                }),
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
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(Gap.md),
        child: Obx(
          () => FilledButton.icon(
            onPressed:
                controller.isLoading.value ||
                    controller.notFound.value ||
                    controller.isSharing.value
                ? null
                : () => controller.share(l),
            icon: const Icon(Icons.share_outlined),
            label: Text(l.ridesCardShare),
          ),
        ),
      ),
    );
  }
}

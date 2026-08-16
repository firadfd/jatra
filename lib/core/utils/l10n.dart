import 'package:get/get.dart' hide Value;

import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_en.dart';

/// The active translations, for the handful of user-facing strings that live
/// in a controller rather than in a widget.
///
/// Views should always use `L.of(context)` — it is the reason a widget has a
/// context, and it rebuilds correctly when the locale changes. This exists for
/// the cases with no context to hand: validator messages returned to a form,
/// and the text of a `Get.snackbar` raised from a save method.
///
/// Falls back to English rather than throwing. A missing overlay context means
/// something is being driven headlessly — a unit test, most likely — and a
/// crash there would be a worse answer than an untranslated string that no one
/// is looking at.
L get l10n {
  final context = Get.context;
  return context == null ? LEn() : L.of(context);
}

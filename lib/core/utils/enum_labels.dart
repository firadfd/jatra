import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import 'clock.dart';

/// Display names for the enums that reach the screen.
///
/// The enums themselves live in `lib/data/models` and deliberately carry no
/// translations: they are persisted values, and a stored category must not
/// change meaning because the interface language did. Their built-in `label`
/// getters are English fallbacks for logs and tests; anything a rider reads
/// comes through here.
extension ExpenseCategoryL10n on ExpenseCategory {
  String labelOf(L l) => switch (this) {
    ExpenseCategory.insurance => l.categoryInsurance,
    ExpenseCategory.taxToken => l.categoryTaxToken,
    ExpenseCategory.fitness => l.categoryFitness,
    ExpenseCategory.registration => l.categoryRegistration,
    ExpenseCategory.accessories => l.categoryAccessories,
    ExpenseCategory.fine => l.categoryFine,
    ExpenseCategory.parking => l.categoryParking,
    ExpenseCategory.washing => l.categoryWashing,
    ExpenseCategory.other => l.categoryOther,
  };
}

extension ServiceStatusL10n on ServiceStatus {
  String labelOf(L l) => switch (this) {
    ServiceStatus.overdue => l.statusOverdue,
    ServiceStatus.dueNow => l.statusDueNow,
    ServiceStatus.dueSoon => l.statusDueSoon,
    ServiceStatus.ok => l.statusOk,
    ServiceStatus.unknown => l.statusNotSet,
  };
}

extension TrackingModeL10n on TrackingMode {
  String labelOf(L l) => switch (this) {
    TrackingMode.off => l.trackingOff,
    TrackingMode.appOpen => l.trackingAppOpen,
    TrackingMode.background => l.trackingBackground,
  };

  String descriptionOf(L l) => switch (this) {
    TrackingMode.off => l.trackingOffExplain,
    TrackingMode.appOpen => l.trackingAppOpenExplain,
    TrackingMode.background => l.trackingBackgroundExplain,
  };
}

extension ReminderTypeL10n on ReminderType {
  String labelOf(L l) => switch (this) {
    ReminderType.service => l.reminderService,
    ReminderType.documentExpiry => l.reminderDocumentExpiry,
    ReminderType.custom => l.reminderCustom,
  };
}

extension DistanceUnitL10n on DistanceUnit {
  /// The unit as a *word*, for pickers and prose.
  ///
  /// Distinct from `Fmt.distanceLabel`, which is the technical suffix printed
  /// beside a figure (`24,180 KM`) and stays Latin in every language for the
  /// same reason the digits do — see `Fmt.numberLocale`.
  String wordOf(L l) => switch (this) {
    DistanceUnit.km => l.unitKm,
    DistanceUnit.mi => l.unitMiles,
  };
}

extension VolumeUnitL10n on VolumeUnit {
  String wordOf(L l) => switch (this) {
    VolumeUnit.l => l.unitLitres,
    VolumeUnit.gal => l.unitGallons,
  };
}

/// `today`, `in 4 days`, `3 days ago` — in the reader's language.
///
/// Lives here rather than on `Fmt` because it is the one date helper that
/// produces *words* rather than a pattern `intl` can localise on its own.
String relativeDayOf(L l, int ms) {
  final days = Dates.daysBetween(
    Dates.startOfLocalDay(Clock.nowMs),
    Dates.startOfLocalDay(ms),
  );
  return switch (days) {
    0 => l.dateToday,
    1 => l.dateTomorrow,
    -1 => l.dateYesterday,
    > 1 => l.dateInDays(days),
    _ => l.dateDaysAgo(-days),
  };
}

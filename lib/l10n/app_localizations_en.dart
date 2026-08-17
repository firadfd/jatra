// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Jatra';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionBack => 'Back';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionNotNow => 'Not now';

  @override
  String get actionGotIt => 'Got it';

  @override
  String get actionSeeAll => 'See all';

  @override
  String get navHome => 'Home';

  @override
  String get navFuelLog => 'Fuel log';

  @override
  String get navService => 'Service';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get navRides => 'Rides';

  @override
  String get navStatistics => 'Statistics';

  @override
  String get navBikes => 'Bikes';

  @override
  String get navSettings => 'Settings';

  @override
  String get navFuel => 'Fuel';

  @override
  String get navMap => 'Map';

  @override
  String get navStats => 'Stats';

  @override
  String onboardingStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingBikeTitle => 'What are you riding?';

  @override
  String get onboardingBikeBody =>
      'A name is all Jatra needs. Everything else can wait.';

  @override
  String get onboardingBikeName => 'Bike name';

  @override
  String get onboardingBikeNameError =>
      'Give your bike a name — \"Pulsar\" works fine.';

  @override
  String get onboardingMake => 'Make';

  @override
  String get onboardingModel => 'Model';

  @override
  String get onboardingFuel => 'Fuel';

  @override
  String get onboardingOdometerTitle => 'What does the odometer read?';

  @override
  String get onboardingOdometerBody =>
      'Jatra measures everything from here. Round to the nearest whole number — it does not need to be exact.';

  @override
  String get onboardingOdometerLabel => 'Current reading';

  @override
  String onboardingOdometerError(String unit) {
    return 'Enter the reading on your odometer right now, in $unit.';
  }

  @override
  String get onboardingUnits => 'Units';

  @override
  String get onboardingDoneTitle => 'You are set.';

  @override
  String get onboardingDoneBody =>
      'Log every refuel and Jatra works out your real mileage, when your next service is due, and what a kilometre actually costs you.';

  @override
  String get onboardingPrivacyTitle => 'Everything stays on this phone';

  @override
  String get onboardingPrivacyBody =>
      'No account, no cloud, no analytics. Your fuel, service and expense records never leave this phone, and all of that works in airplane mode. Export a full backup whenever you want it.\n\nThe one exception: if you record a ride, the map behind it loads from OpenStreetMap, which sees roughly where that ride was.';

  @override
  String get onboardingPermissionNote =>
      'Location tracking is off, and Jatra will not ask for any permission until you turn on a feature that needs one.';

  @override
  String get onboardingStart => 'Start tracking';

  @override
  String get unitKm => 'km';

  @override
  String get unitMiles => 'miles';

  @override
  String get unitLitres => 'litres';

  @override
  String get unitGallons => 'gallons';

  @override
  String get homeOdometer => 'Odometer';

  @override
  String get homeLastTank => 'Last tank';

  @override
  String get homeRunningCost => 'Running cost';

  @override
  String get homeRunningCostCaption => 'Fuel, service and fixed';

  @override
  String get homeNextService => 'Next service';

  @override
  String get homeRecentFills => 'Recent fills';

  @override
  String get homeNeedsTwoTanks => 'Needs two full tanks';

  @override
  String get homeLatestUnreliable => 'Latest tank was unreliable';

  @override
  String homeAverage(String value, String unit) {
    return 'Average $value $unit';
  }

  @override
  String get homeNoBikeTitle => 'No bike selected';

  @override
  String get homeNoBikeBody => 'Add a bike to start logging fuel and services.';

  @override
  String get homeAddBike => 'Add a bike';

  @override
  String get homeNoFillsTitle => 'No fills logged yet';

  @override
  String get homeNoFillsBody =>
      'Add your first refuel to start tracking mileage.';

  @override
  String get homeAddFuel => 'Add fuel';

  @override
  String get homeNothingDue => 'Nothing due';

  @override
  String get homeNoServiceItems => 'No service items set up yet.';

  @override
  String homeAllClear(int count) {
    return 'All $count items are in the clear.';
  }

  @override
  String mileageDropTitle(int percent) {
    return 'Mileage down $percent% this tank';
  }

  @override
  String mileageDropVsUsual(String value) {
    return 'vs your usual $value';
  }

  @override
  String get mileageDropCauses =>
      'Common causes: tyre pressure, air filter, chain tension.';

  @override
  String get fuelAdd => 'Add fuel';

  @override
  String get fuelEdit => 'Edit fill';

  @override
  String get fuelSave => 'Save fill';

  @override
  String get fuelHistory => 'Fuel history';

  @override
  String get fuelWhen => 'When';

  @override
  String get fuelDate => 'Date';

  @override
  String get fuelOdometer => 'Odometer';

  @override
  String fuelLastReading(String value, String unit) {
    return 'Last reading: $value $unit';
  }

  @override
  String fuelOdometerMustBeHigher(String value, String unit) {
    return 'Odometer must be higher than your last reading of $value $unit.';
  }

  @override
  String get fuelHowMuch => 'How much';

  @override
  String get fuelFillAnyTwo => 'Fill in any two';

  @override
  String get fuelAdded => 'Fuel added';

  @override
  String get fuelPrice => 'Price';

  @override
  String get fuelTotalPaid => 'Total paid';

  @override
  String get fuelFilledTank => 'Filled the tank';

  @override
  String get fuelFullTankExplain => 'Mileage is measured between full tanks.';

  @override
  String get fuelPartialExplain =>
      'Partial fill. It counts toward your next full tank, but gets no mileage figure of its own.';

  @override
  String get fuelMissedEntry => 'I missed logging a fill before this';

  @override
  String get fuelMissedEntryExplain =>
      'Keeps this tank out of your averages, since some fuel is unaccounted for.';

  @override
  String get fuelStation => 'Station';

  @override
  String get fuelNotes => 'Notes';

  @override
  String get fuelPartial => 'Partial';

  @override
  String get fuelGap => 'Gap';

  @override
  String get fuelUnreliable => 'unreliable';

  @override
  String get fuelCountsTowardNext => 'Counts toward\nnext tank';

  @override
  String get fuelNoFillsTitle => 'No fills logged yet';

  @override
  String get fuelNoFillsBody =>
      'Add your first refuel to start tracking mileage.';

  @override
  String fuelCountFills(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fills',
      one: '1 fill',
    );
    return '$_temp0';
  }

  @override
  String get serviceTitle => 'Service';

  @override
  String get serviceDue => 'Due';

  @override
  String get serviceNothingPending => 'Nothing pending';

  @override
  String serviceNeedAttention(int count) {
    return '$count need attention';
  }

  @override
  String get serviceLogAction => 'Log service';

  @override
  String get serviceHistory => 'History';

  @override
  String get serviceNoItemsTitle => 'No service items';

  @override
  String get serviceNoItemsBody =>
      'Add the jobs you want Jatra to keep track of — engine oil, chain lube, brake pads.';

  @override
  String get serviceAddItem => 'Add a service item';

  @override
  String get serviceNothingLogged =>
      'Nothing logged yet. Log a service and Jatra will move that item\'s next due point forward for you.';

  @override
  String get serviceRemindersTitle => 'Get told when a service is due';

  @override
  String get serviceRemindersBody =>
      'Jatra will post a reminder on this phone. Nothing is sent anywhere — the reminder is worked out here, from your own log.';

  @override
  String get serviceRemindersEnable => 'Turn on reminders';

  @override
  String serviceToGo(String value, String unit) {
    return '$value $unit to go';
  }

  @override
  String serviceOver(String value, String unit) {
    return '$value $unit over';
  }

  @override
  String get serviceNoInterval => 'No interval set. Edit to add one.';

  @override
  String get statusOk => 'OK';

  @override
  String get statusDueSoon => 'DUE SOON';

  @override
  String get statusDueNow => 'DUE NOW';

  @override
  String get statusOverdue => 'OVERDUE';

  @override
  String get statusNotSet => 'NOT SET';

  @override
  String get expensesTitle => 'Expenses';

  @override
  String get expensesAdd => 'Add an expense';

  @override
  String get expensesDocuments => 'Documents';

  @override
  String get expensesTotal => 'Total';

  @override
  String get expensesAllBikes => 'All bikes';

  @override
  String get expensesNoneTitle => 'No expenses logged';

  @override
  String get expensesNoneBody =>
      'Insurance, tax token, fitness, a new helmet — anything that is not fuel or a service.';

  @override
  String get expensesExpired => 'Expired';

  @override
  String get expensesExpiresToday => 'Expires today';

  @override
  String expensesDaysLeft(int count) {
    return '$count days';
  }

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsRangeThisMonth => 'This month';

  @override
  String get statsRangeLast3Months => 'Last 3 months';

  @override
  String get statsRangeThisYear => 'This year';

  @override
  String get statsRangeAllTime => 'All time';

  @override
  String get statsRangeCustom => 'Custom';

  @override
  String statsCostPer(String unit) {
    return 'Cost per $unit';
  }

  @override
  String get statsFuel => 'Fuel';

  @override
  String get statsFuelExplain =>
      'Petrol only. Moves with pump prices and traffic.';

  @override
  String get statsRunning => 'Running';

  @override
  String get statsRunningExplain => 'Fuel, servicing, parts and fixed costs.';

  @override
  String get statsTrue => 'True';

  @override
  String get statsTrueExplain => 'Running cost plus the value the bike lost.';

  @override
  String get statsEstimate => 'Estimate';

  @override
  String statsNeedTwoReadings(String unit) {
    return 'Two odometer readings in this period are needed before Jatra can work out what a $unit costs. Log another fill.';
  }

  @override
  String get statsAddPurchasePrice =>
      'Add what you paid for the bike to see this.';

  @override
  String get statsTripTitle => 'What would a trip cost?';

  @override
  String get statsTripDistance => 'Distance';

  @override
  String get statsTripUsesRates =>
      'Uses the rates from the period selected above.';

  @override
  String get statsTripNotEnough =>
      'Not enough history in this period to price a trip. Try a wider range.';

  @override
  String get statsTrueCost => 'True cost';

  @override
  String get statsMileageOverTime => 'Mileage over time';

  @override
  String get statsMileageSubtitle =>
      'One point per full tank measured against the last';

  @override
  String get statsMileageEmpty =>
      'Two full tanks in this period will draw a line here.';

  @override
  String get statsMonthlySpend => 'Monthly spend';

  @override
  String get statsMonthlySpendSubtitle => 'Where the money went';

  @override
  String get statsDistancePerMonth => 'Distance per month';

  @override
  String get statsDistanceEmpty =>
      'Needs two odometer readings in a month to measure a distance.';

  @override
  String get statsFuelPricePaid => 'Fuel price paid';

  @override
  String get statsNotEnoughData => 'Not enough data yet.';

  @override
  String get statsOther => 'Other';

  @override
  String get statsDistance => 'Distance';

  @override
  String get statsTotalSpent => 'Total spent';

  @override
  String get statsAverage => 'Average';

  @override
  String get statsBestTank => 'Best tank';

  @override
  String get statsWorstTank => 'Worst tank';

  @override
  String get statsFills => 'Fills';

  @override
  String get statsDaysOwned => 'Days owned';

  @override
  String get statsFuelShare => 'Fuel share';

  @override
  String get ridesTitle => 'Rides';

  @override
  String get ridesStart => 'Start ride';

  @override
  String get ridesRecording => 'Recording';

  @override
  String get ridesPaused => 'Paused';

  @override
  String get ridesPause => 'Pause';

  @override
  String get ridesResume => 'Resume';

  @override
  String get ridesFinish => 'Finish';

  @override
  String ridesPoints(int count) {
    return '$count points';
  }

  @override
  String get ridesTrackingOffTitle => 'Ride tracking is off';

  @override
  String get ridesTrackingOffBody =>
      'Jatra can trace your route with GPS and work out distance and speed. It is off by default and asks for location only when you switch it on.\n\nEverything else in Jatra works without it.';

  @override
  String get ridesSetUp => 'Set up ride tracking';

  @override
  String get ridesNoneTitle => 'No rides recorded';

  @override
  String get ridesNoneBody =>
      'Start a ride and Jatra will trace where you went and how far.';

  @override
  String get ridesInterruptedTitle => 'A ride was left recording';

  @override
  String get ridesResumeAction => 'Resume';

  @override
  String get ridesSaveWhatWeHave => 'Save what we have';

  @override
  String get ridesDiscard => 'Discard';

  @override
  String ridesGapNotice(int minutes) {
    return 'Ride paused while the app was closed — $minutes min gap. Turn on background tracking to keep recording with the screen off.';
  }

  @override
  String get ridesNoPath => 'No path recorded for this ride.';

  @override
  String get ridesMovingTime => 'Moving time';

  @override
  String get ridesTotalTime => 'Total time';

  @override
  String get ridesAverageSpeed => 'Average speed';

  @override
  String get ridesTopSpeed => 'Top speed';

  @override
  String get ridesStopped => 'Stopped';

  @override
  String get ridesElevation => 'Elevation';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPrivacyTitle => 'No data leaves this device, ever';

  @override
  String get settingsPrivacyBody =>
      'Jatra has no account, no server of its own and no analytics. Everything works in airplane mode except the map behind a recorded ride, which loads its tiles from OpenStreetMap.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsMileageAlert => 'Mileage alert';

  @override
  String get settingsMileageAlertPrompt =>
      'Warn me when a tank falls below my usual by';

  @override
  String get settingsMileageAlertOff => 'Off';

  @override
  String get settingsMileageAlertExplain =>
      'Compared against the median of your last five reliable tanks, so one unusual week does not trigger it.';

  @override
  String get settingsMileageAlertDisabled =>
      'Jatra will not comment on mileage changes.';

  @override
  String get settingsReminders => 'Reminders';

  @override
  String get settingsRemindersTitle => 'Service and document reminders';

  @override
  String get settingsRemindersBody =>
      'Posted on this phone, worked out from your own log. Nothing is sent anywhere.';

  @override
  String get settingsRemindersBlocked =>
      'Notifications are switched off for Jatra in your Android settings. Turn them back on there and this will start working again.';

  @override
  String get settingsDepreciation => 'Depreciation';

  @override
  String get settingsDepreciationPrompt =>
      'Assume a bike loses this much of its price each year';

  @override
  String get settingsDepreciationExplain =>
      'Only used for bikes with no current-value estimate. True cost per kilometre is always an estimate.';

  @override
  String get settingsTracking => 'Ride tracking';

  @override
  String get settingsTrackingBody =>
      'Jatra can trace your route with GPS. Everything else in the app works without it.';

  @override
  String get settingsKeepScreenOn => 'Keep screen on during rides';

  @override
  String get settingsKeepScreenOnExplain =>
      'Released as soon as you stop recording.';

  @override
  String get settingsBikes => 'Bikes';

  @override
  String get settingsManageBikes => 'Manage bikes';

  @override
  String get settingsManageBikesBody => 'Add, edit, set default, archive';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsBackup => 'Backup and export';

  @override
  String get settingsBackupBody => 'JSON backup, spreadsheets, restore';

  @override
  String get settingsDeleteLocationHistory => 'Delete location history';

  @override
  String get settingsDeleteLocationHistoryBody =>
      'Removes recorded routes. Ride distances and times are kept.';

  @override
  String get settingsDeleteAll => 'Delete all data';

  @override
  String get settingsDeleteAllBody => 'Every bike, fill, service and setting';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutBody =>
      'An offline fuel, service and ride-cost tracker for motorcycles.';

  @override
  String get settingsFontCredit =>
      'Typeset in Barlow Condensed, Inter, JetBrains Mono and Hind Siliguri, all under the SIL Open Font License.';

  @override
  String get settingsMapCache => 'Offline maps';

  @override
  String get settingsMapCacheBody =>
      'Map areas you look at are kept on this phone, so a route you have already seen still draws with no connection. Nothing is downloaded ahead of time.';

  @override
  String settingsMapCacheStored(String size) {
    return '$size stored';
  }

  @override
  String get settingsMapCacheClear => 'Clear';

  @override
  String get settingsMapCacheCleared => 'Offline map tiles cleared';

  @override
  String get trackingOff => 'Off';

  @override
  String get trackingBackground => 'On';

  @override
  String get trackingOffExplain =>
      'No GPS. Enter ride distances by hand. Everything else works.';

  @override
  String get trackingBackgroundExplain =>
      'Records the whole ride — screen off, another app in front, phone in a pocket — until you tap Finish. A notification shows while recording.';

  @override
  String get trackingDefault => 'Default';

  @override
  String get trackingAskBackgroundTitle => 'Record the whole ride?';

  @override
  String get trackingAskBackgroundBody =>
      'A ride keeps recording after you leave the app or lock the screen, so the distance is the distance you actually rode. A notification shows the whole time it is running, and it stops when you tap Finish.\n\nAndroid will ask you to allow location \"all the time\". Jatra reads it only while a ride is recording.\n\nYour route is saved on this phone and sent nowhere.';

  @override
  String get trackingServicesDisabled =>
      'Location is switched off on this phone, so Jatra cannot record a route.';

  @override
  String get trackingOpenLocationSettings => 'Open location settings';

  @override
  String get trackingBlocked =>
      'Location is blocked for Jatra. Android will not ask again, so it has to be changed in Settings.';

  @override
  String get trackingNotGranted =>
      'Jatra does not have permission to read your location yet.';

  @override
  String get trackingBackgroundNeedsSettings =>
      'Rides still record in the background. But Android only grants \"all the time\" access from Settings, and without it a long ride can be cut short. Choose Jatra → Permissions → Location → Allow all the time.';

  @override
  String get trackingOpenAppSettings => 'Open app settings';

  @override
  String get emptyDash => '—';

  @override
  String fuelDeletedSnack(Object amount, Object date) {
    return 'Deleted the $date fill · $amount';
  }

  @override
  String ridesDeletedSnack(Object date) {
    return 'Deleted the $date ride';
  }

  @override
  String get actionSaveChanges => 'Save changes';

  @override
  String get fuelOptional => 'Optional';

  @override
  String get fuelStationHint => 'Meghna Petrol Pump';

  @override
  String get fuelCorrectionAccepted => 'Reading accepted as a correction.';

  @override
  String get fuelOdometerResetAction => 'My odometer was reset or misread';

  @override
  String get fuelAllowLowerTitle => 'Allow a lower reading?';

  @override
  String get fuelAllowLowerBody =>
      'Jatra normally requires each reading to be higher than the last, because distance is measured between them.\n\nAllow a lower one only if the cluster was replaced or you mistyped a previous fill. Mileage across this gap will not be meaningful.';

  @override
  String get fuelAllowLowerConfirm => 'Allow it';

  @override
  String get statsNoBikeBody => 'Add a bike to see statistics.';

  @override
  String widgetFuelCostPer(String unit) {
    return 'Fuel cost $unit';
  }

  @override
  String get widgetNoBike => 'Add a bike in Jatra to see your numbers here.';

  @override
  String get widgetNoData => 'Log a refuel in Jatra to see your numbers here.';

  @override
  String get statsCostPerDistance => 'Cost per distance';

  @override
  String get statsNoDistanceMeasured => 'No distance measured in this period.';

  @override
  String statsRunningCostPer(Object unit) {
    return 'Running cost $unit';
  }

  @override
  String get statsRunningCostSubtitle =>
      'Fuel, service and fixed costs — excludes depreciation';

  @override
  String statsFuelPriceSubtitle(Object unit) {
    return 'What you actually paid per $unit';
  }

  @override
  String get statsTripHint => '40';

  @override
  String get serviceItemNew => 'New service item';

  @override
  String get serviceItemEdit => 'Edit item';

  @override
  String get serviceItemDelete => 'Delete item';

  @override
  String get serviceItemAdd => 'Add item';

  @override
  String get serviceItemJob => 'The job';

  @override
  String get serviceItemName => 'Name';

  @override
  String get serviceItemNameHint => 'Engine oil';

  @override
  String get serviceItemIcon => 'Icon';

  @override
  String get serviceItemTrack => 'Track this item';

  @override
  String get serviceItemTrackExplain =>
      'Switch off to keep the history but stop Jatra reminding you.';

  @override
  String serviceItemDeleteTitle(Object name) {
    return 'Delete $name?';
  }

  @override
  String get serviceItemDeleteBody =>
      'Jatra stops tracking this job. Services you have already logged against it stay in your history.';

  @override
  String get serviceItemKeep => 'Keep it';

  @override
  String get serviceItemHowOften => 'How often';

  @override
  String get serviceItemHowOftenExplain =>
      'Set either, or both. With both, whichever comes first wins.';

  @override
  String get serviceItemEvery => 'Every';

  @override
  String get serviceItemOrEvery => 'Or every';

  @override
  String get serviceItemDays => 'DAYS';

  @override
  String get serviceItemLastDone => 'Last done';

  @override
  String get serviceItemLastDoneExplain =>
      'Where Jatra counts the next interval from. Logging a service updates this for you.';

  @override
  String get serviceItemAtOdometer => 'At odometer';

  @override
  String get serviceItemOnDate => 'On date';

  @override
  String get actionClear => 'Clear';

  @override
  String get serviceItemNameError => 'Give the job a name.';

  @override
  String get serviceItemIntervalError =>
      'Set a distance interval, a time interval, or both.';

  @override
  String get serviceLogWhatError => 'What was done?';

  @override
  String get serviceLogOdometerError => 'Enter the odometer reading.';

  @override
  String get serviceLogOdometerNumberError => 'Odometer must be a number.';

  @override
  String get serviceLogOdometerNegativeError => 'Odometer cannot be negative.';

  @override
  String get serviceLogged => 'Service logged';

  @override
  String get serviceUpdated => 'Service updated';

  @override
  String get serviceNextDueMoved => 'Next due point moved forward.';

  @override
  String get categoryInsurance => 'Insurance';

  @override
  String get categoryTaxToken => 'Tax token';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get categoryRegistration => 'Registration';

  @override
  String get categoryAccessories => 'Accessories';

  @override
  String get categoryFine => 'Fine';

  @override
  String get categoryParking => 'Parking';

  @override
  String get categoryWashing => 'Washing';

  @override
  String get categoryOther => 'Other';

  @override
  String get reminderService => 'Service';

  @override
  String get reminderDocumentExpiry => 'Document expiry';

  @override
  String get reminderCustom => 'Reminder';

  @override
  String get dateToday => 'today';

  @override
  String get dateTomorrow => 'tomorrow';

  @override
  String get dateYesterday => 'yesterday';

  @override
  String dateInDays(Object count) {
    return 'in $count days';
  }

  @override
  String dateDaysAgo(Object count) {
    return '$count days ago';
  }

  @override
  String dateRoughly(Object when) {
    return 'roughly $when';
  }

  @override
  String serviceDueOn(Object when) {
    return 'Due $when';
  }

  @override
  String serviceIntervalUsed(Object percent) {
    return '$percent% of the interval used';
  }

  @override
  String get expensesEdit => 'Edit expense';

  @override
  String get expensesAddTitle => 'Add expense';

  @override
  String get expensesSave => 'Save expense';

  @override
  String get expensesWhatFor => 'What for';

  @override
  String get expensesAmount => 'Amount';

  @override
  String get expensesPaidOn => 'Paid on';

  @override
  String get expensesNotes => 'Notes';

  @override
  String get expensesCoverPeriod => 'Cover period';

  @override
  String get expensesCoverExplain =>
      'Jatra counts down to the end date and reminds you a fortnight before.';

  @override
  String get expensesValidFrom => 'Valid from';

  @override
  String get expensesValidUntil => 'Valid until';

  @override
  String expensesUntil(Object date) {
    return 'Until $date';
  }

  @override
  String get expensesShowThisBike => 'Show this bike only';

  @override
  String get expensesShowAllBikes => 'Show all bikes';

  @override
  String expensesDeletedSnack(Object amount, Object category) {
    return 'Deleted $category · $amount';
  }

  @override
  String get expensesAmountError => 'Enter what it cost.';

  @override
  String get expensesAmountNumberError =>
      'Amount must be a number, like 1450.00.';

  @override
  String get expensesAmountNegativeError => 'Amount cannot be negative.';

  @override
  String get expensesCoverOrderError => 'Cover cannot end before it starts.';

  @override
  String get expensesSaved => 'Expense saved';

  @override
  String get expensesUpdated => 'Expense updated';

  @override
  String get vehiclesTitle => 'Bikes';

  @override
  String get vehiclesAdd => 'Add a bike';

  @override
  String get vehiclesAddShort => 'Add bike';

  @override
  String get vehiclesEdit => 'Edit bike';

  @override
  String get vehiclesNoneTitle => 'No bikes yet';

  @override
  String get vehiclesArchived => 'Archived';

  @override
  String get vehiclesDefault => 'Default';

  @override
  String get vehiclesMakeDefault => 'Open Jatra on this bike';

  @override
  String get vehiclesArchive => 'Archive';

  @override
  String get vehiclesUnarchive => 'Unarchive';

  @override
  String vehiclesOptionsFor(Object name) {
    return 'Options for $name';
  }

  @override
  String vehiclesDeleteTitle(Object name) {
    return 'Delete $name?';
  }

  @override
  String get vehiclesDeleteEmptyBody =>
      'This bike has no records yet. Deleting it cannot be undone.';

  @override
  String vehiclesDeleteBody(Object records) {
    return 'This deletes $records. It cannot be undone.\n\nExport a backup first if you might want this data back.';
  }

  @override
  String get vehiclesDeleteConfirm => 'Delete bike';

  @override
  String get vehiclesDeleted => 'Deleted';

  @override
  String vehiclesDeletedBody(Object name) {
    return '$name and its records are gone.';
  }

  @override
  String get vehiclesTheBike => 'The bike';

  @override
  String get vehiclesName => 'Name';

  @override
  String get vehiclesNameHint => 'Pulsar';

  @override
  String get vehiclesMake => 'Make';

  @override
  String get vehiclesModel => 'Model';

  @override
  String get vehiclesYear => 'Year';

  @override
  String get vehiclesEngine => 'Engine';

  @override
  String get vehiclesRegistration => 'Registration number';

  @override
  String get vehiclesRegistrationHint => 'DHAKA METRO-L 12-3456';

  @override
  String get vehiclesUnitsCurrency => 'Units and currency';

  @override
  String get vehiclesCurrency => 'Currency';

  @override
  String get vehiclesOwnership => 'Ownership';

  @override
  String get vehiclesOwnershipExplain =>
      'Used to work out depreciation and true cost per kilometre. Leave blank if you would rather not.';

  @override
  String get vehiclesStartingOdometer => 'Odometer when you started logging';

  @override
  String get vehiclesTankCapacity => 'Tank capacity';

  @override
  String get vehiclesPurchaseDate => 'Purchase date';

  @override
  String get ridesNotFoundTitle => 'Ride not found';

  @override
  String get ridesNotFoundBody => 'It may have been deleted.';

  @override
  String get ridesFallbackTitle => 'Ride';

  @override
  String get mapTitle => 'Map';

  @override
  String get mapAllRides => 'All rides';

  @override
  String get mapShowMyLocation => 'Show my location';

  @override
  String get mapRecentre => 'Recentre on my location';

  @override
  String get mapFollowing => 'Following you — drag the map to stop';

  @override
  String get mapYourLocation => 'Your location';

  @override
  String get mapDetails => 'Details';

  @override
  String get mapNoRidesHint =>
      'No rides yet — start one and the path is drawn here as you go.';

  @override
  String get mapTrackingOffHint =>
      'Ride tracking is off. Nothing is recorded until you turn it on.';

  @override
  String get mapSetUp => 'Set up';

  @override
  String get mapLocationNeeded =>
      'Jatra needs location permission to show where you are.';

  @override
  String get mapLocationServicesOff =>
      'Location is switched off on this phone.';

  @override
  String get mapLocationBlocked =>
      'Jatra is blocked from using location. It can only be re-enabled in Android settings.';

  @override
  String get mapTurnOn => 'Turn on';

  @override
  String get mapOpenSettings => 'Settings';

  @override
  String get rideCouldNotStart =>
      'Jatra could not start recording. Check that location is on and allowed for Jatra.';

  @override
  String get ridesDiscardedEmpty =>
      'Ride discarded — no distance was recorded.';

  @override
  String get ridesDiscardTitle => 'Discard this ride?';

  @override
  String get ridesDiscardBody =>
      'The recorded path and distance are deleted. This cannot be undone.';

  @override
  String serviceLoggedCount(Object count) {
    return '$count logged';
  }

  @override
  String get onboardingMakeHint => 'Bajaj';

  @override
  String get onboardingOdometerHint => '24180';

  @override
  String get ridesGapOnce =>
      'Recording stopped once during this ride, so the path has a break in it. Distance across the break is not counted.';

  @override
  String ridesGapMany(Object count) {
    return 'Recording stopped $count times during this ride. Distance across those breaks is not counted.';
  }

  @override
  String get ridesDetails => 'Details';

  @override
  String get ridesStarted => 'Started';

  @override
  String get ridesFinished => 'Finished';

  @override
  String get ridesGpsPoints => 'GPS points';

  @override
  String get ridesOdometer => 'Odometer';

  @override
  String get ridesNotes => 'Notes';

  @override
  String mileageDropCauses2(Object causes) {
    return 'Common causes: $causes.';
  }

  @override
  String get serviceLogEdit => 'Edit service';

  @override
  String get serviceLogWhatDone => 'What was done';

  @override
  String get serviceLogItem => 'Service item';

  @override
  String get serviceLogItemHelp =>
      'Linking it moves that item’s next due point forward.';

  @override
  String get serviceLogOneOff => 'One-off repair';

  @override
  String get serviceLogDescription => 'Description';

  @override
  String get serviceLogDescriptionHint => 'Engine oil + filter';

  @override
  String get serviceLogCost => 'Cost';

  @override
  String get serviceLogParts => 'Parts';

  @override
  String get serviceLogLabour => 'Labour';

  @override
  String get serviceLogTotalHelp =>
      'Adds up from parts and labour, or type a bundled bill.';

  @override
  String get serviceLogWorkshop => 'Workshop';

  @override
  String get serviceLogWorkshopHint => 'Rahman Motors, Mirpur';

  @override
  String get serviceLogPartBrand => 'Part brand';

  @override
  String get serviceLogPartBrandHint => 'Motul 10W-40';

  @override
  String get vehiclesSwitch => 'Switch bike';

  @override
  String get vehiclesManage => 'Manage bikes';

  @override
  String get mapStart => 'Start';

  @override
  String get mapEnd => 'End';

  @override
  String mapScaleAcross(Object distance, Object unit) {
    return '≈ $distance $unit across';
  }

  @override
  String mapGapCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count GAPS',
      one: '1 GAP',
    );
    return '$_temp0';
  }

  @override
  String get backupTitle => 'Backup and export';

  @override
  String get backupExport => 'Export';

  @override
  String get backupExportExplain =>
      'A full JSON backup restores everything exactly, on any device.';

  @override
  String get backupIncludeGps => 'Include ride GPS data';

  @override
  String get backupIncludeGpsExplain =>
      'Off keeps the file small — usually a few hundred KB. On can run to tens of megabytes.';

  @override
  String get backupReadable => 'Readable formatting';

  @override
  String get backupReadableExplain =>
      'Off produces a smaller file that is harder to read.';

  @override
  String get backupExportBackup => 'Export backup';

  @override
  String get backupExportCsv => 'Export spreadsheets (CSV)';

  @override
  String get backupImport => 'Import';

  @override
  String get backupImportExplain =>
      'Jatra checks the whole file before changing anything. If there is a problem, nothing is imported.';

  @override
  String get backupChooseFile => 'Choose a backup file';

  @override
  String get backupCancelImport => 'Cancel import';

  @override
  String get backupContains => 'Contains';

  @override
  String get backupNothing => 'nothing';

  @override
  String get backupCovers => 'Covers';

  @override
  String get backupExported => 'Exported';

  @override
  String get backupGpsData => 'GPS data';

  @override
  String get backupIncluded => 'included';

  @override
  String get backupNotIncluded => 'not included';

  @override
  String get backupMergeQuestion => 'How should Jatra merge this?';

  @override
  String get backupReplaceTitle => 'Replace everything?';

  @override
  String get backupDismiss => 'Dismiss';

  @override
  String get backupCountBikes => 'bikes';

  @override
  String get backupCountFills => 'fills';

  @override
  String get backupCountServiceItems => 'service items';

  @override
  String get backupCountServices => 'services';

  @override
  String get backupCountExpenses => 'expenses';

  @override
  String get backupCountRides => 'rides';

  @override
  String get backupCountGpsPoints => 'GPS points';

  @override
  String get onboardingModelHint => 'NS160';

  @override
  String get vehiclesPurchasePrice => 'Purchase price';

  @override
  String get vehiclesCurrentValue => 'What it is worth now';

  @override
  String get settingsDeleteAllTitle => 'Delete everything?';

  @override
  String get settingsKeepMyData => 'Keep my data';

  @override
  String get settingsDeleteEverything => 'Delete everything';

  @override
  String get settingsDeleteRoutesTitle => 'Delete every recorded route?';

  @override
  String get settingsKeepThem => 'Keep them';

  @override
  String get settingsDeleteRoutes => 'Delete routes';

  @override
  String get backupReplaceConfirm => 'Replace everything';

  @override
  String get backupCopyDatabase => 'Copy database out';

  @override
  String get backupRestoreDatabase => 'Restore a database file';

  @override
  String get backupRestoreTitle => 'Restore a database file?';

  @override
  String get backupPickFile => 'Pick a file';

  @override
  String get backupRestoredTitle => 'Database restored';

  @override
  String get vehiclesDepreciationHelp =>
      'Blank ⇒ Jatra estimates 12% lost per year.';

  @override
  String vehiclesColourN(Object number) {
    return 'Colour $number';
  }

  @override
  String get ridesNotificationTitle => 'Recording your ride';

  @override
  String get ridesLocationServiceTitle => 'Jatra is using your location';

  @override
  String get ridesForegroundNotification =>
      'Keeps your ride recording while the app is in the background.';

  @override
  String get ridesNotificationPaused => 'Ride paused';

  @override
  String get ridesNotificationChannel => 'Ride recording';

  @override
  String reminderServiceTitle(Object item, Object status) {
    return '$item — $status';
  }

  @override
  String get homeTapForDetails => 'Tap for details';

  @override
  String homeMoreCount(Object count) {
    return '+$count more';
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// The app's name. Not translated.
  ///
  /// In en, this message translates to:
  /// **'Jatra'**
  String get appName;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @actionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get actionNotNow;

  /// No description provided for @actionGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get actionGotIt;

  /// No description provided for @actionSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get actionSeeAll;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navFuelLog.
  ///
  /// In en, this message translates to:
  /// **'Fuel log'**
  String get navFuelLog;

  /// No description provided for @navService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get navService;

  /// No description provided for @navExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get navExpenses;

  /// No description provided for @navRides.
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get navRides;

  /// No description provided for @navStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get navStatistics;

  /// No description provided for @navBikes.
  ///
  /// In en, this message translates to:
  /// **'Bikes'**
  String get navBikes;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Bottom-nav label. Shorter than navFuelLog, which titles the screen.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get navFuel;

  /// Bottom-nav label for the map tab.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// Bottom-nav label. Shorter than navStatistics, which titles the screen.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @onboardingBikeTitle.
  ///
  /// In en, this message translates to:
  /// **'What are you riding?'**
  String get onboardingBikeTitle;

  /// No description provided for @onboardingBikeBody.
  ///
  /// In en, this message translates to:
  /// **'A name is all Jatra needs. Everything else can wait.'**
  String get onboardingBikeBody;

  /// No description provided for @onboardingBikeName.
  ///
  /// In en, this message translates to:
  /// **'Bike name'**
  String get onboardingBikeName;

  /// No description provided for @onboardingBikeNameError.
  ///
  /// In en, this message translates to:
  /// **'Give your bike a name — \"Pulsar\" works fine.'**
  String get onboardingBikeNameError;

  /// No description provided for @onboardingMake.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get onboardingMake;

  /// No description provided for @onboardingModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get onboardingModel;

  /// No description provided for @onboardingFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get onboardingFuel;

  /// No description provided for @onboardingOdometerTitle.
  ///
  /// In en, this message translates to:
  /// **'What does the odometer read?'**
  String get onboardingOdometerTitle;

  /// No description provided for @onboardingOdometerBody.
  ///
  /// In en, this message translates to:
  /// **'Jatra measures everything from here. Round to the nearest whole number — it does not need to be exact.'**
  String get onboardingOdometerBody;

  /// No description provided for @onboardingOdometerLabel.
  ///
  /// In en, this message translates to:
  /// **'Current reading'**
  String get onboardingOdometerLabel;

  /// No description provided for @onboardingOdometerError.
  ///
  /// In en, this message translates to:
  /// **'Enter the reading on your odometer right now, in {unit}.'**
  String onboardingOdometerError(String unit);

  /// No description provided for @onboardingUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get onboardingUnits;

  /// No description provided for @onboardingDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'You are set.'**
  String get onboardingDoneTitle;

  /// No description provided for @onboardingDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Log every refuel and Jatra works out your real mileage, when your next service is due, and what a kilometre actually costs you.'**
  String get onboardingDoneBody;

  /// No description provided for @onboardingPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on this phone'**
  String get onboardingPrivacyTitle;

  /// No description provided for @onboardingPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'No account, no cloud, no analytics. Your fuel, service and expense records never leave this phone, and all of that works in airplane mode. Export a full backup whenever you want it.\n\nThe one exception: if you record a ride, the map behind it loads from OpenStreetMap, which sees roughly where that ride was.'**
  String get onboardingPrivacyBody;

  /// No description provided for @onboardingPermissionNote.
  ///
  /// In en, this message translates to:
  /// **'Location tracking is off, and Jatra will not ask for any permission until you turn on a feature that needs one.'**
  String get onboardingPermissionNote;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start tracking'**
  String get onboardingStart;

  /// No description provided for @unitKm.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get unitKm;

  /// No description provided for @unitMiles.
  ///
  /// In en, this message translates to:
  /// **'miles'**
  String get unitMiles;

  /// No description provided for @unitLitres.
  ///
  /// In en, this message translates to:
  /// **'litres'**
  String get unitLitres;

  /// No description provided for @unitGallons.
  ///
  /// In en, this message translates to:
  /// **'gallons'**
  String get unitGallons;

  /// No description provided for @homeOdometer.
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get homeOdometer;

  /// No description provided for @homeLastTank.
  ///
  /// In en, this message translates to:
  /// **'Last tank'**
  String get homeLastTank;

  /// No description provided for @homeRunningCost.
  ///
  /// In en, this message translates to:
  /// **'Running cost'**
  String get homeRunningCost;

  /// No description provided for @homeRunningCostCaption.
  ///
  /// In en, this message translates to:
  /// **'Fuel, service and fixed'**
  String get homeRunningCostCaption;

  /// No description provided for @homeNextService.
  ///
  /// In en, this message translates to:
  /// **'Next service'**
  String get homeNextService;

  /// No description provided for @homeRecentFills.
  ///
  /// In en, this message translates to:
  /// **'Recent fills'**
  String get homeRecentFills;

  /// No description provided for @homeNeedsTwoTanks.
  ///
  /// In en, this message translates to:
  /// **'Needs two full tanks'**
  String get homeNeedsTwoTanks;

  /// No description provided for @homeLatestUnreliable.
  ///
  /// In en, this message translates to:
  /// **'Latest tank was unreliable'**
  String get homeLatestUnreliable;

  /// No description provided for @homeAverage.
  ///
  /// In en, this message translates to:
  /// **'Average {value} {unit}'**
  String homeAverage(String value, String unit);

  /// No description provided for @homeNoBikeTitle.
  ///
  /// In en, this message translates to:
  /// **'No bike selected'**
  String get homeNoBikeTitle;

  /// No description provided for @homeNoBikeBody.
  ///
  /// In en, this message translates to:
  /// **'Add a bike to start logging fuel and services.'**
  String get homeNoBikeBody;

  /// No description provided for @homeAddBike.
  ///
  /// In en, this message translates to:
  /// **'Add a bike'**
  String get homeAddBike;

  /// No description provided for @homeNoFillsTitle.
  ///
  /// In en, this message translates to:
  /// **'No fills logged yet'**
  String get homeNoFillsTitle;

  /// No description provided for @homeNoFillsBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first refuel to start tracking mileage.'**
  String get homeNoFillsBody;

  /// No description provided for @homeAddFuel.
  ///
  /// In en, this message translates to:
  /// **'Add fuel'**
  String get homeAddFuel;

  /// No description provided for @homeNothingDue.
  ///
  /// In en, this message translates to:
  /// **'Nothing due'**
  String get homeNothingDue;

  /// No description provided for @homeNoServiceItems.
  ///
  /// In en, this message translates to:
  /// **'No service items set up yet.'**
  String get homeNoServiceItems;

  /// No description provided for @homeAllClear.
  ///
  /// In en, this message translates to:
  /// **'All {count} items are in the clear.'**
  String homeAllClear(int count);

  /// No description provided for @mileageDropTitle.
  ///
  /// In en, this message translates to:
  /// **'Mileage down {percent}% this tank'**
  String mileageDropTitle(int percent);

  /// No description provided for @mileageDropVsUsual.
  ///
  /// In en, this message translates to:
  /// **'vs your usual {value}'**
  String mileageDropVsUsual(String value);

  /// No description provided for @mileageDropCauses.
  ///
  /// In en, this message translates to:
  /// **'Common causes: tyre pressure, air filter, chain tension.'**
  String get mileageDropCauses;

  /// No description provided for @fuelAdd.
  ///
  /// In en, this message translates to:
  /// **'Add fuel'**
  String get fuelAdd;

  /// No description provided for @fuelEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit fill'**
  String get fuelEdit;

  /// No description provided for @fuelSave.
  ///
  /// In en, this message translates to:
  /// **'Save fill'**
  String get fuelSave;

  /// No description provided for @fuelHistory.
  ///
  /// In en, this message translates to:
  /// **'Fuel history'**
  String get fuelHistory;

  /// No description provided for @fuelWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get fuelWhen;

  /// No description provided for @fuelDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fuelDate;

  /// No description provided for @fuelOdometer.
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get fuelOdometer;

  /// No description provided for @fuelLastReading.
  ///
  /// In en, this message translates to:
  /// **'Last reading: {value} {unit}'**
  String fuelLastReading(String value, String unit);

  /// No description provided for @fuelOdometerMustBeHigher.
  ///
  /// In en, this message translates to:
  /// **'Odometer must be higher than your last reading of {value} {unit}.'**
  String fuelOdometerMustBeHigher(String value, String unit);

  /// No description provided for @fuelHowMuch.
  ///
  /// In en, this message translates to:
  /// **'How much'**
  String get fuelHowMuch;

  /// No description provided for @fuelFillAnyTwo.
  ///
  /// In en, this message translates to:
  /// **'Fill in any two'**
  String get fuelFillAnyTwo;

  /// No description provided for @fuelAdded.
  ///
  /// In en, this message translates to:
  /// **'Fuel added'**
  String get fuelAdded;

  /// No description provided for @fuelPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get fuelPrice;

  /// No description provided for @fuelTotalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get fuelTotalPaid;

  /// No description provided for @fuelFilledTank.
  ///
  /// In en, this message translates to:
  /// **'Filled the tank'**
  String get fuelFilledTank;

  /// No description provided for @fuelFullTankExplain.
  ///
  /// In en, this message translates to:
  /// **'Mileage is measured between full tanks.'**
  String get fuelFullTankExplain;

  /// No description provided for @fuelPartialExplain.
  ///
  /// In en, this message translates to:
  /// **'Partial fill. It counts toward your next full tank, but gets no mileage figure of its own.'**
  String get fuelPartialExplain;

  /// No description provided for @fuelMissedEntry.
  ///
  /// In en, this message translates to:
  /// **'I missed logging a fill before this'**
  String get fuelMissedEntry;

  /// No description provided for @fuelMissedEntryExplain.
  ///
  /// In en, this message translates to:
  /// **'Keeps this tank out of your averages, since some fuel is unaccounted for.'**
  String get fuelMissedEntryExplain;

  /// No description provided for @fuelStation.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get fuelStation;

  /// No description provided for @fuelNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fuelNotes;

  /// No description provided for @fuelPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get fuelPartial;

  /// No description provided for @fuelGap.
  ///
  /// In en, this message translates to:
  /// **'Gap'**
  String get fuelGap;

  /// No description provided for @fuelUnreliable.
  ///
  /// In en, this message translates to:
  /// **'unreliable'**
  String get fuelUnreliable;

  /// No description provided for @fuelCountsTowardNext.
  ///
  /// In en, this message translates to:
  /// **'Counts toward\nnext tank'**
  String get fuelCountsTowardNext;

  /// No description provided for @fuelNoFillsTitle.
  ///
  /// In en, this message translates to:
  /// **'No fills logged yet'**
  String get fuelNoFillsTitle;

  /// No description provided for @fuelNoFillsBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first refuel to start tracking mileage.'**
  String get fuelNoFillsBody;

  /// No description provided for @fuelCountFills.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 fill} other{{count} fills}}'**
  String fuelCountFills(int count);

  /// No description provided for @serviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get serviceTitle;

  /// No description provided for @serviceDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get serviceDue;

  /// No description provided for @serviceNothingPending.
  ///
  /// In en, this message translates to:
  /// **'Nothing pending'**
  String get serviceNothingPending;

  /// No description provided for @serviceNeedAttention.
  ///
  /// In en, this message translates to:
  /// **'{count} need attention'**
  String serviceNeedAttention(int count);

  /// No description provided for @serviceLogAction.
  ///
  /// In en, this message translates to:
  /// **'Log service'**
  String get serviceLogAction;

  /// No description provided for @serviceHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get serviceHistory;

  /// No description provided for @serviceNoItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'No service items'**
  String get serviceNoItemsTitle;

  /// No description provided for @serviceNoItemsBody.
  ///
  /// In en, this message translates to:
  /// **'Add the jobs you want Jatra to keep track of — engine oil, chain lube, brake pads.'**
  String get serviceNoItemsBody;

  /// No description provided for @serviceAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add a service item'**
  String get serviceAddItem;

  /// No description provided for @serviceNothingLogged.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet. Log a service and Jatra will move that item\'s next due point forward for you.'**
  String get serviceNothingLogged;

  /// No description provided for @serviceRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Get told when a service is due'**
  String get serviceRemindersTitle;

  /// No description provided for @serviceRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'Jatra will post a reminder on this phone. Nothing is sent anywhere — the reminder is worked out here, from your own log.'**
  String get serviceRemindersBody;

  /// No description provided for @serviceRemindersEnable.
  ///
  /// In en, this message translates to:
  /// **'Turn on reminders'**
  String get serviceRemindersEnable;

  /// No description provided for @serviceToGo.
  ///
  /// In en, this message translates to:
  /// **'{value} {unit} to go'**
  String serviceToGo(String value, String unit);

  /// No description provided for @serviceOver.
  ///
  /// In en, this message translates to:
  /// **'{value} {unit} over'**
  String serviceOver(String value, String unit);

  /// No description provided for @serviceNoInterval.
  ///
  /// In en, this message translates to:
  /// **'No interval set. Edit to add one.'**
  String get serviceNoInterval;

  /// No description provided for @statusOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get statusOk;

  /// No description provided for @statusDueSoon.
  ///
  /// In en, this message translates to:
  /// **'DUE SOON'**
  String get statusDueSoon;

  /// No description provided for @statusDueNow.
  ///
  /// In en, this message translates to:
  /// **'DUE NOW'**
  String get statusDueNow;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'OVERDUE'**
  String get statusOverdue;

  /// No description provided for @statusNotSet.
  ///
  /// In en, this message translates to:
  /// **'NOT SET'**
  String get statusNotSet;

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesTitle;

  /// No description provided for @expensesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add an expense'**
  String get expensesAdd;

  /// No description provided for @expensesDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get expensesDocuments;

  /// No description provided for @expensesTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get expensesTotal;

  /// No description provided for @expensesAllBikes.
  ///
  /// In en, this message translates to:
  /// **'All bikes'**
  String get expensesAllBikes;

  /// No description provided for @expensesNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses logged'**
  String get expensesNoneTitle;

  /// No description provided for @expensesNoneBody.
  ///
  /// In en, this message translates to:
  /// **'Insurance, tax token, fitness, a new helmet — anything that is not fuel or a service.'**
  String get expensesNoneBody;

  /// No description provided for @expensesExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expensesExpired;

  /// No description provided for @expensesExpiresToday.
  ///
  /// In en, this message translates to:
  /// **'Expires today'**
  String get expensesExpiresToday;

  /// No description provided for @expensesDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String expensesDaysLeft(int count);

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statsRangeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get statsRangeThisMonth;

  /// No description provided for @statsRangeLast3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get statsRangeLast3Months;

  /// No description provided for @statsRangeThisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get statsRangeThisYear;

  /// No description provided for @statsRangeAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get statsRangeAllTime;

  /// No description provided for @statsRangeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get statsRangeCustom;

  /// No description provided for @statsCostPer.
  ///
  /// In en, this message translates to:
  /// **'Cost per {unit}'**
  String statsCostPer(String unit);

  /// No description provided for @statsFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get statsFuel;

  /// No description provided for @statsFuelExplain.
  ///
  /// In en, this message translates to:
  /// **'Petrol only. Moves with pump prices and traffic.'**
  String get statsFuelExplain;

  /// No description provided for @statsRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get statsRunning;

  /// No description provided for @statsRunningExplain.
  ///
  /// In en, this message translates to:
  /// **'Fuel, servicing, parts and fixed costs.'**
  String get statsRunningExplain;

  /// No description provided for @statsTrue.
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get statsTrue;

  /// No description provided for @statsTrueExplain.
  ///
  /// In en, this message translates to:
  /// **'Running cost plus the value the bike lost.'**
  String get statsTrueExplain;

  /// No description provided for @statsEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get statsEstimate;

  /// No description provided for @statsNeedTwoReadings.
  ///
  /// In en, this message translates to:
  /// **'Two odometer readings in this period are needed before Jatra can work out what a {unit} costs. Log another fill.'**
  String statsNeedTwoReadings(String unit);

  /// No description provided for @statsAddPurchasePrice.
  ///
  /// In en, this message translates to:
  /// **'Add what you paid for the bike to see this.'**
  String get statsAddPurchasePrice;

  /// No description provided for @statsTripTitle.
  ///
  /// In en, this message translates to:
  /// **'What would a trip cost?'**
  String get statsTripTitle;

  /// No description provided for @statsTripDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get statsTripDistance;

  /// No description provided for @statsTripUsesRates.
  ///
  /// In en, this message translates to:
  /// **'Uses the rates from the period selected above.'**
  String get statsTripUsesRates;

  /// No description provided for @statsTripNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough history in this period to price a trip. Try a wider range.'**
  String get statsTripNotEnough;

  /// No description provided for @statsTrueCost.
  ///
  /// In en, this message translates to:
  /// **'True cost'**
  String get statsTrueCost;

  /// No description provided for @statsMileageOverTime.
  ///
  /// In en, this message translates to:
  /// **'Mileage over time'**
  String get statsMileageOverTime;

  /// No description provided for @statsMileageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One point per full tank measured against the last'**
  String get statsMileageSubtitle;

  /// No description provided for @statsMileageEmpty.
  ///
  /// In en, this message translates to:
  /// **'Two full tanks in this period will draw a line here.'**
  String get statsMileageEmpty;

  /// No description provided for @statsMonthlySpend.
  ///
  /// In en, this message translates to:
  /// **'Monthly spend'**
  String get statsMonthlySpend;

  /// No description provided for @statsMonthlySpendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Where the money went'**
  String get statsMonthlySpendSubtitle;

  /// No description provided for @statsDistancePerMonth.
  ///
  /// In en, this message translates to:
  /// **'Distance per month'**
  String get statsDistancePerMonth;

  /// No description provided for @statsDistanceEmpty.
  ///
  /// In en, this message translates to:
  /// **'Needs two odometer readings in a month to measure a distance.'**
  String get statsDistanceEmpty;

  /// No description provided for @statsFuelPricePaid.
  ///
  /// In en, this message translates to:
  /// **'Fuel price paid'**
  String get statsFuelPricePaid;

  /// No description provided for @statsNotEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet.'**
  String get statsNotEnoughData;

  /// No description provided for @statsOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get statsOther;

  /// No description provided for @statsDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get statsDistance;

  /// No description provided for @statsTotalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get statsTotalSpent;

  /// No description provided for @statsAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get statsAverage;

  /// No description provided for @statsBestTank.
  ///
  /// In en, this message translates to:
  /// **'Best tank'**
  String get statsBestTank;

  /// No description provided for @statsWorstTank.
  ///
  /// In en, this message translates to:
  /// **'Worst tank'**
  String get statsWorstTank;

  /// No description provided for @statsFills.
  ///
  /// In en, this message translates to:
  /// **'Fills'**
  String get statsFills;

  /// No description provided for @statsDaysOwned.
  ///
  /// In en, this message translates to:
  /// **'Days owned'**
  String get statsDaysOwned;

  /// No description provided for @statsFuelShare.
  ///
  /// In en, this message translates to:
  /// **'Fuel share'**
  String get statsFuelShare;

  /// No description provided for @ridesTitle.
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get ridesTitle;

  /// No description provided for @ridesStart.
  ///
  /// In en, this message translates to:
  /// **'Start ride'**
  String get ridesStart;

  /// No description provided for @ridesRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get ridesRecording;

  /// No description provided for @ridesPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get ridesPaused;

  /// No description provided for @ridesPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get ridesPause;

  /// No description provided for @ridesResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get ridesResume;

  /// No description provided for @ridesFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get ridesFinish;

  /// No description provided for @ridesPoints.
  ///
  /// In en, this message translates to:
  /// **'{count} points'**
  String ridesPoints(int count);

  /// No description provided for @ridesTrackingOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride tracking is off'**
  String get ridesTrackingOffTitle;

  /// No description provided for @ridesTrackingOffBody.
  ///
  /// In en, this message translates to:
  /// **'Jatra can trace your route with GPS and work out distance and speed. It is off by default and asks for location only when you switch it on.\n\nEverything else in Jatra works without it.'**
  String get ridesTrackingOffBody;

  /// No description provided for @ridesSetUp.
  ///
  /// In en, this message translates to:
  /// **'Set up ride tracking'**
  String get ridesSetUp;

  /// No description provided for @ridesNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No rides recorded'**
  String get ridesNoneTitle;

  /// No description provided for @ridesNoneBody.
  ///
  /// In en, this message translates to:
  /// **'Start a ride and Jatra will trace where you went and how far.'**
  String get ridesNoneBody;

  /// No description provided for @ridesInterruptedTitle.
  ///
  /// In en, this message translates to:
  /// **'A ride was left recording'**
  String get ridesInterruptedTitle;

  /// No description provided for @ridesResumeAction.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get ridesResumeAction;

  /// No description provided for @ridesSaveWhatWeHave.
  ///
  /// In en, this message translates to:
  /// **'Save what we have'**
  String get ridesSaveWhatWeHave;

  /// No description provided for @ridesDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get ridesDiscard;

  /// No description provided for @ridesGapNotice.
  ///
  /// In en, this message translates to:
  /// **'Ride paused while the app was closed — {minutes} min gap. Turn on background tracking to keep recording with the screen off.'**
  String ridesGapNotice(int minutes);

  /// No description provided for @ridesNoPath.
  ///
  /// In en, this message translates to:
  /// **'No path recorded for this ride.'**
  String get ridesNoPath;

  /// No description provided for @ridesMovingTime.
  ///
  /// In en, this message translates to:
  /// **'Moving time'**
  String get ridesMovingTime;

  /// No description provided for @ridesTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get ridesTotalTime;

  /// No description provided for @ridesAverageSpeed.
  ///
  /// In en, this message translates to:
  /// **'Average speed'**
  String get ridesAverageSpeed;

  /// No description provided for @ridesTopSpeed.
  ///
  /// In en, this message translates to:
  /// **'Top speed'**
  String get ridesTopSpeed;

  /// No description provided for @ridesStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get ridesStopped;

  /// No description provided for @ridesElevation.
  ///
  /// In en, this message translates to:
  /// **'Elevation'**
  String get ridesElevation;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'No data leaves this device, ever'**
  String get settingsPrivacyTitle;

  /// No description provided for @settingsPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Jatra has no account, no server of its own and no analytics. Everything works in airplane mode except the map behind a recorded ride, which loads its tiles from OpenStreetMap.'**
  String get settingsPrivacyBody;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsMileageAlert.
  ///
  /// In en, this message translates to:
  /// **'Mileage alert'**
  String get settingsMileageAlert;

  /// No description provided for @settingsMileageAlertPrompt.
  ///
  /// In en, this message translates to:
  /// **'Warn me when a tank falls below my usual by'**
  String get settingsMileageAlertPrompt;

  /// No description provided for @settingsMileageAlertOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsMileageAlertOff;

  /// No description provided for @settingsMileageAlertExplain.
  ///
  /// In en, this message translates to:
  /// **'Compared against the median of your last five reliable tanks, so one unusual week does not trigger it.'**
  String get settingsMileageAlertExplain;

  /// No description provided for @settingsMileageAlertDisabled.
  ///
  /// In en, this message translates to:
  /// **'Jatra will not comment on mileage changes.'**
  String get settingsMileageAlertDisabled;

  /// No description provided for @settingsReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsReminders;

  /// No description provided for @settingsRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Service and document reminders'**
  String get settingsRemindersTitle;

  /// No description provided for @settingsRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'Posted on this phone, worked out from your own log. Nothing is sent anywhere.'**
  String get settingsRemindersBody;

  /// No description provided for @settingsRemindersBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are switched off for Jatra in your Android settings. Turn them back on there and this will start working again.'**
  String get settingsRemindersBlocked;

  /// No description provided for @settingsDepreciation.
  ///
  /// In en, this message translates to:
  /// **'Depreciation'**
  String get settingsDepreciation;

  /// No description provided for @settingsDepreciationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Assume a bike loses this much of its price each year'**
  String get settingsDepreciationPrompt;

  /// No description provided for @settingsDepreciationExplain.
  ///
  /// In en, this message translates to:
  /// **'Only used for bikes with no current-value estimate. True cost per kilometre is always an estimate.'**
  String get settingsDepreciationExplain;

  /// No description provided for @settingsTracking.
  ///
  /// In en, this message translates to:
  /// **'Ride tracking'**
  String get settingsTracking;

  /// No description provided for @settingsTrackingBody.
  ///
  /// In en, this message translates to:
  /// **'Jatra can trace your route with GPS. Everything else in the app works without it.'**
  String get settingsTrackingBody;

  /// No description provided for @settingsKeepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on during rides'**
  String get settingsKeepScreenOn;

  /// No description provided for @settingsKeepScreenOnExplain.
  ///
  /// In en, this message translates to:
  /// **'Released as soon as you stop recording.'**
  String get settingsKeepScreenOnExplain;

  /// No description provided for @settingsBikes.
  ///
  /// In en, this message translates to:
  /// **'Bikes'**
  String get settingsBikes;

  /// No description provided for @settingsManageBikes.
  ///
  /// In en, this message translates to:
  /// **'Manage bikes'**
  String get settingsManageBikes;

  /// No description provided for @settingsManageBikesBody.
  ///
  /// In en, this message translates to:
  /// **'Add, edit, set default, archive'**
  String get settingsManageBikesBody;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup and export'**
  String get settingsBackup;

  /// No description provided for @settingsBackupBody.
  ///
  /// In en, this message translates to:
  /// **'JSON backup, spreadsheets, restore'**
  String get settingsBackupBody;

  /// No description provided for @settingsDeleteLocationHistory.
  ///
  /// In en, this message translates to:
  /// **'Delete location history'**
  String get settingsDeleteLocationHistory;

  /// No description provided for @settingsDeleteLocationHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Removes recorded routes. Ride distances and times are kept.'**
  String get settingsDeleteLocationHistoryBody;

  /// No description provided for @settingsDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get settingsDeleteAll;

  /// No description provided for @settingsDeleteAllBody.
  ///
  /// In en, this message translates to:
  /// **'Every bike, fill, service and setting'**
  String get settingsDeleteAllBody;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutBody.
  ///
  /// In en, this message translates to:
  /// **'An offline fuel, service and ride-cost tracker for motorcycles.'**
  String get settingsAboutBody;

  /// No description provided for @settingsFontCredit.
  ///
  /// In en, this message translates to:
  /// **'Typeset in Barlow Condensed, Inter, JetBrains Mono and Hind Siliguri, all under the SIL Open Font License.'**
  String get settingsFontCredit;

  /// No description provided for @trackingOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get trackingOff;

  /// No description provided for @trackingAppOpen.
  ///
  /// In en, this message translates to:
  /// **'While app is open'**
  String get trackingAppOpen;

  /// No description provided for @trackingBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get trackingBackground;

  /// No description provided for @trackingOffExplain.
  ///
  /// In en, this message translates to:
  /// **'No GPS. Enter ride distances by hand. Everything else works.'**
  String get trackingOffExplain;

  /// No description provided for @trackingAppOpenExplain.
  ///
  /// In en, this message translates to:
  /// **'Records while Jatra is on screen. Pauses when you switch away.'**
  String get trackingAppOpenExplain;

  /// No description provided for @trackingBackgroundExplain.
  ///
  /// In en, this message translates to:
  /// **'Keeps recording with the screen off, using a notification.'**
  String get trackingBackgroundExplain;

  /// No description provided for @trackingDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get trackingDefault;

  /// No description provided for @trackingAskForegroundTitle.
  ///
  /// In en, this message translates to:
  /// **'Use your location?'**
  String get trackingAskForegroundTitle;

  /// No description provided for @trackingAskForegroundBody.
  ///
  /// In en, this message translates to:
  /// **'Jatra will read your location while a ride is recording and you have the app open, to trace your route and measure distance.\n\nYour route is saved on this phone and sent nowhere.'**
  String get trackingAskForegroundBody;

  /// No description provided for @trackingAskBackgroundTitle.
  ///
  /// In en, this message translates to:
  /// **'Record with the screen off?'**
  String get trackingAskBackgroundTitle;

  /// No description provided for @trackingAskBackgroundBody.
  ///
  /// In en, this message translates to:
  /// **'Android will ask you to allow location \"all the time\". Jatra uses it only while you are recording a ride, and shows a notification the whole time it is running.\n\nYour route is saved on this phone and sent nowhere.'**
  String get trackingAskBackgroundBody;

  /// No description provided for @trackingServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location is switched off on this phone, so Jatra cannot record a route.'**
  String get trackingServicesDisabled;

  /// No description provided for @trackingOpenLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open location settings'**
  String get trackingOpenLocationSettings;

  /// No description provided for @trackingBlocked.
  ///
  /// In en, this message translates to:
  /// **'Location is blocked for Jatra. Android will not ask again, so it has to be changed in Settings.'**
  String get trackingBlocked;

  /// No description provided for @trackingNotGranted.
  ///
  /// In en, this message translates to:
  /// **'Jatra does not have permission to read your location yet.'**
  String get trackingNotGranted;

  /// No description provided for @trackingBackgroundNeedsSettings.
  ///
  /// In en, this message translates to:
  /// **'Android only allows \"all the time\" access to be granted from Settings. Until then Jatra records while the app is open. Choose Jatra → Permissions → Location → Allow all the time.'**
  String get trackingBackgroundNeedsSettings;

  /// No description provided for @trackingOpenAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Open app settings'**
  String get trackingOpenAppSettings;

  /// No description provided for @emptyDash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get emptyDash;

  /// Undo snackbar after swiping a fill away. {date} is short-form, {amount} is money.
  ///
  /// In en, this message translates to:
  /// **'Deleted the {date} fill · {amount}'**
  String fuelDeletedSnack(Object amount, Object date);

  /// Undo snackbar after swiping a ride away.
  ///
  /// In en, this message translates to:
  /// **'Deleted the {date} ride'**
  String ridesDeletedSnack(Object date);

  /// Submit label when editing an existing record.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get actionSaveChanges;

  /// Section label above the station and notes fields.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get fuelOptional;

  /// Example petrol station name, shown as a hint.
  ///
  /// In en, this message translates to:
  /// **'Meghna Petrol Pump'**
  String get fuelStationHint;

  /// Shown when a lower odometer reading has been allowed.
  ///
  /// In en, this message translates to:
  /// **'Reading accepted as a correction.'**
  String get fuelCorrectionAccepted;

  /// Button that opens the lower-reading confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'My odometer was reset or misread'**
  String get fuelOdometerResetAction;

  /// Dialog title.
  ///
  /// In en, this message translates to:
  /// **'Allow a lower reading?'**
  String get fuelAllowLowerTitle;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'Jatra normally requires each reading to be higher than the last, because distance is measured between them.\n\nAllow a lower one only if the cluster was replaced or you mistyped a previous fill. Mileage across this gap will not be meaningful.'**
  String get fuelAllowLowerBody;

  /// Confirm button on the lower-reading dialog.
  ///
  /// In en, this message translates to:
  /// **'Allow it'**
  String get fuelAllowLowerConfirm;

  /// Empty state on the statistics screen when no bike is selected.
  ///
  /// In en, this message translates to:
  /// **'Add a bike to see statistics.'**
  String get statsNoBikeBody;

  /// Home-screen widget tile and chart label. Petrol only — the widget has no room to explain the difference between fuel, running and true cost, so it shows the one a rider can check against a pump receipt and names it.
  ///
  /// In en, this message translates to:
  /// **'Fuel cost {unit}'**
  String widgetFuelCostPer(String unit);

  /// Home-screen widget, shown when no vehicle exists yet.
  ///
  /// In en, this message translates to:
  /// **'Add a bike in Jatra to see your numbers here.'**
  String get widgetNoBike;

  /// Home-screen widget, shown when a vehicle exists but nothing has been logged against it.
  ///
  /// In en, this message translates to:
  /// **'Log a refuel in Jatra to see your numbers here.'**
  String get widgetNoData;

  /// Section label above the three cost-per-distance figures.
  ///
  /// In en, this message translates to:
  /// **'Cost per distance'**
  String get statsCostPerDistance;

  /// Shown when the selected range contains no measurable distance.
  ///
  /// In en, this message translates to:
  /// **'No distance measured in this period.'**
  String get statsNoDistanceMeasured;

  /// Chart title. {unit} is already formatted, e.g. '/km'.
  ///
  /// In en, this message translates to:
  /// **'Running cost {unit}'**
  String statsRunningCostPer(Object unit);

  /// Chart subtitle.
  ///
  /// In en, this message translates to:
  /// **'Fuel, service and fixed costs — excludes depreciation'**
  String get statsRunningCostSubtitle;

  /// Chart subtitle. {unit} is litres or gallons.
  ///
  /// In en, this message translates to:
  /// **'What you actually paid per {unit}'**
  String statsFuelPriceSubtitle(Object unit);

  /// Example trip distance, shown as a hint in the input.
  ///
  /// In en, this message translates to:
  /// **'40'**
  String get statsTripHint;

  /// Title when creating a service item.
  ///
  /// In en, this message translates to:
  /// **'New service item'**
  String get serviceItemNew;

  /// Title when editing a service item.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get serviceItemEdit;

  /// Deletes a service item.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get serviceItemDelete;

  /// Submit label when creating a service item.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get serviceItemAdd;

  /// Section label above the service item's name and icon.
  ///
  /// In en, this message translates to:
  /// **'The job'**
  String get serviceItemJob;

  /// Service item name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get serviceItemName;

  /// Example service item name.
  ///
  /// In en, this message translates to:
  /// **'Engine oil'**
  String get serviceItemNameHint;

  /// Section label above the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get serviceItemIcon;

  /// Switch that enables reminders for a service item.
  ///
  /// In en, this message translates to:
  /// **'Track this item'**
  String get serviceItemTrack;

  /// Subtitle under the tracking switch.
  ///
  /// In en, this message translates to:
  /// **'Switch off to keep the history but stop Jatra reminding you.'**
  String get serviceItemTrackExplain;

  /// Confirmation dialog title. {name} is the service item's name.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String serviceItemDeleteTitle(Object name);

  /// Confirmation dialog body.
  ///
  /// In en, this message translates to:
  /// **'Jatra stops tracking this job. Services you have already logged against it stay in your history.'**
  String get serviceItemDeleteBody;

  /// Cancel button on the delete-item dialog.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get serviceItemKeep;

  /// Section label above the interval fields.
  ///
  /// In en, this message translates to:
  /// **'How often'**
  String get serviceItemHowOften;

  /// Explains the two interval fields.
  ///
  /// In en, this message translates to:
  /// **'Set either, or both. With both, whichever comes first wins.'**
  String get serviceItemHowOftenExplain;

  /// Distance interval field label.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get serviceItemEvery;

  /// Time interval field label.
  ///
  /// In en, this message translates to:
  /// **'Or every'**
  String get serviceItemOrEvery;

  /// Suffix on the time interval field. Uppercase in English by design.
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get serviceItemDays;

  /// Section label above the last-done fields.
  ///
  /// In en, this message translates to:
  /// **'Last done'**
  String get serviceItemLastDone;

  /// Explains the last-done fields.
  ///
  /// In en, this message translates to:
  /// **'Where Jatra counts the next interval from. Logging a service updates this for you.'**
  String get serviceItemLastDoneExplain;

  /// Last-done odometer field label.
  ///
  /// In en, this message translates to:
  /// **'At odometer'**
  String get serviceItemAtOdometer;

  /// Last-done date field label.
  ///
  /// In en, this message translates to:
  /// **'On date'**
  String get serviceItemOnDate;

  /// Clears an optional field.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// Validation error for an empty service item name.
  ///
  /// In en, this message translates to:
  /// **'Give the job a name.'**
  String get serviceItemNameError;

  /// Validation error when neither interval is set.
  ///
  /// In en, this message translates to:
  /// **'Set a distance interval, a time interval, or both.'**
  String get serviceItemIntervalError;

  /// Validation error for an empty service log description.
  ///
  /// In en, this message translates to:
  /// **'What was done?'**
  String get serviceLogWhatError;

  /// Validation error for an empty odometer field.
  ///
  /// In en, this message translates to:
  /// **'Enter the odometer reading.'**
  String get serviceLogOdometerError;

  /// Validation error for a non-numeric odometer.
  ///
  /// In en, this message translates to:
  /// **'Odometer must be a number.'**
  String get serviceLogOdometerNumberError;

  /// Validation error for a negative odometer.
  ///
  /// In en, this message translates to:
  /// **'Odometer cannot be negative.'**
  String get serviceLogOdometerNegativeError;

  /// Snackbar title after saving a new service log.
  ///
  /// In en, this message translates to:
  /// **'Service logged'**
  String get serviceLogged;

  /// Snackbar title after editing a service log.
  ///
  /// In en, this message translates to:
  /// **'Service updated'**
  String get serviceUpdated;

  /// Snackbar body after logging a service.
  ///
  /// In en, this message translates to:
  /// **'Next due point moved forward.'**
  String get serviceNextDueMoved;

  /// Expense category.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get categoryInsurance;

  /// Expense category.
  ///
  /// In en, this message translates to:
  /// **'Tax token'**
  String get categoryTaxToken;

  /// Expense category — the roadworthiness certificate.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get categoryFitness;

  /// Expense category.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get categoryRegistration;

  /// Expense category.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get categoryAccessories;

  /// Expense category.
  ///
  /// In en, this message translates to:
  /// **'Fine'**
  String get categoryFine;

  /// Expense category.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get categoryParking;

  /// Expense category.
  ///
  /// In en, this message translates to:
  /// **'Washing'**
  String get categoryWashing;

  /// Expense category.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// Reminder type.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get reminderService;

  /// Reminder type.
  ///
  /// In en, this message translates to:
  /// **'Document expiry'**
  String get reminderDocumentExpiry;

  /// Reminder type.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminderCustom;

  /// Relative day, used mid-sentence: 'Due today'.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get dateToday;

  /// Relative day, used mid-sentence.
  ///
  /// In en, this message translates to:
  /// **'tomorrow'**
  String get dateTomorrow;

  /// Relative day, used mid-sentence.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get dateYesterday;

  /// Relative day in the future.
  ///
  /// In en, this message translates to:
  /// **'in {count} days'**
  String dateInDays(Object count);

  /// Relative day in the past.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String dateDaysAgo(Object count);

  /// Wraps a relative day that is an estimate.
  ///
  /// In en, this message translates to:
  /// **'roughly {when}'**
  String dateRoughly(Object when);

  /// Next-service card. {when} is a relative day.
  ///
  /// In en, this message translates to:
  /// **'Due {when}'**
  String serviceDueOn(Object when);

  /// Fallback detail line on a service item.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of the interval used'**
  String serviceIntervalUsed(Object percent);

  /// Title when editing an expense.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get expensesEdit;

  /// Title when adding an expense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get expensesAddTitle;

  /// Submit label when adding an expense.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get expensesSave;

  /// Section label above category and amount.
  ///
  /// In en, this message translates to:
  /// **'What for'**
  String get expensesWhatFor;

  /// Expense amount field.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expensesAmount;

  /// Expense date field.
  ///
  /// In en, this message translates to:
  /// **'Paid on'**
  String get expensesPaidOn;

  /// Expense notes field.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get expensesNotes;

  /// Section label for document validity dates.
  ///
  /// In en, this message translates to:
  /// **'Cover period'**
  String get expensesCoverPeriod;

  /// Explains the cover period fields.
  ///
  /// In en, this message translates to:
  /// **'Jatra counts down to the end date and reminds you a fortnight before.'**
  String get expensesCoverExplain;

  /// Document validity start date.
  ///
  /// In en, this message translates to:
  /// **'Valid from'**
  String get expensesValidFrom;

  /// Document validity end date.
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get expensesValidUntil;

  /// Subtitle on a document row.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String expensesUntil(Object date);

  /// Toggle tooltip.
  ///
  /// In en, this message translates to:
  /// **'Show this bike only'**
  String get expensesShowThisBike;

  /// Toggle tooltip.
  ///
  /// In en, this message translates to:
  /// **'Show all bikes'**
  String get expensesShowAllBikes;

  /// Undo snackbar after swiping an expense away.
  ///
  /// In en, this message translates to:
  /// **'Deleted {category} · {amount}'**
  String expensesDeletedSnack(Object amount, Object category);

  /// Validation error for an empty amount.
  ///
  /// In en, this message translates to:
  /// **'Enter what it cost.'**
  String get expensesAmountError;

  /// Validation error for a non-numeric amount.
  ///
  /// In en, this message translates to:
  /// **'Amount must be a number, like 1450.00.'**
  String get expensesAmountNumberError;

  /// Validation error for a negative amount.
  ///
  /// In en, this message translates to:
  /// **'Amount cannot be negative.'**
  String get expensesAmountNegativeError;

  /// Validation error when validity dates are reversed.
  ///
  /// In en, this message translates to:
  /// **'Cover cannot end before it starts.'**
  String get expensesCoverOrderError;

  /// Snackbar after saving a new expense.
  ///
  /// In en, this message translates to:
  /// **'Expense saved'**
  String get expensesSaved;

  /// Snackbar after editing an expense.
  ///
  /// In en, this message translates to:
  /// **'Expense updated'**
  String get expensesUpdated;

  /// Title of the bike list screen.
  ///
  /// In en, this message translates to:
  /// **'Bikes'**
  String get vehiclesTitle;

  /// Empty-state action on the bike list.
  ///
  /// In en, this message translates to:
  /// **'Add a bike'**
  String get vehiclesAdd;

  /// Floating action button on the bike list.
  ///
  /// In en, this message translates to:
  /// **'Add bike'**
  String get vehiclesAddShort;

  /// Title when editing a bike.
  ///
  /// In en, this message translates to:
  /// **'Edit bike'**
  String get vehiclesEdit;

  /// Empty state on the bike list.
  ///
  /// In en, this message translates to:
  /// **'No bikes yet'**
  String get vehiclesNoneTitle;

  /// Section label above archived bikes.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get vehiclesArchived;

  /// Pill on the bike Jatra opens with.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get vehiclesDefault;

  /// Menu action that makes a bike the default.
  ///
  /// In en, this message translates to:
  /// **'Open Jatra on this bike'**
  String get vehiclesMakeDefault;

  /// Menu action.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get vehiclesArchive;

  /// Menu action.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get vehiclesUnarchive;

  /// Tooltip on a bike's overflow menu.
  ///
  /// In en, this message translates to:
  /// **'Options for {name}'**
  String vehiclesOptionsFor(Object name);

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String vehiclesDeleteTitle(Object name);

  /// Delete confirmation for a bike with no records.
  ///
  /// In en, this message translates to:
  /// **'This bike has no records yet. Deleting it cannot be undone.'**
  String get vehiclesDeleteEmptyBody;

  /// Delete confirmation. {records} lists the record counts.
  ///
  /// In en, this message translates to:
  /// **'This deletes {records}. It cannot be undone.\n\nExport a backup first if you might want this data back.'**
  String vehiclesDeleteBody(Object records);

  /// Confirm button on the delete-bike dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete bike'**
  String get vehiclesDeleteConfirm;

  /// Snackbar title after deleting a bike.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get vehiclesDeleted;

  /// Snackbar body after deleting a bike.
  ///
  /// In en, this message translates to:
  /// **'{name} and its records are gone.'**
  String vehiclesDeletedBody(Object name);

  /// Section label on the bike form.
  ///
  /// In en, this message translates to:
  /// **'The bike'**
  String get vehiclesTheBike;

  /// Bike name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get vehiclesName;

  /// Example bike name.
  ///
  /// In en, this message translates to:
  /// **'Pulsar'**
  String get vehiclesNameHint;

  /// Bike manufacturer field.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get vehiclesMake;

  /// Bike model field.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get vehiclesModel;

  /// Bike year field.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get vehiclesYear;

  /// Bike engine capacity field.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get vehiclesEngine;

  /// Bike registration field.
  ///
  /// In en, this message translates to:
  /// **'Registration number'**
  String get vehiclesRegistration;

  /// Example Bangladeshi registration plate.
  ///
  /// In en, this message translates to:
  /// **'DHAKA METRO-L 12-3456'**
  String get vehiclesRegistrationHint;

  /// Section label on the bike form.
  ///
  /// In en, this message translates to:
  /// **'Units and currency'**
  String get vehiclesUnitsCurrency;

  /// Currency picker label.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get vehiclesCurrency;

  /// Section label on the bike form.
  ///
  /// In en, this message translates to:
  /// **'Ownership'**
  String get vehiclesOwnership;

  /// Explains the optional ownership fields.
  ///
  /// In en, this message translates to:
  /// **'Used to work out depreciation and true cost per kilometre. Leave blank if you would rather not.'**
  String get vehiclesOwnershipExplain;

  /// Starting odometer field.
  ///
  /// In en, this message translates to:
  /// **'Odometer when you started logging'**
  String get vehiclesStartingOdometer;

  /// Tank capacity field.
  ///
  /// In en, this message translates to:
  /// **'Tank capacity'**
  String get vehiclesTankCapacity;

  /// Purchase date field.
  ///
  /// In en, this message translates to:
  /// **'Purchase date'**
  String get vehiclesPurchaseDate;

  /// Empty state when a ride cannot be loaded.
  ///
  /// In en, this message translates to:
  /// **'Ride not found'**
  String get ridesNotFoundTitle;

  /// Empty state body.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted.'**
  String get ridesNotFoundBody;

  /// Fallback title for a ride with no name or date.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get ridesFallbackTitle;

  /// Title of the map screen.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTitle;

  /// Tooltip on the button opening the ride list.
  ///
  /// In en, this message translates to:
  /// **'All rides'**
  String get mapAllRides;

  /// Tooltip on the locate button when the dot is off.
  ///
  /// In en, this message translates to:
  /// **'Show my location'**
  String get mapShowMyLocation;

  /// Tooltip on the locate button when the dot is on.
  ///
  /// In en, this message translates to:
  /// **'Recentre on my location'**
  String get mapRecentre;

  /// Accessibility label for the current-location dot.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get mapYourLocation;

  /// Opens the detail screen for the ride on the map.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get mapDetails;

  /// Hint above the map when no ride has been recorded.
  ///
  /// In en, this message translates to:
  /// **'No rides yet — start one and the path is drawn here as you go.'**
  String get mapNoRidesHint;

  /// Hint above the map when tracking is off.
  ///
  /// In en, this message translates to:
  /// **'Ride tracking is off. Nothing is recorded until you turn it on.'**
  String get mapTrackingOffHint;

  /// Short action that opens tracking settings from the map.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get mapSetUp;

  /// Shown when location permission is refused.
  ///
  /// In en, this message translates to:
  /// **'Jatra needs location permission to show where you are.'**
  String get mapLocationNeeded;

  /// Shown when device location services are disabled.
  ///
  /// In en, this message translates to:
  /// **'Location is switched off on this phone.'**
  String get mapLocationServicesOff;

  /// Shown when location permission is permanently denied.
  ///
  /// In en, this message translates to:
  /// **'Jatra is blocked from using location. It can only be re-enabled in Android settings.'**
  String get mapLocationBlocked;

  /// Snackbar action opening the device location settings.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get mapTurnOn;

  /// Snackbar action opening the app settings page.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get mapOpenSettings;

  /// Snackbar when starting a ride fails.
  ///
  /// In en, this message translates to:
  /// **'Jatra could not start recording. Check that location is on and allowed for Jatra.'**
  String get rideCouldNotStart;

  /// Snackbar when a ride is finished with zero distance.
  ///
  /// In en, this message translates to:
  /// **'Ride discarded — no distance was recorded.'**
  String get ridesDiscardedEmpty;

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Discard this ride?'**
  String get ridesDiscardTitle;

  /// Confirmation dialog body.
  ///
  /// In en, this message translates to:
  /// **'The recorded path and distance are deleted. This cannot be undone.'**
  String get ridesDiscardBody;

  /// Count of service history entries.
  ///
  /// In en, this message translates to:
  /// **'{count} logged'**
  String serviceLoggedCount(Object count);

  /// Example motorcycle manufacturer.
  ///
  /// In en, this message translates to:
  /// **'Bajaj'**
  String get onboardingMakeHint;

  /// Example odometer reading. Digits stay Latin in every language.
  ///
  /// In en, this message translates to:
  /// **'24180'**
  String get onboardingOdometerHint;

  /// Explains a single gap in a recorded ride.
  ///
  /// In en, this message translates to:
  /// **'Recording stopped once during this ride, so the path has a break in it. Distance across the break is not counted.'**
  String get ridesGapOnce;

  /// Explains several gaps in a recorded ride.
  ///
  /// In en, this message translates to:
  /// **'Recording stopped {count} times during this ride. Distance across those breaks is not counted.'**
  String ridesGapMany(Object count);

  /// Section label on the ride detail screen.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get ridesDetails;

  /// Ride start time.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get ridesStarted;

  /// Ride end time.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get ridesFinished;

  /// Number of recorded GPS samples.
  ///
  /// In en, this message translates to:
  /// **'GPS points'**
  String get ridesGpsPoints;

  /// Odometer range covered by a ride.
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get ridesOdometer;

  /// Ride notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get ridesNotes;

  /// Lists likely reasons for a mileage drop.
  ///
  /// In en, this message translates to:
  /// **'Common causes: {causes}.'**
  String mileageDropCauses2(Object causes);

  /// Title when editing a service log.
  ///
  /// In en, this message translates to:
  /// **'Edit service'**
  String get serviceLogEdit;

  /// Section label on the service log form.
  ///
  /// In en, this message translates to:
  /// **'What was done'**
  String get serviceLogWhatDone;

  /// Picker linking a log to a tracked item.
  ///
  /// In en, this message translates to:
  /// **'Service item'**
  String get serviceLogItem;

  /// Help text under the service item picker.
  ///
  /// In en, this message translates to:
  /// **'Linking it moves that item’s next due point forward.'**
  String get serviceLogItemHelp;

  /// Picker option for a log not tied to a tracked item.
  ///
  /// In en, this message translates to:
  /// **'One-off repair'**
  String get serviceLogOneOff;

  /// Service log description field.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get serviceLogDescription;

  /// Example service description.
  ///
  /// In en, this message translates to:
  /// **'Engine oil + filter'**
  String get serviceLogDescriptionHint;

  /// Section label above the cost fields.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get serviceLogCost;

  /// Parts cost field.
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get serviceLogParts;

  /// Labour cost field.
  ///
  /// In en, this message translates to:
  /// **'Labour'**
  String get serviceLogLabour;

  /// Help text under the total cost field.
  ///
  /// In en, this message translates to:
  /// **'Adds up from parts and labour, or type a bundled bill.'**
  String get serviceLogTotalHelp;

  /// Workshop name field.
  ///
  /// In en, this message translates to:
  /// **'Workshop'**
  String get serviceLogWorkshop;

  /// Example workshop name.
  ///
  /// In en, this message translates to:
  /// **'Rahman Motors, Mirpur'**
  String get serviceLogWorkshopHint;

  /// Part brand field.
  ///
  /// In en, this message translates to:
  /// **'Part brand'**
  String get serviceLogPartBrand;

  /// Example part brand.
  ///
  /// In en, this message translates to:
  /// **'Motul 10W-40'**
  String get serviceLogPartBrandHint;

  /// Tooltip on the bike switcher.
  ///
  /// In en, this message translates to:
  /// **'Switch bike'**
  String get vehiclesSwitch;

  /// Menu item opening the bike list.
  ///
  /// In en, this message translates to:
  /// **'Manage bikes'**
  String get vehiclesManage;

  /// Accessibility label for the start marker on a ride path.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get mapStart;

  /// Accessibility label for the end marker on a ride path.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get mapEnd;

  /// Scale bar on the map.
  ///
  /// In en, this message translates to:
  /// **'≈ {distance} {unit} across'**
  String mapScaleAcross(Object distance, Object unit);

  /// Badge showing breaks in a recorded path.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 GAP} other{{count} GAPS}}'**
  String mapGapCount(num count);

  /// Title of the backup screen.
  ///
  /// In en, this message translates to:
  /// **'Backup and export'**
  String get backupTitle;

  /// Section label.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get backupExport;

  /// Explains the JSON backup.
  ///
  /// In en, this message translates to:
  /// **'A full JSON backup restores everything exactly, on any device.'**
  String get backupExportExplain;

  /// Switch controlling whether ride points are exported.
  ///
  /// In en, this message translates to:
  /// **'Include ride GPS data'**
  String get backupIncludeGps;

  /// Explains the GPS export switch.
  ///
  /// In en, this message translates to:
  /// **'Off keeps the file small — usually a few hundred KB. On can run to tens of megabytes.'**
  String get backupIncludeGpsExplain;

  /// Switch controlling pretty-printed JSON.
  ///
  /// In en, this message translates to:
  /// **'Readable formatting'**
  String get backupReadable;

  /// Explains the formatting switch.
  ///
  /// In en, this message translates to:
  /// **'Off produces a smaller file that is harder to read.'**
  String get backupReadableExplain;

  /// Button that shares a JSON backup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get backupExportBackup;

  /// Button that shares CSV files.
  ///
  /// In en, this message translates to:
  /// **'Export spreadsheets (CSV)'**
  String get backupExportCsv;

  /// Section label.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get backupImport;

  /// Explains the import safety check.
  ///
  /// In en, this message translates to:
  /// **'Jatra checks the whole file before changing anything. If there is a problem, nothing is imported.'**
  String get backupImportExplain;

  /// Button that opens the file picker.
  ///
  /// In en, this message translates to:
  /// **'Choose a backup file'**
  String get backupChooseFile;

  /// Tooltip that discards a staged import.
  ///
  /// In en, this message translates to:
  /// **'Cancel import'**
  String get backupCancelImport;

  /// Label above the record counts in an import preview.
  ///
  /// In en, this message translates to:
  /// **'Contains'**
  String get backupContains;

  /// Shown when a backup file contains no records.
  ///
  /// In en, this message translates to:
  /// **'nothing'**
  String get backupNothing;

  /// Date range covered by a backup.
  ///
  /// In en, this message translates to:
  /// **'Covers'**
  String get backupCovers;

  /// When the backup file was made.
  ///
  /// In en, this message translates to:
  /// **'Exported'**
  String get backupExported;

  /// Whether a backup includes ride points.
  ///
  /// In en, this message translates to:
  /// **'GPS data'**
  String get backupGpsData;

  /// GPS data is present in the backup.
  ///
  /// In en, this message translates to:
  /// **'included'**
  String get backupIncluded;

  /// GPS data is absent from the backup.
  ///
  /// In en, this message translates to:
  /// **'not included'**
  String get backupNotIncluded;

  /// Section label above the merge strategy options.
  ///
  /// In en, this message translates to:
  /// **'How should Jatra merge this?'**
  String get backupMergeQuestion;

  /// Confirmation dialog title for a destructive restore.
  ///
  /// In en, this message translates to:
  /// **'Replace everything?'**
  String get backupReplaceTitle;

  /// Dismisses an error message.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get backupDismiss;

  /// Record type in an import preview.
  ///
  /// In en, this message translates to:
  /// **'bikes'**
  String get backupCountBikes;

  /// Record type in an import preview.
  ///
  /// In en, this message translates to:
  /// **'fills'**
  String get backupCountFills;

  /// Record type in an import preview.
  ///
  /// In en, this message translates to:
  /// **'service items'**
  String get backupCountServiceItems;

  /// Record type in an import preview.
  ///
  /// In en, this message translates to:
  /// **'services'**
  String get backupCountServices;

  /// Record type in an import preview.
  ///
  /// In en, this message translates to:
  /// **'expenses'**
  String get backupCountExpenses;

  /// Record type in an import preview.
  ///
  /// In en, this message translates to:
  /// **'rides'**
  String get backupCountRides;

  /// Record type in an import preview.
  ///
  /// In en, this message translates to:
  /// **'GPS points'**
  String get backupCountGpsPoints;

  /// Example motorcycle model.
  ///
  /// In en, this message translates to:
  /// **'NS160'**
  String get onboardingModelHint;

  /// What the bike cost.
  ///
  /// In en, this message translates to:
  /// **'Purchase price'**
  String get vehiclesPurchasePrice;

  /// The bike's current estimated value.
  ///
  /// In en, this message translates to:
  /// **'What it is worth now'**
  String get vehiclesCurrentValue;

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete everything?'**
  String get settingsDeleteAllTitle;

  /// Cancel button on the delete-everything dialog.
  ///
  /// In en, this message translates to:
  /// **'Keep my data'**
  String get settingsKeepMyData;

  /// Confirm button on the delete-everything dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get settingsDeleteEverything;

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete every recorded route?'**
  String get settingsDeleteRoutesTitle;

  /// Cancel button on the delete-routes dialog.
  ///
  /// In en, this message translates to:
  /// **'Keep them'**
  String get settingsKeepThem;

  /// Confirm button on the delete-routes dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete routes'**
  String get settingsDeleteRoutes;

  /// Confirm button on the replace dialog.
  ///
  /// In en, this message translates to:
  /// **'Replace everything'**
  String get backupReplaceConfirm;

  /// Exports the raw database file.
  ///
  /// In en, this message translates to:
  /// **'Copy database out'**
  String get backupCopyDatabase;

  /// Restores from a raw database file.
  ///
  /// In en, this message translates to:
  /// **'Restore a database file'**
  String get backupRestoreDatabase;

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Restore a database file?'**
  String get backupRestoreTitle;

  /// Opens the file picker.
  ///
  /// In en, this message translates to:
  /// **'Pick a file'**
  String get backupPickFile;

  /// Dialog title after a successful raw restore.
  ///
  /// In en, this message translates to:
  /// **'Database restored'**
  String get backupRestoredTitle;

  /// Helper text under the current-value field.
  ///
  /// In en, this message translates to:
  /// **'Blank ⇒ Jatra estimates 12% lost per year.'**
  String get vehiclesDepreciationHelp;

  /// Accessibility label for a colour swatch.
  ///
  /// In en, this message translates to:
  /// **'Colour {number}'**
  String vehiclesColourN(Object number);

  /// Text of the Android notification shown while a ride records in the background.
  ///
  /// In en, this message translates to:
  /// **'Tap to return to Jatra'**
  String get ridesForegroundNotification;

  /// Notification title for a due service. {status} is a lowercased status word.
  ///
  /// In en, this message translates to:
  /// **'{item} — {status}'**
  String reminderServiceTitle(Object item, Object status);

  /// Fallback detail line on the next-service card.
  ///
  /// In en, this message translates to:
  /// **'Tap for details'**
  String get homeTapForDetails;

  /// Count of further service items not shown.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String homeMoreCount(Object count);
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return LBn();
    case 'en':
      return LEn();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

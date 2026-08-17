// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class LBn extends L {
  LBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'Jatra';

  @override
  String get actionSave => 'সংরক্ষণ';

  @override
  String get actionCancel => 'বাতিল';

  @override
  String get actionContinue => 'এগিয়ে যান';

  @override
  String get actionBack => 'পিছনে';

  @override
  String get actionDelete => 'মুছুন';

  @override
  String get actionEdit => 'সম্পাদনা';

  @override
  String get actionUndo => 'ফিরিয়ে আনুন';

  @override
  String get actionNotNow => 'এখন নয়';

  @override
  String get actionGotIt => 'বুঝেছি';

  @override
  String get actionSeeAll => 'সবগুলো দেখুন';

  @override
  String get navHome => 'হোম';

  @override
  String get navFuelLog => 'জ্বালানি হিসাব';

  @override
  String get navService => 'সার্ভিসিং';

  @override
  String get navExpenses => 'খরচ';

  @override
  String get navRides => 'যাত্রা';

  @override
  String get navStatistics => 'পরিসংখ্যান';

  @override
  String get navBikes => 'বাইক';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get navFuel => 'জ্বালানি';

  @override
  String get navMap => 'ম্যাপ';

  @override
  String get navStats => 'পরিসংখ্যান';

  @override
  String onboardingStep(int current, int total) {
    return 'ধাপ $current/$total';
  }

  @override
  String get onboardingBikeTitle => 'কোন বাইক চালাচ্ছেন?';

  @override
  String get onboardingBikeBody =>
      'শুধু একটি নাম দিলেই হবে। বাকিটা পরে দিলেও চলবে।';

  @override
  String get onboardingBikeName => 'বাইকের নাম';

  @override
  String get onboardingBikeNameError =>
      'বাইকের একটি নাম দিন — যেমন \"পালসার\"।';

  @override
  String get onboardingMake => 'ব্র্যান্ড';

  @override
  String get onboardingModel => 'মডেল';

  @override
  String get onboardingFuel => 'জ্বালানি';

  @override
  String get onboardingOdometerTitle => 'ওডোমিটারে কত দেখাচ্ছে?';

  @override
  String get onboardingOdometerBody =>
      'Jatra এখান থেকেই সব হিসাব শুরু করবে। পূর্ণসংখ্যায় লিখলেই চলবে — একদম নিখুঁত হওয়ার দরকার নেই।';

  @override
  String get onboardingOdometerLabel => 'বর্তমান রিডিং';

  @override
  String onboardingOdometerError(String unit) {
    return 'এই মুহূর্তে ওডোমিটারে যা দেখাচ্ছে তা $unit-এ লিখুন।';
  }

  @override
  String get onboardingUnits => 'একক';

  @override
  String get onboardingDoneTitle => 'সব প্রস্তুত।';

  @override
  String get onboardingDoneBody =>
      'প্রতিবার তেল নেওয়ার হিসাব রাখুন — Jatra বের করে দেবে আসল মাইলেজ, পরের সার্ভিসিং কবে, আর প্রতি কিলোমিটারে আসলে কত খরচ হচ্ছে।';

  @override
  String get onboardingPrivacyTitle => 'সব তথ্য এই ফোনেই থাকে';

  @override
  String get onboardingPrivacyBody =>
      'কোনো অ্যাকাউন্ট নেই, ক্লাউড নেই, অ্যানালিটিক্স নেই। আপনার জ্বালানি, সার্ভিসিং ও খরচের হিসাব এই ফোন ছেড়ে কোথাও যায় না, আর এসবই এয়ারপ্লেন মোডে কাজ করে। যখন খুশি পুরো ব্যাকআপ নিতে পারবেন।\n\nএকটি ব্যতিক্রম: আপনি যাত্রা রেকর্ড করলে তার পেছনের মানচিত্র OpenStreetMap থেকে আসে, ফলে যাত্রাটি মোটামুটি কোথায় হয়েছে তা তারা জানতে পারে।';

  @override
  String get onboardingPermissionNote =>
      'লোকেশন ট্র্যাকিং বন্ধ আছে। যে সুবিধার জন্য অনুমতি দরকার, সেটি চালু না করা পর্যন্ত Jatra কোনো অনুমতি চাইবে না।';

  @override
  String get onboardingStart => 'শুরু করুন';

  @override
  String get unitKm => 'কিমি';

  @override
  String get unitMiles => 'মাইল';

  @override
  String get unitLitres => 'লিটার';

  @override
  String get unitGallons => 'গ্যালন';

  @override
  String get homeOdometer => 'ওডোমিটার';

  @override
  String get homeLastTank => 'শেষ ট্যাংক';

  @override
  String get homeRunningCost => 'চালানোর খরচ';

  @override
  String get homeRunningCostCaption => 'জ্বালানি, সার্ভিসিং ও নির্দিষ্ট খরচ';

  @override
  String get homeNextService => 'পরের সার্ভিসিং';

  @override
  String get homeRecentFills => 'সাম্প্রতিক তেল নেওয়া';

  @override
  String get homeNeedsTwoTanks => 'দুইবার ফুল ট্যাংক দরকার';

  @override
  String get homeLatestUnreliable => 'শেষ ট্যাংকের হিসাব নির্ভরযোগ্য নয়';

  @override
  String homeAverage(String value, String unit) {
    return 'গড় $value $unit';
  }

  @override
  String get homeNoBikeTitle => 'কোনো বাইক নির্বাচন করা নেই';

  @override
  String get homeNoBikeBody =>
      'জ্বালানি ও সার্ভিসিংয়ের হিসাব রাখতে একটি বাইক যোগ করুন।';

  @override
  String get homeAddBike => 'বাইক যোগ করুন';

  @override
  String get homeNoFillsTitle => 'এখনো কোনো হিসাব নেই';

  @override
  String get homeNoFillsBody =>
      'মাইলেজের হিসাব শুরু করতে প্রথম তেল নেওয়ার তথ্য যোগ করুন।';

  @override
  String get homeAddFuel => 'তেল যোগ করুন';

  @override
  String get homeNothingDue => 'এখন কিছু বাকি নেই';

  @override
  String get homeNoServiceItems => 'এখনো কোনো সার্ভিস আইটেম যোগ করা হয়নি।';

  @override
  String homeAllClear(int count) {
    return 'সবগুলো $countটি আইটেম ঠিক আছে।';
  }

  @override
  String mileageDropTitle(int percent) {
    return 'এই ট্যাংকে মাইলেজ $percent% কমেছে';
  }

  @override
  String mileageDropVsUsual(String value) {
    return 'আপনার সাধারণ $value-এর তুলনায়';
  }

  @override
  String get mileageDropCauses =>
      'সাধারণ কারণ: টায়ারের হাওয়া, এয়ার ফিল্টার, চেইনের টান।';

  @override
  String get fuelAdd => 'তেল যোগ করুন';

  @override
  String get fuelEdit => 'সম্পাদনা করুন';

  @override
  String get fuelSave => 'সংরক্ষণ করুন';

  @override
  String get fuelHistory => 'জ্বালানির হিসাব';

  @override
  String get fuelWhen => 'কখন';

  @override
  String get fuelDate => 'তারিখ';

  @override
  String get fuelOdometer => 'ওডোমিটার';

  @override
  String fuelLastReading(String value, String unit) {
    return 'শেষ রিডিং: $value $unit';
  }

  @override
  String fuelOdometerMustBeHigher(String value, String unit) {
    return 'ওডোমিটারের মান আপনার শেষ রিডিং $value $unit-এর চেয়ে বেশি হতে হবে।';
  }

  @override
  String get fuelHowMuch => 'কতটুকু';

  @override
  String get fuelFillAnyTwo => 'যেকোনো দুটি লিখুন';

  @override
  String get fuelAdded => 'যত তেল নিয়েছেন';

  @override
  String get fuelPrice => 'দাম';

  @override
  String get fuelTotalPaid => 'মোট দিয়েছেন';

  @override
  String get fuelFilledTank => 'ট্যাংক ফুল করেছি';

  @override
  String get fuelFullTankExplain =>
      'দুইবার ফুল ট্যাংকের মাঝেই মাইলেজ মাপা হয়।';

  @override
  String get fuelPartialExplain =>
      'আংশিক তেল। এটি পরের ফুল ট্যাংকের হিসাবে যোগ হবে, তবে এর আলাদা মাইলেজ হিসাব হবে না।';

  @override
  String get fuelMissedEntry => 'এর আগে একবার হিসাব লিখতে ভুলে গিয়েছিলাম';

  @override
  String get fuelMissedEntryExplain =>
      'কিছু তেলের হিসাব নেই বলে এই ট্যাংকটি গড় হিসাব থেকে বাদ থাকবে।';

  @override
  String get fuelStation => 'পাম্প';

  @override
  String get fuelNotes => 'মন্তব্য';

  @override
  String get fuelPartial => 'আংশিক';

  @override
  String get fuelGap => 'ঘাটতি';

  @override
  String get fuelUnreliable => 'নির্ভরযোগ্য নয়';

  @override
  String get fuelCountsTowardNext => 'পরের ট্যাংকে\nযোগ হবে';

  @override
  String get fuelNoFillsTitle => 'এখনো কোনো হিসাব নেই';

  @override
  String get fuelNoFillsBody =>
      'মাইলেজের হিসাব শুরু করতে প্রথম তেল নেওয়ার তথ্য যোগ করুন।';

  @override
  String fuelCountFills(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count বার',
      one: '১ বার',
    );
    return '$_temp0';
  }

  @override
  String get serviceTitle => 'সার্ভিসিং';

  @override
  String get serviceDue => 'যা বাকি';

  @override
  String get serviceNothingPending => 'কিছু বাকি নেই';

  @override
  String serviceNeedAttention(int count) {
    return '$countটি দেখা দরকার';
  }

  @override
  String get serviceLogAction => 'সার্ভিসিং লিখুন';

  @override
  String get serviceHistory => 'ইতিহাস';

  @override
  String get serviceNoItemsTitle => 'কোনো সার্ভিস আইটেম নেই';

  @override
  String get serviceNoItemsBody =>
      'যেসব কাজের হিসাব Jatra রাখবে সেগুলো যোগ করুন — ইঞ্জিন অয়েল, চেইন লুব, ব্রেক প্যাড।';

  @override
  String get serviceAddItem => 'সার্ভিস আইটেম যোগ করুন';

  @override
  String get serviceNothingLogged =>
      'এখনো কিছু লেখা হয়নি। সার্ভিসিং লিখলে Jatra নিজেই পরের তারিখ এগিয়ে দেবে।';

  @override
  String get serviceRemindersTitle => 'সার্ভিসিংয়ের সময় হলে জানিয়ে দিই?';

  @override
  String get serviceRemindersBody =>
      'Jatra এই ফোনেই একটি রিমাইন্ডার দেখাবে। কোথাও কিছু পাঠানো হয় না — আপনার নিজের হিসাব থেকেই এটি বের করা হয়।';

  @override
  String get serviceRemindersEnable => 'রিমাইন্ডার চালু করুন';

  @override
  String serviceToGo(String value, String unit) {
    return 'আরও $value $unit বাকি';
  }

  @override
  String serviceOver(String value, String unit) {
    return '$value $unit পার হয়ে গেছে';
  }

  @override
  String get serviceNoInterval =>
      'কোনো সময়সীমা দেওয়া নেই। সম্পাদনা করে যোগ করুন।';

  @override
  String get statusOk => 'ঠিক আছে';

  @override
  String get statusDueSoon => 'শীঘ্রই';

  @override
  String get statusDueNow => 'এখনই';

  @override
  String get statusOverdue => 'সময় পেরিয়েছে';

  @override
  String get statusNotSet => 'নির্ধারিত নয়';

  @override
  String get expensesTitle => 'খরচ';

  @override
  String get expensesAdd => 'খরচ যোগ করুন';

  @override
  String get expensesDocuments => 'কাগজপত্র';

  @override
  String get expensesTotal => 'মোট';

  @override
  String get expensesAllBikes => 'সব বাইক';

  @override
  String get expensesNoneTitle => 'কোনো খরচ লেখা হয়নি';

  @override
  String get expensesNoneBody =>
      'ইনস্যুরেন্স, ট্যাক্স টোকেন, ফিটনেস, নতুন হেলমেট — জ্বালানি ও সার্ভিসিং ছাড়া সবকিছু।';

  @override
  String get expensesExpired => 'মেয়াদ শেষ';

  @override
  String get expensesExpiresToday => 'আজ মেয়াদ শেষ';

  @override
  String expensesDaysLeft(int count) {
    return '$count দিন';
  }

  @override
  String get statsTitle => 'পরিসংখ্যান';

  @override
  String get statsRangeThisMonth => 'এই মাস';

  @override
  String get statsRangeLast3Months => 'গত ৩ মাস';

  @override
  String get statsRangeThisYear => 'এই বছর';

  @override
  String get statsRangeAllTime => 'সব সময়';

  @override
  String get statsRangeCustom => 'নিজের পছন্দ';

  @override
  String statsCostPer(String unit) {
    return 'প্রতি $unit-এ খরচ';
  }

  @override
  String get statsFuel => 'জ্বালানি';

  @override
  String get statsFuelExplain =>
      'শুধু তেল। পাম্পের দাম আর যানজটের সঙ্গে বদলায়।';

  @override
  String get statsRunning => 'চালানোর';

  @override
  String get statsRunningExplain =>
      'জ্বালানি, সার্ভিসিং, যন্ত্রাংশ ও নির্দিষ্ট খরচ।';

  @override
  String get statsTrue => 'প্রকৃত';

  @override
  String get statsTrueExplain =>
      'চালানোর খরচের সঙ্গে বাইকের মূল্য কমে যাওয়া যোগ করে।';

  @override
  String get statsEstimate => 'আনুমানিক';

  @override
  String statsNeedTwoReadings(String unit) {
    return 'প্রতি $unit-এ খরচ বের করতে এই সময়ের মধ্যে অন্তত দুটি ওডোমিটার রিডিং দরকার। আরেকবার তেলের হিসাব লিখুন।';
  }

  @override
  String get statsAddPurchasePrice =>
      'বাইকটি কত দামে কিনেছেন তা যোগ করলে এটি দেখা যাবে।';

  @override
  String get statsTripTitle => 'একটি যাত্রায় কত খরচ হবে?';

  @override
  String get statsTripDistance => 'দূরত্ব';

  @override
  String get statsTripUsesRates =>
      'উপরে বেছে নেওয়া সময়ের হিসাব ব্যবহার করা হয়েছে।';

  @override
  String get statsTripNotEnough =>
      'এই সময়ের যথেষ্ট তথ্য নেই। আরও বড় সময় বেছে নিন।';

  @override
  String get statsTrueCost => 'প্রকৃত খরচ';

  @override
  String get statsMileageOverTime => 'সময়ের সঙ্গে মাইলেজ';

  @override
  String get statsMileageSubtitle => 'প্রতিটি ফুল ট্যাংকের জন্য একটি বিন্দু';

  @override
  String get statsMileageEmpty =>
      'এই সময়ে দুইবার ফুল ট্যাংক হলে এখানে রেখা আঁকা হবে।';

  @override
  String get statsMonthlySpend => 'মাসিক খরচ';

  @override
  String get statsMonthlySpendSubtitle => 'টাকা কোথায় গেছে';

  @override
  String get statsDistancePerMonth => 'মাসে কত দূরত্ব';

  @override
  String get statsDistanceEmpty =>
      'দূরত্ব মাপতে এক মাসে অন্তত দুটি ওডোমিটার রিডিং দরকার।';

  @override
  String get statsFuelPricePaid => 'তেলের যা দাম দিয়েছেন';

  @override
  String get statsNotEnoughData => 'এখনো যথেষ্ট তথ্য নেই।';

  @override
  String get statsOther => 'অন্যান্য';

  @override
  String get statsDistance => 'দূরত্ব';

  @override
  String get statsTotalSpent => 'মোট খরচ';

  @override
  String get statsAverage => 'গড়';

  @override
  String get statsBestTank => 'সেরা ট্যাংক';

  @override
  String get statsWorstTank => 'সবচেয়ে খারাপ ট্যাংক';

  @override
  String get statsFills => 'কতবার তেল';

  @override
  String get statsDaysOwned => 'যত দিন ধরে';

  @override
  String get statsFuelShare => 'জ্বালানির অংশ';

  @override
  String get ridesTitle => 'যাত্রা';

  @override
  String get ridesStart => 'যাত্রা শুরু';

  @override
  String get ridesRecording => 'রেকর্ড হচ্ছে';

  @override
  String get ridesPaused => 'বিরতি';

  @override
  String get ridesPause => 'বিরতি';

  @override
  String get ridesResume => 'আবার শুরু';

  @override
  String get ridesFinish => 'শেষ করুন';

  @override
  String ridesPoints(int count) {
    return '$countটি বিন্দু';
  }

  @override
  String get ridesTrackingOffTitle => 'যাত্রা ট্র্যাকিং বন্ধ আছে';

  @override
  String get ridesTrackingOffBody =>
      'Jatra জিপিএস দিয়ে আপনার পথ এঁকে দূরত্ব ও গতি বের করতে পারে। এটি শুরুতে বন্ধ থাকে এবং চালু করলে তবেই লোকেশনের অনুমতি চায়।\n\nএটি ছাড়াও Jatra-র বাকি সব কাজ করে।';

  @override
  String get ridesSetUp => 'যাত্রা ট্র্যাকিং চালু করুন';

  @override
  String get ridesNoneTitle => 'কোনো যাত্রা রেকর্ড হয়নি';

  @override
  String get ridesNoneBody =>
      'যাত্রা শুরু করুন, Jatra আপনার পথ ও দূরত্ব লিখে রাখবে।';

  @override
  String get ridesInterruptedTitle => 'একটি যাত্রা রেকর্ড অবস্থায় ছিল';

  @override
  String get ridesResumeAction => 'আবার শুরু';

  @override
  String get ridesSaveWhatWeHave => 'যতটুকু আছে রাখুন';

  @override
  String get ridesDiscard => 'বাদ দিন';

  @override
  String ridesGapNotice(int minutes) {
    return 'অ্যাপ বন্ধ থাকায় যাত্রা থেমে ছিল — $minutes মিনিটের ঘাটতি। স্ক্রিন বন্ধ রেখেও রেকর্ড করতে ব্যাকগ্রাউন্ড ট্র্যাকিং চালু করুন।';
  }

  @override
  String get ridesNoPath => 'এই যাত্রার কোনো পথ রেকর্ড হয়নি।';

  @override
  String get ridesMovingTime => 'চলার সময়';

  @override
  String get ridesTotalTime => 'মোট সময়';

  @override
  String get ridesAverageSpeed => 'গড় গতি';

  @override
  String get ridesTopSpeed => 'সর্বোচ্চ গতি';

  @override
  String get ridesStopped => 'থেমে ছিলেন';

  @override
  String get ridesElevation => 'উচ্চতা';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get settingsPrivacyTitle => 'কোনো তথ্য এই ফোন ছেড়ে যায় না';

  @override
  String get settingsPrivacyBody =>
      'Jatra-র নিজস্ব কোনো অ্যাকাউন্ট, সার্ভার বা অ্যানালিটিক্স নেই। রেকর্ড করা যাত্রার পেছনের মানচিত্র ছাড়া সবকিছুই এয়ারপ্লেন মোডে কাজ করে; সেই মানচিত্রের টাইল OpenStreetMap থেকে আসে।';

  @override
  String get settingsAppearance => 'চেহারা';

  @override
  String get settingsThemeDark => 'গাঢ়';

  @override
  String get settingsThemeLight => 'হালকা';

  @override
  String get settingsThemeSystem => 'ফোন অনুযায়ী';

  @override
  String get settingsLanguage => 'ভাষা';

  @override
  String get settingsMileageAlert => 'মাইলেজ সতর্কতা';

  @override
  String get settingsMileageAlertPrompt =>
      'মাইলেজ সাধারণের চেয়ে এত কমলে জানাবেন';

  @override
  String get settingsMileageAlertOff => 'বন্ধ';

  @override
  String get settingsMileageAlertExplain =>
      'আপনার শেষ পাঁচটি নির্ভরযোগ্য ট্যাংকের মধ্যমা ধরে তুলনা করা হয়, তাই একটি অস্বাভাবিক সপ্তাহে সতর্কতা আসে না।';

  @override
  String get settingsMileageAlertDisabled =>
      'Jatra মাইলেজের পরিবর্তন নিয়ে কিছু বলবে না।';

  @override
  String get settingsReminders => 'রিমাইন্ডার';

  @override
  String get settingsRemindersTitle => 'সার্ভিসিং ও কাগজপত্রের রিমাইন্ডার';

  @override
  String get settingsRemindersBody =>
      'এই ফোনেই দেখানো হয়, আপনার নিজের হিসাব থেকে বের করা। কোথাও কিছু পাঠানো হয় না।';

  @override
  String get settingsRemindersBlocked =>
      'আপনার অ্যান্ড্রয়েড সেটিংসে Jatra-র নোটিফিকেশন বন্ধ আছে। সেখান থেকে চালু করলে এটি আবার কাজ করবে।';

  @override
  String get settingsDepreciation => 'মূল্য হ্রাস';

  @override
  String get settingsDepreciationPrompt => 'ধরে নিন বাইকের দাম বছরে এতটা কমে';

  @override
  String get settingsDepreciationExplain =>
      'শুধু যেসব বাইকের বর্তমান দাম লেখা নেই তাদের জন্য। প্রতি কিলোমিটারে প্রকৃত খরচ সবসময়ই আনুমানিক।';

  @override
  String get settingsTracking => 'যাত্রা ট্র্যাকিং';

  @override
  String get settingsTrackingBody =>
      'Jatra জিপিএস দিয়ে আপনার পথ এঁকে দিতে পারে। এটি ছাড়াও বাকি সব কাজ করে।';

  @override
  String get settingsKeepScreenOn => 'যাত্রার সময় স্ক্রিন চালু রাখুন';

  @override
  String get settingsKeepScreenOnExplain =>
      'রেকর্ড বন্ধ করার সঙ্গে সঙ্গেই ছেড়ে দেওয়া হয়।';

  @override
  String get settingsBikes => 'বাইক';

  @override
  String get settingsManageBikes => 'বাইক ব্যবস্থাপনা';

  @override
  String get settingsManageBikesBody =>
      'যোগ, সম্পাদনা, ডিফল্ট নির্বাচন, আর্কাইভ';

  @override
  String get settingsData => 'তথ্য';

  @override
  String get settingsBackup => 'ব্যাকআপ ও রপ্তানি';

  @override
  String get settingsBackupBody => 'JSON ব্যাকআপ, স্প্রেডশিট, পুনরুদ্ধার';

  @override
  String get settingsDeleteLocationHistory => 'লোকেশন ইতিহাস মুছুন';

  @override
  String get settingsDeleteLocationHistoryBody =>
      'রেকর্ড করা পথ মুছে যাবে। যাত্রার দূরত্ব ও সময় থেকে যাবে।';

  @override
  String get settingsDeleteAll => 'সব তথ্য মুছুন';

  @override
  String get settingsDeleteAllBody =>
      'সব বাইক, তেলের হিসাব, সার্ভিসিং ও সেটিংস';

  @override
  String get settingsAbout => 'পরিচিতি';

  @override
  String get settingsAboutBody =>
      'মোটরসাইকেলের জন্য অফলাইন জ্বালানি, সার্ভিসিং ও খরচের হিসাব।';

  @override
  String get settingsFontCredit =>
      'Barlow Condensed, Inter, JetBrains Mono ও Hind Siliguri ফন্টে তৈরি, সবই SIL Open Font License-এর অধীনে।';

  @override
  String get settingsMapCache => 'অফলাইন ম্যাপ';

  @override
  String get settingsMapCacheBody =>
      'আপনি ম্যাপে যে এলাকা দেখেন তা এই ফোনেই রাখা হয়, তাই আগে দেখা পথ ইন্টারনেট ছাড়াও আঁকা হয়। আগেভাগে কিছু ডাউনলোড করা হয় না।';

  @override
  String settingsMapCacheStored(String size) {
    return '$size জমা আছে';
  }

  @override
  String get settingsMapCacheClear => 'মুছে ফেলুন';

  @override
  String get settingsMapCacheCleared => 'অফলাইন ম্যাপের টাইল মুছে ফেলা হয়েছে';

  @override
  String get trackingOff => 'বন্ধ';

  @override
  String get trackingBackground => 'চালু';

  @override
  String get trackingOffExplain =>
      'জিপিএস নেই। দূরত্ব নিজে লিখবেন। বাকি সব কাজ করবে।';

  @override
  String get trackingBackgroundExplain =>
      'স্ক্রিন বন্ধ থাকলেও, অন্য অ্যাপে গেলেও, ফোন পকেটে থাকলেও — \"শেষ\" চাপা পর্যন্ত পুরো যাত্রা রেকর্ড হয়। রেকর্ড চলাকালে একটি নোটিফিকেশন দেখা যায়।';

  @override
  String get trackingDefault => 'ডিফল্ট';

  @override
  String get trackingAskBackgroundTitle => 'পুরো যাত্রা রেকর্ড করব?';

  @override
  String get trackingAskBackgroundBody =>
      'অ্যাপ থেকে বেরিয়ে গেলে বা স্ক্রিন বন্ধ করলেও যাত্রার রেকর্ড চলতে থাকে, তাই দূরত্ব হবে আপনি সত্যিই যতটা চালিয়েছেন ততটাই। পুরো সময় একটি নোটিফিকেশন দেখা যায়, আর \"শেষ\" চাপলেই থেমে যায়।\n\nঅ্যান্ড্রয়েড আপনাকে \"সবসময়\" লোকেশনের অনুমতি দিতে বলবে। Jatra শুধু যাত্রা রেকর্ডের সময়ই এটি পড়ে।\n\nআপনার পথ এই ফোনেই সংরক্ষিত থাকে, কোথাও পাঠানো হয় না।';

  @override
  String get trackingServicesDisabled =>
      'এই ফোনে লোকেশন বন্ধ আছে, তাই Jatra পথ রেকর্ড করতে পারছে না।';

  @override
  String get trackingOpenLocationSettings => 'লোকেশন সেটিংস খুলুন';

  @override
  String get trackingBlocked =>
      'Jatra-র জন্য লোকেশন বন্ধ করা আছে। অ্যান্ড্রয়েড আর জিজ্ঞেস করবে না, তাই সেটিংস থেকে বদলাতে হবে।';

  @override
  String get trackingNotGranted =>
      'Jatra এখনো আপনার লোকেশন পড়ার অনুমতি পায়নি।';

  @override
  String get trackingBackgroundNeedsSettings =>
      'যাত্রা ব্যাকগ্রাউন্ডেও রেকর্ড হবে। তবে অ্যান্ড্রয়েড \"সবসময়\" অনুমতি শুধু সেটিংস থেকেই দিতে দেয়, আর সেটি ছাড়া দীর্ঘ যাত্রার রেকর্ড মাঝপথে থেমে যেতে পারে। বেছে নিন: Jatra → Permissions → Location → Allow all the time।';

  @override
  String get trackingOpenAppSettings => 'অ্যাপ সেটিংস খুলুন';

  @override
  String get emptyDash => '—';

  @override
  String fuelDeletedSnack(Object amount, Object date) {
    return '$date তারিখের তেল ভরার হিসাব মুছে ফেলা হয়েছে · $amount';
  }

  @override
  String ridesDeletedSnack(Object date) {
    return '$date তারিখের যাত্রা মুছে ফেলা হয়েছে';
  }

  @override
  String get actionSaveChanges => 'পরিবর্তন সংরক্ষণ';

  @override
  String get fuelOptional => 'ঐচ্ছিক';

  @override
  String get fuelStationHint => 'মেঘনা পেট্রোল পাম্প';

  @override
  String get fuelCorrectionAccepted =>
      'রিডিংটি সংশোধন হিসেবে গ্রহণ করা হয়েছে।';

  @override
  String get fuelOdometerResetAction =>
      'আমার ওডোমিটার রিসেট হয়েছে বা ভুল পড়া হয়েছে';

  @override
  String get fuelAllowLowerTitle => 'কম রিডিং অনুমোদন করবেন?';

  @override
  String get fuelAllowLowerBody =>
      'সাধারণত প্রতিটি রিডিং আগেরটির চেয়ে বেশি হতে হয়, কারণ দূরত্ব এ দুটির মধ্যে মাপা হয়।\n\nমিটার বদলানো হলে বা আগের কোনো এন্ট্রি ভুল টাইপ করলেই কেবল কম রিডিং অনুমোদন করুন। এই ফাঁকের মাইলেজ অর্থবহ হবে না।';

  @override
  String get fuelAllowLowerConfirm => 'অনুমোদন করুন';

  @override
  String get statsNoBikeBody => 'পরিসংখ্যান দেখতে একটি বাইক যোগ করুন।';

  @override
  String widgetFuelCostPer(String unit) {
    return 'জ্বালানি খরচ $unit';
  }

  @override
  String get widgetNoBike =>
      'এখানে আপনার হিসাব দেখতে Jatra-তে একটি বাইক যোগ করুন।';

  @override
  String get widgetNoData =>
      'এখানে আপনার হিসাব দেখতে Jatra-তে একটি রিফুয়েল লিখুন।';

  @override
  String get statsCostPerDistance => 'প্রতি দূরত্বে খরচ';

  @override
  String get statsNoDistanceMeasured => 'এই সময়ে কোনো দূরত্ব মাপা হয়নি।';

  @override
  String statsRunningCostPer(Object unit) {
    return 'চলমান খরচ $unit';
  }

  @override
  String get statsRunningCostSubtitle =>
      'জ্বালানি, সার্ভিসিং ও নির্দিষ্ট খরচ — অবচয় বাদে';

  @override
  String statsFuelPriceSubtitle(Object unit) {
    return 'প্রতি $unit-এ আপনি আসলে যা দিয়েছেন';
  }

  @override
  String get statsTripHint => '৪০';

  @override
  String get serviceItemNew => 'নতুন সার্ভিস আইটেম';

  @override
  String get serviceItemEdit => 'আইটেম সম্পাদনা';

  @override
  String get serviceItemDelete => 'আইটেম মুছুন';

  @override
  String get serviceItemAdd => 'আইটেম যোগ করুন';

  @override
  String get serviceItemJob => 'কাজ';

  @override
  String get serviceItemName => 'নাম';

  @override
  String get serviceItemNameHint => 'ইঞ্জিন অয়েল';

  @override
  String get serviceItemIcon => 'আইকন';

  @override
  String get serviceItemTrack => 'এই আইটেম ট্র্যাক করুন';

  @override
  String get serviceItemTrackExplain =>
      'বন্ধ করলে হিসাব থাকবে, তবে Jatra আর মনে করিয়ে দেবে না।';

  @override
  String serviceItemDeleteTitle(Object name) {
    return '$name মুছে ফেলবেন?';
  }

  @override
  String get serviceItemDeleteBody =>
      'Jatra এই কাজটি আর ট্র্যাক করবে না। আগে যেসব সার্ভিস লগ করেছেন সেগুলো হিসাবে থেকে যাবে।';

  @override
  String get serviceItemKeep => 'থাক';

  @override
  String get serviceItemHowOften => 'কত ঘন ঘন';

  @override
  String get serviceItemHowOftenExplain =>
      'যেকোনো একটি বা দুটোই দিন। দুটো দিলে যেটি আগে আসে সেটিই ধরা হবে।';

  @override
  String get serviceItemEvery => 'প্রতি';

  @override
  String get serviceItemOrEvery => 'অথবা প্রতি';

  @override
  String get serviceItemDays => 'দিন';

  @override
  String get serviceItemLastDone => 'সর্বশেষ করা হয়েছে';

  @override
  String get serviceItemLastDoneExplain =>
      'Jatra এখান থেকেই পরের বার হিসাব শুরু করে। সার্ভিস লগ করলে এটি নিজেই হালনাগাদ হয়।';

  @override
  String get serviceItemAtOdometer => 'ওডোমিটারে';

  @override
  String get serviceItemOnDate => 'তারিখে';

  @override
  String get actionClear => 'মুছুন';

  @override
  String get serviceItemNameError => 'কাজটির একটি নাম দিন।';

  @override
  String get serviceItemIntervalError =>
      'দূরত্ব বা সময়ের ব্যবধান, অথবা দুটোই দিন।';

  @override
  String get serviceLogWhatError => 'কী কাজ করা হয়েছে?';

  @override
  String get serviceLogOdometerError => 'ওডোমিটারের রিডিং লিখুন।';

  @override
  String get serviceLogOdometerNumberError => 'ওডোমিটার একটি সংখ্যা হতে হবে।';

  @override
  String get serviceLogOdometerNegativeError => 'ওডোমিটার ঋণাত্মক হতে পারে না।';

  @override
  String get serviceLogged => 'সার্ভিস লগ করা হয়েছে';

  @override
  String get serviceUpdated => 'সার্ভিস হালনাগাদ হয়েছে';

  @override
  String get serviceNextDueMoved =>
      'পরবর্তী সার্ভিসের সময় এগিয়ে নেওয়া হয়েছে।';

  @override
  String get categoryInsurance => 'বিমা';

  @override
  String get categoryTaxToken => 'ট্যাক্স টোকেন';

  @override
  String get categoryFitness => 'ফিটনেস';

  @override
  String get categoryRegistration => 'রেজিস্ট্রেশন';

  @override
  String get categoryAccessories => 'যন্ত্রাংশ';

  @override
  String get categoryFine => 'জরিমানা';

  @override
  String get categoryParking => 'পার্কিং';

  @override
  String get categoryWashing => 'ধোয়া';

  @override
  String get categoryOther => 'অন্যান্য';

  @override
  String get reminderService => 'সার্ভিসিং';

  @override
  String get reminderDocumentExpiry => 'কাগজের মেয়াদ';

  @override
  String get reminderCustom => 'রিমাইন্ডার';

  @override
  String get dateToday => 'আজ';

  @override
  String get dateTomorrow => 'আগামীকাল';

  @override
  String get dateYesterday => 'গতকাল';

  @override
  String dateInDays(Object count) {
    return '$count দিনে';
  }

  @override
  String dateDaysAgo(Object count) {
    return '$count দিন আগে';
  }

  @override
  String dateRoughly(Object when) {
    return 'আনুমানিক $when';
  }

  @override
  String serviceDueOn(Object when) {
    return '$when সার্ভিসের সময়';
  }

  @override
  String serviceIntervalUsed(Object percent) {
    return 'ব্যবধানের $percent% ব্যবহৃত';
  }

  @override
  String get expensesEdit => 'খরচ সম্পাদনা';

  @override
  String get expensesAddTitle => 'খরচ যোগ করুন';

  @override
  String get expensesSave => 'খরচ সংরক্ষণ';

  @override
  String get expensesWhatFor => 'কী বাবদ';

  @override
  String get expensesAmount => 'পরিমাণ';

  @override
  String get expensesPaidOn => 'পরিশোধের তারিখ';

  @override
  String get expensesNotes => 'নোট';

  @override
  String get expensesCoverPeriod => 'মেয়াদকাল';

  @override
  String get expensesCoverExplain =>
      'Jatra শেষ তারিখ পর্যন্ত গণনা করে এবং দুই সপ্তাহ আগে মনে করিয়ে দেয়।';

  @override
  String get expensesValidFrom => 'শুরু';

  @override
  String get expensesValidUntil => 'শেষ';

  @override
  String expensesUntil(Object date) {
    return '$date পর্যন্ত';
  }

  @override
  String get expensesShowThisBike => 'শুধু এই বাইক দেখান';

  @override
  String get expensesShowAllBikes => 'সব বাইক দেখান';

  @override
  String expensesDeletedSnack(Object amount, Object category) {
    return '$category · $amount মুছে ফেলা হয়েছে';
  }

  @override
  String get expensesAmountError => 'কত খরচ হয়েছে লিখুন।';

  @override
  String get expensesAmountNumberError =>
      'পরিমাণ একটি সংখ্যা হতে হবে, যেমন 1450.00।';

  @override
  String get expensesAmountNegativeError => 'পরিমাণ ঋণাত্মক হতে পারে না।';

  @override
  String get expensesCoverOrderError => 'মেয়াদ শুরুর আগে শেষ হতে পারে না।';

  @override
  String get expensesSaved => 'খরচ সংরক্ষিত হয়েছে';

  @override
  String get expensesUpdated => 'খরচ হালনাগাদ হয়েছে';

  @override
  String get vehiclesTitle => 'বাইক';

  @override
  String get vehiclesAdd => 'বাইক যোগ করুন';

  @override
  String get vehiclesAddShort => 'বাইক যোগ';

  @override
  String get vehiclesEdit => 'বাইক সম্পাদনা';

  @override
  String get vehiclesNoneTitle => 'এখনো কোনো বাইক নেই';

  @override
  String get vehiclesArchived => 'সংরক্ষণাগারে';

  @override
  String get vehiclesDefault => 'ডিফল্ট';

  @override
  String get vehiclesMakeDefault => 'Jatra এই বাইক দিয়ে খুলুন';

  @override
  String get vehiclesArchive => 'সংরক্ষণাগারে রাখুন';

  @override
  String get vehiclesUnarchive => 'সংরক্ষণাগার থেকে ফেরান';

  @override
  String vehiclesOptionsFor(Object name) {
    return '$name-এর অপশন';
  }

  @override
  String vehiclesDeleteTitle(Object name) {
    return '$name মুছে ফেলবেন?';
  }

  @override
  String get vehiclesDeleteEmptyBody =>
      'এই বাইকের কোনো হিসাব নেই। মুছে ফেললে আর ফেরানো যাবে না।';

  @override
  String vehiclesDeleteBody(Object records) {
    return 'এতে $records মুছে যাবে। এটি আর ফেরানো যাবে না।\n\nতথ্য পরে দরকার হলে আগে ব্যাকআপ নিন।';
  }

  @override
  String get vehiclesDeleteConfirm => 'বাইক মুছুন';

  @override
  String get vehiclesDeleted => 'মুছে ফেলা হয়েছে';

  @override
  String vehiclesDeletedBody(Object name) {
    return '$name এবং তার সব হিসাব মুছে গেছে।';
  }

  @override
  String get vehiclesTheBike => 'বাইক';

  @override
  String get vehiclesName => 'নাম';

  @override
  String get vehiclesNameHint => 'পালসার';

  @override
  String get vehiclesMake => 'ব্র্যান্ড';

  @override
  String get vehiclesModel => 'মডেল';

  @override
  String get vehiclesYear => 'সাল';

  @override
  String get vehiclesEngine => 'ইঞ্জিন';

  @override
  String get vehiclesRegistration => 'রেজিস্ট্রেশন নম্বর';

  @override
  String get vehiclesRegistrationHint => 'ঢাকা মেট্রো-ল ১২-৩৪৫৬';

  @override
  String get vehiclesUnitsCurrency => 'একক ও মুদ্রা';

  @override
  String get vehiclesCurrency => 'মুদ্রা';

  @override
  String get vehiclesOwnership => 'মালিকানা';

  @override
  String get vehiclesOwnershipExplain =>
      'অবচয় ও প্রকৃত খরচ বের করতে ব্যবহৃত হয়। না চাইলে খালি রাখুন।';

  @override
  String get vehiclesStartingOdometer => 'হিসাব শুরুর সময়ের ওডোমিটার';

  @override
  String get vehiclesTankCapacity => 'ট্যাংকের ধারণক্ষমতা';

  @override
  String get vehiclesPurchaseDate => 'কেনার তারিখ';

  @override
  String get ridesNotFoundTitle => 'যাত্রা পাওয়া যায়নি';

  @override
  String get ridesNotFoundBody => 'সম্ভবত এটি মুছে ফেলা হয়েছে।';

  @override
  String get ridesFallbackTitle => 'যাত্রা';

  @override
  String get mapTitle => 'ম্যাপ';

  @override
  String get mapAllRides => 'সব যাত্রা';

  @override
  String get mapShowMyLocation => 'আমার অবস্থান দেখান';

  @override
  String get mapRecentre => 'আমার অবস্থানে ফিরে যান';

  @override
  String get mapFollowing => 'আপনাকে অনুসরণ করছে — থামাতে ম্যাপ টানুন';

  @override
  String get mapYourLocation => 'আপনার অবস্থান';

  @override
  String get mapDetails => 'বিস্তারিত';

  @override
  String get mapNoRidesHint =>
      'এখনো কোনো যাত্রা নেই — শুরু করলে পথটি এখানেই আঁকা হবে।';

  @override
  String get mapTrackingOffHint =>
      'যাত্রা ট্র্যাকিং বন্ধ। চালু না করা পর্যন্ত কিছুই রেকর্ড হবে না।';

  @override
  String get mapSetUp => 'চালু করুন';

  @override
  String get mapLocationNeeded =>
      'আপনার অবস্থান দেখাতে Jatra-র লোকেশন অনুমতি প্রয়োজন।';

  @override
  String get mapLocationServicesOff => 'এই ফোনে লোকেশন বন্ধ আছে।';

  @override
  String get mapLocationBlocked =>
      'Jatra-র লোকেশন ব্যবহার বন্ধ করা আছে। এটি কেবল অ্যান্ড্রয়েড সেটিংস থেকে চালু করা যাবে।';

  @override
  String get mapTurnOn => 'চালু করুন';

  @override
  String get mapOpenSettings => 'সেটিংস';

  @override
  String get rideCouldNotStart =>
      'Jatra রেকর্ডিং শুরু করতে পারেনি। লোকেশন চালু আছে এবং Jatra-র জন্য অনুমোদিত কিনা দেখুন।';

  @override
  String get ridesDiscardedEmpty => 'যাত্রা বাতিল — কোনো দূরত্ব রেকর্ড হয়নি।';

  @override
  String get ridesDiscardTitle => 'এই যাত্রা বাতিল করবেন?';

  @override
  String get ridesDiscardBody =>
      'রেকর্ড করা পথ ও দূরত্ব মুছে যাবে। এটি আর ফেরানো যাবে না।';

  @override
  String serviceLoggedCount(Object count) {
    return '$countটি লগ করা হয়েছে';
  }

  @override
  String get onboardingMakeHint => 'বাজাজ';

  @override
  String get onboardingOdometerHint => '24180';

  @override
  String get ridesGapOnce =>
      'এই যাত্রার মাঝে একবার রেকর্ডিং থেমেছিল, তাই পথে একটি ফাঁক আছে। ওই ফাঁকের দূরত্ব হিসাবে ধরা হয়নি।';

  @override
  String ridesGapMany(Object count) {
    return 'এই যাত্রার মাঝে $count বার রেকর্ডিং থেমেছিল। ওই ফাঁকগুলোর দূরত্ব হিসাবে ধরা হয়নি।';
  }

  @override
  String get ridesDetails => 'বিস্তারিত';

  @override
  String get ridesStarted => 'শুরু';

  @override
  String get ridesFinished => 'শেষ';

  @override
  String get ridesGpsPoints => 'জিপিএস পয়েন্ট';

  @override
  String get ridesNotes => 'নোট';

  @override
  String mileageDropCauses2(Object causes) {
    return 'সাধারণ কারণ: $causes।';
  }

  @override
  String get serviceLogEdit => 'সার্ভিস সম্পাদনা';

  @override
  String get serviceLogWhatDone => 'কী কাজ হয়েছে';

  @override
  String get serviceLogItem => 'সার্ভিস আইটেম';

  @override
  String get serviceLogItemHelp =>
      'যুক্ত করলে ওই আইটেমের পরবর্তী সময় এগিয়ে যাবে।';

  @override
  String get serviceLogOneOff => 'এককালীন মেরামত';

  @override
  String get serviceLogDescription => 'বিবরণ';

  @override
  String get serviceLogDescriptionHint => 'ইঞ্জিন অয়েল + ফিল্টার';

  @override
  String get serviceLogCost => 'খরচ';

  @override
  String get serviceLogParts => 'যন্ত্রাংশ';

  @override
  String get serviceLogLabour => 'মজুরি';

  @override
  String get serviceLogTotalHelp =>
      'যন্ত্রাংশ ও মজুরি যোগ হয়ে যায়, অথবা মোট বিল লিখুন।';

  @override
  String get serviceLogWorkshop => 'ওয়ার্কশপ';

  @override
  String get serviceLogWorkshopHint => 'রহমান মোটরস, মিরপুর';

  @override
  String get serviceLogPartBrand => 'যন্ত্রাংশের ব্র্যান্ড';

  @override
  String get serviceLogPartBrandHint => 'মতুল 10W-40';

  @override
  String get vehiclesSwitch => 'বাইক বদলান';

  @override
  String get vehiclesManage => 'বাইক ব্যবস্থাপনা';

  @override
  String get mapStart => 'শুরু';

  @override
  String get mapEnd => 'শেষ';

  @override
  String mapScaleAcross(Object distance, Object unit) {
    return '≈ $distance $unit প্রশস্ত';
  }

  @override
  String mapGapCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ফাঁক',
    );
    return '$_temp0';
  }

  @override
  String get backupTitle => 'ব্যাকআপ ও রপ্তানি';

  @override
  String get backupExport => 'রপ্তানি';

  @override
  String get backupExportExplain =>
      'সম্পূর্ণ JSON ব্যাকআপ যেকোনো ডিভাইসে সবকিছু হুবহু ফিরিয়ে আনে।';

  @override
  String get backupIncludeGps => 'যাত্রার জিপিএস তথ্য অন্তর্ভুক্ত করুন';

  @override
  String get backupIncludeGpsExplain =>
      'বন্ধ রাখলে ফাইল ছোট থাকে — সাধারণত কয়েকশ কিলোবাইট। চালু করলে কয়েক দশ মেগাবাইট হতে পারে।';

  @override
  String get backupReadable => 'পাঠযোগ্য বিন্যাস';

  @override
  String get backupReadableExplain => 'বন্ধ রাখলে ফাইল ছোট হয়, তবে পড়া কঠিন।';

  @override
  String get backupExportBackup => 'ব্যাকআপ রপ্তানি';

  @override
  String get backupExportCsv => 'স্প্রেডশিট রপ্তানি (CSV)';

  @override
  String get backupImport => 'আমদানি';

  @override
  String get backupImportExplain =>
      'Jatra কিছু বদলানোর আগে পুরো ফাইল যাচাই করে। কোনো সমস্যা থাকলে কিছুই আমদানি হয় না।';

  @override
  String get backupChooseFile => 'ব্যাকআপ ফাইল বাছুন';

  @override
  String get backupCancelImport => 'আমদানি বাতিল';

  @override
  String get backupContains => 'যা আছে';

  @override
  String get backupNothing => 'কিছুই নেই';

  @override
  String get backupCovers => 'সময়কাল';

  @override
  String get backupExported => 'রপ্তানির তারিখ';

  @override
  String get backupGpsData => 'জিপিএস তথ্য';

  @override
  String get backupIncluded => 'অন্তর্ভুক্ত';

  @override
  String get backupNotIncluded => 'অন্তর্ভুক্ত নয়';

  @override
  String get backupMergeQuestion => 'Jatra কীভাবে এটি যুক্ত করবে?';

  @override
  String get backupReplaceTitle => 'সবকিছু প্রতিস্থাপন করবেন?';

  @override
  String get backupDismiss => 'বন্ধ করুন';

  @override
  String get backupCountBikes => 'বাইক';

  @override
  String get backupCountFills => 'তেল ভরা';

  @override
  String get backupCountServiceItems => 'সার্ভিস আইটেম';

  @override
  String get backupCountServices => 'সার্ভিস';

  @override
  String get backupCountExpenses => 'খরচ';

  @override
  String get backupCountRides => 'যাত্রা';

  @override
  String get backupCountGpsPoints => 'জিপিএস পয়েন্ট';

  @override
  String get onboardingModelHint => 'NS160';

  @override
  String get vehiclesPurchasePrice => 'কেনার দাম';

  @override
  String get vehiclesCurrentValue => 'এখনকার আনুমানিক দাম';

  @override
  String get settingsDeleteAllTitle => 'সবকিছু মুছে ফেলবেন?';

  @override
  String get settingsKeepMyData => 'আমার তথ্য থাক';

  @override
  String get settingsDeleteEverything => 'সবকিছু মুছুন';

  @override
  String get settingsDeleteRoutesTitle => 'সব রেকর্ড করা পথ মুছে ফেলবেন?';

  @override
  String get settingsKeepThem => 'থাক';

  @override
  String get settingsDeleteRoutes => 'পথ মুছুন';

  @override
  String get backupReplaceConfirm => 'সবকিছু প্রতিস্থাপন';

  @override
  String get backupCopyDatabase => 'ডেটাবেস কপি করুন';

  @override
  String get backupRestoreDatabase => 'ডেটাবেস ফাইল পুনরুদ্ধার';

  @override
  String get backupRestoreTitle => 'ডেটাবেস ফাইল পুনরুদ্ধার করবেন?';

  @override
  String get backupPickFile => 'ফাইল বাছুন';

  @override
  String get backupRestoredTitle => 'ডেটাবেস পুনরুদ্ধার হয়েছে';

  @override
  String get vehiclesDepreciationHelp =>
      'খালি রাখলে ⇒ Jatra বছরে ১২% অবচয় ধরে নেয়।';

  @override
  String vehiclesColourN(Object number) {
    return 'রং $number';
  }

  @override
  String get ridesNotificationTitle => 'আপনার যাত্রা রেকর্ড হচ্ছে';

  @override
  String get ridesLocationServiceTitle => 'Jatra আপনার লোকেশন ব্যবহার করছে';

  @override
  String get ridesForegroundNotification =>
      'অ্যাপ ব্যাকগ্রাউন্ডে থাকলেও যাত্রার রেকর্ড চালু রাখে।';

  @override
  String get ridesNotificationPaused => 'যাত্রা থামানো আছে';

  @override
  String get ridesNotificationChannel => 'যাত্রা রেকর্ডিং';

  @override
  String reminderServiceTitle(Object item, Object status) {
    return '$item — $status';
  }

  @override
  String get homeTapForDetails => 'বিস্তারিত দেখতে ট্যাপ করুন';

  @override
  String homeMoreCount(Object count) {
    return '+আরও $countটি';
  }
}

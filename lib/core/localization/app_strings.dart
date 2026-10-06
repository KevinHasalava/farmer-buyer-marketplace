import 'app_settings.dart';

/// All user-facing strings in Sinhala, Tamil and English.
///
/// Usage: `context.tr.getStarted`
class AppStrings {
  const AppStrings(this.lang);

  final AppLanguage lang;

  String _t(String en, String si, String ta) => switch (lang) {
        AppLanguage.english => en,
        AppLanguage.sinhala => si,
        AppLanguage.tamil => ta,
      };

  // ── General ─────────────────────────────────────────────────────────────
  String get appName => 'Farm2Home';
  String get tagline => _t(
        'Fresh from the farm, straight to your home',
        'ගොවිපොළේ සිට නැවුම්ව, ඔබේ නිවසටම',
        'பண்ணையிலிருந்து புதிதாக, நேராக உங்கள் வீட்டிற்கு',
      );
  String get continueBtn => _t('Continue', 'ඉදිරියට', 'தொடரவும்');
  String get next => _t('Next', 'ඊළඟ', 'அடுத்து');
  String get skip => _t('Skip', 'මඟ හරින්න', 'தவிர்');
  String get getStarted => _t('Get Started', 'ආරම්භ කරන්න', 'தொடங்குங்கள்');
  String get language => _t('Language', 'භාෂාව', 'மொழி');
  String get step => _t('Step', 'පියවර', 'படி');
  String get of => _t('of', 'න්', 'இல்');
  String get logout => _t('Log out', 'ඉවත් වන්න', 'வெளியேறு');

  // ── Language selection ──────────────────────────────────────────────────
  String get chooseLanguage => _t(
        'Choose your language',
        'ඔබේ භාෂාව තෝරන්න',
        'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்',
      );
  String get chooseLanguageSub => _t(
        'The whole app will be shown in the language you pick. You can change it anytime.',
        'ඔබ තෝරන භාෂාවෙන් මුළු ඇප් එකම පෙන්වයි. ඕනෑම වේලාවක වෙනස් කළ හැක.',
        'நீங்கள் தேர்ந்தெடுக்கும் மொழியில் முழு செயலியும் காட்டப்படும். எப்போது வேண்டுமானாலும் மாற்றலாம்.',
      );

  // ── Onboarding ──────────────────────────────────────────────────────────
  String get onb1Tag => _t('FARM DIRECT', 'ගොවිබිමෙන්ම සෘජුව', 'நேரடி பண்ணை');
  String get onb1Title => _t(
        'Grown this morning.\nYours by evening.',
        'උදෑසන නෙළාගත් අස්වැන්න.\nසවසට ඔබේ නිවසටම.',
        'காலையில் அறுவடை.\nமாலையில் உங்களிடம்.',
      );
  String get onb1Body => _t(
        'Skip the middleman. Pay the farmer, not the warehouse.',
        'අතරමැදියන් මඟහරින්න. ගබඩාවට නොව, සෘජුවම ගොවියාට ගෙවන්න.',
        'இடைத்தரகர்களைத் தவிர்த்து, விவசாயிக்கு நேரடியாகச் செலுத்துங்கள்.',
      );
  String get onb1ChipA => _t('0% Middlemen', 'අතරමැදියන් නැත', 'இடைத்தரகர் இல்லை');
  String get onb1ChipB => _t('Your price', 'ඔබේම මිල', 'உங்கள் விலை');
  String get onb1ChipC => _t('Instant cash', 'ක්ෂණික මුදල්', 'உடனடி பணம்');
  String get onb1Quote => _t(
        '🌾 "Grown this morning. Yours by evening."',
        '🌾 "උදෑසන නෙළාගත් අස්වැන්න. සවසට ඔබේ නිවසටම."',
        '🌾 "காலையில் அறுவடை. மாலையில் உங்களிடம்."',
      );

  String get onb2Tag => _t('UNDER 24 HOURS', 'පැය 24ක් ඇතුළත', '24 மணி நேரத்திற்குள்');
  String get onb2Title => _t(
        'From soil to doorstep,\novernight.',
        'ගොවිබිමේ සිට දොරකඩට,\nඑක රැයකින්.',
        'மண்ணிலிருந்து வீட்டு வாசலுக்கு,\nஒரே இரவில்.',
      );
  String get onb2Body => _t(
        "Order by 6pm and it's at your door before breakfast.",
        'සවස 6ට පෙර ඇණවුම් කරන්න, උදෑසන ආහාරයට පෙර ඔබේ දොරකඩටම.',
        'மாலை 6 மணிக்குள் ஆர்டர் செய்யுங்கள், காலை உணவுக்கு முன் உங்கள் வாசலில்.',
      );
  String get onb2ChipA => _t('Overnight delivery', 'එක රැයකින් බෙදාහැරීම', 'ஒரே இரவில் டெலிவரி');
  String get onb2ChipB => _t('Farm direct', 'ගොවිබිමෙන්ම', 'பண்ணையிலிருந்து');
  String get onb2ChipC => _t('Before breakfast', 'උදෑසනට පෙර', 'காலை உணவுக்கு முன்');
  String get onb2Quote => _t(
        '🥬 "From soil to doorstep, overnight."',
        '🥬 "ගොවිබිමේ සිට දොරකඩට, එක රැයකින්."',
        '🥬 "மண்ணிலிருந்து வீட்டு வாசலுக்கு, ஒரே இரவில்."',
      );

  String get onb3Tag => _t('FOR DRIVERS', 'රියදුරන් සඳහා', 'ஓட்டுநர்களுக்கு');
  String get onb3Title => _t(
        'Deliver orders,\nearn more',
        'ඇණවුම් භාරදී\nආදායම් උපයන්න',
        'ஆர்டர்களை டெலிவரி செய்து\nவருமானம் ஈட்டுங்கள்',
      );
  String get onb3Body => _t(
        'Accept nearby delivery orders on your own schedule and get paid for every trip.',
        'ඔබට පහසු වේලාවට අසල ප්‍රවාහන ඇණවුම් භාරගෙන, සෑම ගමනකටම ගෙවීම් ලබන්න.',
        'உங்களுக்கு வசதியான நேரத்தில் அருகிலுள்ள ஆர்டர்களை ஏற்று, ஒவ்வொரு பயணத்திற்கும் கட்டணம் பெறுங்கள்.',
      );
  String get onb3ChipA => _t('Flexible hours', 'නිදහස් වේලාවන්', 'நெகிழ்வான நேரம்');
  String get onb3ChipB => _t('Daily payouts', 'දිනපතා ගෙවීම්', 'தினசரி கட்டணம்');
  String get onb3ChipC => _t('Local routes', 'ප්‍රදේශයේ ඇණවුම්', 'உள்ளூர் வழிகள்');
  String get onb3Quote => _t(
        '🚚 "Connecting rural village farmers to buyers with fast transport"',
        '🚚 "ගමේ ගොවියාගේ අස්වැන්න ඉක්මනින් නගරයට ගෙනියන්න"',
        '🚚 "கிராமப்புற விவசாயிகளை வாங்குபவர்களுடன் இணைக்கும் போக்குவரத்து"',
      );

  // ── Role selection ──────────────────────────────────────────────────────
  String get whoAreYou => _t(
        'Choose your role',
        'ඔබේ භූමිකාව තෝරන්න',
        'உங்கள் பங்கைத் தேர்ந்தெடுக்கவும்',
      );
  String get whoAreYouSub => _t(
        'Connecting farmers, buyers, and local drivers across Sri Lanka',
        'ශ්‍රී ලංකාවේ ගොවීන්, ගැණුම්කරුවන් සහ රියදුරන් එකට යා කරන වෙළඳපොළ',
        'இலங்கையின் விவசாயிகள், வாங்குபவர்கள் மற்றும் ஓட்டுநர்களை இணைக்கும் தளம்',
      );
  String get roleSelectHint => _t(
        'SELECT ACCOUNT TYPE',
        'ගිණුම් වර්ගය තෝරන්න',
        'கணக்கு வகையைத் தேர்ந்தெடுக்கவும்',
      );
  String get roleSelectedBadge => _t('SELECTED', 'තෝරා ඇත', 'தேர்ந்தெடுக்கப்பட்டது');
  String get roleTapToSelect => _t('TAP TO SELECT', 'තේරීමට ස්පර්ශ කරන්න', 'தேர்ந்தெடுக்க தட்டவும்');
  String get roleBuyer => _t("I'm Buying", 'මම මිලදී ගන්නවා', 'நான் வாங்குகிறேன்');
  String get roleBuyerTitle => _t("Buyer / Wholesale", 'ගැණුම්කරු (Buyer)', 'வாங்குபவர்');
  String get roleBuyerSub => _t(
        'Buy farm-fresh vegetables, fruits & grains at fair prices',
        'නැවුම් එළවළු, පළතුරු සහ ධාන්‍ය අඩුම මිලට ලබාගන්න',
        'புதிய காய்கறி, பழங்கள் & தானியங்களை நியாய விலையில் பெறுங்கள்',
      );
  String get roleFarmer => _t("I'm Farming", 'මම ගොවිතැන් කරනවා', 'நான் விவசாயம் செய்கிறேன்');
  String get roleFarmerTitle => _t("Farmer / Producer", 'ගොවි මහතා (Farmer)', 'விவசாயி');
  String get roleFarmerSub => _t(
        'Sell your harvest directly without middlemen at your own price',
        'අතරමැදියන් නැතිව ඔබේම මිලට අස්වැන්න කෙළින්ම විකුණන්න',
        'இடைத்தரகர்கள் இன்றி உங்கள் சொந்த விலையில் அறுவடையை விற்கவும்',
      );
  String get roleDriver => _t("I'm Driving", 'මම රිය පදවනවා', 'நான் வாகனம் ஓட்டுகிறேன்');
  String get roleDriverTitle => _t("Logistics / Driver", 'ප්‍රවාහකයා (Driver)', 'ஓட்டுநர்');
  String get roleDriverSub => _t(
        'Accept delivery orders and earn daily income on your schedule',
        'ප්‍රවාහන ඇණවුම් භාරගෙන දිනපතා ස්ථිර ආදායමක් ලබන්න',
        'டெலிவரி ஆர்டர்களை ஏற்று தினசரி வருமானம் பெறுங்கள்',
      );

  // ── Phone / OTP auth ────────────────────────────────────────────────────
  String get enterPhone => _t(
        'Enter your\nmobile number',
        'ඔබේ ජංගම දුරකථන\nඅංකය ඇතුළත් කරන්න',
        'உங்கள் கைபேசி\nஎண்ணை உள்ளிடவும்',
      );
  String get enterPhoneSub => _t(
        "We'll send you a 6-digit code. No password to remember!",
        'අපි ඔබට ඉලක්කම් 6ක කේතයක් එවන්නෙමු. මුරපද මතක තබා ගැනීමට අවශ්‍ය නැත!',
        '6 இலக்க குறியீட்டை அனுப்புவோம். கடவுச்சொல் நினைவில் வைக்க தேவையில்லை!',
      );
  String get phoneLabel => _t('Mobile number', 'ජංගම අංකය', 'கைபேசி எண்');
  String get sendOtp => _t('Send Code', 'කේතය එවන්න', 'குறியீட்டை அனுப்பு');
  String get invalidPhone => _t(
        'Enter a valid Sri Lankan mobile number',
        'වලංගු ශ්‍රී ලංකා ජංගම අංකයක් ඇතුළත් කරන්න',
        'சரியான இலங்கை கைபேசி எண்ணை உள்ளிடவும்',
      );
  String get secureNote => _t(
        'Your number is safe and never shared',
        'ඔබේ අංකය ආරක්ෂිතයි, කිසිවෙකුට ලබා නොදේ',
        'உங்கள் எண் பாதுகாப்பானது, பகிரப்படாது',
      );
  String get enterOtp => _t(
        'Enter the\nverification code',
        'තහවුරු කිරීමේ\nකේතය ඇතුළත් කරන්න',
        'சரிபார்ப்புக்\nகுறியீட்டை உள்ளிடவும்',
      );
  String get otpSentTo => _t('We sent a 6-digit code to', 'ඉලක්කම් 6ක කේතය යැව්වේ', '6 இலக்க குறியீடு அனுப்பப்பட்டது');
  String get verify => _t('Verify', 'තහවුරු කරන්න', 'சரிபார்');
  String get resendIn => _t('Resend code in', 'නැවත එවීමට', 'மீண்டும் அனுப்ப');
  String get resend => _t('Resend code', 'කේතය නැවත එවන්න', 'மீண்டும் அனுப்பு');
  String get changeNumber => _t('Change number', 'අංකය වෙනස් කරන්න', 'எண்ணை மாற்று');
  String get invalidOtp => _t(
        'Invalid code. Please try again.',
        'වැරදි කේතයකි. නැවත උත්සාහ කරන්න.',
        'தவறான குறியீடு. மீண்டும் முயற்சிக்கவும்.',
      );
  String get demoNotice => _t(
        'SMS service is not configured — demo mode. Use code 123456',
        'SMS සේවාව සකසා නැත — පරීක්ෂණ ආකාරය. 123456 කේතය භාවිතා කරන්න',
        'SMS சேவை அமைக்கப்படவில்லை — டெமோ முறை. 123456 குறியீட்டைப் பயன்படுத்தவும்',
      );
  String get yourName => _t(
        'What should\nwe call you?',
        'අපි ඔබව\nහඳුන්වන්නේ කෙසේද?',
        'உங்களை எப்படி\nஅழைக்கலாம்?',
      );
  String get yourNameSub => _t(
        'Just one more step to finish your profile',
        'ඔබේ පැතිකඩ සම්පූර්ණ කිරීමට තවත් එක් පියවරක් පමණි',
        'உங்கள் சுயவிவரத்தை முடிக்க இன்னும் ஒரு படி',
      );
  String get fullName => _t('Full name', 'සම්පූර්ණ නම', 'முழுப் பெயர்');
  String get nameRequired => _t(
        'Please enter your name',
        'කරුණාකර ඔබේ නම ඇතුළත් කරන්න',
        'உங்கள் பெயரை உள்ளிடவும்',
      );
  String get finish => _t('Finish & Continue', 'අවසන් කර ඉදිරියට', 'முடித்து தொடரவும்');
  String get somethingWrong => _t(
        'Something went wrong. Please try again.',
        'යම් දෝෂයක් සිදුවිය. නැවත උත්සාහ කරන්න.',
        'ஏதோ தவறு நடந்தது. மீண்டும் முயற்சிக்கவும்.',
      );

  // ── Driver dashboard ────────────────────────────────────────────────────
  String get hello => _t('Hello', 'ආයුබෝවන්', 'வணக்கம்');
  String get online => _t("You're Online", 'ඔබ සක්‍රීයයි', 'நீங்கள் ஆன்லைனில்');
  String get offline => _t("You're Offline", 'ඔබ අක්‍රීයයි', 'நீங்கள் ஆஃப்லைனில்');
  String get offlineHint => _t(
        'Go online to start receiving delivery orders',
        'ඇණවුම් ලබා ගැනීමට සක්‍රීය වන්න',
        'ஆர்டர்களைப் பெற ஆன்லைனுக்கு வாருங்கள்',
      );
  String get todaysEarnings => _t("Today's earnings", 'අද ආදායම', 'இன்றைய வருமானம்');
  String get trips => _t('Trips', 'ගමන්', 'பயணங்கள்');
  String get distance => _t('Distance', 'දුර', 'தூரம்');
  String get rating => _t('Rating', 'ශ්‍රේණිය', 'மதிப்பீடு');
  String get availableOrders => _t(
        'Available delivery orders',
        'ලබාගත හැකි ප්‍රවාහන ඇණවුම්',
        'கிடைக்கும் டெலிவரி ஆர்டர்கள்',
      );
  String get nearby => _t('nearby', 'අසලින්', 'அருகில்');
  String get pickup => _t('Pickup', 'ලබාගැනීම', 'பிக்அப்');
  String get dropoff => _t('Drop-off', 'භාරදීම', 'டிராப்');
  String get accept => _t('Accept', 'භාරගන්න', 'ஏற்கவும்');
  String get accepted => _t('Accepted', 'භාරගත්තා', 'ஏற்கப்பட்டது');
  String get orderAccepted => _t(
        'Order accepted! Head to the pickup point.',
        'ඇණවුම භාරගත්තා! ලබාගැනීමේ ස්ථානයට යන්න.',
        'ஆர்டர் ஏற்கப்பட்டது! பிக்அப் இடத்திற்குச் செல்லுங்கள்.',
      );
  String get navHome => _t('Home', 'මුල් පිටුව', 'முகப்பு');
  String get navOrders => _t('Orders', 'ඇණවුම්', 'ஆர்டர்கள்');
  String get navEarnings => _t('Earnings', 'ආදායම', 'வருமானம்');
  String get navProfile => _t('Profile', 'පැතිකඩ', 'சுயவிவரம்');
}

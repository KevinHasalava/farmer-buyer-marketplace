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

  // ── General & Common ─────────────────────────────────────────────────────
  String get appName => 'Farm2Home';
  String get tagline => _t(
        'Fresh from the farm, straight to your home',
        'ගොවිපොළේ සිට නැවුම්ව, ඔබේ නිවසටම',
        'பண்ணையிலிருந்து புதிதாக, நேராக உங்கள் வீட்டிற்கு',
      );
  String get continueBtn => _t('Continue', 'ඉදිරියට', 'தொடரவும்');
  String get next => _t('Next', 'ඊළඟ', 'அடுத்து');
  String get skip => _t('Skip', 'මඟ හරින්න', 'தவிර්');
  String get getStarted => _t('Get Started', 'ආරම්භ කරන්න', 'தொடங்குங்கள்');
  String get language => _t('Language', 'භාෂාව', 'மொழி');
  String get step => _t('Step', 'පියවර', 'படி');
  String get of => _t('of', 'න්', 'இல்');
  String get logout => _t('Log out', 'ඉවත් වන්න', 'வெளியேறு');
  String get back => _t('Back', 'ආපසු', 'பின்செல்');
  String get close => _t('Close', 'වසන්න', 'மூடு');
  String get cancel => _t('Cancel', 'අවලංගු කරන්න', 'ரத்து செய்');
  String get save => _t('Save', 'සුරකින්න', 'சேமி');
  String get edit => _t('Edit', 'සංස්කරණය', 'திருத்து');
  String get delete => _t('Delete', 'මකන්න', 'நீக்கு');
  String get apply => _t('Apply', 'යොදන්න', 'பயன்படுத்து');
  String get confirm => _t('Confirm', 'තහවුරු කරන්න', 'உறுதிசெய்');
  String get submit => _t('Submit', 'යොමු කරන්න', 'சமர்ப்பி');
  String get done => _t('Done', 'නිමයි', 'முடிந்தது');
  String get select => _t('Select', 'තෝරන්න', 'தேர்ந்தெடு');
  String get search => _t('Search', 'සොයන්න', 'தேடு');
  String get filter => _t('Filter', 'පෙරහන', 'வடிகட்டி');
  String get seeAll => _t('See All', 'සියල්ල බලන්න', 'அனைத்தும் பார்க்க');
  String get refresh => _t('Refresh', 'නැවුම් කරන්න', 'புதுப்பி');
  String get loading => _t('Loading...', 'පූරණය වෙමින්...', 'ஏற்றுகிறது...');
  String get success => _t('Success', 'සාර්ථකයි', 'வெற்றி');
  String get error => _t('Error', 'දෝෂයක්', 'பிழை');
  String get priceRs => _t('Rs.', 'රු.', 'ரூ.');
  String get qty => _t('Qty', 'ප්‍රමාණය', 'அளவு');
  String get total => _t('Total', 'මුළු එකතුව', 'மொத்தம்');
  String get subtotal => _t('Subtotal', 'උප එකතුව', 'கூட்டுத்தொகை');
  String get deliveryFee => _t('Delivery Fee', 'ප්‍රවාහන ගාස්තුව', 'டெலிவரி கட்டணம்');
  String get freeDelivery => _t('Free Delivery', 'නොමිලේ ප්‍රවාහනය', 'இலவச டெலிவரி');
  String get discount => _t('Discount', 'වට්ටම', 'தள்ளுபடி');
  String get viewDetails => _t('View Details', 'විස්තර බලන්න', 'விவரங்களை பார்க்க');
  String get call => _t('Call', 'අමතන්න', 'அழைக்கவும்');
  String get message => _t('Message', 'පණිවිඩය', 'செய்தி');

  // ── Navigation Items ─────────────────────────────────────────────────────
  String get navHome => _t('Home', 'මුල් පිටුව', 'முகப்பு');
  String get navCategories => _t('Categories', 'කාණ්ඩ', 'வகைகள்');
  String get navOrders => _t('Orders', 'ඇණවුම්', 'ஆர்டர்கள்');
  String get navChat => _t('Chat', 'සංවාද', 'அரட்டை');
  String get navDeliveries => _t('Deliveries', 'බෙදාහැරීම්', 'டெலிவரிகள்');
  String get navEarnings => _t('Earnings', 'ආදායම', 'வருமானம்');
  String get navProfile => _t('Profile', 'පැතිකඩ', 'சுயவிவரம்');
  String get navCart => _t('Cart', 'කරත්තය', 'கூடை');

  // ── Status Labels ────────────────────────────────────────────────────────
  String get statusActive => _t('Active', 'සක්‍රීය', 'செயலில்');
  String get statusPending => _t('Pending', 'තහවුරු කිරීමට නියමිත', 'நிலுவையில்');
  String get statusConfirmed => _t('Confirmed', 'තහවුරු කරන ලදී', 'உறுதிப்படுத்தப்பட்டது');
  String get statusInTransit => _t('In Transit', 'ප්‍රවාහනයේ', 'வழியில்');
  String get statusDelivered => _t('Delivered', 'බෙදාහරින ලදී', 'டெலிவரி செய்யப்பட்டது');
  String get statusCancelled => _t('Cancelled', 'අවලංගුයි', 'ரத்து செய்யப்பட்டது');
  String get statusReadyPickup => _t('Ready for Pickup', 'ලබා ගැනීමට සූදානම්', 'பிக்அப் தயார்');
  String get statusOutOfStock => _t('Out of Stock', 'තොග අවසන්', 'கையிருப்பில் இல்லை');

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
  String get sinhalaName => 'සිංහල';
  String get tamilName => 'தமிழ்';
  String get englishName => 'English';
  String get languageChanged => _t(
        'Language changed successfully',
        'භාෂාව සාර්ථකව වෙනස් කරන ලදී',
        'மொழி வெற்றிகரமாக மாற்றப்பட்டது',
      );

  // ── Authentication ───────────────────────────────────────────────────────
  String get signIn => _t('Sign In', 'ඇතුල් වන්න', 'உள்நுழைக');
  String get signInToYourAccount => _t(
        'Sign in to your account',
        'ඔබගේ ගිණුමට ඇතුල් වන්න',
        'உங்கள் கணக்கில் உள்நுழைக',
      );
  String get enterEmailPassword => _t(
        'Enter your email & password to continue',
        'ඉදිරියට යාමට ඔබගේ විද්‍යුත් තැපෑල සහ මුරපදය ඇතුළත් කරන්න',
        'தொடர உங்கள் மின்னஞ்சல் மற்றும் கடவுச்சொல்லை உள்ளிடவும்',
      );
  String get selectAccountType => _t(
        'SELECT YOUR ACCOUNT TYPE',
        'ගිණුම් වර්ගය තෝරන්න',
        'கணக்கு வகையைத் தேர்ந்தெடுக்கவும்',
      );
  String get buyer => _t('Buyer', 'මිලදී ගන්නා', 'வாங்குபவர்');
  String get farmer => _t('Farmer', 'ගොවියා', 'விவசாயி');
  String get driver => _t('Driver', 'රියදුරු', 'ஓட்டுநர்');
  String get email => _t('Email Address', 'විද්‍යුත් තැපෑල', 'மின்னஞ்சல் முகவரி');
  String get password => _t('Password', 'මුරපදය', 'கடவுச்சொல்');

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
  String get switchRole => _t('Switch Role', 'භූමිකාව වෙනස් කරන්න', 'பங்கை மாற்றவும்');
  String get switchAccountOrLogout => _t(
        'Switch Account or Log Out',
        'ගිණුම මාරු කරන්න හෝ ඉවත් වන්න',
        'கணக்கை மாற்றவும் அல்லது வெளியேறவும்',
      );

  // ── Phone / OTP auth & Login ─────────────────────────────────────────────
  String get signInTitle => _t(
        'Sign in to your account',
        'ඔබගේ ගිණුමට ඇතුල් වන්න',
        'உங்கள் கணக்கில் உள்நுழையவும்',
      );
  String get signInSub => _t(
        'Enter your email & password to continue',
        'ඉදිරියට යාමට විද්‍යුත් තැපෑල සහ මුරපදය ඇතුළත් කරන්න',
        'தொடர உங்கள் மின்னஞ்சல் மற்றும் கடவுச்சொல்லை உள்ளிடவும்',
      );
  String get emailLabel => _t('Email address', 'විද්‍යුත් තැපෑල', 'மின்னஞ்சல் முகவரி');
  String get passwordLabel => _t('Password', 'මුරපදය', 'கடவுச்சொல்');
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

  // ── Buyer Portal ─────────────────────────────────────────────────────────
  String welcomeBuyer(String name) => _t(
        'Welcome, $name 👋',
        'ආයුබෝවන්, $name 👋',
        'வணக்கம், $name 👋',
      );
  String get deliverTo => _t('Deliver to', 'බෙදාහරින්නේ', 'டெலிவரி செய்யுமிடம்');
  String get selectDeliveryLocation => _t(
        'Select Delivery Location',
        'බෙදාහැරීමේ ස්ථානය තෝරන්න',
        'டெலிவரி இடத்தை தேர்ந்தெடுக்கவும்',
      );
  String get searchPlaceholder => _t(
        'Search vegetables, fruits, spices...',
        'එළවළු, පළතුරු, කුළුබඩු සොයන්න...',
        'காய்கறிகள், பழங்கள், மசாலாப் பொருட்களைத் தேடுங்கள்...',
      );
  String get springHarvestFest => _t(
        'SPRING HARVEST FEST',
        'නැවුම් අස්වනු මංගල්‍යය',
        'வசந்தகால அறுவடை திருவிழா',
      );
  String get promoHeadline => _t(
        'Up to 25% Off Fresh\nGreens',
        'නැවුම් පලා වර්ග සඳහා\n25% දක්වා වට්ටම්',
        'புதிய கீரைகளுக்கு\n25% வரை தள்ளுபடி',
      );
  String get promoSub => _t(
        'Hand-cut at dawn from local organic farmers across the valley.',
        'ප්‍රදේශයේ ගොවීන් විසින් උදෑසනම නෙළාගත් නැවුම් කාබනික අස්වැන්න.',
        'உள்ளூர் இயற்கை விவசாயிகளிடமிருந்து அதிகாலையில் அறுவடை செய்யப்பட்டது.',
      );
  String get shopSeasonSpecials => _t(
        'Shop Season Specials',
        'විශේෂ අස්වැන්න මිලදී ගන්න',
        'பருவகால சிறப்புப் பொருட்களை வாங்கவும்',
      );
  String get categories => _t('Categories', 'කාණ්ඩ', 'வகைகள்');
  String get allProduceCategories => _t(
        'All Produce Categories',
        'සියලුම අස්වැන්න කාණ්ඩ',
        'அனைத்து உற்பத்தி வகைகள்',
      );
  String get dailyHarvestDeals => _t(
        'Daily Harvest Deals',
        'දවසේ විශේෂ අස්වනු මිල',
        'தினசரி அறுவடை சலுகைகள்',
      );
  String get popularRightNow => _t(
        'Popular Right Now',
        'ජනප්‍රියම අස්වැන්න',
        'இப்போது பிரபலமானவை',
      );
  String get verifiedFreshPartner => _t(
        'Verified fresh from island-wide partner farms',
        'දිවයින පුරා අපගේ ගොවිපොළවලින් නැවුම්ව සහතිකයි',
        'நாடு முழுவதும் உள்ள பண்ணைகளிலிருந்து புதியது என சரிபார்க்கப்பட்டது',
      );
  String get freshPick => _t('Fresh Pick', 'නැවුම් තේරීම', 'புதிய தேர்வு');
  String get addToCart => _t('Add to Cart', 'කරත්තයට එක් කරන්න', 'கூடையில் சேர்க்க');
  String addedToCart(String item) => _t(
        'Added $item to cart!',
        '$item කරත්තයට එක් කරන ලදී!',
        '$item கூடையில் சேர்க்கப்பட்டது!',
      );
  String get viewCart => _t('View Cart', 'කරත්තය බලන්න', 'கூடையைப் பார்க்க');

  // Produce Categories
  String get categoryVegetables => _t('Vegetables', 'එළවළු', 'காய்கறிகள்');
  String get categoryFruits => _t('Fruits', 'පළතුරු', 'பழங்கள்');
  String get categoryGrains => _t('Grains & Rice', 'ධාන්‍ය සහ සහල්', 'தானியங்கள் & அரிசி');
  String get categorySpices => _t('Spices & Herbs', 'කුළුබඩු සහ ඖෂධ', 'மசாலா மற்றும் மூலிகைகள்');
  String get categoryOrganic => _t('Organic & Traditional', 'කාබනික සහ දේශීය', 'இயற்கை மற்றும் பாரம்பரிய');
  String get categoryDairy => _t('Dairy & Farm Fresh', 'කිරි සහ නැවුම් නිෂ්පාදන', 'பால் & பண்ணை புதியவை');

  // Product Details
  String get productDetails => _t('Product Details', 'නිෂ්පාදන විස්තර', 'தயாரிப்பு விவரங்கள்');
  String get farmOrigin => _t('Farm Origin', 'ගොවිපොළ', 'பண்ணை மூலம்');
  String get harvestedAt => _t('Harvested at', 'නෙළාගත්තේ', 'அறுவடை செய்யப்பட்டது');
  String get freshnessGuarantee => _t(
        '100% Freshness Guarantee',
        '100% නැවුම්බව සහතිකයි',
        '100% புத்துணர்ச்சி உத்தரவாதம்',
      );
  String get buyNow => _t('Buy Now', 'දැන් මිලදී ගන්න', 'இப்போது வாங்கவும்');
  String get reviews => _t('Reviews', 'පාරිභෝගික අදහස්', 'மதிப்புரைகள்');
  String get inStock => _t('In Stock', 'තොග ඇත', 'கையிருப்பில் உள்ளது');

  // Cart & Checkout
  String get myCart => _t('My Cart', 'මගේ කරත්තය', 'என் கூடை');
  String get cartEmpty => _t('Your cart is empty', 'ඔබේ කරත්තය හිස්ය', 'உங்கள் கூடை காலியாக உள்ளது');
  String get cartEmptySub => _t(
        'Explore fresh produce and add items to your cart',
        'නැවුම් එළවළු සහ පළතුරු ඔබේ කරත්තයට එක් කරන්න',
        'புதிய பொருட்களை உங்கள் கூடையில் சேர்க்கவும்',
      );
  String get checkout => _t('Checkout', 'ගෙවීම් වෙත', 'செக்அவுட்');
  String get checkoutDelivery => _t('Checkout & Delivery', 'ඇණවුම සහ බෙදාහැරීම', 'செக்அவுட் & டெலிவரி');
  String get deliveryAddress => _t('DELIVERY ADDRESS', 'බෙදාහැරීමේ ලිපිනය', 'டெலிவரி முகவரி');
  String get contactNumber => _t('CONTACT NUMBER', 'දුරකථන අංකය', 'தொடர்பு எண்');
  String get deliveryMethod => _t('DELIVERY METHOD', 'බෙදාහැරීමේ ක්‍රමය', 'டெலிவரி முறை');
  String get preferredDateTime => _t('PREFERRED DATE & TIME', 'කැමති දිනය සහ වේලාව', 'விருப்பமான தேதி & நேரம்');
  String get paymentMethod => _t('PAYMENT METHOD', 'ගෙවීමේ ක්‍රමය', 'பணம் செலுத்தும் முறை');
  String get orderSummary => _t('Order Summary', 'ඇණවුම් සාරාංශය', 'ஆர்டர் சுருக்கம்');
  String get placeOrder => _t('Place Order', 'ඇණවුම තහවුරු කරන්න', 'ஆர்டரை உறுதிசெய்');
  String get orderPlacedSuccess => _t(
        'Order Placed Successfully!',
        'ඇණවුම සාර්ථකව සිදුකරන ලදී!',
        'ஆர்டர் வெற்றிகரமாக செய்யப்பட்டது!',
      );
  String get orderPlacedSub => _t(
        'Your fresh harvest is confirmed. Our delivery partner will contact you soon.',
        'ඔබේ ඇණවුම තහවුරු කරන ලදී. අපගේ ප්‍රවාහකයා ඔබව ඉක්මනින් අමතනු ඇත.',
        'உங்கள் ஆர்டர் உறுதி செய்யப்பட்டது. டெலிவரி பார்ட்னர் உங்களை விரைவில் தொடர்புகொள்வார்.',
      );

  // Buyer Profile
  String get buyerProfile => _t('Buyer Profile', 'ගැණුම්කරුගේ පැතිකඩ', 'வாங்குபவர் சுயவிவரம்');
  String get consumerHub => _t('Consumer Hub', 'පාරිභෝගික මධ්‍යස්ථානය', 'நுகர்வோர் மையம்');
  String get completedOrders => _t('Completed Orders', 'සම්පූර්ණ කළ ඇණවුම්', 'முடிந்த ஆர்டர்கள்');
  String get directFarmSpend => _t('Direct Farm Spend', 'ගොවීන්ට කෙලින්ම ගෙවූ මුදල', 'நேரடி பண்ணை செலவு');
  String get co2FootprintSaved => _t('CO₂ Footprint Saved', 'ඉතිරි කළ කාබන් ප්‍රමාණය', 'சேமிக்கப்பட்ட CO₂');
  String get weeklyHarvestBox => _t('WEEKLY HARVEST BOX', 'සතිපතා අස්වනු පෙට්ටිය', 'வாராந்திர அறுவடை பெட்டி');
  String get nextFarmDispatch => _t('Next Farm Dispatch', 'ඊළඟ ගොවිපොළ පිටත් කිරීම', 'அடுத்த பண்ணை அனுப்புதல்');
  String get pause => _t('Pause', 'නවත්වන්න', 'இடைநிறுத்து');
  String get resume => _t('Resume', 'නැවත අරඹන්න', 'தொடங்கு');
  String get customize => _t('Customize', 'වෙනස් කරන්න', 'தனிப்பயனாக்கு');
  String get defaultHubAndAddress => _t(
        'DEFAULT DELIVERY HUB & ADDRESS',
        'ප්‍රධාන බෙදාහැරීමේ මධ්‍යස්ථානය සහ ලිපිනය',
        'இயல்புநிலை டெலிவரி மையம் & முகவரி',
      );
  String get buyerFreshnessPromise => _t(
        'Buyer Freshness Promise Active',
        'නැවුම්බව පිළිබඳ පාරිභෝගික පොරොන්දුව',
        'புத்துணர்ச்சி உத்தரவாதம் செயலில்',
      );
  String get freshnessPromiseBody => _t(
        'Zero middleman markup, transparent farm gate price, guaranteed harvest within 24h of morning picking.',
        'අතරමැදි වියදම් නැත, විනිවිද පෙනෙන ගොවිබිම් මිල, උදෑසන නෙළා පැය 24ක් තුළ ඔබේ නිවසටම.',
        'இடைத்தரகர் கட்டணம் இல்லை, வெளிப்படையான பண்ணை விலை, 24 மணி நேரத்திற்குள் புதிய அறுவடை.',
      );
  String get farmDirectWallet => _t('Farm Direct Wallet', 'Farm Direct මුදල් පසුම්බිය', 'பண்ணை நேரடி பணப்பை');
  String get savedDirectFarmers => _t('Saved Direct Farmers', 'සුරැකි ගොවි මහත්වරුන්', 'சேமிக்கப்பட்ட விவசாயிகள்');
  String get orderHistoryFarmDispatch => _t(
        'Order History & Live Farm Dispatch',
        'ඇණවුම් ඉතිහාසය සහ සජීවී ප්‍රවාහනය',
        'ஆர்டர் வரலாறு & நேரடி அனுப்புதல்',
      );
  String get ruralFairTradeCharter => _t(
        'Sri Lanka Rural Direct Fair-Trade Charter',
        'ශ්‍රී ලංකා ග්‍රාමීය සාධාරණ වෙළඳ ප්‍රඥප්තිය',
        'இலங்கை கிராமப்புற நியாய வர்த்தக சாசனம்',
      );
  String get officerHubSupport => _t('Field Officer & Hub Support', 'ක්ෂේත්‍ර නිලධාරී සහ මධ්‍යස්ථාන සහාය', 'கள அதிகாரி & மைய ஆதரவு');
  String get notifications => _t('Notifications', 'දැනුම්දීම්', 'அறிவிப்புகள்');
  String get noNotifications => _t('No notifications yet', 'තවමත් දැනුම්දීම් නොමැත', 'அறிவிப்புகள் எதுவும் இல்லை');
  String get markAllRead => _t('Mark all as read', 'සියල්ල කියවූ ලෙස සලකුණු කරන්න', 'அனைத்தையும் படித்ததாகக் குறிக்கவும்');

  // ── Farmer Portal ────────────────────────────────────────────────────────
  String get farmerDashboard => _t('Farmer Dashboard', 'ගොවි උපකරණ පුවරුව', 'விவசாயி டாஷ்போர்டு');
  String get goodMorning => _t('Good Morning', 'සුභ උදෑසනක්', 'காலை வணக்கம்');
  String get goodAfternoon => _t('Good Afternoon', 'සුභ දහවලක්', 'மதிய வணக்கம்');
  String get goodEvening => _t('Good Evening', 'සුභ සන්ධ්‍යාවක්', 'மாலை வணக்கம்');
  String get farmOverview => _t("Here's your farm overview", 'ඔබගේ ගොවිපොළ දළ විශ්ලේෂණය මෙන්න', 'உங்கள் பண்ணை கண்ணோட்டம் இதோ');
  String get buyerView => _t('Buyer View', 'ගැණුම්කරු පිටුව', 'வாங்குபவர் பார்வை');
  String get activeProducts => _t('Active Products', 'සක්‍රීය නිෂ්පාදන', 'செயலில் உள்ள பொருட்கள்');
  String get newOrders => _t('New Orders', 'නව ඇණවුම්', 'புதிய ஆர்டர்கள்');
  String get completedOrdersFarmer => _t('Completed Orders', 'සම්පූර්ණ කළ ඇණවුම්', 'முடிந்த ஆர்டர்கள்');
  String get thisWeekEarnings => _t('This Week Earnings', 'මෙම සතියේ ආදායම', 'இந்த வார வருமானம்');
  String get quickActions => _t('QUICK ACTIONS', 'ක්ෂණික ක්‍රියා', 'விரைவு நடவடிக்கைகள்');
  String get addProduct => _t('Add Product', 'නිෂ්පාදනයක් එක් කරන්න', 'பொருளைச் சேர்க்க');
  String get myProducts => _t('My Products', 'මගේ නිෂ්පාදන', 'என் பொருட்கள்');
  String get messages => _t('Messages', 'පණිවිඩ', 'செய்திகள்');
  String get recentOrders => _t('Recent Orders', 'මෑත ඇණවුම්', 'சமீபத்திய ஆர்டர்கள்');
  String get incomingOrders => _t('Incoming Orders', 'ලැබුණු ඇණවුම්', 'உள்வரும் ஆர்டர்கள்');
  String get farmerDirectChat => _t('Farmer Direct Chat', 'ගොවි සෘජු සංවාදය', 'விவசாயி நேரடி அரட்டை');
  String get farmerDirectChatSub => _t(
        'Chat directly with verified buyers inquiring about your fresh produce.',
        'ඔබේ නැවුම් අස්වැන්න පිළිබඳ ගැණුම්කරුවන් සමඟ කෙලින්ම කතා කරන්න.',
        'உங்கள் விளைபொருட்களைப் பற்றி வாங்குபவர்களுடன் நேரடியாக உரையாடுங்கள்.',
      );
  String get addNewProduct => _t('+ Add New Product', '+ නව නිෂ්පාදනයක් එක් කරන්න', '+ புதிய பொருளைச் சேர்க்க');
  String get cropName => _t('Crop Name', 'බෝගයේ නම', 'பயிர் பெயர்');
  String get pricePerKg => _t('Price per kg (Rs.)', 'කිලෝවක මිල (රු.)', 'ஒரு கிலோ விலை (ரூ.)');
  String get availableQuantity => _t('Available Stock (kg)', 'පවතින තොගය (කිලෝ)', 'கையிருப்பு அளவு (கிலோ)');
  String get harvestDate => _t('Harvest Date', 'නෙළාගත් දිනය', 'அறுவடை தேதி');
  String get saveProduct => _t('Save Product', 'නිෂ්පාදනය සුරකින්න', 'பொருளைச் சேமிக்கவும்');

  // ── Driver Portal ────────────────────────────────────────────────────────
  String get driverDashboard => _t('Driver Dashboard', 'රියදුරු උපකරණ පුවරුව', 'ஓட்டுநர் டாஷ்போர்டு');
  String get hello => _t('Hello', 'ආයුබෝවන්', 'வணக்கம்');
  String get online => _t("You're Online", 'ඔබ සක්‍රීයයි', 'நீங்கள் ஆன்லைனில்');
  String get offline => _t("You're Offline", 'ඔබ අක්‍රීයයි', 'நீங்கள் ஆஃப்லைனில்');
  String get onDuty => _t('ON DUTY', 'සේවයේ', 'பணியில்');
  String get offDuty => _t('OFF DUTY', 'විවේකයේ', 'விடுப்பில்');
  String get activeShift => _t('Active Shift', 'ක්‍රියාකාරී සේවා මුරය', 'செயலில் உள்ள பணி');
  String get offlineHint => _t(
        'Go online to start receiving delivery orders',
        'ඇණවුම් ලබා ගැනීමට සක්‍රීය වන්න',
        'ஆர்டர்களைப் பெற ஆன்லைனுக்கு வாருங்கள்',
      );
  String get todaysEarnings => _t("Today's earnings", 'අද ආදායම', 'இன்றைய வருமானம்');
  String get netEarnings => _t('Net Earnings', 'ශුද්ධ ආදායම', 'நிகர வருமானம்');
  String get scheduledDeliveries => _t('Scheduled Deliveries', 'නියමිත බෙදාහැරීම්', 'திட்டமிடப்பட்ட டெலிவரிகள்');
  String get deliveredToday => _t('Delivered Today', 'අද භාරදුන් ගණන', 'இன்று டெலிவரி செய்தவை');
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
  String get activeDeliveryMission => _t(
        'ACTIVE DELIVERY MISSION',
        'ක්‍රියාකාරී බෙදාහැරීමේ මෙහෙයුම',
        'செயலில் உள்ள டெலிவரி பணி',
      );
  String get estimatedPayout => _t('Estimated Payout', 'ඇස්තමේන්තුගත ගෙවීම', 'மதிப்பிடப்பட்ட கட்டணம்');
  String get startNavigation => _t('Start Navigation', 'මාර්ගය බලන්න', 'வழிகாட்டுதலைத் தொடங்கு');
  String get verifyPickup => _t('Verify Pickup', 'ලබාගැනීම තහවුරු කරන්න', 'பிக்அப்பை உறுதிசெய்');
  String get startDelivery => _t('Start Delivery', 'ප්‍රවාහනය ආරම්භ කරන්න', 'டெலிவரியைத் தொடங்கு');
  String get completeDelivery => _t('Complete Delivery', 'බෙදාහැරීම අවසන් කරන්න', 'டெலிவரியை முடிக்க');
  String get driverProfile => _t('Driver Profile', 'රියදුරු පැතිකඩ', 'ஓட்டுநர் சுயவிவரம்');
  String get agriTransitPartner => _t(
        'Verified Agri-Transit Partner',
        'සහතිකලත් කෘෂි ප්‍රවාහන සහකරු',
        'சரிபார்க்கப்பட்ட விவசாய போக்குவரத்து பங்குதாரர்',
      );
  String get vehicleSpecs => _t('Vehicle Specs', 'වාහන තොරතුරු', 'வாகன விவரங்கள்');
  String get bankAndPayouts => _t('Bank & Payouts', 'බැංකුව සහ ගෙවීම්', 'வங்கி & கட்டணங்கள்');
  String get withdrawFunds => _t('Withdraw Funds', 'මුදල් ලබාගන්න', 'பணத்தை எடுக்க');
  String get codBalance => _t('Cash on Delivery Balance', 'භාණ්ඩ භාරදී ලබාගත් මුදල්', 'கேஷ் ஆன் டெலிவரி இருப்பு');

  // ── Orders & Chat ────────────────────────────────────────────────────────
  String get ordersAndChat => _t('Orders & Chat', 'ඇණවුම් සහ සංවාද', 'ஆர்டர்கள் & அரட்டை');
  String get orders => _t('Orders', 'ඇණවුම්', 'ஆர்டர்கள்');
  String get chat => _t('Chat', 'සංවාද', 'அரட்டை');
  String get trackOrderLive => _t('Track Order Live', 'සජීවීව ඇණවුම නිරීක්ෂණය', 'நேரலை டிராக்கிங்');
  String get reorderAllItems => _t('Reorder All Items', 'නැවත ඇණවුම් කරන්න', 'மீண்டும் ஆர்டர் செய்க');
  String get searchOrdersOrChats => _t(
        'Search orders or chats...',
        'ඇණවුම් හෝ සංවාද සොයන්න...',
        'ஆர்டர்கள் அல்லது அரட்டையைத் தேடுங்கள்...',
      );
  String get viewAllChats => _t('View All Chats', 'සියලු සංවාද බලන්න', 'அனைத்து அரட்டைகளையும் பார்க்க');
}

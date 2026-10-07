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
  String get home => navHome;
  String get dashboard => _t('Dashboard', 'පාලක පුවරුව', 'டாஷ்போர்டு');
  String get profile => navProfile;

  // ── Status Labels ────────────────────────────────────────────────────────
  String get statusActive => _t('Active', 'සක්‍රීය', 'செயலில்');
  String get active => statusActive;
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
  String get itemsOrdered => _t('Items Ordered', 'ඇණවුම් කළ භාණ්ඩ', 'ஆர்டர் செய்யப்பட்ட பொருட்கள்');
  String get totalPaid => _t('Total Paid', 'ගෙවූ මුළු මුදල', 'செலுத்தப்பட்ட மொத்தம்');
  String get searchChatsPlaceholder => _t('Search chats...', 'සංවාද සොයන්න...', 'அரட்டைகளைத் தேடுங்கள்...');
  String get searchOrdersPlaceholder => _t('Search orders (#ID or item)...', 'ඇණවුම් සොයන්න (#ID හෝ නම)...', 'ஆர்டர்களைத் தேடுங்கள்...');
  String get typeMessagePlaceholder => _t('Type a message...', 'පණිවිඩයක් ලියන්න...', 'செய்தியை தட்டச்சு செய்க...');
  String get onlineNow => _t('Online now', 'දැන් ක්‍රියාකාරීයි', 'ஆன்லைனில் உள்ளார்');
  String get offlineStatus => _t('Offline', 'නොබැඳිව', 'ஆஃப்லைனில்');
  String get contactLabel => _t('Contact:', 'දුරකථනය:', 'தொடர்பு:');
  String get paymentLabel => _t('Payment:', 'ගෙවීම:', 'பணம் செலுத்துதல்:');
  String get deliveryTimeline => _t('DELIVERY TIMELINE', 'බෙදාහැරීමේ කාලරේඛාව', 'டெலிவரி காலவரிசை');
  String get driverAndVehicle => _t('DRIVER & VEHICLE', 'රියදුරු සහ වාහන තොරතුරු', 'ஓட்டுநர் & வாகனம்');
  String get callDriver => _t('Call Driver', 'රියදුරු අමතන්න', 'ஓட்டுநரை அழைக்கவும்');
  String get chatDriver => _t('Chat', 'සංවාදය', 'அரட்டை');
  String get estArrival => _t('Est. Arrival:', 'පැමිණෙන වේලාව:', 'வருகை நேரம்:');
  String get freshHarvestOnWay => _t('Fresh Harvest On The Way! 🚚', 'නැවුම් අස්වැන්න රැගෙන එමින් පවතී! 🚚', 'புதிய அறுவடை வழியில் உள்ளது! 🚚');

  // ── Product Details & Actions ────────────────────────────────────────────
  String get directFarmHarvest => _t('Direct Farm Harvest', 'ගොවිබිමෙන්ම සෘජු අස්වැන්න', 'நேரடி பண்ணை அறுவடை');
  String get organicProduceBadge => _t('100% Organic', '100% කාබනික', '100% இயற்கை');
  String get farmDirectProduce => _t('Farm Direct Produce', 'ගොවිපොළෙන් සෘජු නිෂ්පාදන', 'பண்ணை நேரடி உற்பத்தி');
  String get testedPesticideFree => _t('Tested pesticide-free • LKR/Farm Direct', 'කෘමිනාශක තොර බව තහවුරු කළ • ගොවිබිම් සෘජු මිල', 'பூச்சிக்கொல்லி அற்றது என சோதிக்கப்பட்டது • பண்ணை விலை');
  String get verifiedBuyerReviews => _t('verified buyer reviews', 'තහවුරු කළ පාරිභෝගික ඇගයීම්', 'சரிபார்க்கப்பட்ட மதிப்புரைகள்');
  String get availableInStock => _t('available in stock', 'තොග පවතී', 'கையிருப்பில் உள்ளது');
  String get harvestTransparency => _t('HARVEST TRANSPARENCY', 'අස්වනු විනිවිදභාවය', 'அறுவடை வெளிப்படைத்தன்மை');
  String get verifiedOrigin => _t('Verified Origin', 'තහවුරු කළ ගොවිබිම', 'சரிபார்க்கப்பட்ட தோற்றம்');
  String get harvested => _t('HARVESTED', 'නෙළාගත්තේ', 'அறுவடை செய்யப்பட்டது');
  String get dispatchVia => _t('DISPATCH VIA', 'ප්‍රවාහන ක්‍රමය', 'அனுப்பும் முறை');
  String get harvestNotes => _t('Harvest Notes', 'අස්වනු සටහන්', 'அறுவடை குறிப்புகள்');
  String get springWashed => _t('Spring Washed', 'ස්වභාවික ජලයෙන් සේදූ', 'சுத்தமான நீரால் கழுவப்பட்டது');
  String get zeroChemical => _t('Zero Chemical', 'රසායනික ද්‍රව්‍ය නැත', 'இரசாயனமற்றது');
  String get aeratedBox => _t('Aerated Box', 'වාතාශ්‍රය සහිත ඇසුරුම', 'காற்றோட்டமான பெட்டி');
  String get selectedWeight => _t('Selected Weight:', 'තෝරාගත් බර:', 'தேர்ந்தெடுக்கப்பட்ட எடை:');
  String get chatWithFarmer => _t('Chat with Farmer', 'ගොවි මහතා සමඟ කතා කරන්න', 'விவசாயியுடன் அரட்டையடி');
  String get expressMorningDelivery => _t('Express guaranteed morning delivery to Greater Colombo.', 'කොළඹ සහ අවට ප්‍රදේශ සඳහා උදෑසනම කඩිනම් ප්‍රවාහනය සහතිකයි.', 'கொழும்பு மற்றும் சுற்றுப்புறங்களுக்கு அதிகாலை விரைவு டெலிவரி உத்தரவாதம்.');
  String get add => _t('Add', 'එක් කරන්න', 'சேர்க்க');
  String get clear => _t('Clear', 'ඉවත් කරන්න', 'அழி');
  String get clearAll => _t('Clear All', 'සියල්ල මකන්න', 'அனைத்தையும் அழி');

  // ── Product List, Search & Filters ───────────────────────────────────────
  String get sortProducts => _t('Sort Products', 'නිෂ්පාදන පෙළගස්වන්න', 'தயாரிப்புகளை வரிசைப்படுத்து');
  String get sortHarvestsBy => _t('Sort Harvests By', 'අස්වැන්න පෙළගස්වන්න', 'அறுவடையை வரிசைப்படுத்துக');
  String get priceLowToHigh => _t('Price: Low to High', 'මිල: අඩු සිට වැඩි දක්වා', 'விலை: குறைந்தது முதல் அதிகம்');
  String get priceHighToLow => _t('Price: High to Low', 'මිල: වැඩි සිට අඩු දක්වා', 'விலை: அதிகம் முதல் குறைந்தது');
  String get highestRated => _t('Highest Rated (4.5+ ★)', 'ඉහළම ඇගයීම් ලත් (4.5+ ★)', 'அதிக மதிப்பீடு (4.5+ ★)');
  String get newestHarvestFirst => _t('Newest Harvest First', 'නවතම අස්වැන්න පළමුව', 'புதிய அறுவடை முதலில்');
  String get allPicks => _t('All Picks', 'සියලු අස්වැන්න', 'அனைத்தும்');
  String get underRs400 => _t('Under Rs. 400', 'රු. 400ට අඩු', 'ரூ. 400க்கு கீழ்');
  String get pickedToday => _t('Picked Today', 'අද නෙළාගත්', 'இன்று அறுவடை');
  String get noProduceFound => _t('No produce found matching the criteria', 'තෝරාගත් කොන්දේසිවලට ගැලපෙන අස්වැන්නක් හමු නොවීය', 'பொருந்தக்கூடிய பொருட்கள் எதுவும் கிடைக்கவில்லை');
  String get recentSearchesHeader => _t('RECENT:', 'මෑතකදී සෙවූ:', 'சமீபத்தியவை:');
  String get directFromSriLankanFarmers => _t('Directly from verified Sri Lankan farmers', 'ශ්‍රී ලාංකික ගොවි මහත්වරුන්ගෙන් සෘජුවම', 'இலங்கை விவசாயிகளிடமிருந்து நேரடியாக');
  String get noMiddlemenMarkups => _t('No Middlemen Markups', 'අතරමැදි ලාභ නැත', 'இடைத்தரகர் கூடுதல் கட்டணம் இல்லை');
  String get filtersAndSorting => _t('Filters & Sorting', 'පෙරහන් සහ පෙළගැස්වීම', 'வடிகட்டிகள் & வரிசைப்படுத்துதல்');
  String get filteredHarvests => _t('Filtered Harvests', 'පෙරහන් කළ අස්වැන්න', 'வடிகட்டப்பட்ட அறுவடைகள்');
  String get activeTag => _t('Active', 'සක්‍රීය', 'செயலில்');
  String get resetAll => _t('Reset All', 'සියල්ල යළි සකසන්න', 'அனைத்தையும் மீட்டமை');
  String get zeroWarehousing => _t('ZERO WAREHOUSING: Direct transit directly to you', 'ගබඩා වියදම් නැත: සෘජුවම ඔබේ නිවසටම ප්‍රවාහනය', 'கிடங்கு இல்லை: நேரடியாக உங்களுக்கே டெலிவரி');
  String get guaranteedFresh => _t('Guaranteed Fresh', 'නැවුම්බව සහතිකයි', 'புத்துணர்ச்சி உத்தரவாதம்');
  String get itemsSubtotal => _t('Items Subtotal', 'අයිතම උප එකතුව', 'பொருட்கள் கூட்டுத்தொகை');
  String get farmDirectDeliveryFee => _t('Farm Direct Delivery Fee', 'ගොවිපොළ සෘජු ප්‍රවාහන ගාස්තුව', 'நேரடி பண்ணை டெலிவரி கட்டணம்');
  String get freshPackaging => _t('Fresh Produce Packaging', 'නැවුම් ඇසුරුම්කරණය', 'புதிய உற்பத்தி பேக்கேஜிங்');
  String get free => _t('Free', 'නොමිලේ', 'இலவசம்');
  String get allLeviesIncluded => _t('incl. all agricultural levies', 'සියලු ගාස්තු ඇතුළත්ව', 'அனைத்து வரிகளும் உட்பட');
  String get editDeliveryAddress => _t('Edit Delivery Address', 'බෙදාහැරීමේ ලිපිනය සංස්කරණය', 'டெலிவரி முகவரியை மாற்று');
  String get editContactNumber => _t('Edit Contact Number', 'දුරකථන අංකය සංස්කරණය', 'தொடர்பு எண்ணை மாற்று');
  String get saveAddress => _t('Save Address', 'ලිපිනය සුරකින්න', 'முகவரியை சேமி');
  String get saveContact => _t('Save Contact Number', 'අංකය සුරකින්න', 'எண்ணை சேமி');
  String get selectTimeSlot => _t('Select Preferred Time Slot', 'කැමති වේලාව තෝරන්න', 'நேரத்தை தேர்ந்தெடுக்கவும்');
  String get directVanDelivery => _t('Direct Van Delivery', 'කඩිනම් වෑන් රථ බෙදාහැරීම', 'நேரடி வேன் டெலிவரி');
  String get ecoBikeCourier => _t('Eco Bike Courier', 'පරිසර හිතකාමී යතුරුපැදි කුරියර්', 'பைக் கூரியர்');
  String get farmPickup => _t('Farm Pickup', 'ගොවිපොළෙන්ම ලබාගැනීම', 'பண்ணை பிக்அப்');
  String get cashOnDelivery => _t('Cash on Delivery', 'භාණ්ඩ ලැබුණු පසු මුදල් ගෙවීම (COD)', 'பொருளை பெற்று பணம் செலுத்துதல்');
  String get onlineBankTransfer => _t('Online Bank Transfer / QR', 'බැංකු හුවමාරුව / QR', 'வங்கி பரிமாற்றம் / QR');
  String get visaMastercard => _t('Visa / Mastercard', 'වීසා / මාස්ටර් කාඩ්පත්', 'விசா / மாஸ்டர்கார்டு');
  String get viewOrders => _t('View Orders', 'ඇණවුම් බලන්න', 'ஆர்டர்களை பார்க்க');
  String get trackOrder => _t('Track Order', 'ඇණවුම නිරීක්ෂණය', 'ஆர்டரை கண்காணிக்க');
  String get orderId => _t('Order ID', 'ඇණවුම් අංකය', 'ஆர்டர் எண்');

  // ── Farmer Portal ────────────────────────────────────────────────────────
  String get allProducts => _t('All Products', 'සියලු නිෂ්පාදන', 'அனைத்து பொருட்கள்');
  String get outOfStock => _t('Out of Stock', 'තොග අවසන්', 'கையிருப்பில் இல்லை');
  String get bestseller => _t('Bestseller', 'වැඩිපුරම අලෙවි වන', 'அதிகம் விற்பனையாகும்');
  String get organicCertified => _t('Organic Certified', 'කාබනික සහතිකලත්', 'இயற்கை சான்றளிக்கப்பட்டது');
  String get deleteProductTitle => _t('Delete Product', 'නිෂ්පාදනය මකන්න', 'பொருளை நீக்கு');
  String get location => _t('Location', 'ස්ථානය', 'இடம்');
  String get description => _t('Description', 'විස්තරය', 'விளக்கம்');
  String get farmerProfile => _t('Farmer Profile', 'ගොවි මහතාගේ පැතිකඩ', 'விவசாயி சுயவிவரம்');
  String get experience => _t('Experience', 'පළපුරුද්ද', 'அனுபவம்');
  String get harvestFromFarmer => _t('Harvest From This Farmer', 'මෙම ගොවිපොළේ අස්වැන්න', 'இப்பண்ணையின் அறுவடை');

  // ── Driver Portal ────────────────────────────────────────────────────────
  String get baseHaulRate => _t('Base Haul Rate', 'මූලික ප්‍රවාහන ගාස්තුව', 'அடிப்படை கட்டணம்');
  String get mountainTransitAllowance => _t('Mountain Transit Allowance', 'කඳුකර ප්‍රවාහන දීමනාව', 'போக்குவரத்து படி');
  String get totalDriverEarning => _t('Total Driver Earning', 'රියදුරු මුළු ඉපැයීම', 'மொத்த வருமானம்');
  String get creditedUponDelivery => _t('Credited upon delivery verification', 'බෙදාහැරීම තහවුරු කළ පසු බැර කෙරේ', 'டெலிவரிக்கு பின் வரவு வைக்கப்படும்');
  String get driverFee => _t('Driver Fee', 'රියදුරු ගාස්තුව', 'ஓட்டுநர் கட்டணம்');
  String get deliveryDetails => _t('Delivery Details', 'බෙදාහැරීමේ විස්තර', 'டெலிவரி விவரங்கள்');
  String get navigateToFarm => _t('Navigate to Farm', 'ගොවිපොළ වෙත සංචලනය', 'பண்ணைக்கு செல்லவும்');
  String get roleDriverTag => _t('DRIVER', 'රියදුරු', 'ஓட்டுநர்');
  String get manifestAlerts => _t('Manifest & Dispatch Alerts', 'ඇණවුම් සහ ප්‍රවාහන දැනුම්දීම්', 'அறிவிப்புகள்');
  String get manifestAlertsSub => _t('Pickup run sequencing & cargo verification', 'භාණ්ඩ ලබාගැනීම සහ සත්‍යාපනය', 'சரிபார்ப்பு');
  String get markAllAsRead => _t('Mark All as Read', 'සියල්ල කියවූ බව සලකුණු කරන්න', 'அனைத்தையும் வாசித்ததாகக் குறிக்கவும்');
  String get callNow => _t('Call Now', 'දැන් අමතන්න', 'இப்போது அழைக்கவும்');
  String callPerson(String person) => _t('Call $person', '$person අමතන්න', '$person அழைக்கவும்');
  String orderDetailsId(String id) => _t('Order $id Details', '$id ඇණවුමේ විස්තර', 'ஆர்டர் $id விவரங்கள்');
  String orderScheduledNotice(String dateTime) => _t(
        'Your fresh farm produce is scheduled for delivery on $dateTime. You can track the status live.',
        'ඔබගේ නැවුම් ගොවිපොළ අස්වැන්න $dateTime දින බෙදාහැරීමට නියමිතයි. ඔබට එහි ප්‍රගතිය සජීවීව නිරීක්ෂණය කළ හැකිය.',
        'உங்கள் புதிய பண்ணை விளைபொருட்கள் $dateTime அன்று டெலிவரி செய்ய திட்டமிடப்பட்டுள்ளது. நேரலையில் கண்காணிக்கலாம்.',
      );
  String get selectPreferredLanguage => _t(
        'SELECT YOUR PREFERRED LANGUAGE',
        'ඔබ කැමති භාෂාව තෝරන්න',
        'விருப்பமான மொழியைத் தேர்ந்தெடுக்கவும்',
      );
  String get assignedDeliveries => _t('Assigned Deliveries', 'භාරදුන් බෙදාහැරීම්', 'ஒதுக்கப்பட்ட டெலிவரிகள்');
  String get activeManifest => _t('ACTIVE MANIFEST', 'ක්‍රියාකාරී ඇණවුම් ලැයිස්තුව', 'செயலில் உள்ள பட்டியல்');
  String get optimizedRoute => _t('OPTIMIZED ROUTE: Highland Express Corridor', 'විශේෂ ප්‍රවාහන මාර්ගය: කඳුකර අධිවේගී තීරය', 'உகந்த பாதை: மலைப்பாதை எக்ஸ்பிரஸ்');
  String get readyForPickup => _t('Ready for Pickup', 'ලබා ගැනීමට සූදානම්', 'பிக்அப் தயார்');
  String get enRoutePickup => _t('En Route to Pickup', 'ලබාගැනීම සඳහා ගමන් කරමින්', 'பிக்அப் நோக்கி பயணிக்கிறது');
  String get inTransit => _t('In Transit', 'ප්‍රවාහනයේ පවතී', 'வழியில் உள்ளது');
  String get viewRoute => _t('View Route', 'මාර්ගය බලන්න', 'பாதையை பார்க்க');
  String get startPickupRoute => _t('Start Pickup Route', 'ලබාගැනීමේ ගමන අරඹන්න', 'பிக்அப் பயணத்தைத் தொடங்கு');
  String get confirmLoadCargo => _t('Confirm & Load Cargo', 'තහවුරු කර භාණ්ඩ පටවන්න', 'சரக்கை ஏற்றுவதை உறுதிசெய்');
  String get cargoManifest => _t('Cargo Manifest', 'පටවන ලද භාණ්ඩ විස්තරය', 'சரக்கு பட்டியல்');
  String get pickupFromFarmer => _t('Pickup from Farmer', 'ගොවි මහතාගෙන් ලබාගැනීම', 'விவசாயியிடமிருந்து பிக்அப்');
  String get deliverToBuyer => _t('Deliver to Buyer', 'ගැණුම්කරු වෙත භාරදීම', 'வாங்குபவருக்கு டெலிவரி');
  String get potentialEarnings => _t("Today's Potential Earnings", 'අද උපයාගත හැකි මුදල', 'இன்றைய சாத்தியமான வருமானம்');
  String get pickupVerification => _t('Pickup Verification', 'ලබාගැනීම තහවුරු කිරීම', 'பிக்அப் சரிபார்ப்பு');
  String get deliveryCompleted => _t('Delivery Completed!', 'බෙදාහැරීම සාර්ථකව අවසන්!', 'டெலிவரி முடிந்தது!');

  // ── Auth & Account Navigation ────────────────────────────────────────────
  String get dontHaveAccount => _t("Don't have an account? ", 'ගිණුමක් නැද්ද? ', 'கணக்கு இல்லையா? ');
  String get registerAsBuyer => _t('Register as Buyer', 'ගැණුම්කරුවෙකු ලෙස ලියාපදිංචි වන්න', 'வாங்குபவராக பதிவு செய்க');
  String get registerAsFarmer => _t('Register as Farmer', 'ගොවි මහතෙකු ලෙස ලියාපදිංචි වන්න', 'விவசாயியாக பதிவு செய்க');
  String get registerAsDriver => _t('Register as Driver', 'රියදුරෙකු ලෙස ලියාපදිංචි වන්න', 'ஓட்டுநராக பதிவு செய்க');
  String get mobileOtpInstead => _t('Sign in with Mobile OTP instead', 'ජංගම OTP මඟින් ඇතුල් වන්න', 'மொபைல் OTP மூலம் உள்நுழைக');
  String get skipDemoUser => _t('Skip & Explore as Demo User', 'පරීක්ෂණ ආකාරයෙන් ඉදිරියට යන්න', 'டெமோ பயனராக தொடர்க');
  String get orDivider => _t('OR', 'හෝ', 'அல்லது');
  String get alreadyHaveAccount => _t('Already have an account? ', 'දැනටමත් ගිණුමක් තිබේද? ', 'ஏற்கனவே கணக்கு உள்ளதா? ');
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
  String get pricePerKg => _t('Price per Kg (Rs.)', 'කිලෝවක මිල (රු.)', 'ஒரு கிலோ விலை (ரூ.)');
  String get availableQuantity => _t('Available Quantity (kg)', 'පවතින ප්‍රමාණය (කිලෝ)', 'கையிருப்பு அளவு (கிலோ)');
  String get harvestDate => _t('Harvest Date', 'නෙළාගත් දිනය', 'அறுவடை தேதி');
  String get saveProduct => _t('Save Product', 'නිෂ්පාදනය සුරකින්න', 'பொருளைச் சேமிக்கவும்');
  String get deleteProductQuestion => _t('Delete Product?', 'නිෂ්පාදනය මකන්නද?', 'பொருளை நீக்கவா?');
  String deleteProductConfirm(String name) => switch (lang) {
        AppLanguage.english => 'Are you sure you want to delete "$name"? This action cannot be undone.',
        AppLanguage.sinhala => '"$name" මකා දැමීමට ඔබට විශ්වාසද? මෙම ක්‍රියාව ආපසු හැරවිය නොහැක.',
        AppLanguage.tamil => '"$name" ஐ நீக்க விரும்புகிறீர்களா? இந்த செயலை மாற்ற முடியாது.',
      };
  String productUpdated(String name) => switch (lang) {
        AppLanguage.english => '$name updated successfully!',
        AppLanguage.sinhala => '$name සාර්ථකව යාවත්කාලීන විය!',
        AppLanguage.tamil => '$name வெற்றிகரமாக புதுப்பிக்கப்பட்டது!',
      };
  String productAdded(String name) => switch (lang) {
        AppLanguage.english => '$name added to your products!',
        AppLanguage.sinhala => '$name ඔබේ නිෂ්පාදනවලට එක් කරන ලදී!',
        AppLanguage.tamil => '$name உங்கள் பொருட்களில் சேர்க்கப்பட்டது!',
      };
  String get selectProductPhoto => _t('Select Product Photo', 'නිෂ්පාදන ඡායාරූපය තෝරන්න', 'பொருள் புகைப்படத்தைத் தேர்ந்தெடுக்கவும்');
  String get category => _t('Category', 'වර්ගය', 'வகை');
  String get organic => _t('Organic', 'කාබනික', 'இயற்கை');
  String get fresh => _t('Fresh', 'නැවුම්', 'புதிய');
  String get productName => _t('Product Name', 'නිෂ්පාදනයේ නම', 'பொருளின் பெயர்');
  String get available => _t('Available', 'ලබාගත හැකි', 'கிடைக்கக்கூடிய');
  String get farmerRole => _t('Small-Scale Farmer', 'සුළු පරිමාණ ගොවි', 'சிறு அளவிலான விவசாயி');
  String get noProductsFound => _t('No Products Found', 'නිෂ්පාදන හමු නොවීය', 'பொருட்கள் எதுவும் கிடைக்கவில்லை');
  String get noProductsFilter => _t('There are no products matching this filter.', 'මෙම පෙරහනට ගැලපෙන නිෂ්පාදන නොමැත.', 'இந்த வடிப்பானுடன் பொருந்தக்கூடிய பொருட்கள் எதுவும் இல்லை.');
  String get markOutOfStock => _t('Mark Out of Stock', 'තොග අවසන් ලෙස සලකුණු කරන්න', 'கையிருப்பில் இல்லை என குறிக்கவும்');
  String get markActive => _t('Mark as Active', 'සක්‍රීය ලෙස සලකුණු කරන්න', 'செயலில் உள்ளது என குறிக்கவும்');
  String get addPhoto => _t('Add Photo', 'ඡායාරූපයක් එක් කරන්න', 'புகைப்படம் சேர்க்க');
  String get addEditProduct => _t('Add/Edit Product', 'නිෂ්පාදනය එක් කරන්න/සංස්කරණය කරන්න', 'பொருளைச் சேர்க்கவும்/திருத்தவும்');
  String get productNotificationSettings => _t('Product notification settings', 'නිෂ්පාදන දැනුම්දීම් සැකසුම්', 'பொருள் அறிவிப்பு அமைப்புகள்');
  String get editProduct => _t('Edit Product', 'නිෂ්පාදනය සංස්කරණය කරන්න', 'பொருளைத் திருத்தவும்');
  String get noProductAlerts => _t('No new product alerts', 'නව නිෂ්පාදන ඇඟවීම් නොමැත', 'புதிய பொருள் எச்சரிக்கைகள் இல்லை');

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

  // ── Missing Roles & Auth ────────────────────────────────────────────────
  String get householdRole => _t('Household', 'ගෘහස්ථ / පාරිභෝගික', 'வீட்டுப் பயன்பாடு');
  String get producerRole => _t('Producer', 'නිෂ්පාදක / ගොවි', 'உற்பத்தியாளர்');
  String get transitRole => _t('Transit', 'ප්‍රවාහක / රියදුරු', 'போக்குவரத்து');
  String get invalidEmail => _t('Enter a valid email', 'වලංගු විද්‍යුත් තැපෑලක් ඇතුළත් කරන්න', 'சரியான மின்னஞ்சலை உள்ளிடவும்');
  String get passwordMinLength => _t('Min. 6 characters', 'අවම වශයෙන් අක්ෂර 6ක්', 'குறைந்தது 6 எழுத்துக்கள்');
  String get emailNoticeTitle => _t('Notice', 'දැනුම්දීම', 'அறிவிப்பு');
  String get emailNoticeBody => _t('Supabase free tier limits confirmation emails to 3 per hour.', 'තහවුරු කිරීමේ ඊමේල් සීමාව පැයකට 3කි.', 'மின்னஞ்சல் உறுதிப்படுத்தல் வரம்பு மணிக்கு 3 மட்டுமே.');
  String get emailNoticeTip => _t('💡 Tip: You can continue directly without email verification for testing.', '💡 උපදෙස: පරීක්ෂා කිරීම සඳහා ඊමේල් තහවුරු කිරීමකින් තොරව කෙලින්ම ඇතුළු විය හැක.', '💡 குறிப்பு: சோதனைக்கு மின்னஞ்சல் உறுதிப்படுத்தல் தேவையில்லை.');
  String get enterDirectlyPrompt => _t('Would you like to enter directly into the app now?', 'ඔබට දැන් කෙලින්ම යෙදුමට ඇතුළු වීමට අවශ්‍යද?', 'இப்போது நேரடியாக செயலியில் நுழைய விரும்புகிறீர்களா?');
  String get continueToApp => _t('Continue to App', 'යෙදුමට පිවිසෙන්න', 'செயலிக்குச் செல்லவும்');
  String get freshDirectHonest => _t('FRESH • DIRECT • HONEST', 'නැවුම් • සෘජු • විශ්වාසනීය', 'புதிய • நேரடி • நேர்மையான');

  // ── Missing Order Filters & Details ──────────────────────────────────────
  String get filterAll => _t('All', 'සියල්ල', 'அனைத்தும்');
  String get filterActive => _t('Active', 'ක්‍රියාකාරී', 'செயலில்');
  String get filterDelivered => _t('Delivered', 'භාරදුන්', 'டெலிவரி செய்தவை');
  String get filterCancelled => _t('Cancelled', 'අවලංගු කළ', 'ரத்து செய்தவை');
  String get liveBadge => _t('● Live', '● සජීවී', '● நேரலை');
  String get reorder => _t('Reorder', 'නැවත ඇණවුම්', 'மீண்டும் ஆர்டர்');
  String get browseMarketplace => _t('Browse Marketplace', 'වෙළඳපොළ පිරික්සන්න', 'சந்தையை உலாவுக');
  String get ordersEmptySub => _t(
        'Your farm-to-table deliveries and active orders will appear here.',
        'ඔබගේ නැවුම් එළවළු බෙදාහැරීම් සහ සක්‍රීය ඇණවුම් මෙහි දිස්වනු ඇත.',
        'உங்கள் டெலிவரிகள் மற்றும் செயலில் உள்ள ஆர்டர்கள் இங்கு தோன்றும்.',
      );
  String get noOrdersFound => _t('No orders found', 'ඇණවුම් කිසිවක් හමු නොවීය', 'ஆர்டர்கள் எதுவும் கிடைக்கவில்லை');
  String noOrdersMatching(String q) => _t(
        'No orders matching ""',
        '"" සඳහා ගැලපෙන ඇණවුම් හමු නොවීය',
        '"" உடன் பொருந்தும் ஆர்டர்கள் எதுவும் இல்லை',
      );
  String dispatchedOnRoute(String addr) => _t(
        'Dispatched · On route to ',
        'පිටත් විය ·  වෙත ගමන් කරමින්',
        'புறப்பட்டது ·  நோக்கி பயணிக்கிறது',
      );
  String get noChatsYet => _t('No conversations yet', 'තවමත් සංවාද නොමැත', 'உரையாடல்கள் எதுவும் இல்லை');
  String noChatsMatching(String q) => _t(
        'No chats matching ""',
        '"" සඳහා ගැලපෙන සංවාද නොමැත',
        '"" உடன் பொருந்தும் அரட்டைகள் இல்லை',
      );
  String get chatsEmptySub => _t(
        'Direct conversations with farmers will show here.',
        'ගොවීන් සමඟ සෘජු සංවාද මෙහි දිස්වනු ඇත.',
        'விவசாயிகளுடனான நேரடி அரட்டைகள் இங்கு தோன்றும்.',
      );
  String get showingAllChats => _t(
        'Showing all active buyer & farmer conversations',
        'සියලු සක්‍රීය ගැණුම්කරු සහ ගොවි සංවාද පෙන්වයි',
        'அனைத்து செயலில் உள்ள அரட்டைகளும் காட்டப்படுகின்றன',
      );
  String get trackingTimeline => _t('TRACKING TIMELINE', 'නිරීක්ෂණ කාලරේඛාව', 'கண்காணிப்பு காலவரிசை');
  String get destinationAndContact => _t('DESTINATION & CONTACT', 'ගමනාන්තය සහ සබඳතා', 'இலக்கு மற்றும் தொடர்பு');
  String get freshHarvestOnTheWay => _t('Fresh Harvest On The Way! 🚚', 'නැවුම් අස්වැන්න රැගෙන එමින් පවතී! 🚚', 'புதிய அறுவடை வழியில் உள்ளது! 🚚');
  String get pickedDirectly => _t(
        'Picked directly from Sunil Perera Farm, Hambantota',
        'හම්බන්තොට සුනිල් පෙරේරා ගොවිපොළෙන් සෘජුවම නෙළාගන්නා ලදී',
        'ஹம்பாந்தோட்டை சுனில் பெரேரா பண்ணையிலிருந்து நேரடியாகப் பறிக்கப்பட்டது',
      );

  // ── Missing Chat Details ─────────────────────────────────────────────────
  String get quickReply1 => _t('Are these freshly harvested?', 'මේවා නැවුම්ව නෙළාගත් ඒවාද?', 'இவை புதிதாக அறுவடை செய்யப்பட்டவையா?');
  String get quickReply2 => _t('Can I get 5kg ready for delivery?', 'මට කිලෝ 5ක් සූදානම් කරගත හැකිද?', 'எனக்கு 5 கிலோ தயார் செய்ய முடியுமா?');
  String get quickReply3 => _t('What time is the farm pickup?', 'ගොවිපොළෙන් ලබාගන්නේ කීයටද?', 'பண்ணையிலிருந்து பிக்அப் எப்போது?');
  String get quickReply4 => _t('Is it 100% organic?', 'මෙය 100% කාබනිකද?', 'இது 100% இயற்கையானதா?');
  String get typeMessageHint => _t('Type a message to the farmer...', 'ගොවියාට පණිවිඩයක් ලියන්න...', 'விவசாயிக்கு செய்தி அனுப்புங்கள்...');
  String get farmerAutoReply => _t(
        'Noted! I will make sure the produce is packed carefully for you.',
        'සටහන් කරගත්තා! ඔබට නැවුම්ව නිෂ්පාදන සූදානම් කර තබන්නෙමි.',
        'குறித்துக் கொண்டேன்! உங்களுக்காக பொருட்கள் கவனமாக பேக் செய்யப்படும்.',
      );

  // ── Missing Buyer Profile & Notifications ────────────────────────────────
  String get editProfileDetails => _t('Edit Profile Details', 'පැතිකඩ තොරතුරු සංස්කරණය', 'சுயவிவர விவரங்களைத் திருத்துக');
  String get editProfile => _t('Edit Profile', 'පැතිකඩ සංස්කරණය', 'சுயவிவரத்தை திருத்துக');
  String get saveChanges => _t('Save Changes', 'වෙනස්කම් සුරකින්න', 'மாற்றங்களைச் சேமி');
  String get verifiedFreshBuyer => _t('Verified Fresh Buyer', 'සහතිකලත් ගැණුම්කරු', 'சரிபார்க்கப்பட்ட வாங்குபவர்');
  String get memberSince => _t('Farm2Home Direct Member since', 'සෘජු සාමාජිකත්වය', 'நேரடி உறுப்பினர் காலம்');
  String get tier => _t('Tier', 'ශ්‍රේණිය', 'நிலை');
  String get direct100 => _t('100% Direct', '100% සෘජු', '100% நேரடி');
  String get zeroMiddleman => _t('0% Middleman', '0% අතරමැදියන්', '0% இடைத்தரகர்கள்');
  String get weeklyHarvestBoxSub => _t(
        'Pre-sorted organic basket delivered weekly.',
        'සතිපතා බෙදාහරින කාබනික එළවළු කූඩය.',
        'வாராந்திர இயற்கை கூடை.',
      );
  String get freshnessPromiseTitle => _t('Buyer Freshness Promise Active', 'නැවුම් බවේ පොරොන්දුව සක්‍රීයයි', 'புத்துணர்ச்சி உறுதிப்பாடு செயலில்');
  String get freshnessPromiseSub => _t(
        'Zero middleman markup, transparent farm gate price, guaranteed harvest within 24h of morning picking.',
        'අතරමැදියන් නැත, විනිවිදභාවය සහිත මිල, පැය 24ක් තුළ නෙළාගත් නැවුම් එළවළු.',
        'இடைத்தரகர் இல்லை, வெளிப்படையான விலை, 24 மணி நேரத்திற்குள் அறுவடை.',
      );
  String get walletSub => _t('Preloaded credits & fair-trade incentives', 'මුදල් ශේෂය සහ සාධාරණ වෙළඳ වරප්‍රසාද', 'முன்பணம் மற்றும் சலுகைகள்');
  String get savedFarmersSub => _t('Favorite local growers', 'ප්‍රියතම ප්‍රාදේශීය ගොවීන්', 'விருப்பமான விவசாயிகள்');
  String get orderHistorySub => _t('View harvest certificates & batch codes', 'නෙළීමේ සහතික සහ කේත බලන්න', 'அறுவடை சான்றிதழ்களைக் காண்க');
  String get fairTradeSub => _t('84% of payment directly to rural growers', 'ගෙවීමෙන් 84%ක් සෘජුවම ගම්බද ගොවීන්ට', '84% தொகை நேரடியாக விவசாயிகளுக்கு');
  String get officerHubSub => _t('24/7 harvest inquiries & order assistance', '24/7 විමසීම් සහ ඇණවුම් සහාය', '24/7 உதவி மற்றும் ஆதரவு');
  String get notificationsTitle => _t('Notifications', 'දැනුම්දීම්', 'அறிவிப்புகள்');
  String get notificationsSub => _t(
        'Real-time updates on harvests, deliveries, and deals.',
        'නෙළීම්, බෙදාහැරීම් සහ දීමනා පිළිබඳ ක්ෂණික තොරතුරු.',
        'அறுவடை மற்றும் டெலிவரி தகவல்கள்.',
      );
  String get liveTransitTracking => _t('Live Transit Tracking', 'සජීවී ප්‍රවාහන නිරීක්ෂණය', 'நேரலை போக்குவரத்து கண்காணிப்பு');
  String get away500m => _t('500m Away', 'මීටර් 500ක් දුරින්', '500 மீ தொலைவில்');
  String get transitRoute => _t('Transit Route:', 'ප්‍රවාහන මාර්ගය:', 'போக்குவரத்து பாதை:');
  String get acknowledgeArrival => _t('Acknowledge Gate Arrival', 'පැමිණීම තහවුරු කරන්න', 'வருகையை உறுதிப்படுத்து');
  String get contactDriver => _t('Contact Driver', 'රියදුරු අමතන්න', 'ஓட்டுநரைத் தொடர்பு கொள்க');
  String get callingDriver => _t('Calling driver...', 'රියදුරු අමතමින්...', 'ஓட்டுநரை அழைக்கின்றது...');

  // ── Missing Cart & Checkout ──────────────────────────────────────────────
  String get clearCart => _t('Clear Cart', 'කරත්තය හිස් කරන්න', 'கூடையை காலியாக்கு');
  String get clearCartDialogTitle => _t('Clear Cart?', 'කරත්තය හිස් කරන්නද?', 'கூடையை காலியாக்கவா?');
  String get clearCartDialogBody => _t(
        'Are you sure you want to remove all items from your cart?',
        'ඔබේ කරත්තයේ ඇති සියලුම ද්‍රව්‍ය ඉවත් කිරීමට ඔබට සහතිකද?',
        'உங்கள் கூடையிலுள்ள அனைத்தையும் நீக்க விரும்புகிறீர்களா?',
      );
  String get shopFreshProduce => _t('Shop Fresh Produce', 'නැවුම් අස්වැන්න මිලදී ගන්න', 'புதிய பொருட்களை வாங்கு');
  String get directRouteTitle => _t('DIRECT ROUTE: Cold chain dispatch within 2h', 'සෘජු ප්‍රවාහනය: පැය 2ක් තුළ ශීතකරණ ප්‍රවාහනය', 'நேரடி பாதை: 2 மணி நேரத்தில் டெலிவரி');
  String get directRouteSub => _t(
        'Zero intermediate warehousing. Direct from farm gate to your doorstep.',
        'මැද ගබඩා කිරීම් නැත. ගොවිපොළෙන් කෙළින්ම ඔබේ දොරකඩට.',
        'இடைத்தரகர் கிடங்கு இல்லை. பண்ணையிலிருந்து நேராக வீட்டிற்கு.',
      );
  String get deliveryFeeLabel => _t('Farm Direct Delivery Fee', 'ගොවිපොළ සෘජු ප්‍රවාහන ගාස්තුව', 'நேரடி பண்ணை டெலிவரி கட்டணம்');
  String get packagingLabel => _t('Fresh Produce Packaging', 'නැවුම් ඇසුරුම්කරණය', 'புதிய உற்பத்தி பேக்கேஜிங்');
  String get inclLevies => _t('incl. all agricultural levies', 'සියලු ගාස්තු ඇතුළත්ව', 'அனைத்து வரிகளும் உட்பட');
  String get co2SavedWholesale => _t(
        '3.2 kg CO₂ saved vs traditional wholesale',
        'සාම්ප්‍රදායික තොග වෙළඳාමට වඩා CO₂ කිලෝ 3.2ක් ඉතිරි විය',
        '3.2 கிலோ CO₂ சேமிக்கப்பட்டது',
      );
  String get impacted => _t('IMPACTED', 'දායකත්වය', 'தாக்கம்');
  String get tomorrowDeliverySlot => _t(
        'Tomorrow Morning Slot (6AM - 9AM)',
        'හෙට උදෑසන (පෙ.ව. 6 - 9)',
        'நாளை காலை (காலை 6 - 9)',
      );
  String get clearCartConfirm => _t(
        'Are you sure you want to remove all items from your cart?',
        'ඔබගේ කරත්තයේ ඇති සියලුම ද්‍රව්‍ය ඉවත් කිරීමට අවශ්‍ය බව විශ්වාසද?',
        'உங்கள் கூடையிலுள்ள அனைத்தையும் நீக்க விரும்புகிறீர்களா?',
      );
  String get co2SavedNotice => _t(
        '3.2 kg CO₂ saved vs traditional wholesale',
        'සාම්ප්‍රදායික තොග වෙළඳාමට වඩා CO₂ කිලෝ 3.2ක් ඉතිරි විය',
        '3.2 கிலோ CO₂ சேமிக்கப்பட்டது',
      );
  String get proceedToCheckout => _t('Proceed to Checkout', 'ගෙවීමට ඉදිරියට යන්න', 'செக்அவுட் தொடரவும்');
  String get checkoutAndDelivery => _t('Checkout & Delivery', 'ගෙවීම සහ බෙදාහැරීම', 'செக்அவுட் & டெலிவரி');
  String get categoriesSubtitle => _t(
        'Direct from 60+ family farms across Sri Lanka',
        'ශ්‍රී ලංකාවේ පවුල් ගොවිපොළ 60+ කින් සෘජුවම',
        'இலங்கையின் 60+ பண்ணைகளிலிருந்து நேரடியாக',
      );
  String get searchCategoriesPlaceholder => _t(
        'Search vegetables, fruits, spices...',
        'එළවළු, පලතුරු, කුළුබඩු සොයන්න...',
        'காய்கறிகள், பழங்கள், மசாலாப் பொருட்களைத் தேடுங்கள்...',
      );

  // ── Missing Driver Portal ────────────────────────────────────────────────
  String get driverOperations => _t('DRIVER OPERATIONS', 'රියදුරු මෙහෙයුම්', 'ஓட்டுநர் செயல்பாடுகள்');
  String get deliveryHistoryStatements => _t('Delivery History & Statements', 'බෙදාහැරීම් ඉතිහාසය සහ වාර්තා', 'டெலிவரி வரலாறு & அறிக்கைகள்');
  String get earningsAndBank => _t('Earnings & Bank Account', 'ආදායම සහ බැංකු ගිණුම', 'வருமானம் & வங்கி கணக்கு');
  String get vehicleDocuments => _t('Vehicle Documents & SL-Transport', 'වාහන ලියකියවිලි සහ ප්‍රවාහන', 'வாகன ஆவணங்கள் & போக்குவரத்து');
  String get notificationsAndAlerts => _t('App Notifications & Highway Alerts', 'දැනුම්දීම් සහ අනතුරු ඇඟවීම්', 'அறிவிப்புகள் & எச்சரிக்கைகள்');
  String get urgentReadyForPickup => _t('Urgent: Ready for Pickup', 'හදිසි: ලබාගැනීමට සූදානම්', 'அவசரம்: பிக்அப்பிற்கு தயார்');
  String get kmAway => _t('2.4 km away', 'කි.මී. 2.4ක් දුරින්', '2.4 கி.மீ தொலைவில்');

  // ── Missing Welcome & Onboarding & Role Meta ─────────────────────────────
  String get ethicalAndDirect => _t('100% ETHICAL & DIRECT', '100% සදාචාරාත්මක සහ සෘජු', '100% நேரடி மற்றும் நியாயமான');
  String get welcomeHeroSub => _t(
        'Fresh from real farmers, directly to your table with guaranteed trust and verified fair pricing.',
        'සැබෑ ගොවීන්ගෙන් නැවුම් අස්වැන්න, විශ්වාසය සහ සාධාරණ මිලක් සමඟින් සෘජුවම ඔබේ මේසයට.',
        'உண்மையான விவசாயிகளிடமிருந்து புதிய விளைபொருட்கள், உத்தரவாதமான விலையில் உங்கள் வீட்டிற்கு.',
      );
  String get enterMobileNumber => _t('ENTER YOUR MOBILE NUMBER', 'ඔබගේ දුරකථන අංකය ඇතුළත් කරන්න', 'உங்கள் மொபைல் எண்ணை உள்ளிடவும்');
  String get enterVerificationCode => _t('ENTER 6-DIGIT VERIFICATION CODE', 'ඉලක්කම් 6ක සත්‍යාපන කේතය ඇතුළත් කරන්න', '6 இலக்க சரிபார்ப்புக் குறியீட்டை உள்ளிடவும்');
  String get enterFullName => _t('ENTER YOUR FULL NAME', 'ඔබගේ සම්පූර්ණ නම ඇතුළත් කරන්න', 'உங்கள் முழுப் பெயரை உள்ளிடவும்');
  String get popular => _t('POPULAR', 'ජනප්‍රිය', 'பிரபலமான');
  String get earn => _t('EARN', 'උපයන්න', 'சம்பாதிக்க');
  String get roleProfile => _t('Role Profile', 'භූමිකාව', 'பயனர் பங்கு');
  String get change => _t('Change', 'වෙනස් කරන්න', 'மாற்றுக');
  String get totalAmount => _t('Total Amount', 'මුළු මුදල', 'மொத்த தொகை');
  String get searchChatsHint => _t('Search chats...', 'සංවාද සොයන්න...', 'அரட்டைகளைத் தேடுங்கள்...');
  String get searchOrdersHint => _t('Search orders (#ID or item)...', 'ඇණවුම් සොයන්න (#ID හෝ නම)...', 'ஆர்டர்களைத் தேடுங்கள்...');
  String get statusProcessing => _t('Harvesting & Packing', 'නෙළීම සහ ඇසිරීම', 'அறுவடை & பேக்கிங்');
  String get contact => _t('Contact', 'සබඳතා', 'தொடர்பු');
  String get regardingItem => _t('Regarding item', 'අදාළ භාණ්ඩය', 'பொருள் தொடர்பாக');
  String get categoryVegetables => _t('Vegetables', 'එළවළු', 'காய்கறிகள்');
  String get categoryFruits => _t('Fruits', 'පලතුරු', 'பழங்கள்');
  String get categoryGrains => _t('Grains & Rice', 'ධාන්‍ය සහ සහල්', 'தானியங்கள் & அரிசி');
  String get categorySpices => _t('Spices & Herbs', 'කුළුබඩු සහ ඖෂධ පැළෑටි', 'மசாலா மற்றும் மூலிகைகள்');
  String get categoryOrganic => _t('Organic & Traditional', 'කාබනික සහ දේශීය', 'இயற்கை & பாரம்பரிய');
  String get phoneNumber => _t('Phone Number', 'දුරකථන අංකය', 'தொலைபேசி எண்');
  String get ecoRoute => _t('Eco Route', 'පරිසර හිතකාමී මාර්ගය', 'சுற்றுச்சூழல் பாதை');
  String get weeklyHarvestBoxPaused => _t('Weekly Harvest Box paused.', 'සතිපතා අස්වනු පෙට්ටිය තාවකාලිකව නැවැත්තුවා.', 'வாராந்திர அறுவடை பெட்டி இடைநிறுத்தப்பட்டது.');
  String get weeklyHarvestBoxActivated => _t('Weekly Harvest Box activated!', 'සතිපතා අස්වනු පෙට්ටිය සක්‍රීය කළා!', 'வாராந்திர அறுවடை பெட்டி செயல்படுத்தப்பட்டது!');
  String get customizingHarvestItems => _t('Customizing your weekly harvest items...', 'ඔබගේ සතිපතා අස්වනු භාණ්ඩ සකසමින් පවතී...', 'உங்கள் வாராந்திர அறுவடை பொருட்களை தனிப்பயனாக்குகிறது...');
  String get walletBalance => _t('Farm Direct Wallet Balance', 'Farm Direct මුදල් ශේෂය', 'பண்ணை நேரடி பணப்பை இருப்பு');
  String get fairTradeCharterTitle => _t('Fair-Trade Charter', 'සාධාරණ වෙළඳ ප්‍රඥප්තිය', 'நியாய வர்த்தக சாசனம்');

  // ── Registration: Farmer ─────────────────────────────────────────────────
  String get producerWelcomeMsg => _t(
        'Your farm is now registered with Farm2Home. Direct payouts & zero middleman commission activated!',
        'ඔබේ ගොවිපොළ Farm2Home සමඟ ලියාපදිංචි විය. සෘජු ගෙවීම් සහ 0% අතරමැදි කොමිස් ක්‍රියාත්මකයි!',
        'உங்கள் பண்ணை Farm2Home இல் பதிவு செய்யப்பட்டுள்ளது. நேரடி கொடுப்பனவுகள் & 0% இடைத்தரகர் கட்டணம் செயல்படுத்தப்பட்டது!',
      );
  String get launchFarmerDashboard => _t('Launch Farmer Dashboard', 'ගොවි උපකරණ පුවරුව අරඹන්න', 'விவசாயி டாஷ்போர்டை தொடங்கவும்');
  String get roleProfileFarmer => _t('Small-Scale Farmer / Producer', 'සුළු පරිමාණ ගොවි / නිෂ්පාදක', 'சிறு விவசாயி / உற்பத்தியாளர்');
  String get farmNameLabel => _t('Farm / Estate Name', 'ගොවිපොළේ නම', 'பண்ணை பெயர்');
  String get nicLabel => _t('National Identity Card (NIC)', 'ජාතික හැඳුනුම්පත් අංකය (NIC)', 'தேசிய அடையாள அட்டை (NIC)');
  String get districtLabel => _t('District', 'දිස්ත්‍රික්කය', 'மாவட்டம்');
  String get agrarianCenterLabel => _t('Agrarian Services Center', 'ගොවිජන සේවා මධ්‍යස්ථානය', 'விவசாய சேவைகள் மையம்');
  String get scaleOfFarmingLabel => _t('Scale of Farming', 'වගා පරිමාණය', 'விவசாய அளவு');
  String get farmingPracticeLabel => _t('Farming Practice', 'වගා ක්‍රමවේදය', 'விவசாய முறை');
  String get primaryCropsLabel => _t('Primary Crops Cultivated', 'ප්‍රධාන වශයෙන් වගා කරන බෝග', 'பயிரிடப்படும் முதன்மை பயிர்கள்');
  String get bankAccountDetailsLabel => _t('Bank Account for Direct Payouts', 'සෘජු ගෙවීම් සඳහා බැංකු ගිණුම', 'நேரடி செலுத்துதலுக்கான வங்கி கணக்கு');
  String get registerFarmBtn => _t('Register Farm & Start Selling', 'ගොවිපොළ ලියාපදිංචි කර විකිණීම අරඹන්න', 'பண்ணையை பதிவு செய்து விற்கத் தொடங்குங்கள்');

  // ── Registration: Driver ─────────────────────────────────────────────────
  String get driverRegistrationTitle => _t('Agri-Transit Driver Registration', 'කෘෂි ප්‍රවාහන රියදුරු ලියාපදිංචිය', 'விவசாய போக்குவரத்து ஓட்டுநர் பதிவு');
  String get driverSubtitle => _t(
        'Connect local farms to urban kitchens. Keep 100% of fair delivery fares with instant daily payouts.',
        'දේශීය ගොවිබිම් නාගරික කුස්සියට සම්බන්ධ කරන්න. දිනපතා ක්ෂණික ගෙවීම් සමඟින් 100% ප්‍රවාහන ගාස්තු ඔබ සතුව තබා ගන්න.',
        'உள்ளூர் பண்ணைகளை இணைக்கவும். தினசரி கொடுப்பனவுகளுடன் 100% டெலிவரி கட்டணத்தை வைத்துக் கொள்ளுங்கள்.',
      );
  String get step1VehicleDetails => _t('Step 1: Vehicle Details', 'පියවර 1: වාහන තොරතුරු', 'படி 1: வாகன விவரங்கள்');
  String get step2CorridorsPayout => _t('Step 2: Corridors & Payout', 'පියවර 2: මාර්ග සහ ගෙවීම්', 'படி 2: பாதைகள் & செலுத்துதல்');
  String get vehicleType => _t('VEHICLE TYPE', 'වාහන වර්ගය', 'வாகன வகை');
  String get vehicleRegNumber => _t('Vehicle Registration Number', 'වාහන ලියාපදිංචි අංකය', 'வாகன பதிவு எண்');
  String get vehicleRegHint => _t('e.g. WP ND-4589', 'උදා. WP ND-4589', 'எ.கா. WP ND-4589');
  String get cargoCapacity => _t('Cargo Capacity (KG)', 'භාණ්ඩ ධාරිතාව (කිලෝ)', 'சரக்கு கொள்ளளவு (கிலோ)');
  String get cargoCapacityHint => _t('e.g. 1200', 'උදා. 1200', 'எ.கா. 1200');
  String get maxPayloadLabel => _t('Max Payload / Capacity Note', 'උපරිම පැටවුම් සටහන', 'அதிகபட்ச சுமை குறிப்பு');
  String get maxPayloadHint => _t('e.g. Insulated crates, fresh produce only', 'උදා. වාතාශ්‍රය සහිත කූඩ, නැවුම් එළවළු පමණි', 'எ.கா. புதிய விளைபொருட்கள் மட்டும்');
  String get coolingCapability => _t('COOLING CAPABILITY', 'ශීතකරණ පහසුකම', 'குளிரூட்டும் வசதி');
  String get chilledBonus => _t('+Rs. 50 bonus per cold-chain delivery', 'සෑම ශීත ප්‍රවාහනයකටම රු. 50 ප්‍රසාද දීමනාවක්', '+ரூ. 50 போனஸ்');
  String get operatingCorridorsLabel => _t('OPERATING CORRIDORS', 'ධාවනය වන මාර්ග', 'செயல்படும் பாதைகள்');
  String get multiSelectPill => _t('Multi-select', 'කිහිපයක් තෝරන්න', 'பல தேர்வு');
  String get payoutAccount => _t('PAYOUT ACCOUNT', 'ගෙවීම් ලැබෙන ගිණුම', 'செலுத்துதல் கணக்கு');
  String get instantDailyPayouts => _t('Instant Daily Payouts', 'දිනපතා ක්ෂණික ගෙවීම්', 'உடனடி தினசரி கொடுப்பනவுகள்');
  String get nextStepVerification => _t(
        'Next step: Quick photo verification of Driving License & Vehicle Revenue papers for instant clearance.',
        'මීළඟ පියවර: කඩිනම් අනුමැතිය සඳහා රියදුරු බලපත්‍රය සහ ආදායම් බලපත්‍රය ඡායාරූප මඟින් තහවුරු කිරීම.',
        'அடுத்த படி: விரைவான அனுமதிக்கான உரிமம் & வாகன ஆவண சரிபார்ப்பு.',
      );
  String get submitApplicationContinue => _t('Submit Application & continue', 'අයදුම්පත ඉදිරිපත් කර ඉදිරියට යන්න', 'விண்ணப்பத்தை சமர்ப்பித்து தொடரவும்');
  String get alreadyRegisteredDriver => _t('Already a registered driver? ', 'දැනටමත් ලියාපදිංචි රියදුරෙක්ද? ', 'ஏற்கனவே பதிவுசெய்த ஓட்டுநரா? ');
  String get driverApprovedTitle => _t('Driver Application Approved!', 'රියදුරු අයදුම්පත අනුමත විය!', 'ஓட்டுநர் விண்ணப்பம் அங்கீகரிக்கப்பட்டது!');
  String get driverApprovedMsg => _t(
        'Your Farm2Home Agri-Transit partner account is ready. 100% delivery fees direct to you!',
        'ඔබගේ Farm2Home කෘෂි ප්‍රවාහන හවුල්කාර ගිණුම සූදානම්. 100% ප්‍රවාහන ගාස්තු සෘජුවම ඔබට ලැබෙනු ඇත!',
        'உங்கள் Farm2Home வேளாண் போக்குவரத்து கூட்டாளர் கணக்கு தயாராக உள்ளது. 100% டெலிவரி கட்டணங்கள் நேரடியாக உங்களுக்கே!',
      );
  String get launchDriverDashboard => _t('Launch Driver Dashboard', 'රියදුරු පාලක පුවරුවට පිවිසෙන්න', 'ஓட்டுநர் டாஷ்போர்டுக்கு செல்க');

  // Vehicle Option Labels & Corridors
  String get chilledVanTitle => _t('Chilled / Refrigerated Van', 'ශීතකරණ වෑන් රථය', 'குளிரூட்டப்பட்ட வேன்');
  String get chilledVanSub => _t('Carrier / ThermoKing equipped', 'Carrier / ThermoKing පහසුකම් සහිතයි', 'Carrier / ThermoKing பொருத்தப்பட்டது');
  String get topEarnerBadge => _t('TOP EARNER', 'වැඩිම ආදායම්', 'அதிக வருவாய்');
  String get cargoVanTitle => _t('Insulated Agro Cargo Van', 'ආවරණය කළ කෘෂි වෑන් රථය', 'வெப்பக்காப்பு வேளாண் வேன்');
  String get cargoVanSub => _t('HiAce / Caravan thermal fit', 'HiAce / Caravan තාප පරිවාරක', 'HiAce / Caravan வெப்ப காப்பு');
  String get lightTruckTitle => _t('Covered Light Truck / Lorry', 'ආවරණය කළ සැහැල්ලු ලොරි රථය', 'மூடப்பட்ட இலகு ரக லாரி');
  String get lightTruckSub => _t('Dimo Batta / Tata Ace Tarpaulin', 'ඩිමෝ බට්ටා / ටාටා ඒස් ටෙන්ට් සහිත', 'டிமோ பட்டா / டாடா ஏஸ்');
  String get tukTukTitle => _t('Three-Wheeler / Cargo Tuk', 'ත්‍රිරෝද රථ / කාර්ගෝ ටුක්', 'முச்சக்கர வண்டி / சரக்கு டக்');
  String get tukTukSub => _t('Urban last-mile agile delivery', 'නගරාශ්‍රිත අවසන් බෙදාහැරීම සඳහා', 'நகர்ப்புற கடைசி மைல் டெலிவரி');

  String get corridorNuwaraEliyaColombo => _t('Nuwara Eliya ⇌ Colombo (A7)', 'නුවරඑළිය ⇌ කොළඹ (A7)', 'நுவரெலியா ⇌ கொழும்பு (A7)');
  String get corridorDambullaColombo => _t('Dambulla ⇌ Colombo (A6)', 'දඹුල්ල ⇌ කොළඹ (A6)', 'தம்புள்ளை ⇌ கொழும்பு (A6)');
  String get corridorKandyColombo => _t('Kandy ⇌ Colombo', 'මහනුවර ⇌ කොළඹ', 'கண்டி ⇌ கொழும்பு');
  String get corridorColomboLocal => _t('Greater Colombo Local Drops', 'කොළඹ තදාසන්න බෙදාහැරීම්', 'கொழும்பு உள்ளூர் டெலிவரிகள்');

  // ── Produce Browsing & Details ───────────────────────────────────────────
  String get itemsAvailableText => _t('items available', 'අයිතම ඇත', 'பொருட்கள் உள்ளன');
  String itemsAvailableCount(int count) => switch (lang) {
        AppLanguage.english => '$count fresh ${count == 1 ? 'item' : 'items'} available',
        AppLanguage.sinhala => 'නැවුම් නිෂ්පාදන $countක් තිබේ',
        AppLanguage.tamil => '$count புதிய பொருட்கள் உள்ளன',
      };
  String get pickedFromPartnerFarms => _t(
        'Picked fresh from local partner farms',
        'දේශීය හවුල්කාර ගොවිපොළවලින් නැවුම්ව නෙළාගත්',
        'உள்ளூர் பண்ணைகளிலிருந்து புதிய அறுவடை',
      );
  String get callFarmer => _t('Call Farmer', 'ගොවි මහතා අමතන්න', 'விவசாயியை அழைக்க');
  String get callBuyer => _t('Call Buyer', 'ගැණුම්කරු අමතන්න', 'வாங்குபவரை அழைக்க');
  String get chatBuyer => _t('Chat Buyer', 'ගැණුම්කරු සමඟ කතාබස්', 'வாங்குபவருடன் அரட்டையடிக்க');
  String get noProductsMatch => _t('No Products Match This Selection', 'මෙම තේරීමට ගැලපෙන නිෂ්පාදන හමු නොවීය', 'பொருந்தக்கூடிய தயாரிப்புகள் இல்லை');
  String get tryResettingFilters => _t('Try resetting your active filters or choosing another category.', 'පෙරහන් යළි සකසා වෙනත් කාණ්ඩයක් තෝරා බලන්න.', 'வடிகட்டிகளை மீட்டமைக்க அல்லது மற்றொரு வகையைத் தேர்ந்தெடுக்கவும்.');
  String get showAllProduce => _t('Show All Produce', 'සියලු අස්වැන්න පෙන්වන්න', 'அனைத்து பொருட்களையும் காட்டு');
  String verifiedBuyerReviewsCount(int count) => switch (lang) {
        AppLanguage.english => '$count verified buyer reviews',
        AppLanguage.sinhala => 'තහවුරු කළ ගැනුම්කරු සමාලෝචන $countක්',
        AppLanguage.tamil => '$count சரிபார்க்கப்பட்ட வாங்குபவர் மதிப்புரைகள்',
      };
  String get organicPercent => _t('100% Organic', '100% කාබනික', '100% இயற்கை');
  String inStockCount(String count) => switch (lang) {
        AppLanguage.english => '$count in stock',
        AppLanguage.sinhala => 'තොග $count ක් ඇත',
        AppLanguage.tamil => '$count கையிருப்பில் உள்ளது',
      };
  String addedToCartNotice(String name, String price) => switch (lang) {
        AppLanguage.english => 'Added $name ($price) to cart!',
        AppLanguage.sinhala => '$name ($price) කරත්තයට එක් කරන ලදී!',
        AppLanguage.tamil => '$name ($price) கூடையில் சேர்க்கப்பட்டது!',
      };
  String addedQtyProduceNotice(int qty, String unit, String name) => switch (lang) {
        AppLanguage.english => 'Added $qty $unit of $name to cart!',
        AppLanguage.sinhala => '$name $unit $qty ක් කරත්තයට එක් කරන ලදී!',
        AppLanguage.tamil => '$name $qty $unit கூடையில் சேர்க்கப்பட்டது!',
      };

  // ── Driver Deliveries Details & Completion ────────────────────────────────
  String get secureHandover => _t('Secure Handover', 'සුරක්ෂිත භාරදීම', 'பாதுகாப்பான ஒப்படைப்பு');
  String get dropoffPhotoVerified => _t('Drop-off photo verified', 'භාරදීමේ ඡායාරූපය තහවුරු විය', 'புகைப்படம் சரிபார்க்கப்பட்டது');
  String get tripPayout => _t('TRIP PAYOUT', 'ගමන් ගාස්තුව', 'பயணக் கொடுப்பනவு');
  String get dailyWalletTotal => _t('Daily Wallet Total', 'දෛනික මුදල් පසුම්බිය', 'தினசரி பணப்பை மொத்தம்');
  String get deliverySummary => _t('Delivery Summary', 'බෙදාහැරීමේ සාරාංශය', 'டெலிவரி சுருக்கம்');
  String get deliveredTo => _t('Delivered To', 'භාරදුන් ස්ථානය', 'டெலிவரி செய்யப்பட்ட இடம்');
  String get customerRating => _t('Customer Rating', 'පාරිභෝගික ඇගයීම', 'வாடிக்கையாளர் மதிப்பீடு');
  String get buyerRatedInstantly => _t('Buyer rated instantly', 'පාරිභෝගිකයා ක්ෂණිකව ඇගයීය', 'வாங்குபவர் மதிப்பீடு செய்தார்');
  String get takeNextOrder => _t('Back to Deliveries / Take Next Order', 'නැවත බෙදාහැරීම් වෙත / මීළඟ ඇණවුම භාරගන්න', 'டெலிவரிகளுக்கு திரும்பு / அடுத்த ஆர்டர்');
  String get startRouteToFarm => _t('Start Route to Farm (Navigate)', 'ගොවිපොළ වෙත ගමන අරඹන්න (සංචලනය)', 'பண்ணைக்கான பயணத்தைத் தொடங்கு');
  String get resetDemo => _t('Reset Demo', 'නැවත සකසන්න', 'மீட்டமை');
  String get highlandCorridorExpress => _t('Highland Express Corridor', 'කඳුකර අධිවේගී ප්‍රවාහන මාර්ගය', 'மலைநாட்டு விரைவு பாதை');
  String get todaysPotentialEarnings => _t("Today's Potential Earnings", 'අද දින ඇස්තමේන්තුගත ආදායම', 'இன்றைய சாத்தியமான வருமானம்');
  String get enRouteToPickup => _t('En Route to Pickup', 'භාරගැනීමට ගමන් කරමින්', 'ஏற்ற செல்கிறது');
  String get upcomingTurn => _t('UPCOMING TURN', 'මීළඟ හැරවුම', 'அடுத்த திருப்பம்');
  String get arrivalVerified => _t('ARRIVAL VERIFIED', 'පැමිණීම තහවුරු විය', 'வருகை சரிபார்க்கப்பட்டது');
  String get qualityChecklist => _t('Quality Checklist', 'තත්ත්ව පිරික්සුම් ලැයිස්තුව', 'தர சரிபார்ப்பு பட்டியல்');
  String get handoverAuth => _t('Handover Auth', 'භාරදීමේ සත්‍යාපනය', 'ஒப்படைப்பு அங்கீகாரம்');
  String get confirmPickupAndLoad => _t('Confirm Pickup & Load to Van', 'භාරගැනීම තහවුරු කර වෑන් රථයට පටවන්න', 'சரிபார்த்து வேனில் ஏற்றவும்');
  String stepOf(int current, int total) => switch (lang) {
        AppLanguage.english => 'STEP $current OF $total',
        AppLanguage.sinhala => 'පියවර $current / $total',
        AppLanguage.tamil => 'படி $current / $total',
      };
  String get save38Mins => _t('Save 38 mins', 'විනාඩි 38ක් ඉතිරි වේ', '38 நிமிடங்கள் மிச்சம்');
  String get preSortedFarmPickups => _t(
        'Save 38 mins with pre-sorted farm gate pickups',
        'වර්ගීකරණය කළ භාරගැනීම් මඟින් විනාඩි 38ක් ඉතිරි කරගන්න',
        'முன்கூட்டியே வரிசைப்படுத்தியதால் 38 நிமிடங்கள் மிச்சம்',
      );
  String get totalFromCurrentTrips => _t('total from current trips', 'වත්මන් ගමන්වාරවල මුළු එකතුව', 'தற்போதைய பயணங்களின் மொத்தம்');
  String get settlingWallet => _t('Settling Wallet & Deliveries...', 'මුදල් පසුම්බිය සහ බෙදාහැරීම් යාවත්කාලීන වෙමින්...', 'பணப்பை புதுப்பிக்கப்படுகிறது...');
  String get dropoffLocation => _t('Drop-off', 'භාරදෙන ස්ථානය', 'இறக்கும் இடம்');
  String get badgeFreshPick => _t('Fresh Pick', 'නැවුම් තේරීම', 'புதிய தெரிவு');

  // ── Categories & Filtering ────────────────────────────────────────────────
  String get categoryAll => _t('All', 'සියල්ල', 'அனைத்தும்');
  String localizedCategory(String category) {
    if (lang == AppLanguage.english) return category;
    final c = category.toLowerCase().trim();
    if (c == 'all') return lang == AppLanguage.sinhala ? 'සියල්ල' : 'அனைத்தும்';
    if (c.contains('vegetable') || c.contains('veg')) return lang == AppLanguage.sinhala ? 'නැවුම් එළවළු' : 'புதிய காய்கறிகள்';
    if (c.contains('fruit')) return lang == AppLanguage.sinhala ? 'නැවුම් පලතුරු' : 'பழங்கள்';
    if (c.contains('grain') || c.contains('rice')) return lang == AppLanguage.sinhala ? 'ධාන්‍ය සහ සහල්' : 'தானியங்கள் & அரிசி';
    if (c.contains('spice') || c.contains('herb')) return lang == AppLanguage.sinhala ? 'කුළුබඩු සහ ඖෂධ පැළෑටි' : 'மசாலா & மூலிகைகள்';
    if (c.contains('organic') || c.contains('trad')) return lang == AppLanguage.sinhala ? 'කාබනික සහ දේශීය' : 'இயற்கை & பாரம்பரியம்';
    if (c.contains('dairy') || c.contains('fresh')) return lang == AppLanguage.sinhala ? 'කිරි සහ නැවුම් නිෂ්පාදන' : 'பால் & பண்ணை பொருட்கள்';
    if (c.contains('filtered') || c.contains('fresh harvests')) return lang == AppLanguage.sinhala ? 'තෝරාගත් අස්වැන්න' : 'வடிகட்டப்பட்ட அறுவடை';
    return category;
  }

  // ── Filters and Sorting ──────────────────────────────────────────────────
  String get applyFilters => _t('Apply Filters', 'පෙරහන් යොදන්න', 'வடிகட்டிகளைப் பயன்படுத்துග');
  String get showAllCategories => _t('Show All Categories', 'සියලු කාණ්ඩ පෙන්වන්න', 'அனைத்து வகைகளையும் காட்டு');
  String get filterOrCropHint => _t('Filter category or crop name...', 'කාණ්ඩය හෝ බෝගයේ නම සොයන්න...', 'வகை அல்லது பயிர் பெயரைத் தேடுங்கள்...');
  String get specialCertifications => _t('SPECIAL CERTIFICATIONS', 'විශේෂ සහතික කිරීම්', 'சிறப்பு சான்றிதழ்கள்');
  String get freshHarvestOnly => _t('Fresh Harvest Only (Picked < 24h)', 'නැවුම් අස්වැන්න පමණි (< පැය 24)', 'புதிய அறுவடை மட்டும் (< 24 மணி)');
  String get certifiedOrganicOnly => _t('Certified Organic Only', 'සහතික කළ කාබනික පමණි', 'சான்றளிக்கப்பட்ட இயற்கை மட்டும்');
  String get directFarmDispatch => _t('Direct Farm Dispatch Verified', 'ගොවිපොළෙන් සෘජු ප්‍රවාහනය', 'நேரடி பண்ணை அனுப்புதல்');
  String get priceRangeLabel => _t('PRICE RANGE (LKR / KG)', 'මිල පරාසය (රුපියල් / කි.ග්‍රෑ)', 'விலை வரம்பு (ரூபாய் / கி.கி)');
  String get regionProvinceLabel => _t('REGION / PROVINCE', 'කලාපය / පළාත', 'பகுதி / மாகாணம்');
  String get sortByLabel => _t('SORT HARVESTS BY', 'අස්වැන්න පෙළගස්වන්න', 'வரிசைப்படுத்துக');
  String get recentSearches => _t('RECENT SEARCHES', 'මෑතකදී සෙවූ දෑ', 'சமீபத்திய தேடல்கள்');
  String get recentSearchesLabel => _t('RECENT:', 'මෑතකදී:', 'சமீபத்திய:');
  String get searchProduceHint => _t('Search vegetables, fruits, rice or farms...', 'එළවළු, පලතුරු, සහල් හෝ ගොවිපොළවල් සොයන්න...', 'காய்கறிகள், பழங்கள், அரிசி அல்லது பண்ணைகளைத் தேடுங்கள்...');
  String get addToBasket => _t('Add to Basket', 'බාස්කට්ටුවට එක් කරන්න', 'கூடையில் சேர்க்க');
  String get sortDistanceClosest => _t('Distance (Closest Farm First)', 'ආසන්නතම ගොවිපොළ පළමුව', 'அருகிலுள்ள பண்ணை முதலில்');
  String get sortPriceLowToHigh => _t('Price: Low to High', 'මිල: අඩු සිට වැඩි දක්වා', 'விலை: குறைந்தது முதல் அதிகம் வரை');
  String get sortPriceHighToLow => _t('Price: High to Low', 'මිල: වැඩි සිට අඩු දක්වා', 'விலை: அதிகம் முதல் குறைந்தது வரை');
  String get sortHighestRated => _t('Highest Rated (4.5+ ★)', 'ඉහළම ඇගයුම් (4.5+ ★)', 'அதிக மதிப்பீடு (4.5+ ★)');
  String get sortNewestHarvest => _t('Newest Harvest First', 'අලුත්ම අස්වැන්න පළමුව', 'புதிய அறுவடை முதலில்');
  String get sortRecommended => _t('Recommended', 'නිර්දේශිත', 'பரிந்துரைக்கப்பட்டது');
  String get quickFilterAll => _t('All Picks', 'සියලු තේරීම්', 'அனைத்தும்');
  String get quickFilterUnder400 => _t('Under Rs. 400', 'රු. 400ට අඩු', 'ரூ. 400க்கு கீழ்');
  String get quickFilterOrganic => _t('100% Organic', '100% කාබනික', '100% இயற்கை');
  String get quickFilterToday => _t('Picked Today', 'අද නෙළන ලද', 'இன்று பறிக்கப்பட்டது');
  String activeFiltersCountText(int count) => switch (lang) {
        AppLanguage.english => '$count Active',
        AppLanguage.sinhala => '$countක් සක්‍රීයයි',
        AppLanguage.tamil => '$count செயலில்',
      };
  String get harvestedLabel => _t('HARVESTED', 'නෙළාගත් වේලාව', 'அறுவடை செய்யப்பட்டது');
  String get dispatchViaLabel => _t('DISPATCH VIA', 'ප්‍රවාහන මාධ්‍යය', 'அனுப்பும் முறை');
  String get customizingFarmBasket => _t('Customizing Your Farm Basket', 'ඔබේ කෘෂි බාස්කට්ටුව සකසන්න', 'கூடையைத் தனிப்பயனாக்குதல்');
  String get refineHarvestOrigins => _t(
        'Refine harvest origins, organic purity, price per kg, and dispatch hub.',
        'අස්වැන්න ලැබෙන ප්‍රදේශ, කාබනික බව, මිල සහ බෙදාහැරීමේ මධ්‍යස්ථාන තෝරන්න.',
        'தோற்றம், விலை மற்றும் மையங்களை வடிகட்டவும்.',
      );
  String get priceRange => _t('Price Range', 'මිල පරාසය', 'விலை வரம்பு');
  String get minimumPrice => _t('MINIMUM', 'අවම', 'குறைந்தபட்சம்');
  String get maximumPrice => _t('MAXIMUM', 'උපරිම', 'அதிகபட்சம்');
  String get sourcingRegion => _t('Sourcing Region', 'අස්වනු කලාපය', 'ஆதார பகுதி');
  String get harvestStandards => _t('Harvest Standards', 'අස්වනු ප්‍රමිතීන්', 'அறுவடை தரநிலைகள்');
  String get verifiedQualityBadge => _t('Verified quality badge', 'තහවුරු කළ තත්ත්ව සහතිකය', 'சரிபார்க்கப்பட்ட தரம்');
  String get freshHarvestToday => _t('Fresh Harvest Today', 'අද නෙළූ නැවුම් අස්වැන්න', 'இன்றைய புதிய அறுவடை');
  String get pluckedWithin24Hours => _t(
        'Plucked from fields at dawn within 24 hours',
        'පැය 24ක් තුළ කෙතෙන්ම නෙළාගත්',
        '24 மணி நேரத்திற்குள் பறிக்கப்பட்டது',
      );
  String get certifiedOrganicOnlyToggle => _t('100% Certified Organic Only', '100% සහතික කළ කාබනික පමණි', '100% இயற்கை சான்றளிக்கப்பட்டது');
  String get zeroChemicalSprays => _t(
        'Zero synthetic chemical sprays or fertilizers',
        'කෘතිම රසායනික ද්‍රව්‍ය හෝ පොහොර ශුන්‍යයි',
        'இரசாயன உரங்கள் இல்லாதது',
      );
  String get directFarmDispatchToggle => _t('Direct Farm Dispatch', 'ගොවිපොළෙන් සෘජු ප්‍රවාහනය', 'நேரடி பண்ணை அனுப்புதல்');
  String get directColdTransit => _t(
        'Direct cold transit straight to your doorstep',
        'ශීතකරණ ප්‍රවාහනයෙන් කෙළින්ම ඔබේ දොරකඩට',
        'நேரடியாக உங்கள் வீட்டு வாசலுக்கு',
      );
  String get sortResultsBy => _t('Sort Results By', 'ප්‍රතිඵල පෙළගස්වන්න', 'முடிவுகளை வரிசைப்படுத்து');
  String get liveOrdering => _t('Live ordering', 'සජීවී ඇණවුම්', 'நேரலை வரிசை');
  String applyFiltersCount(int count) => switch (lang) {
        AppLanguage.english => 'Apply Filters ($count ${count == 1 ? 'Product' : 'Products'})',
        AppLanguage.sinhala => 'පෙරහන් යොදන්න (නිෂ්පාදන $count)',
        AppLanguage.tamil => 'வடிகட்டிகளைப் பயன்படுத்து ($count தயாரிப்புகள்)',
      };
  String get directlyFromFarmers => _t('Directly from verified Sri Lankan farmers', 'තහවුරු කළ දේශීය ගොවීන්ගෙන් සෘජුවම', 'சரிபார்க்கப்பட்ட விவசாயிகளிடமிருந்து நேரடியாக');
  String get noMiddlemenMarkupsText => _t('No Middlemen Markups', 'අතරමැදි මිල ඉහළ දැමීම් නැත', 'இடைத்தரகர் கூடுதல் கட்டணம் இல்லை');
  String get resetAllFilters => _t('Reset All Filters', 'සියලු පෙරහන් යළි සකසන්න', 'அனைத்து வடிகட்டிகளையும் மீட்டமை');
  String get defaultDeliveryHubAddress => _t('Default Delivery Hub & Address', 'පෙරනිමි බෙදාහැරීමේ මධ්‍යස්ථානය සහ ලිපිනය', 'இயல்புநிலை டெலிவரி மையம் & முகவரி');
  String get regionalDeliveryHub => _t('Regional Delivery Hub', 'ප්‍රාදේශීය බෙදාහැරීමේ මධ්‍යස්ථානය', 'பிராந்திய டெலிவரி மையம்');
  String get deliveryStreetAddress => _t('Delivery Street Address', 'බෙදාහැරීමේ ලිපිනය', 'டெலிவரி முகவரி');
  String get deliveryAddressSaved => _t('Delivery address & hub saved!', 'බෙදාහැරීමේ ලිපිනය සුරකින ලදී!', 'டெலிவரி முகவரி சேமிக்கப்பட்டது!');
  String get updateDeliveryHub => _t('Update Delivery Hub', 'මධ්‍යස්ථානය යාවත්කාලීන කරන්න', 'மையத்தைப் புதுப்பிக்கவும்');
  String get logoutConfirmBody => _t(
        'Are you sure you want to sign out of your Farm2Home buyer account?',
        'ඔබේ Farm2Home ගිණුමෙන් ඉවත් වීමට ඔබට සහතිකද?',
        'உங்கள் Farm2Home கணக்கிலிருந்து வெளியேற விரும்புகிறீர்களா?',
      );
  String get activeCrops => _t('Active Crops', 'ක්‍රියාකාරී බෝග', 'செயலில் உள்ள பயிர்கள்');
  String get onTimeDispatch => _t('On-Time Dispatch', 'නියමිත වේලාවට ප්‍රවාහනය', 'சரியான நேரத்தில் அனுப்புதல்');
  String get directFarmTrace => _t('Direct Farm Trace', 'සෘජු ගොවිබිම් සත්‍යාපනය', 'நேரடி பண்ணை தடம்');
  String get per => _t('Per', 'එකකට', 'ஒன்றுக்கு');
  String get farmFreshGuaranteedBanner => _t(
        '100% Guaranteed Farm Fresh: Guaranteed delivery within 12-24 hours from harvest.',
        '100% නැවුම් ගොවිපොළ අස්වැන්න: නෙළා පැය 12-24ක් තුළ බෙදාහැරීම සහතිකයි.',
        '100% பண்ணை புதியது: அறுவடை செய்த 12-24 மணி நேரத்திற்குள் டெலிவரி.',
      );
  String get noFreshHarvestsFound => _t('No Fresh Harvests Found', 'නැවුම් අස්වනු කිසිවක් හමු නොවීය', 'புதிய அறுவடைகள் எதுவும் கிடைக்கவில்லை');
  String get noFreshHarvestsBody => _t(
        'We could not find any products matching your search or filters. Try adjusting your keywords or clearing active filters.',
        'ඔබේ සෙවුමට ගැළපෙන නිෂ්පාදන හමු නොවීය. පෙරහන් ඉවත් කර හෝ වෙනත් වචන යොදා බලන්න.',
        'உங்கள் தேடலுக்கு ஏற்ப தயாரிப்புகள் எதுவும் கிடைக்கவில்லை. வேறு சொற்களைப் பயன்படுத்தி முயற்சிக்கவும்.',
      );
  String get directFieldLink => _t('DIRECT FIELD LINK • ACTIVE NOW', 'සෘජු ගොවිබිම් සබඳතාව • දැන් සක්‍රීයයි', 'நேரடி பண்ணை இணைப்பு • செயலில் உள்ளது');
  String get topRatedProducer => _t('Top Rated Producer', 'ඉහළම ඇගයුම් නිෂ්පාදක', 'உயர் மதிப்பீடு உற்பத்தியாளர்');
  String get heritageFarming => _t('Heritage Farming', 'පාරම්පරික ගොවිතැන', 'பாரம்பரிய விவசாயம்');
  String get callFarmDirectly => _t('Call Farm Directly', 'ගොවිපොළට සෘජුවම අමතන්න', 'பண்ணையை நேரடியாக அழைக்கவும்');
  String get activeHarvestListings => _t('Active Harvest Listings', 'ක්‍රියාකාරී අස්වනු ලැයිස්තුව', 'செயலில் உள்ள விளைச்சல் பட்டியல்');
  String get harvestedFreshUponOrder => _t(
        'Harvested fresh upon order confirmation',
        'ඇණවුම තහවුරු කළ පසු නැවුම්ව නෙළනු ලැබේ',
        'ஆர்டர் உறுதிப்படுத்திய பின் பறிக்கப்படும்',
      );
  String get ordersFulfilledLabel => _t('Orders Fulfilled', 'සම්පූර්ණ කළ ඇණවුම්', 'நிறைவேற்றப்பட்ட ஆர்டர்கள்');
  String get onTimeOutLabel => _t('On-Time Out', 'නියමිත වේලාවට පිටත්වීම', 'சரியான நேர அனுப்புதல்');
  String get directTraceLabel => _t('Direct Trace', 'සෘජු සත්‍යාපනය', 'நேரடி தடம்');
  String get hakgalaTerroir => _t(
        'HAKGALA TERROIR: Naturally mineral-rich mountain soil',
        'හග්ගල ප්‍රදේශය: ස්වභාවික ඛනිජ සාරවත් කඳුකර පස',
        'ஹக்கல பகுதி: கனிம வளம் நிறைந்த மலை மண்',
      );
  String get viewCartBtn => _t('View Cart', 'කරත්තය බලන්න', 'கூடையைப் பார்');

  String localizedRegion(String region) {
    if (lang == AppLanguage.english) return region;
    final r = region.toLowerCase();
    if (r.contains('all sri lanka')) return lang == AppLanguage.sinhala ? 'මුළු ශ්‍රී ලංකාවම' : 'முழு இலங்கை';
    if (r.contains('nuwara eliya')) return lang == AppLanguage.sinhala ? 'නුවරඑළිය' : 'நுவரெலியா';
    if (r.contains('dambulla')) return lang == AppLanguage.sinhala ? 'දඹුල්ල' : 'தம்புள்ளை';
    if (r.contains('kandy')) return lang == AppLanguage.sinhala ? 'මහනුවර' : 'கண்டி';
    if (r.contains('welimada')) return lang == AppLanguage.sinhala ? 'වැලිමඩ' : 'வெலிமடை';
    if (r.contains('matale')) return lang == AppLanguage.sinhala ? 'මාතලේ' : 'மாத்தளை';
    if (r.contains('jaffna')) return lang == AppLanguage.sinhala ? 'යාපනය' : 'யாழ்ப்பாணம்';
    if (r.contains('kurunegala')) return lang == AppLanguage.sinhala ? 'කුරුණෑගල' : 'குருநாகல்';
    if (r.contains('monaragala')) return lang == AppLanguage.sinhala ? 'මොණරාගල' : 'மொனராகலை';
    return region;
  }

  String localizedRegionSub(String sub) {
    if (lang == AppLanguage.english) return sub;
    final s = sub.toLowerCase();
    if (s.contains('9 provinces')) return lang == AppLanguage.sinhala ? 'සියලු පළාත් 9න්ම' : 'அனைத்து 9 மாகாணங்கள்';
    if (s.contains('cool-climate')) return lang == AppLanguage.sinhala ? 'උඩරට සිසිල් දේශගුණය' : 'குளிர்ந்த மலைப்பகுதி';
    if (s.contains('north central')) return lang == AppLanguage.sinhala ? 'උතුරු මැද කෘෂි මධ්‍යස්ථානය' : 'வட மத்திய மையம்';
    if (s.contains('mid-country')) return lang == AppLanguage.sinhala ? 'මැදරට කෘෂි කලාපය' : 'மத்திய நாட்டு பகுதி';
    if (s.contains('highland valley')) return lang == AppLanguage.sinhala ? 'කඳුකර නිම්න ගොවිබිම්' : 'பள்ளத்தாக்கு பண்ணைகள்';
    if (s.contains('spices')) return lang == AppLanguage.sinhala ? 'කුළුබඩු සහ කඳු බවුම්' : 'மசாலா மற்றும் மலை சரிவுகள்';
    if (s.contains('northern red soil')) return lang == AppLanguage.sinhala ? 'උතුරේ රතු පස් අස්වැන්න' : 'வடக்கு செம்மண் விளைச்சல்';
    if (s.contains('coconut triangle')) return lang == AppLanguage.sinhala ? 'පොල් ත්‍රිකෝණය සහ පලතුරු' : 'தென்னை முக்கோணம் & பழங்கள்';
    if (s.contains('dry zone')) return lang == AppLanguage.sinhala ? 'වියළි කලාපීය හේන් සහ මීපැණි' : 'வறண்ட பகுதி தேன்';
    return sub;
  }

  String localizedSort(String sort) {
    if (lang == AppLanguage.english) return sort;
    final s = sort.toLowerCase();
    if (s.contains('recommended')) return lang == AppLanguage.sinhala ? 'නිර්දේශිත' : 'பரிந்துரைக்கப்பட்டது';
    if (s.contains('distance') || s.contains('closest')) return lang == AppLanguage.sinhala ? 'දුර (ළඟම ඇති ගොවිපොළ)' : 'தூரம் (அருகிலுள்ள பண்ணை)';
    if (s.contains('low to high')) return lang == AppLanguage.sinhala ? 'මිල: අඩු සිට වැඩි දක්වා' : 'விலை: குறைந்தது முதல் அதிகம் வரை';
    if (s.contains('high to low')) return lang == AppLanguage.sinhala ? 'මිල: වැඩි සිට අඩු දක්වා' : 'விலை: அதிகம் முதல் குறைந்தது வரை';
    if (s.contains('highest rated')) return lang == AppLanguage.sinhala ? 'ඉහළම ඇගයුම් (4.5+ ★)' : 'அதிக மதிப்பீடு (4.5+ ★)';
    if (s.contains('newest harvest')) return lang == AppLanguage.sinhala ? 'අලුත්ම අස්වැන්න පළමුව' : 'புதிய அறுவடை முதலில்';
    return sort;
  }

  String localizedSortSub(String desc) {
    if (lang == AppLanguage.english) return desc;
    final d = desc.toLowerCase();
    if (d.contains('lowest transit') || d.contains('carbon')) return lang == AppLanguage.sinhala ? 'අවම ප්‍රවාහන කාබන් පියසටහන' : 'குறைந்த போக்குவரத்து தடம்';
    if (d.contains('best budget') || d.contains('per 1 kg')) return lang == AppLanguage.sinhala ? 'කිලෝ 1කට හොඳම සහන මිල' : '1 கிலோவிற்கு சிறந்த விலை';
    if (d.contains('premium export') || d.contains('whole packs')) return lang == AppLanguage.sinhala ? 'විශේෂිත සහ තොග ඇසුරුම්' : 'ஏற்றுமதி & முழு பேக்குகள்';
    if (d.contains('consistently') || d.contains('freshness')) return lang == AppLanguage.sinhala ? 'නිරන්තරයෙන් තහවුරු කළ නැවුම්බව' : 'சரிபார்க்கப்பட்ட புத்துணர்ச்சி';
    if (d.contains('uploaded') || d.contains('within today')) return lang == AppLanguage.sinhala ? 'අද දිනය තුළ ඇතුළත් කළ' : 'இன்று பதிவேற்றப்பட்டது';
    return desc;
  }

  String localizedHarvestTime(String harvestTime) {
    if (lang == AppLanguage.english) return harvestTime;
    final h = harvestTime.toLowerCase();
    if (h.contains('today')) return lang == AppLanguage.sinhala ? 'අද නෙළන ලදී' : 'இன்று பறிக்கப்பட்டது';
    if (h.contains('yesterday')) return lang == AppLanguage.sinhala ? 'ඊයේ නෙළන ලදී' : 'நேற்று பறிக்கப்பட்டது';
    if (h.contains('dawn')) return lang == AppLanguage.sinhala ? 'පාන්දර අස්වැන්න' : 'விடியற்காலை அறுவடை';
    if (h.contains('hours ago')) {
      final numStr = RegExp(r'd+').firstMatch(harvestTime)?.group(0) ?? '';
      return lang == AppLanguage.sinhala ? 'පැය $numStrකට පෙර' : '$numStr மணி நேரத்திற்கு முன்';
    }
    return harvestTime;
  }
  // ── Driver Pickup Verification ───────────────────────────────────────────
  String get liveTransitNav => _t('Live Transit Navigation', 'සජීවී ප්‍රවාහන මඟපෙන්වීම', 'நேரலை வழிசெலுத்தல்');
  String get closeNavigationView => _t('Close Navigation View', 'සිතියම වසන්න', 'வழிசெலுத்தலை மூடு');
  String get hostFarmer => _t('Host Farmer', 'සත්කාරක ගොවියා', 'வழங்குநர் விவசாயி');
  String get gateShed => _t('Gate / Shed', 'දොරටුව / ගබඩාව', 'வாயில் / கொட்டகை');
  String get threeOfThreeVerified => _t('3 of 3 Verified', '3න් 3ක් තහවුරු විය', '3ல் 3 சரிபார்க்கப்பட்டது');
  String get qualityChecklistSub => _t(
        'Verify field condition, sealed weight, and scan codes before staging into cold van manifest.',
        'ශීතල වෑන් රථයට පැටවීමට පෙර තත්ත්වය, බර සහ කේත පරීක්ෂා කරන්න.',
        'வாகனத்தில் ஏற்றுவதற்கு முன் நிலை, எடை மற்றும் குறியீடுகளை சரிபார்க்கவும்.',
      );
  String get freshBundledHydroCooled => _t('Fresh bundled, hydro-cooled', 'නැවුම්ව බැඳ, සිසිල් කර ඇත', 'புதிதாக கட்டப்பட்டு, குளிர்விக்கப்பட்டது');
  String get crateTagScanned => _t('Crate Tag Scanned', 'කූඩයේ ටැගය ස්කෑන් කරන ලදී', 'கூடை குறிச்சொல் ஸ்கேன் செய்யப்பட்டது');
  String get freshnessOk => _t('Freshness OK', 'නැවුම් බව සාර්ථකයි', 'புத்துணர்ச்சி சரி');
  String ambientOptimal(String temp) => _t('Ambient: $temp (Optimal)', 'පරිසරය: $temp (සුදුසුයි)', 'சூழல்: $temp (உகந்தது)');
  String get needHelpContactDispatch => _t('Need Help? Contact Dispatch', 'උදව් අවශ්‍යද? ඩිස්පැච් අමතන්න', 'உதவி தேவையா? அனுப்புனரை அழைக்கவும்');
  String get fieldVerification => _t('Field Verification', 'ක්ෂේත්‍ර සත්‍යාපනය', 'கள சரிபார்ப்பு');
  String get farmerPinHandover => _t('Farmer PIN Handover', 'ගොවියාගේ රහස් අංකය (PIN)', 'விவசாயி பின் குறியீடு');
  String get pinMatched => _t('Matched', 'ගැලපේ', 'பொருந்தியது');
  String get verifyingAndStaging => _t('Verifying & Staging to Van...', 'තහවුරු කරමින් රථයට පටවමින් පවතී...', 'சரிபார்த்தු வாகனத்தில் ஏற்றப்படுகிறது...');
  String get pickupVerifiedLoadedTitle => _t('Pickup Verified & Loaded!', 'පිකප් කර රථයට පැටවීම සාර්ථකයි!', 'பிக்அப் சரிபார்க்கப்பட்டு ஏற்றப்பட்டது!');
  String get pickupVerifiedLoadedDesc => _t(
        '2 Crates securely staged into cold van manifest.\nNext stage: En route to Colombo dropoff.',
        'කූඩ 2ක් සාර්ථකව ශීතල වෑන් රථයට පටවන ලදී.\nඊළඟ පියවර: කොළඹ වෙත ගමන් කිරීම.',
        '2 கூடைகள் வாகனத்தில் ஏற்றப்பட்டன.\nஅடுத்த கட்டம்: கொழும்பு நோக்கி பயணம்.',
      );
  String get backToDriverDashboard => _t('Back to Driver Dashboard', 'රියදුරු පාලක පුවරුවට', 'ஓட்டுநர் டாஷ்போர்டிற்கு');
  String get agriDispatchHotline => _t('Agri-Dispatch Hotline', 'කෘෂි-ඩිස්පැච් ක්ෂණික ඇමතුම්', 'அனுப்புதல் உதவி எண்');
  String get agriDispatchHotlineSub => _t(
        'Direct line for corridor re-routing or crate issues.',
        'මාර්ගය වෙනස් කිරීම හෝ කූඩ ගැටළු සඳහා සෘජු ඇමතුම්.',
        'பாதை மாற்றம் அல்லது கூடை சிக்கல்களுக்கான நேரடி தொடர்பு.',
      );
  String get callDispatch1920 => _t('Call Dispatch (1920)', 'ඩිස්පැච් අමතන්න (1920)', 'அனுப்புனரை அழைக்கவும் (1920)');
  String get dialingDispatch => _t('Dialing Dispatch Central Hotline...', 'ඩිස්පැච් මධ්‍යස්ථානය අමතමින්...', 'அனுப்புதல் மையத்தை அழைக்கிறது...');

  // ── Driver Delivery Completed ─────────────────────────────────────────────
  String orderDroppedOff(String orderId) => _t(
        'Order $orderId dropped off & confirmed',
        'ඇණවුම $orderId බාරදී තහවුරු කරන ලදී',
        'ஆர்டர் $orderId ஒப்படைக்கப்பட்டு உறுதிசெய்யப்பட்டது',
      );
  String get totalEarnedLabel => _t('total earned', 'මුළු ඉපැයීම', 'மொத்த வருவாய்');
  String baseTransitKm(String km) => _t('Base Transit ($km km)', 'මූලික ගමන් ගාස්තුව ($km km)', 'அடிப்படை போக்குவரத்து ($km km)');
  String get highlandTerrainBonus => _t('Highland Terrain Bonus', 'කඳුකර මාර්ග දීමනාව', 'மலைப்பாதை போனஸ்');
  String get directTip => _t('Direct Tip', 'සෘජු පාරිතෝෂිකය', 'நேரடி உதவித்தொகை');
  String get completedBadge => _t('✓ Completed', '✓ සම්පූර්ණයි', '✓ முடிந்தது');
  String get deliveredAt => _t('Delivered At', 'භාරදුන් වේලාව', 'டெலிவரி செய்யப்பட்ட நேரம்');
  String get handoverAndPayment => _t('Handover & Payment', 'භාරදීම සහ ගෙවීම', 'ஒப்படைப்பு மற்றும் கட்டணம்');
  String get starRating => _t('Star', 'තරු', 'நட்சத்திரம்');

  // ── Driver Delivery Tracking ──────────────────────────────────────────────
  String get deliveryTracking => _t('Delivery Tracking', 'බෙදාහැරීම නිරීක්ෂණය', 'டெலிவரி கண்காணிப்பு');
  String get voiceNavToggled => _t('Voice navigation audio toggled', 'හඬ මඟපෙන්වීම මාරු කරන ලදී', 'குரல் வழிசெலுத்தல் மாற்றப்பட்டது');
  String get routeSmoothNormal => _t('Route Smooth • Normal Traffic', 'මාර්ගය පැහැදිලියි • සාමාන්‍ය ගමනාගමනය', 'சுமூகமான பாதை • சாதாரண போக்குவரத்து');
  String get originHakgala => _t('ORIGIN: ', 'ආරම්භය: ', 'தோற்றம்: ');
  String get destination => _t('DESTINATION', 'ගමනාන්තය', 'சேருமிடம்');
  String get cargoCool => _t('Cargo Cool: ', 'ශීතල උෂ්ණත්වය: ', 'சரக்கு குளிர்ச்சி: ');
  String get remaining => _t('REMAINING', 'ඉතිරි දුර', 'மீதமுள்ள தூரம்');
  String get estTime => _t('EST. TIME', 'ඇස්තමේන්තුගත කාලය', 'மதிப்பிடப்பட்ட நேரம்');
  String get fastest => _t('Fastest', 'වේගවත්ම', 'வேகமானது');
  String get targetEta => _t('TARGET ETA', 'ඉලක්කගත ළඟාවීම', 'இலக்கு நேரம்');
  String get onTime => _t('On Time', 'නියමිත වේලාවට', 'சரியான நேரத்தில்');
  String get paymentOnArrival => _t('PAYMENT ON ARRIVAL', 'ළඟාවූ පසු මුදල් ගෙවීම', 'வந்தவுடன் பணம்');
  String get cashOnDeliveryLabel => _t('Cash on Delivery: ', 'භාණ්ඩ ලැබුණු පසු මුදල්: ', 'டெலிவரியின் போது பணம்: ');
  String get gateCodeLabel => _t('Gate code ', 'දොරටු අංකය ', 'வாயில் குறியீடு ');
  String get slideToStartNav => _t('Slide to Start Live Navigation', 'සජීවී මඟපෙන්වීම සඳහා ස්ලයිඩ් කරන්න', 'நேரலை வழிசெலுத்தலுக்கு சறுக்குங்கள்');
  String get handoverProduceViewReceipt => _t('Handover Produce • View Receipt →', 'අස්වැන්න භාරදෙන්න • බිල්පත බලන්න →', 'பொருட்களை ஒப்படைக்கவும் • ரசீது பார்க்க →');
  String get callBuyerNow => _t('Call Buyer Now', 'පාරිභෝගිකයාට දැන් අමතන්න', 'வாங்குபவரை இப்போது அழைக்கவும்');
  String chatWithBuyer(String name) => _t('Chat with $name', '$name සමඟ සංවාදය', '$name உடன் அரட்டை');
  String askBuyerPrepareCash(String amt) => _t(
        'Ask buyer to prepare cash ($amt) on delivery arrival.',
        'භාණ්ඩ ළඟාවීමට පෙර මුදල් ($amt) සූදානම් කර තබන ලෙස දැනුම් දෙන්න.',
        'டெலிவரிக்கு முன் பணம் ($amt) தயாராக வைக்கக் கூறவும்.',
      );
  String get openDirectChat => _t('Open Direct Chat', 'සෘජු සංවාදය අරඹන්න', 'நேரடி அரட்டை திறக்க');
  String get handingOverProduce => _t('Handing Over Produce to Buyer', 'පාරිභෝගිකයා වෙත අස්වැන්න භාරදෙමින් පවතී', 'பொருட்களை வாங்குபவரிடம் ஒப்படைக்கிறது');
  String get updatingStatusToCompleted => _t('Updating delivery status to Completed...', 'බෙදාහැරීමේ තත්ත්වය සම්පූර්ණයි ලෙස යාවත්කාලීන වේ...', 'டெலிவரி நிலை முடிந்தது என புதுப்பிக்கப்படுகிறது...');
  String get confirmHandoverViewReceipt => _t('Confirm Handover & View Receipt →', 'භාරදීම තහවුරු කර බිල්පත බලන්න →', 'ஒப்படைப்பை உறுதிசெய்து ரசீதை காண்க →');

  // ── Driver Delivery History ───────────────────────────────────────────────
  String get deliveryHistory => _t('Delivery History', 'බෙදාහැරීම් ඉතිහාසය', 'டெலிவரி வரலாறு');
  String get verifiedDriver => _t('Verified Driver', 'සත්‍යාපිත රියදුරු', 'சரிபார்க்கப்பட்ட ஓட்டுநர்');
  String completedTripsSriLanka(int count) => _t(
        '$count Completed Trips across Sri Lanka',
        'මුළු ශ්‍රී ලංකාව පුරා සම්පූර්ණ කළ ගමන් $count',
        'இலங்கை முழுவதும் $count முடித்த பயணங்கள்',
      );
  String get tripsMade => _t('Trips Made', 'සිදුකළ ගමන්', 'செய்த பயணங்கள்');
  String get onTimeRate => _t('On-Time', 'නියමිත වේලාවට', 'சரியான நேரத்தில்');
  String get completedTrips => _t('COMPLETED TRIPS', 'සම්පූර්ණ කළ ගමන්', 'முடித்த பயணங்கள்');
  String recentShown(int count) => _t('$count Recent Shown', 'මෑතකදී කළ $countක් පෙන්වයි', 'சமீபத்திய $count காட்டப்படுகிறது');
  String get thisWeek => _t('This Week', 'මෙම සතියේ', 'இந்த வாரம்');
  String get lastWeek => _t('Last Week', 'පසුගිය සතියේ', 'கடந்த வாரம்');
  String get thisMonth => _t('This Month', 'මෙම මාසයේ', 'இந்த மாதம்');
  String get drop => _t('Drop', 'භාරදීම', 'ஒப்படைப்பு');
  String get farmFreshAssured => _t('100% Farm Fresh Assured', '100% ගොවිපොළ නැවුම් බව තහවුරුයි', '100% பண்ணை புத்துணர்ச்சி உறுதி');
  String get farmFreshAssuredSub => _t(
        'Direct dispatch reduces transit decay by maintaining optimal farm-gate chill standards.',
        'සෘජු ප්‍රවාහනය මඟින් නැවුම් බව සුරැකී පාරිභෝගිකයා වෙත ලැබේ.',
        'நேரடி அனுப்புதல் புத்துணர்ச்சியை பாதுகாத்து வாடிக்கையாளரை சென்றடைகிறது.',
      );
  String get downloadTaxPdf => _t('Download Tax & Payment Statement (PDF)', 'බදු සහ ගෙවීම් වාර්තාව බාගන්න (PDF)', 'வரி & கட்டண அறிக்கையை பதிவிறக்கவும் (PDF)');
  String get pdfDownloadedTitle => _t('PDF Statement Downloaded!', 'PDF වාර්තාව බාගත විය!', 'PDF அறிக்கை பதிவிறக்கப்பட்டது!');
  String get openStatement => _t('Open Statement', 'වාර්තාව විවෘත කරන්න', 'அறிக்கையை திறக்கவும்');
  String get removeTripRecord => _t('Remove Trip Record?', 'ගමන් වාර්තාව ඉවත් කරන්නද?', 'பயண பதிவை நீக்கவா?');
  String removeTripRecordDesc(String id) => _t(
        'Are you sure you want to remove #$id from your delivery history? This will remove the record from your active history in the database.',
        '#$id ගමන් වාර්තාව ඔබගේ ඉතිහාසයෙන් ඉවත් කිරීමට ඔබට සහතිකද?',
        '#$id பயண பதிவை வரலாற்றிலிருந்து நீக்க விரும்புகிறீர்களா?',
      );
  String get removeRecord => _t('Remove Record', 'වාර්තාව ඉවත් කරන්න', 'பதிவை நீக்கு');
  String get noTripsInPeriod => _t('No completed trips in this period', 'මෙම කාලසීමාව තුළ සම්පූර්ණ කළ ගමන් නොමැත', 'இந்த காலகட்டத்தில் பயணங்கள் இல்லை');
  String get recordsArchivedOrRemoved => _t('Records may have been archived or removed', 'වාර්තා සංරක්ෂණය කර හෝ ඉවත් කර ඇත', 'பதிவுகள் காப்பகப்படுத்தப்பட்டிருக்கலாம்');

  // ── Driver Chat ───────────────────────────────────────────────────────────
  String get typeYourMessage => _t('Type your message...', 'පණිවිඩය ටයිප් කරන්න...', 'செய்தியை தட்டச்சு செய்க...');
  String get arrivedAtLocation => _t('Arrived at location', 'ස්ථානයට ළඟා විය', 'இடத்திற்கு வந்துவிட்டேன்');
  String get delayedByTraffic => _t('Delayed by traffic (5-10m)', 'මාර්ග තදබදය නිසා ප්‍රමාදයි (විනාඩි 5-10)', 'போக்குவரத்து நெரிசல் காரணமாக தாமதம்');
  String get loadedAndSecured => _t('Loaded and secured', 'පටවා සුරක්ෂිත කරන ලදී', 'ஏற்றப்பட்டு பாதுகாக்கப்பட்டது');
  String get deliveredSafely => _t('Delivered safely', 'ආරක්ෂිතව බෙදාහරින ලදී', 'பாதுகாப்பாக டெலிவரி செய்யப்பட்டது');
  String get support => _t('Support', 'සහාය', 'ஆதரவு');

  // ── Cart & Search ─────────────────────────────────────────────────────────
  String itemsCountLabel(int count) => _t('$count items', 'භාණ්ඩ $count', '$count பொருட்கள்');
  String get clearShoppingCartTitle => _t('Clear Shopping Cart?', 'කරත්තය හිස් කරන්නද?', 'ஷாப்பிங் கூடையை அழிக்கவா?');
  String get clearShoppingCartBody => _t(
        'Are you sure you want to remove all fresh produce items from your cart?',
        'ඔබගේ කරත්තයේ ඇති සියලුම නැවුම් අස්වනු ඉවත් කිරීමට ඔබට සහතිකද?',
        'உங்கள் கூடையிலுள்ள அனைத்து பொருட்களையும் நீக்க விரும்புகிறீர்களா?',
      );
  String get orderTotal => _t('Order Total', 'ඇණවුමේ මුළු මුදල', 'ஆர்டர் மொத்தம்');
  String get promoCodeVouchers => _t('PROMO CODE & VOUCHERS', 'ප්‍රවර්ධන කේත සහ වවුචර්', 'ப்ரோமோ குறியீடுகள்');
  String get enterPromoCode => _t('Enter promo code', 'ප්‍රවර්ධන කේතය ඇතුළත් කරන්න', 'ப்ரோமோ குறியீட்டை உள்ளிடவும்');
  String discountWithCode(String code) => _t('Discount ($code)', 'වට්ටම ($code)', 'தள்ளுபடி ($code)');
  String get totalPayment => _t('Total Payment', 'ගෙවිය යුතු මුළු මුදල', 'மொத்த கட்டணம்');
  String get yourCartIsEmpty => _t('Your Cart is Empty', 'ඔබේ කරත්තය හිස්ය', 'உங்கள் கூடை காலியாக உள்ளது');
  String get cartEmptyDesc => _t(
        'Explore fresh fruits, vegetables, and spices directly from verified local farmers.',
        'දේශීය ගොවීන්ගෙන් සෘජුවම නැවුම් එළවළු, පලතුරු සහ කුළුබඩු ලබාගන්න.',
        'உள்ளூர் விவசாயிகளிடமிருந்து புதிய விளைச்சல்களை பெறுங்கள்.',
      );
  String get exploreProduce => _t('Explore Produce', 'අස්වනු ගවේෂණය කරන්න', 'பொருட்களை ஆராய்க');
  String get searchAndFilter => _t('Search & Filter', 'සෙවීම සහ පෙරහන', 'தேடல் & வடிகட்டி');
  String get searchProductsHint => _t('Search products...', 'නිෂ්පාදන සොයන්න...', 'பொருட்களைத் தேடுங்கள்...');
  String get onlyFresh => _t('Only Fresh', 'නැවුම් අස්වනු පමණි', 'புதியவை மட்டும்');
  String get onlyOrganic => _t('Only Organic', 'කාබනික පමණි', 'இயற்கை விவசாயம் மட்டும்');
  String get filteredResults => _t('Filtered Results', 'පෙරහන් කළ ප්‍රතිඵල', 'வடிகட்டிய முடிவுகள்');
  String get noMatchingProducts => _t('No matching products found', 'ගැලපෙන නිෂ්පාදන හමු නොවීය', 'பொருந்தும் பொருட்கள் எதுவும் இல்லை');
  String get adjustSearchCriteria => _t(
        'Try adjusting your search criteria or price range.',
        'සෙවුම් පරාමිතීන් හෝ මිල පරාසය වෙනස් කර උත්සාහ කරන්න.',
        'தேடல் அளவுகோல்கள் அல்லது விலை வரம்பை சரிசெய்யவும்.',
      );
  String get nearMe => _t('Near me', 'මා අසල', 'எனக்கு அருகில்');

  String get aboutMe => _t('ABOUT ME', 'මා ගැන', 'என்னைப் பற்றி');
  String get products => _t('Products', 'නිෂ්පාදන', 'பொருட்கள்');
  String get routeMap => _t('Route Map', 'මාර්ග සිතියම', 'பாதை வரைபடம்');

  String get alreadyAtFarmerRoot => _t('Already at Farmer Dashboard root view', 'දැනටමත් ගොවි පාලක පුවරුවේ මුල් පිටුවේ සිටී', 'ஏற்கனவே விவசாயி டாஷ்போர்டு முகப்பில் உள்ளது');
  String get pendingOrderAlert => _t('Pending Orders', 'තහවුරු කිරීමට නියමිත ඇණවුම්', 'நிலுவையிலுள்ள ஆர்டர்கள்');
  String get weeklyEarningsSummary => _t('Weekly Earnings Summary', 'සතිපතා ආදායම් සාරාංශය', 'வாராந்திர வருமான சுருக்கம்');

  // ── Missing Presentation Getters (Auth, Buyer, Farmer, Driver, Cart) ──────
  String get buyerAccountCreated => _t('Buyer Account Created!', 'ගැනුම්කරු ගිණුම සාදන ලදී!', 'வாங்குபவர் கணக்கு உருவாக்கப்பட்டது!');
  String get buyerWelcomeMsg => _t('Welcome to direct farm-to-table sourcing.', 'නැවුම් ගොවිපළ අස්වනු සෘජුවම ලබාගැනීමට සාදරයෙන් පිළිගනිමු.', 'பண்ணையிலிருந்து நேரடியாக வாங்குவதற்கு வரவேற்கிறோம்.');
  String get exploreFreshProduce => _t('Explore Fresh Produce', 'නැවුම් අස්වනු ගවේෂණය කරන්න', 'புதிய விளைச்சலை ஆராய்க');
  String get registerAsBuyerTitle => _t('Register as Buyer', 'ගැනුම්කරුවෙකු ලෙස ලියාපදිංචි වන්න', 'வாங்குபவராக பதிவு செய்க');
  String get roleProfileBuyer => _t('Role Profile: Verified Buyer', 'භූමිකාව: තහවුරු කළ ගැනුම්කරු', 'சுயவிவரம்: சரிபார்க்கப்பட்ட வாங்குபவர்');
  String get changeRole => _t('Change Role', 'භූමිකාව වෙනස් කරන්න', 'பங்கினை மாற்றுக');
  String get buyerTypeLabel => _t('Select Buyer Type', 'ගැනුම්කරු වර්ගය තෝරන්න', 'வாங்குபவர் வகையைத் தேர்ந்தெடுக்கவும்');
  String get fullNameLabel => _t('Full Name', 'සම්පූර්ණ නම', 'முழு பெயர்');
  String get mobileNumberLabel => _t('Mobile Number', 'ජංගම දුරකථන අංකය', 'கைபேசி எண்');
  String get regionalHubLabel => _t('Delivery City / Hub Area', 'බෙදාහැරීමේ නගරය / කලාපීය මධ්‍යස්ථානය', 'டெலிவரி நகரம் / மையப் பகுதி');
  String get deliveryAddressLabel => _t('Default Street Address', 'පෙරනිමි ලිපිනය', 'இயல்புநிலை முகவரி');
  String get confirmPasswordLabel => _t('Confirm Password', 'මුරපදය තහවුරු කරන්න', 'கடவுச்சொல்லை உறுதிப்படுத்துக');
  String get producePreferencesLabel => _t('Produce Preferences', 'අස්වනු මනාපයන්', 'விருப்பமான விளைச்சல்கள்');
  String get agreeTermsBuyer => _t('I agree to the Terms of Service & Privacy Policy', 'මම සේවා කොන්දේසි සහ රහස්‍යතා ප්‍රතිපත්තියට එකඟ වෙමි', 'சேவை விதிமுறைகள் மற்றும் தனியுரிமைக் கொள்கையை ஏற்கிறேன்');
  String get createBuyerAccountBtn => _t('Create Buyer Account', 'ගැනුම්කරු ගිණුමක් සාදන්න', 'வாங்குபவர் கணக்கை உருவாக்குக');

  String get agriTransitTitle => _t('Agri-Transit Logistics', 'කෘෂි ප්‍රවාහන සේවා', 'விவசாய போக்குவரத்து');
  String get feeToYouBanner => _t('Fair Transit Guarantee', 'සාධාරණ ප්‍රවාහන සහතිකය', 'நியாயமான போக்குவரத்து உத்தரவாதம்');
  String get fairTransit => _t('FAIR TRANSIT', 'සාධාරණ ප්‍රවාහනය', 'நியாயமான போக்குவரத்து');
  String get zeroPlatformCommissions => _t('Zero Platform Commissions on Driver Delivery Fees', 'රියදුරු ගාස්තු මත කිසිදු කොමිස් මුදලක් අය නොකෙරේ', 'ஓட்டுநர் கட்டணத்தில் பூஜ்ஜிய கமிஷன்');
  String get driverInformation => _t('Driver Information', 'රියදුරු තොරතුරු', 'ஓட்டுநர் தகவல்');
  String get verifiedStep13 => _t('Step 1 of 3: Verified', 'පියවර 1/3: තහවුරු කර ඇත', 'படி 1/3: சரிபார்க்கப்பட்டது');
  String get fullLegalName => _t('Full Legal Name', 'සම්පූර්ණ නීත්‍යානුකූල නම', 'முழு சட்டப்பூர்வ பெயர்');
  String get drivingLicenseNumber => _t('Driving License Number', 'රියදුරු බලපත්‍ර අංකය', 'ஓட்டுநர் உரிம எண்');
  String get mobileNumberOtp => _t('Mobile Number (SMS OTP)', 'ජංගම දුරකථන අංකය (SMS OTP)', 'கைபேசி எண் (SMS OTP)');
  String get smsVerificationClearance => _t('SMS verification required for security clearance', 'ආරක්ෂිත නිෂ්කාශනය සඳහා SMS තහවුරු කිරීම අවශ්‍ය වේ', 'பாதுகாப்பு சரிபார்ப்புக்கு SMS தேவை');
  String get vehicleTypeLabel => _t('Vehicle Type', 'වාහන වර්ගය', 'வாகன வகை');
  String get primaryTransit => _t('PRIMARY TRANSIT', 'ප්‍රධාන ප්‍රවාහනය', 'முக்கிய போக்குவரத்து');
  String get regPlateNo => _t('Registration Plate No.', 'ලියාපදිංචි අංක තහඩුව', 'பதிவு எண் பலகை');
  String get cargoCapacityLabel => _t('Cargo Capacity', 'ප්‍රවාහන ධාරිතාව', 'சரக்கு கொள்ளளவு');
  String get chilledUnitEquipped => _t('Chilled Unit Equipped (Refrigerated)', 'ශීතකරණ පහසුකම් සහිතයි', 'குளிரூட்டப்பட்ட வசதி கொண்டது');
  String get logIn => _t('Log In', 'ඇතුල් වන්න', 'உள்நுழைக');

  String get producerAccountRegistered => _t('Producer Account Registered!', 'ගොවි ගිණුම ලියාපදිංචි කරන ලදී!', 'உற்பத்தியாளர் கணக்கு பதிவு செய்யப்பட்டது!');
  String get goToFarmerDashboard => _t('Go to Farmer Dashboard', 'ගොවි පාලක පුවරුවට යන්න', 'விவசாயி டாஷ்போர்டுக்கு செல்க');
  String get producerPortalPill => _t('PRODUCER PORTAL', 'ගොවි පියස', 'உற்பத்தியாளர் போர்டல்');
  String get farmerGrowerPartner => _t('Farmer & Grower Partner', 'ගොවි සහ නිෂ්පාදක හවුල්කරු', 'விவசாய கூட்டாளி');
  String get registerFarmerTitle => _t('Register My Farm', 'මගේ ගොවිපළ ලියාපදිංචි කරන්න', 'எனது பண்ணையை பதிவு செய்க');
  String get farmerRegisterSub => _t('Direct farm-gate access to buyers islandwide', 'දිවයින පුරා ගැනුම්කරුවන් වෙත සෘජුවම අස්වනු අලෙවි කරන්න', 'நாடு தழுவிய வாங்குபவர்களுக்கு நேரடி அணுகல்');
  String get govtAgrarianPartnership => _t('GOVT AGRARIAN PARTNERSHIP', 'රජයේ ගොවිජන හවුල්කාරිත්වය', 'அரசு விவசாய கூட்டாண்மை');
  String get registeredWithAgrarianCollective => _t('Registered with Agrarian Services Collective', 'ගොවිජන සේවා එකමුතුවේ ලියාපදිංචි වී ඇත', 'விவசாய சேவைகள் கூட்டமைப்பில் பதிவு செய்யப்பட்டுள்ளது');
  String get freeCrateCollection => _t('Free crate pickup & return at regional centers', 'කලාපීය මධ්‍යස්ථාන වලින් නොමිලේ කූඩ ලබාගැනීම සහ ආපසු භාරදීම', 'இலவச பெட்டி எடுப்பு மற்றும் திரும்புதல்');
  String get producerDetails => _t('Producer Details', 'නිෂ්පාදක තොරතුරු', 'உற்பத்தியாளர் விவரங்கள்');
  String get fullNameFarmLead => _t('Full Name (Lead Farmer)', 'සම්පූර්ණ නම (ප්‍රධාන ගොවි)', 'முழு பெயர் (முதன்மை விவசாயி)');
  String get mobileNumber => _t('Mobile Number', 'ජංගම දුරකථන අංකය', 'கைபேசி எண்');
  String get smsOtpVerified => _t('SMS Verified', 'SMS මඟින් තහවුරු කර ඇත', 'SMS சரிபார்க்கப்பட்டது');
  String get smsOtpVerification => _t('SMS OTP Verification', 'SMS OTP තහවුරු කිරීම', 'SMS OTP சரிபார்ப்பு');
  String get verified => _t('Verified', 'තහවුරු කර ඇත', 'சரிபார்க்கப்பட்டது');
  String get locationLogisticsHub => _t('Location & Logistics Hub', 'ස්ථානය සහ ප්‍රවාහන මධ්‍යස්ථානය', 'இருப்பிடம் & போக்குவரத்து மையம்');
  String get farmingRegionDistrict => _t('Farming Region / District', 'වගා කලාපය / දිස්ත්‍රික්කය', 'விவசாய மண்டலம் / மாவட்டம்');
  String get nearestAgrarianCenter => _t('Nearest Agrarian Service Center', 'ළඟම ඇති ගොවිජන සේවා මධ්‍යස්ථානය', 'அருகிலுள்ள விவசாய சேவை மையம்');
  String get cropsAndScale => _t('Crops & Cultivation Scale', 'බෝග සහ වගා ප්‍රමාණය', 'பயிர்கள் & சாகுபடி அளவு');
  String get primaryCropsHarvestTypes => _t('Primary Crops & Harvest Types', 'ප්‍රධාන බෝග සහ අස්වනු වර්ග', 'முக்கிய பயிர்கள் & அறுவடை வகைகள்');
  String get selectMultiple => _t('Select multiple', 'කිහිපයක් තෝරන්න', 'பலவற்றைத் தேர்ந்தெடுக்கவும்');
  String get totalCultivationArea => _t('Total Cultivation Area', 'මුළු වගා බිම් ප්‍රමාණය', 'மொத்த சாகுபடி பரப்பு');
  String get farmingPracticeCertification => _t('Farming Practice & Certification', 'ගොවිතැන් ක්‍රමය සහ සහතික', 'விவசாய முறை & சான்றிதழ்');
  String get topRate => _t('TOP RATED', 'ඉහළම ශ්‍රේණිගත', 'உயர் மதிப்பீடு');
  String get directBankPayouts => _t('Direct Bank Payouts', 'සෘජු බැංකු ගෙවීම්', 'நேரடி வங்கி பணம் செலுத்துதல்');
  String get dailyWeekly => _t('Daily / Weekly', 'දිනපතා / සතිපතා', 'தினசரி / வாராந்திர');
  String get zeroCommissionBankSettlement => _t('Zero-commission direct settlement to your bank account', 'ඔබගේ බැංකු ගිණුමට කිසිදු කොමිස් මුදලක් රහිතව සෘජු ගෙවීම්', 'உங்கள் வங்கிக் கணக்கில் கமிஷன் இல்லாத நேரடி தீர்வு');
  String get bankNameBranch => _t('Bank Name & Branch', 'බැංකුවේ නම සහ ශාඛාව', 'வங்கி பெயர் & கிளை');
  String get accountNumberLabel => _t('Account Number', 'ගිණුම් අංකය', 'கணக்கு எண்');
  String get certificatesLandDeed => _t('Certificates & Land Deed', 'සහතික සහ ඉඩම් ඔප්පු', 'சான்றிதழ்கள் & காணிப் பத்திரம்');
  String get optionalNow => _t('Optional for now', 'දැනට අත්‍යවශ්‍ය නොවේ', 'தற்போது விருப்பமானது');
  String get uploadLandDeedDesc => _t('Upload Agrarian certificate or proof of land cultivation', 'ගොවිජන සහතිකය හෝ ඉඩම් වගා සාක්ෂි උඩුගත කරන්න', 'விவசாய சான்றிதழ் அல்லது காணி ஆவணத்தை பதிவேற்றவும்');
  String get attachPhotosDocuments => _t('Attach Photos / Documents', 'ඡායාරූප / ලේඛන අමුණන්න', 'புகைப்படங்கள் / ஆவணங்களை இணைக்கவும்');
  String get registerMyFarm => _t('Register My Farm', 'මගේ ගොවිපළ ලියාපදිංචි කරන්න', 'எனது பண்ணையை பதிவு செய்க');
  String get alreadyRegisteredFarmer => _t('Already registered as a farmer?', 'දැනටමත් ගොවියෙකු ලෙස ලියාපදිංචි වී තිබේද?', 'ஏற்கனவே விவசாயியாக பதிவு செய்துள்ளீர்களா?');
  String get login => _t('Log In', 'ඇතුල් වන්න', 'உள்நுழைக');

  String get orSignInWithEmail => _t('Or sign in with email', 'හෝ ඊමේල් මඟින් ඇතුල් වන්න', 'அல்லது மின்னஞ்சல் மூலம் உள்நுழைக');
  String get signUp => _t('Sign Up', 'ලියාපදිංචි වන්න', 'பதிவு செய்க');
  String get enterPhoneLabel => _t('Enter your mobile number to receive an SMS verification code', 'SMS තහවුරු කිරීමේ කේතයක් ලබාගැනීමට ඔබගේ ජංගම දුරකථන අංකය ඇතුළත් කරන්න', 'SMS சரிபார்ப்புக் குறியீட்டைப் பெற உங்கள் கைபேசி எண்ணை உள்ளிடவும்');
  String get enterOtpCodeLabel => _t('Enter the 6-digit code sent to your phone', 'ඔබගේ දුරකථනයට එවූ ඉලක්කම් 6 කේතය ඇතුළත් කරන්න', 'உங்கள் தொலைபேசிக்கு அனுப்பப்பட்ட 6 இலக்க குறியீட்டை உள்ளிடவும்');

  String get badgePopular => _t('POPULAR', 'ජනප්‍රිය', 'பிரபலமானது');
  String get badgeEarn => _t('EARN ON ROUTE', 'මාර්ගයේදී උපයන්න', 'பாதையில் சம்பாதிக்கலாம்');

  String get driverLabel => _t('Driver', 'රියදුරු', 'ஓட்டுநர்');
  String get vehicleLabel => _t('Vehicle', 'වාහනය', 'வாகனம்');
  String get allNotificationsMarkedRead => _t('All notifications marked as read', 'සියලුම දැනුම්දීම් කියවූ බව සලකුණු කරන ලදී', 'அனைத்து அறிவிப்புகளும் படித்ததாக குறிக்கப்பட்டன');
  String get filterOrders => _t('Orders', 'ඇණවුම්', 'ஆர்டர்கள்');
  String get filterHarvestAlerts => _t('Harvest Alerts', 'අස්වනු දැනුම්දීම්', 'அறுவடை எச்சரிக்கைகள்');
  String get trackDriverLive => _t('Track Driver Live', 'රියදුරු සජීවීව නිරීක්ෂණය කරන්න', 'ஓட்டுநரை நேரலையாக கண்காணிக்கவும்');
  String get viewHarvestAndReserve => _t('View Harvest & Reserve', 'අස්වැන්න බලා වෙන්කරවා ගන්න', 'அறுவடையைப் பார்த்து முன்பதிவு செய்க');
  String get coldChainCertified => _t('Cold-Chain Certified', 'ශීතකරණ සහතික ලත්', 'குளிர் சங்கிலி சான்றிதழ் பெற்றது');
  String get ecoCrateSealed => _t('Eco-Crate Sealed', 'පරිසර හිතකාමී මුද්‍රා තැබූ කූඩය', 'சுற்றுச்சூழல் பெட்டி சீல் வைக்கப்பட்டது');
  String get tapToRate => _t('Tap to rate experience:', 'අත්දැකීම ශ්‍රේණිගත කරන්න:', 'மதிப்பிட தட்டவும்:');
  String get leaveReviewCoins => _t('Leave Review (+10 Coins)', 'සමාලෝචනයක් එක්කරන්න (+10 කාසි)', 'மதிப்பாய்வு செய்க (+10 நாணயங்கள்)');
  String get farmGatePricingActive => _t('Farm-Gate Direct Pricing is active today', 'අද ගොවිපළ සෘජු මිල ගණන් ක්‍රියාත්මකයි', 'பண்ணை நேரடி விலை இன்று செயல்பாட்டில் உள்ளது');

  String get directFarmers => _t('Direct Farmers', 'සෘජු ගොවීන්', 'நேரடி விவசாயிகள்');
  String get fairTradeCharterBody => _t('We connect buyers directly to verified Sri Lankan producers with zero middlemen and transparent fair pricing.', 'අපි අතරමැදියන් නොමැතිව පාරිභෝගිකයින් සෘජුවම දේශීය ගොවීන් හා සම්බන්ධ කර සාධාරණ මිලක් ලබාදෙමු.', 'இடைத்தரகர்கள் இன்றி நுகர்வோரை விவசாயிகளுடன் இணைத்து நியாயமான விலையை உறுதி செய்கிறோம்.');
  String get appVersionFooter => _t('GoviPola Sri Lanka • Version 1.0.0 (Build 42)', 'ගොවිපොළ ශ්‍රී ලංකා • සංස්කරණය 1.0.0 (නිර්මාණය 42)', 'கோவிபொல இலங்கை • பதிப்பு 1.0.0 (பில்ட் 42)');

  String get enterAddressHint => _t('Enter full delivery address...', 'සම්පූර්ණ බෙදාහැරීමේ ලිපිනය ඇතුළත් කරන්න...', 'முழு டெலிவரி முகவரியை உள்ளிடவும்...');
  String get saveContactNumber => _t('Save Contact Number', 'දුරකථන අංකය සුරකින්න', 'தொடர்பு எண்ணைச் சேமிக்கவும்');
  String get homeDelivery => _t('Home Delivery', 'නිවසටම බෙදාහැරීම', 'வீட்டு டெலிவரி');
  String get selfPickup => _t('Self Pickup', 'ස්වයං ලබාගැනීම', 'சுய எடுப்பு');
  String get scheduledDelivery => _t('Scheduled Delivery', 'නියමිත වේලාවට බෙදාහැරීම', 'திட்டமிடப்பட்ட டெலிவரி');
  String get cardPayment => _t('Credit / Debit Card', 'ක්‍රෙඩිට් / ඩෙබිට් කාඩ්පත්', 'கிரெடிட் / டெபிட் கார்டு');
  String get mobileWallet => _t('Mobile Wallet', 'ජංගම පසුම්බිය', 'மொபைல் வாலட்');
  String get bankTransfer => _t('Bank Transfer', 'බැංකු හුවමාරුව', 'வங்கி பரிமாற்றம்');

  String get highlandAgriCorridor => _t('Central Highland Agri Corridor', 'මධ්‍යම කඳුකර කෘෂි ප්‍රවාහන මාර්ගය', 'மத்திய மலைநாட்டு விவசாய பாதை');
  String get dutyOn => _t('You are now ON DUTY. Ready to receive delivery tasks.', 'ඔබ දැන් රාජකාරියේ නියුතුයි. බෙදාහැරීම් භාරගැනීමට සූදානම්.', 'நீங்கள் இப்போது பணியில் உள்ளீர்கள். டெலிவரிகளைப் பெற தயாராக உள்ளீர்கள்.');
  String get dutyOff => _t('You are now OFF DUTY.', 'ඔබ දැන් රාජකාරියෙන් නිදහස්.', 'நீங்கள் இப்போது பணியில் இல்லை.');
  String get urgentPickup => _t('URGENT PICKUP', 'ක්ෂණික ලබාගැනීම', 'அவசர எடுப்பு');
  String get startRoute => _t('Start Route', 'මාර්ගය ආරම්භ කරන්න', 'பாதையைத் தொடங்குங்கள்');

  String get deliveryHistoryTitle => _t('Delivery History & Log', 'බෙදාහැරීම් ඉතිහාසය සහ වාර්තා', 'டெலிவரி வரலாறு & பதிவு');
  String get earningsAndBankTitle => _t('Earnings & Bank Account', 'ආදායම සහ බැංකු ගිණුම', 'வருமானம் & வங்கிக் கணக்கு');
  String get vehicleDocsTitle => _t('Vehicle Documents & Permit', 'වාහන ලේඛන සහ බලපත්‍ර', 'வாகன ஆவணங்கள் & அனுமதி');
  String get appNotificationsTitle => _t('App Notifications', 'යෙදුම් දැනුම්දීම්', 'பயன்பாட்டு அறிவிப்புகள்');

  String get farmerChatSub => _t('Connect directly with buyers and drivers about orders and harvest', 'ඇණවුම් සහ අස්වනු පිළිබඳව ගැනුම්කරුවන් සහ රියදුරන් සමඟ සෘජුවම සම්බන්ධ වන්න', 'ஆர்டர்கள் மற்றும் அறுவடை பற்றி வாங்குபவர்கள் மற்றும் ஓட்டுநர்களுடன் நேரடியாக தொடர்பு கொள்ளுங்கள்');

}

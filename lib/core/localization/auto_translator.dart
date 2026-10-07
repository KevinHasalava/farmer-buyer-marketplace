import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import 'app_settings.dart';

/// Hybrid Automated Localization & Translation Engine for FarmTrust Marketplace.
///
/// Features:
/// 1. Instant 0ms memory dictionary covering agricultural, e-commerce, UI, and logistics terms.
/// 2. Smart composite phrase and numerical decomposition (currency, units, item counts).
/// 3. Persistent local cache across app launches via [SharedPreferences].
/// 4. Asynchronous fallback translation for custom user/farmer dynamic inputs.
/// 5. Reactive [ChangeNotifier] to update widgets seamlessly when translations complete.
class AppAutoTranslator extends ChangeNotifier {
  AppAutoTranslator._();
  static final AppAutoTranslator instance = AppAutoTranslator._();

  static const String _cachePrefix = 'auto_trans_';
  SharedPreferences? _prefs;
  final Map<String, String> _memoryCache = {};
  final Set<String> _pendingRequests = {};

  /// Initialize persistent cache storage.
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final keys = _prefs?.getKeys() ?? {};
      for (final k in keys) {
        if (k.startsWith(_cachePrefix)) {
          final val = _prefs?.getString(k);
          if (val != null) {
            _memoryCache[k.substring(_cachePrefix.length)] = val;
          }
        }
      }
    } catch (e) {
      debugPrint('[AppAutoTranslator] Init error: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // PUBLIC TRANSLATION API
  // ───────────────────────────────────────────────────────────────────────────

  /// Synchronously returns translated text. If the text is not yet cached or
  /// recognized, returns an intelligent heuristic translation and schedules a
  /// background fetch for future rebuilds.
  String translateSync(String text, AppLanguage targetLang) {
    if (text.isEmpty || targetLang == AppLanguage.english) {
      return text;
    }

    final trimmed = text.trim();
    final langCode = targetLang.code;
    final cacheKey = '${langCode}_$trimmed';

    // 1. Check in-memory persistent cache
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey]!;
    }

    // 2. Check curated instant dictionary
    final dictMatch = _lookupDictionary(trimmed, targetLang);
    if (dictMatch != null) {
      _saveToCache(cacheKey, dictMatch);
      return dictMatch;
    }

    // 3. Smart composite phrase translation (e.g., "Rs. 1,500 / kg", "Fresh Carrot (500g)")
    final compositeMatch = _translateComposite(trimmed, targetLang);
    if (compositeMatch != null) {
      _saveToCache(cacheKey, compositeMatch);
      return compositeMatch;
    }

    // 4. Fallback: Trigger background translation for custom sentences
    _scheduleAsyncTranslation(trimmed, targetLang);

    // Return the original text while background resolution is in progress
    return text;
  }

  /// Asynchronously translates text, guaranteeing fresh resolution and updating cache.
  Future<String> translateAsync(String text, AppLanguage targetLang) async {
    if (text.isEmpty || targetLang == AppLanguage.english) {
      return text;
    }

    final syncResult = translateSync(text, targetLang);
    if (syncResult != text) {
      return syncResult;
    }

    final fetched = await _fetchOnlineTranslation(text, targetLang);
    if (fetched != null && fetched.isNotEmpty) {
      final cacheKey = '${targetLang.code}_${text.trim()}';
      _saveToCache(cacheKey, fetched);
      notifyListeners();
      return fetched;
    }

    return text;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // COMPOSITE & PATTERN TRANSLATION
  // ───────────────────────────────────────────────────────────────────────────

  String? _translateComposite(String input, AppLanguage targetLang) {
    var result = input;
    bool modified = false;

    // Currency formatting
    if (result.contains('Rs.') || result.contains('LKR')) {
      final currency = targetLang == AppLanguage.sinhala ? 'රු.' : 'ரூ.';
      result = result.replaceAll('Rs.', currency).replaceAll('LKR', currency);
      modified = true;
    }

    // Unit replacements
    for (final entry in _unitMap.entries) {
      if (result.toLowerCase().contains(entry.key.toLowerCase())) {
        final replacement = targetLang == AppLanguage.sinhala ? entry.value.$1 : entry.value.$2;
        result = result.replaceAll(RegExp(entry.key, caseSensitive: false), replacement);
        modified = true;
      }
    }

    // Keyword replacements in phrases
    for (final entry in _primaryVocab.entries) {
      final word = entry.key;
      final regex = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
      if (regex.hasMatch(result)) {
        final rep = targetLang == AppLanguage.sinhala ? entry.value.$1 : entry.value.$2;
        result = result.replaceAll(regex, rep);
        modified = true;
      }
    }

    return modified ? result : null;
  }

  String? _lookupDictionary(String text, AppLanguage targetLang) {
    final lower = text.toLowerCase();

    // Exact match in primary vocabulary
    for (final entry in _primaryVocab.entries) {
      if (entry.key.toLowerCase() == lower) {
        return targetLang == AppLanguage.sinhala ? entry.value.$1 : entry.value.$2;
      }
    }

    // UI phrases exact match
    for (final entry in _uiPhrases.entries) {
      if (entry.key.toLowerCase() == lower) {
        return targetLang == AppLanguage.sinhala ? entry.value.$1 : entry.value.$2;
      }
    }

    return null;
  }

  void _saveToCache(String key, String value) {
    _memoryCache[key] = value;
    _prefs?.setString('$_cachePrefix$key', value);
  }

  void _scheduleAsyncTranslation(String text, AppLanguage targetLang) {
    final key = '${targetLang.code}_$text';
    if (_pendingRequests.contains(key)) return;
    _pendingRequests.add(key);

    Timer(const Duration(milliseconds: 100), () async {
      try {
        final result = await _fetchOnlineTranslation(text, targetLang);
        if (result != null && result.isNotEmpty && result.toLowerCase() != text.toLowerCase()) {
          _saveToCache(key, result);
          notifyListeners();
        }
      } catch (e) {
        debugPrint('[AppAutoTranslator] Background translation error: $e');
      } finally {
        _pendingRequests.remove(key);
      }
    });
  }

  Future<String?> _fetchOnlineTranslation(String text, AppLanguage targetLang) async {
    HttpClient? client;
    try {
      final langPair = 'en|${targetLang.code}';
      final uri = Uri.parse(
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=$langPair',
      );
      client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        final translatedText = data['responseData']?['translatedText'] as String?;
        if (translatedText != null &&
            !translatedText.contains('MYMEMORY WARNING') &&
            translatedText.trim().isNotEmpty) {
          return translatedText.trim();
        }
      }
    } catch (_) {
      // Silently ignore network failures; offline vocabulary guarantees core operation.
    } finally {
      client?.close();
    }
    return null;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CURATED AGRICULTURAL & COMMERCE VOCABULARY DICTIONARY
  // ───────────────────────────────────────────────────────────────────────────

  static const Map<String, (String, String)> _unitMap = {
    '/kg': ('/කි.ග්‍රෑ', '/கி.கி'),
    'kg': ('කි.ග්‍රෑ', 'கி.கி'),
    '/500g': ('/500ග්‍රෑ', '/500கிராம்'),
    '500g': ('500ග්‍රෑ', '500கிராம்'),
    '/100g': ('/100ග්‍රෑ', '/100கிராம்'),
    '100g': ('100ග්‍රෑ', '100கிராம்'),
    '/bundle': ('/මිටිය', '/கட்டு'),
    'bundle': ('මිටිය', 'கட்டு'),
    '/pack': ('/ඇසුරුම', '/பாக்கெட்'),
    'pack': ('ඇසුරුම', 'பாக்கெட்'),
    '/bottle': ('/බෝතලය', '/பாட்டில்'),
    'bottle': ('බෝතලය', 'பாட்டில்'),
    '/pot': ('/හට්ටිය', '/சட்டி'),
    'pot': ('හට්ටිය', 'சட்டி'),
    '/crate': ('/කූඩය', '/பெட்டி'),
    'crate': ('කූඩය', 'பெட்டி'),
    '/item': ('/එකක්', '/ஒன்று'),
    '/each': ('/එකක්', '/ஒன்று'),
  };

  static const Map<String, (String, String)> _primaryVocab = {
    // ── Vegetables ─────────────────────────────────────────────────────────────
    'Carrot': ('කැරට්', 'கேரட்'),
    'Carrots': ('කැරට්', 'கேரட்'),
    'Tomato': ('තක්කාලි', 'தக்காளி'),
    'Tomatoes': ('තක්කාලි', 'தக்காளி'),
    'Leek': ('ලීක්ස්', 'லீக்ஸ்'),
    'Leeks': ('ලීක්ස්', 'லீக்ஸ்'),
    'Potato': ('අර්තාපල්', 'உருளைக்கிழங்கு'),
    'Potatoes': ('අර්තාපල්', 'உருளைக்கிழங்கு'),
    'Cabbage': ('ගෝවා', 'முட்டைக்கோஸ்'),
    'Capsicum': ('මාළු මිරිස්', 'குடைமிளகாய்'),
    'Bell Pepper': ('මාළු මිරිස්', 'குடைமிளகாய்'),
    'Chili': ('මිරිස්', 'மிளகாய்'),
    'Green Chili': ('අමු මිරිස්', 'பச்சை மிளகாய்'),
    'Red Chili': ('රතු මිරිස්', 'சிவப்பு மிளகாய்'),
    'Onion': ('ලූනු', 'வெங்காயம்'),
    'Red Onion': ('රතු ලූනු', 'சிவப்பு வெங்காயம்'),
    'Big Onion': ('බී ලූනු', 'பெரிய வெங்காயம்'),
    'Pumpkin': ('වට්ටක්කා', 'பூசணிக்காய்'),
    'Beans': ('බෝංචි', 'பீன்ஸ்'),
    'Green Beans': ('බෝංචි', 'பச்சை பீன்ஸ்'),
    'Eggplant': ('වම්බටු', 'கத்தரிக்காய்'),
    'Brinjal': ('වම්බටු', 'கத்தரிக்காய்'),
    'Cucumber': ('පිපිඤ්ඤා', 'வெள்ளரிக்காய்'),
    'Beetroot': ('බීට්රූට්', 'பீட்ரூட்'),
    'Broccoli': ('බ්‍රොකොලි', 'ப்ரோக்கோலி'),
    'Radish': ('රාබු', 'முள்ளங்கி'),
    'Ladies Finger': ('බණ්ඩක්කා', 'வெண்டைக்காய்'),
    'Okra': ('බණ්ඩක්කා', 'வெண்டைக்காய்'),
    'Bitter Gourd': ('කරවිල', 'பாகற்காய்'),
    'Snake Gourd': ('පතෝල', 'புடலங்காய்'),
    'Ridge Gourd': ('වැටකොළු', 'பீர்க்கங்காய்'),
    'Winged Beans': ('දඹල', 'சிறகு அவரை'),
    'Long Beans': ('මෑකරල්', 'பயற்றங்காய்'),
    'Knol Khol': ('නෝකෝල්', 'நோல்கோல்'),
    'Sweet Potato': ('බතල', 'சர்க்கரைவள்ளிக்கிழங்கு'),
    'Manioc': ('මඤ්ඤොක්කා', 'மரவள்ளிக்கிழங்கு'),
    'Cassava': ('මඤ්ඤොක්කා', 'மரவள்ளிக்கிழங்கு'),
    'Kiri Ala': ('කිරි අල', 'சேப்பங்கிழங்கு'),
    'Taro': ('කිරි අල', 'சேப்பங்கிழங்கு'),
    'Kohila': ('කොහිල', 'கொஹில'),

    // ── Fruits ────────────────────────────────────────────────────────────────
    'Avocado': ('අලිගැටපේර', 'அவகேடோ'),
    'Papaya': ('පැපොල්', 'பப்பாளி'),
    'Mango': ('අඹ', 'மாம்பழம்'),
    'Banana': ('කෙසෙල්', 'வாழைப்பழம்'),
    'Pineapple': ('අන්නාසි', 'அன்னாசி'),
    'Passion Fruit': ('පැෂන් ෆෘට්', 'பாஷன் பழம்'),
    'King Coconut': ('තැඹිලි', 'செவ்விளநீர்'),
    'Coconut': ('පොල්', 'தேங்காய்'),
    'Guava': ('පේර', 'கொய்யா'),
    'Watermelon': ('කොමඩු', 'தர்பூசணி'),
    'Orange': ('දොඩම්', 'ஆரஞ்சு'),
    'Lime': ('දෙහි', 'எலுமிச்சை'),
    'Strawberry': ('ස්ට්‍රෝබෙරි', 'ஸ்ட்ராபெரி'),
    'Rambutan': ('රඹුටන්', 'ரம்புட்டான்'),
    'Mangosteen': ('මැංගුස්', 'மங்குஸ்தான்'),
    'Woodapple': ('දිවුල්', 'விளாம்பழம்'),

    // ── Grains & Rice ─────────────────────────────────────────────────────────
    'Keeri Samba': ('කීරි සම්බා', 'கீரி சம்பா'),
    'Samba Rice': ('සම්බා සහල්', 'சம்பா அரிசி'),
    'Red Rice': ('රතු කැකුළු', 'சிவப்பு அரிசி'),
    'White Rice': ('සුදු කැකුළු', 'வெள்ளை அரிசி'),
    'Nadu Rice': ('නාඩු සහල්', 'நாடு அரிசி'),
    'Suwandel': ('සුවඳැල්', 'சுவந்தெல்'),
    'Kurakkan': ('කුරක්කන්', 'குரக்கன்'),
    'Finger Millet': ('කුරක්කන්', 'குரக்கன்'),
    'Green Gram': ('මුං ඇට', 'பச்சைப்பயறு'),
    'Cowpea': ('කවුපි', 'காராமணி'),
    'Chickpeas': ('කඩල', 'கொண்டைக்கடலை'),
    'Sesame': ('තල', 'எள்'),

    // ── Spices & Herbs ────────────────────────────────────────────────────────
    'Cinnamon': ('කුරුඳු', 'இலவங்கப்பட்டை'),
    'Black Pepper': ('කළු ගම්මිරිස්', 'கருப்பு மிளகு'),
    'Pepper': ('ගම්මිරිස්', 'மிளகு'),
    'Cardamom': ('කරදමුංගු', 'ஏலக்காய்'),
    'Cloves': ('කරාබුනැටි', 'கிராம்பு'),
    'Nutmeg': ('සාදික්කා', 'ஜாதிக்காய்'),
    'Turmeric': ('කහ', 'மஞ்சள்'),
    'Ginger': ('ඉඟුරු', 'இஞ்சி'),
    'Garlic': ('සුදුලූනු', 'பூண்டு'),
    'Goraka': ('ගොරකා', 'குடம்புளி'),
    'Coriander': ('කොත්තමල්ලි', 'கொத்தமல்லி'),
    'Cumin': ('සූදුරු', 'சீரகம்'),
    'Mustard': ('අබ', 'கடுகு'),
    'Curry Leaves': ('කරපිංචා', 'கறிவேப்பிலை'),
    'Pandan': ('රම්පේ', 'ரம்பை'),
    'Lemongrass': ('සේර', 'எலுமிச்சம்புல்'),

    // ── Greens ────────────────────────────────────────────────────────────────
    'Gotukola': ('ගොටුකොළ', 'வல்லாரை'),
    'Mukunuwenna': ('මුකුණුවැන්න', 'பொன்னாங்கண்ணி'),
    'Kangkung': ('කංකුං', 'கங்குன்'),
    'Spinach': ('නිවිති', 'பசலைக்கீரை'),
    'Moringa': ('මුරුංගා', 'முருங்கை'),
    'Sarana': ('සාරණ', 'சாரணை'),

    // ── Traditional & Dairy ───────────────────────────────────────────────────
    'Curd': ('මීකිරි', 'எருமைத் தயிர்'),
    'Buffalo Curd': ('රුහුණු මීකිරි', 'ருஹுணு எருமைத் தயிர்'),
    'Honey': ('මීපැණි', 'தேன்'),
    'Wild Honey': ('වන මීපැණි', 'காட்டுத் தேன்'),
    'Farm Eggs': ('ගම්බිත්තර', 'நாட்டுக்கோழி முட்டை'),
    'Eggs': ('බිත්තර', 'முட்டை'),
    'Kitul Treacle': ('කිතුල් පැණි', 'கித்துள் பாகு'),
    'Kitul Jaggery': ('කිතුල් හකුරු', 'கித்துள் சர்க்கரை'),
    'Fresh Milk': ('නැවුම් එළකිරි', 'புதிய பால்'),

    // ── Quality & Badges ──────────────────────────────────────────────────────
    'Fresh': ('නැවුම්', 'புதிய'),
    'Organic': ('කාබනික', 'இயற்கை'),
    '100% Organic': ('100% කාබනික', '100% இயற்கை'),
    'Picked Today': ('අද නෙළූ', 'இன்று பறிக்கப்பட்டது'),
    'Just In': ('දැන්ම ලැබුණු', 'புதிய வரவு'),
    'Best Value': ('ඉහළම වටිනාකම', 'சிறந்த மதிப்பு'),
    'Export Grade': ('අපනයන තත්ත්වයේ', 'ஏற்றுமதி தரம்'),
    'Direct Farm': ('සෘජු ගොවිපළ', 'நேரடி பண்ணை'),
    'Local': ('දේශීය', 'உள்ளூர்'),
    'Verified': ('තහවුරු කළ', 'சரிபார்க்கப்பட்டது'),
    'In Stock': ('තොග ඇත', 'கையிருப்பில் உள்ளது'),
    'Out of Stock': ('තොග අවසන්', 'கையிருப்பில் இல்லை'),
  };

  static const Map<String, (String, String)> _uiPhrases = {
    // ── Navigation & Common Actions ───────────────────────────────────────────
    'Home': ('මුල් පිටුව', 'முகப்பு'),
    'Categories': ('ප්‍රවර්ග', 'வகைகள்'),
    'My Cart': ('මගේ කරත්තය', 'என் கூடை'),
    'Cart': ('කරත්තය', 'கூடை'),
    'Orders': ('ඇණවුම්', 'ஆர்டர்கள்'),
    'Profile': ('ගිණුම', 'சுயவிவரம்'),
    'Search': ('සොයන්න', 'தேடல்'),
    'Search products': ('නිෂ්පාදන සොයන්න', 'பொருட்களைத் தேடுங்கள்'),
    'Filter': ('පෙරහන්', 'வடிகட்டி'),
    'Sort by': ('අනුපිළිවෙල', 'வரிசைப்படுத்து'),
    'View All': ('සියල්ල බලන්න', 'அனைத்தையும் பார்'),
    'See More': ('තවත් බලන්න', 'மேலும் பார்க்க'),
    'Back': ('ආපසු', 'பின்செல்'),
    'Next': ('ඉදිරියට', 'அடுத்து'),
    'Done': ('අවසන්', 'முடிந்தது'),
    'Submit': ('යොමු කරන්න', 'சமர்ப்பிக்கவும்'),
    'Save': ('සුරකින්න', 'சேமிக்கவும்'),
    'Cancel': ('අවලංගු කරන්න', 'ரத்து செய்'),
    'Confirm': ('තහවුරු කරන්න', 'உறுதி செய்'),
    'Apply': ('යොදන්න', 'பயன்படுத்துக'),
    'Clear': ('හිස් කරන්න', 'அழிக்கவும்'),
    'Delete': ('මකන්න', 'நீக்கு'),
    'Edit': ('සංස්කරණය', 'திருத்து'),
    'Loading': ('පූරණය වෙමින්...', 'ஏற்றுகிறது...'),
    'Success': ('සාර්ථකයි', 'வெற்றி'),
    'Error': ('දෝෂයක්', 'பிழை'),
    'Retry': ('නැවත උත්සාහ කරන්න', 'மீண்டும் முயற்சிக்கவும்'),
    'Yes': ('ඔව්', 'ஆம்'),
    'No': ('නැත', 'இல்லை'),

    // ── Cart & Checkout ───────────────────────────────────────────────────────
    'Add to Cart': ('කරත්තයට එක්කරන්න', 'கூடையில் சேர்க்கவும்'),
    'Buy Now': ('දැන්ම මිලදී ගන්න', 'இப்போதே வாங்குக'),
    'Checkout': ('ගෙවීම් පිටුවට', 'பணம் செலுத்துக'),
    'Proceed to Checkout': ('ගෙවීම සඳහා ඉදිරියට යන්න', 'செக் அவுட்டுக்கு செல்க'),
    'Item Details': ('භාණ්ඩ විස්තර', 'பொருள் விவரங்கள்'),
    'Order Summary': ('ඇණවුම් සාරාංශය', 'ஆர்டர் சுருக்கம்'),
    'Order Total': ('ඇණවුමේ මුළු මුදල', 'ஆர்டர் மொத்தம்'),
    'Delivery Address': ('බෙදාහැරීමේ ලිපිනය', 'டெலிவரி முகவரி'),
    'Payment Method': ('ගෙවීම් ක්‍රමය', 'கட்டண முறை'),
    'Cash on Delivery': ('භාණ්ඩ ලැබුණු පසු මුදල් ගෙවීම', 'டெலிவரியின் போது பணம்'),
    'Total Payment': ('ගෙවිය යුතු මුළු මුදල', 'மொத்த கட்டணம்'),
    'Free Delivery': ('නොමිලේ බෙදාහැරීම', 'இலவச டெலிவரி'),
    'Discount': ('වට්ටම', 'தள்ளுபடி'),
    'Promo Code': ('ප්‍රවර්ධන කේතය', 'ப்ரோமோ குறியீடு'),
    'Apply Promo': ('කේතය යොදන්න', 'குறியீட்டைப் பயன்படுத்து'),

    // ── Farmer & Products ─────────────────────────────────────────────────────
    'Farmer Dashboard': ('ගොවි පාලක පුවරුව', 'விவசாயி டாஷ்போர்டு'),
    'My Products': ('මගේ නිෂ්පාදන', 'என் பொருட்கள்'),
    'Add New Product': ('නව නිෂ්පාදනයක් එක්කරන්න', 'புதிய பொருளைச் சேர்க்கவும்'),
    'Edit Product': ('නිෂ්පාදනය සංස්කරණය කරන්න', 'பொருளைத் திருத்தவும்'),
    'Product Name': ('නිෂ්පාදනයේ නම', 'பொருளின் பெயர்'),
    'Category': ('ප්‍රවර්ගය', 'வகை'),
    'Price per Unit': ('ඒකකයක මිල', 'ஒரு யூனிட் விலை'),
    'Available Quantity': ('පවතින ප්‍රමාණය', 'கிடைக்கக்கூடிய அளவு'),
    'Harvest Date': ('අස්වනු නෙළූ දිනය', 'அறுவடை தேதி'),
    'Farm Location': ('ගොවිපළ පිහිටීම', 'பண்ணை இருப்பிடம்'),
    'Description': ('විස්තරය', 'விவரம்'),

    // ── Logistics & Driver ────────────────────────────────────────────────────
    'Driver Dashboard': ('රියදුරු පාලක පුවරුව', 'ஓட்டுநர் டாஷ்போர்டு'),
    'Delivery Status': ('බෙදාහැරීමේ තත්ත්වය', 'டெலிவரி நிலை'),
    'Assigned Deliveries': ('පවරා ඇති බෙදාහැරීම්', 'ஒதுக்கப்பட்ட டெலிவரிகள்'),
    'Pickup Location': ('ලබාගන්නා ස්ථානය', 'எடுக்கும் இடம்'),
    'Dropoff Location': ('භාරදෙන ස්ථානය', 'இறக்கும் இடம்'),
    'Start Delivery': ('බෙදාහැරීම ආරම්භ කරන්න', 'டெலிவரியைத் தொடங்கு'),
    'Delivery Completed': ('බෙදාහැරීම සම්පූර්ණයි', 'டெலிவரி முடிந்தது'),
    'Track Live': ('සජීවීව නිරීක්ෂණය කරන්න', 'நேரலையாக கண்காணிக்கவும்'),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// CONVENIENCE EXTENSIONS & WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// Extension to auto-translate any string dynamically in the active build context.
extension AutoTranslateStringX on String {
  /// Translates the string automatically to the active app language.
  String trAuto(BuildContext context) {
    final lang = context.currentLanguage;
    return AppAutoTranslator.instance.translateSync(this, lang);
  }

  /// Translates the string directly to a specific [AppLanguage].
  String trAutoLang(AppLanguage lang) {
    return AppAutoTranslator.instance.translateSync(this, lang);
  }
}

/// A drop-in replacement for [Text] that automatically translates any string
/// into the current user-selected language with optimal Noto Sans typography.
class AutoText extends StatelessWidget {
  const AutoText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.overflow,
    this.maxLines,
    this.softWrap,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    final lang = context.currentLanguage;
    final translated = AppAutoTranslator.instance.translateSync(text, lang);

    // Apply native localized typography (Noto Sans Sinhala / Tamil)
    final resolvedStyle = AppTheme.fontStyle(
      lang,
      fontSize: style?.fontSize,
      fontWeight: style?.fontWeight,
      color: style?.color,
      letterSpacing: style?.letterSpacing,
      height: style?.height,
    ).merge(style);

    return Text(
      translated,
      style: resolvedStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
    );
  }
}

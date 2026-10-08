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
    for (final entry in _compositeKeywords.entries) {
      final word = entry.key;
      final regex = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
      if (regex.hasMatch(result)) {
        final rep = targetLang == AppLanguage.sinhala ? entry.value.$1 : entry.value.$2;
        result = result.replaceAll(regex, rep);
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
    'crates': ('කූඩ', 'பெட்டிகள்'),
    '/item': ('/එකක්', '/ஒன்று'),
    '/each': ('/එකක්', '/ஒன்று'),
    'km': ('කි.මී.', 'கி.மீ'),
    'km/h': ('පැ.කි.මී.', 'கி.மீ/மணி'),
  };

  static const Map<String, (String, String)> _compositeKeywords = {
    // ── Time & Duration ───────────────────────────────────────────────────────
    'Today': ('අද', 'இன்று'),
    'Yesterday': ('ඊයේ', 'நேற்று'),
    'AM': ('පෙ.ව.', 'மு.ப.'),
    'PM': ('ප.ව.', 'பி.ப.'),
    'm ago': ('මිනි. පෙර', 'நிமி. முன்'),
    'h ago': ('පැය පෙර', 'மணி முன்'),
    'away': ('ඈතින්', 'தொலைவில்'),
    'min': ('මිනි.', 'நிமி.'),
    'Due': ('නියමිත', 'நேரம்'),
    'Due in': ('නියමිතයි:', 'நேரம்:'),
    'Scheduled': ('නියමිතයි', 'திட்டமிடப்பட்டது'),
    'Delivered': ('බෙදාහරින ලදී', 'வழங்கப்பட்டது'),
    'Completed': ('සම්පූර්ණයි', 'முடிந்தது'),
    'peak': ('උපරිම', 'உச்சம்'),
    'tips': ('පාරිතෝෂික', 'டிப்ஸ்'),

    // ── Geographic & Address Elements ─────────────────────────────────────────
    'Farm Gate': ('ගොවිපළ දොරටුව', 'பண்ணை வாயில்'),
    'Gate': ('දොරටුව', 'வாயில்'),
    'North': ('උතුරු', 'வடக்கு'),
    'South': ('දකුණු', 'தெற்கு'),
    'East': ('නැගෙනහිර', 'கிழக்கு'),
    'West': ('බටහිර', 'மேற்கு'),
    'Central': ('මධ්‍යම', 'மத்திய'),
    'Depot': ('ඩිපෝව', 'கிடங்கு'),
    'Hub': ('මධ්‍යස්ථානය', 'மையம்'),
    'Market': ('වෙළඳපොළ', 'சந்தை'),
    'Farm': ('ගොවිපළ', 'பண்ணை'),
    'Road': ('පාර', 'வீதி'),
    'Rd': ('පාර', 'வீதி'),
    'Street': ('වීදිය', 'தெரு'),
    'Avenue': ('මාවත', 'அவென்யூ'),
    'Pass': ('කපොල්ල', 'கணவாய்'),
    'Valley': ('නිම්නය', 'பள்ளத்தாக்கு'),
    'Highlands': ('කඳුකරය', 'மலைநாடு'),
    'Highland': ('කඳුකර', 'மலைநாட்டு'),
    'Center': ('මධ්‍යස්ථානය', 'மையம்'),
    'Co-Op': ('සමුපකාරය', 'கூட்டுறவு'),
    'Cooperative': ('සමුපකාර', 'கூட்டுறவு'),
    'Province': ('පළාත', 'மாகாணம்'),
    'Urban': ('නාගරික', 'நகர'),
    'Wholesale': ('තොග', 'மொத்த'),
    'Retail': ('සිල්ලර', 'சில்லறை'),
    'Corridor': ('ප්‍රවාහන කලාපය', 'பாதை'),
    'Pass Road': ('කඳුකර පාර', 'மலைப்பாதை சாலை'),

    // ── Cities & Towns ────────────────────────────────────────────────────────
    'Hakgala': ('හග්ගල', 'ஹக்கல'),
    'Nuwara Eliya': ('නුවරඑළිය', 'நுவரெலியா'),
    'Colombo': ('කොළඹ', 'கொழும்பு'),
    'Havelock': ('හැව්ලොක්', 'ஹேவ்லாக்'),
    'Welimada': ('වැලිමඩ', 'வெலிமட'),
    'Kandy': ('මහනුවර', 'கண்டி'),
    'Maharagama': ('මහරගම', 'மஹரகம'),
    'Bandarawela': ('බණ්ඩාරවෙල', 'பண்டாரவளை'),
    'Nugegoda': ('නුගේගොඩ', 'நுகேகொட'),
    'Keppetipola': ('කැප්පෙටිපොළ', 'கெப்பட்டிபொல'),
    'Moratuwa': ('මොරටුව', 'மொரட்டுவ'),
    'Battaramulla': ('බත්තරමුල්ල', 'பத்தரமுல்ல'),
    'Rajagiriya': ('රාජගිරිය', 'ராஜகிரிய'),
    'Colpetty': ('කොල්ලුපිටිය', 'கொல்லுப்பிட்டி'),
    'Dambulla': ('දඹුල්ල', 'தம்புள்ளை'),
    'Dehiwala': ('දෙහිවල', 'தெஹிவளை'),
    'Ragala': ('රාගල', 'ராகல'),
    'Badulla': ('බදුල්ල', 'பதுளை'),

    // ── Produce Modifiers ─────────────────────────────────────────────────────
    'Produce': ('අස්වනු', 'விளைச்சல்'),
    'Bulk': ('තොග', 'மொத்த'),
    'Greens': ('කොළ එළවළු', 'கீரை வகைகள்'),
    'Salad': ('සලාද', 'சாலட்'),
    'Mixed': ('මිශ්‍ර', 'கலப்பு'),
    'Crisp': ('නැවුම්', 'புதிய'),
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
    "Today's Shift Pulse": ('අද දවසේ සාරාංශය', 'இன்றைய பணித் துடிப்பு'),
    'Shift Pulse': ('දවසේ සාරාංශය', 'பணித் துடிப்பு'),
    '6 Scheduled': ('6ක් නියමිතයි', '6 திட்டமிடப்பட்டது'),
    '4 Delivered Today': ('අද 4ක් බෙදාහරින ලදී', 'இன்று 4 வழங்கப்பட்டது'),
    'Delivered Today': ('අද බෙදාහරින ලදී', 'இன்று வழங்கப்பட்டது'),
    'Scheduled': ('නියමිතයි', 'திட்டமிடப்பட்டது'),
    'Net Earnings': ('ශුද්ධ ආදායම', 'நிகர வருமானம்'),
    "Today's Earnings": ('අද උපයාගත් ආදායම', 'இன்றைய வருமானம்'),
    'Corridor Route Map': ('ප්‍රවාහන මාර්ග සිතියම', 'பாதை வரைபடம்'),
    'A7 Highway Clear': ('A7 මහාමාර්ගය පැහැදිලියි', 'A7 நெடுஞ்சாலை தெளிவானது'),
    'Live Transit: 38 km/h': ('සජීවී ප්‍රවාහනය: පැ.කි.මී. 38', 'நேரலை போக்குவரத்து: 38 கி.மீ/மணி'),
    'Live Transit': ('සජීවී ප්‍රවාහනය', 'நேரலை போக்குவரத்து'),
    'Hakgala Corridor': ('හග්ගල ප්‍රවාහන කලාපය', 'ஹக்கல பாதை'),
    'Cargo Chiller: 12°C': ('ශීතකරණ උෂ්ණත්වය: 12°C', 'சரக்கு குளிரூட்டி: 12°C'),
    'Cargo Chiller': ('ශීතකරණ පද්ධතිය', 'சரக்கு குளிரூட்டி'),
    'Target 10°C - 14°C • Veg Safe': ('ඉලක්කය 10°C - 14°C • එළවළු සුරක්ෂිතයි', 'இலக்கு 10°C - 14°C • காய்கறி பாதுகாப்பு'),
    'Optimal': ('උපරිම මට්ටමේ', 'உகந்தது'),
    'Est. Payout': ('ඇස්තමේන්තු ගෙවීම', 'மதிப்பிடப்பட்ட ஊதியம்'),
    'PICKUP LOCATION': ('ලබාගන්නා ස්ථානය', 'எடுக்கும் இடம்'),
    'DROPOFF BUYER': ('භාරදෙන ගැනුම්කරු', 'ஒப்படைக்கும் வாங்குபவர்'),
    'DROPOFF LOCATION': ('භාරදෙන ස්ථානය', 'இறக்கும் இடம்'),
    'Order Details': ('ඇණවුම් විස්තර', 'ஆர்டர் விவரங்கள்'),
    'Delivery History': ('බෙදාහැරීම් ඉතිහාසය', 'டெலிவரி வரலாறு'),
    'Verified Driver': ('සත්‍යාපිත රියදුරු', 'சரிபார்க்கப்பட்ட ஓட்டுநர்'),
    'This Week': ('මෙම සතියේ', 'இந்த வாரம்'),
    'Last Week': ('පසුගිය සතියේ', 'கடந்த வாரம்'),
    'This Month': ('මෙම මාසයේ', 'இந்த மாதம்'),
    'Trips Made': ('සිදුකළ ගමන්', 'செய்த பயணங்கள்'),
    'On-Time Rate': ('නියමිත වේලාවට %', 'சரியான நேரத்தில் %'),
    'COMPLETED TRIPS': ('සම්පූර්ණ කළ ගමන්', 'முடித்த பயணங்கள்'),
    'Completed Trips': ('සම්පූර්ණ කළ ගමන්', 'முடித்த பயணங்கள்'),
    'Pickup': ('ලබාගැනීම', 'எடுப்பு'),
    'Drop': ('භාරදීම', 'ஒப்படைப்பு'),
    '100% Farm Fresh Assured': ('100% ගොවිපොළ නැවුම් බව තහවුරුයි', '100% பண்ணை புத்துணர்ச்சி உறுதி'),
    'Download Tax & Payment Statement (PDF)': ('බදු සහ ගෙවීම් වාර්තාව බාගන්න (PDF)', 'வரி & கட்டண அறிக்கையை பதிவிறக்கவும் (PDF)'),
    'OFFICIAL DRIVER STATEMENT': ('නිල රියදුරු ගෙවීම් වාර්තාව', 'அதிகாரப்பூர்வ ஓட்டுநர் அறிக்கை'),
    'Official Driver Payout & Tax Statement': ('නිල රියදුරු ගෙවීම් සහ බදු ප්‍රකාශනය', 'அதிகாரப்பூர்வ ஓட்டுநர் கட்டண & வரி அறிக்கை'),
    'Period': ('කාලසීමාව', 'காலம்'),
    'Generated On': ('ජනනය කළ දිනය', 'உருவாக்கப்பட்ட தேதி'),
    'Driver ID': ('රියදුරු අංකය', 'ஓட்டுநர் அடையாள எண்'),
    'Vehicle Plate': ('වාහන අංකය', 'வாகன எண்'),
    'License Class': ('බලපත්‍ර පන්තිය', 'உரிம வகுப்பு'),
    'Total Deliveries': ('මුළු බෙදාහැරීම්', 'மொத்த டெலிவரிகள்'),
    'Completed Deliveries': ('සම්පූර්ණ කළ බෙදාහැරීම්', 'முடித்த டெலிவரிகள்'),
    'Gross Compensation': ('මුළු ආදායම', 'மொத்த வருமானம்'),
    'Fuel Surcharge': ('ඉන්ධන සහනාධාරය', 'எரிபொருள் கூடுதல் கட்டணம்'),
    'Net Remittance': ('ශුද්ධ ගෙවීම', 'நிகர பணம்'),
    'Trip Breakdown': ('ගමන් විස්තරය', 'பயண விவரம்'),
    'Date / Time': ('දිනය / වේලාව', 'தேதி / நேரம்'),
    'From / To': ('සිට / දක්වා', 'இருந்து / வரை'),
    'Cargo Item': ('අස්වනු භාණ්ඩ', 'சரக்கு பொருள்'),
    'Fee': ('ගාස්තුව', 'கட்டணம்'),
    'Signature of Operations Officer': ('මෙහෙයුම් නිලධාරී අත්සන', 'செயல்பாட்டு அதிகாரியின் கையொப்பம்'),
    'System Generated Cryptographic Audit Seal': ('පද්ධතියෙන් ජනනය කළ විගණන මුද්‍රාව', 'கணினி உருவாக்கிய தணிக்கை முத்திரை'),
    'Download Official PDF (Signed)': ('නිල PDF වාර්තාව බාගන්න (අත්සන් සහිත)', 'அதிகாரப்பூர்வ PDF பதிவிறக்குக (கையொப்பமிடப்பட்டது)'),
    'PDF Statement Downloaded!': ('PDF වාර්තාව බාගත විය!', 'PDF அறிக்கை பதிவிறக்கப்பட்டது!'),
    'Open Statement': ('වාර්තාව විවෘත කරන්න', 'அறிக்கையை திறக்கவும்'),
    'Remove Trip Record?': ('ගමන් වාර්තාව ඉවත් කරන්නද?', 'பயண பதிவை நீக்கவா?'),
    'Remove Record': ('වාර්තාව ඉවත් කරන්න', 'பதிவை நீக்கு'),
    'Navigate to Farm': ('ගොවිපළට මඟපෙන්වන්න', 'பண்ணைக்கு செல்லவும்'),
    '3 Crates': ('කූඩ 3ක්', '3 பெட்டிகள்'),
    'Priority Dispatch': ('ප්‍රමුඛතා බෙදාහැරීම', 'முன்னுரிமை அனுப்புதல்'),
    'Mountain Pass Road': ('කඳුකර මාර්ගය', 'மலைப்பாதை சாலை'),
    'Welimada Valley Pass': ('වැලිමඩ නිම්න මාර්ගය', 'வெலிமட பள்ளத்தாக்கு பாதை'),
    'Base Haul Rate': ('මූලික ප්‍රවාහන ගාස්තුව', 'அடிப்படை போக்குவரத்து கட்டணம்'),
    'Transit Allowance': ('ප්‍රවාහන දීමනාව', 'போக்குவரத்து படி'),
    'Total Driver Earning': ('මුළු රියදුරු ආදායම', 'மொத்த ஓட்டுநர் வருமானம்'),
    'Pickup By': ('ලබාගත යුතු වේලාව', 'பிக்அப் நேரம்'),
    'Dropoff By': ('භාරදිය යුතු වේලාව', 'ஒப்படைக்கும் நேரம்'),
    'Slide to Start Live Navigation': ('සජීවී මඟපෙන්වීම සඳහා ස්ලයිඩ් කරන්න', 'நேரலை வழிசெலுத்தலுக்கு சறுக்குங்கள்'),
    'Confirm Handover & View Receipt →': ('භාරදීම තහවුරු කර බිල්පත බලන්න →', 'ஒப்படைப்பை உறுதிசெய்து ரசீதை காண்க →'),
    'Handover Produce • View Receipt →': ('අස්වැන්න භාරදෙන්න • බිල්පත බලන්න →', 'பொருட்களை ஒப்படைக்கவும் • ரசீது பார்க்க →'),
    'Open Direct Chat': ('සෘජු සංවාදය අරඹන්න', 'நேரடி அரட்டை திறக்க'),
    'Call Buyer Now': ('පාරිභෝගිකයාට දැන් අමතන්න', 'வாங்குபவரை இப்போது அழைக்கவும்'),
    'Revenue License (WP)': ('ආදායම් බලපත්‍රය (බස්නාහිර)', 'வருமான வரி உரிமம் (மேல் மாகாணம்)'),
    'Commercial Goods Transit Permit': ('වාණිජ භාණ්ඩ ප්‍රවාහන බලපත්‍රය', 'வணிக பொருட்கள் போக்குவரத்து அனுமதி'),
    'Cold Chain Agro Sanitation Pass': ('ශීතකරණ කෘෂි සනීපාරක්ෂක බලපත්‍රය', 'குளிர் சங்கிலி விவசாய சுகாதார சான்றிதழ்'),
    'Approved & Active': ('අනුමත කර සක්‍රීයයි', 'அங்கீகரிக்கப்பட்டு செயலில் உள்ளது'),
    'Grade A Certified': ('Grade A සහතික ලත්', 'Grade A சான்றளிக்கப்பட்டது'),
    'DRIVER': ('රියදුරු', 'ஓட்டுநர்'),
    '66% Completed': ('66% සම්පූර්ණයි', '66% முடிந்தது'),
    '+2 peak': ('+2 උපරිම', '+2 உச்சம்'),
    '+1.2k tips': ('+1.2k පාරිතෝෂික', '+1.2k டிப்ஸ்'),
    '2.4 km away': ('කි.මී. 2.4ක් ඈතින්', '2.4 கி.மீ தொலைவில்'),
    '22.8 km away': ('කි.මී. 22.8ක් ඈතින්', '22.8 கி.மீ தொலைவில்'),
    '14.2 km': ('කි.මී. 14.2', '14.2 கி.மீ'),
    '22.8 km': ('කි.මී. 22.8', '22.8 கி.மீ'),
    'Start Pickup Route': ('ප්‍රවාහන මාර්ගය අරඹන්න', 'எடுக்கும் பாதையைத் தொடங்கு'),
    'Route to Hakgala Organic Farm (2.4 km)\nDispatch order #FH-8841 is marked as active.': ('හග්ගල කාබනික ගොවිපළට මාර්ගය (කි.මී. 2.4)\n#FH-8841 ඇණවුම සක්‍රීය කර ඇත.', 'ஹக்கல இயற்கை பண்ணைக்கான பாதை (2.4 கி.மீ)\n#FH-8841 ஆர்டர் செயலில் உள்ளது.'),
    'Launch Turn-by-Turn GPS': ('GPS මඟපෙන්වීම අරඹන්න', 'ஜிபிஎஸ் வழிசெலுத்தலைத் தொடங்கு'),
    'Turn-by-turn navigation started for #FH-8841': ('#FH-8841 සඳහා GPS මඟපෙන්වීම ඇරඹිණි', '#FH-8841 க்கான ஜிபிஎஸ் வழிசெலுத்தல் தொடங்கியது'),
    'Order Details #FH-8841': ('ඇණවුම් විස්තර #FH-8841', 'ஆர்டர் விவரங்கள் #FH-8841'),
    'Farmer Name': ('ගොවියාගේ නම', 'விவசாயியின் பெயர்'),
    'Contact Phone': ('දුරකථන අංකය', 'தொலைபேசி எண்'),
    'Pickup Address': ('ලබාගන්නා ලිපිනය', 'பிக்அப் முகவரி'),
    'Upper Division Gate B, Hakgala Rd': ('ඉහළ කොටස B දොරටුව, හග්ගල පාර', 'மேல் பிரிவு கேட் B, ஹக்கல சாலை'),
    'Buyer Name': ('ගැනුම්කරුගේ නම', 'வாங்குபவரின் பெயர்'),
    'Chaminda Perera': ('චමින්ද පෙරේරා', 'சமிந்த பெரேரா'),
    'Chaminda Perera • Havelock Rd, Colombo': ('චමින්ද පෙරේරා • හැව්ලොක් පාර, කොළඹ', 'சமிந்த பெரேரா • ஹேவ்லாக் சாலை, கொழும்பு'),
    'Dropoff Address': ('භාරදෙන ලිපිනය', 'ஒப்படைப்பு முகவரி'),
    'Havelock Rd, Colombo 05': ('හැව්ලොක් පාර, කොළඹ 05', 'ஹேவ்லாக் சாலை, கொழும்பு 05'),
    'Cargo Breakdown': ('ප්‍රවාහන භාණ්ඩ විස්තරය', 'சரக்கு விவரம்'),
    '5 kg Fresh Carrots, Leeks (Crate #C)': ('නැවුම් කැරට්, ලීක්ස් කි.ග්‍රෑ. 5 (කූඩය #C)', 'புதிய கேரட், லீக்ஸ் 5 கிலோ (பெட்டி #C)'),
    'Storage Requirement': ('ගබඩා කිරීමේ අවශ්‍යතාවය', 'சேமிப்பு தேவை'),
    'Chilled (10°C - 14°C)': ('ශීත කළ (10°C - 14°C)', 'குளிரூட்டப்பட்ட (10°C - 14°C)'),
    'Driver Compensation': ('රියදුරු ගෙවීම', 'ஓட்டுநர் ஊதியம்'),
    'Close': ('වසන්න', 'மூடு'),
    'Call Farmer Bandar': ('ගොවි බණ්ඩාර අමතන්න', 'விவசாயி பண்டாரவை அழைக்கவும்'),
    '+94 77 458 1920 • Hakgala Organic Farm': ('+94 77 458 1920 • හග්ගල කාබනික ගොවිපළ', '+94 77 458 1920 • ஹக்கல இயற்கை பண்ணை'),
    'Cancel': ('අවලංගු කරන්න', 'ரத்து செய்'),
    'Dialing Farmer Bandar (+94 77 458 1920)...': ('ගොවි බණ්ඩාර අමතමින් (+94 77 458 1920)...', 'விவசாயி பண்டாரவை அழைக்கிறது (+94 77 458 1920)...'),
    'Call Now': ('දැන් අමතන්න', 'இப்போது அழைக்கவும்'),
    'Shift & Dispatch Alerts': ('දැනුම්දීම් සහ පණිවිඩ', 'அறிவிப்புகள் மற்றும் எச்சரிக்கைகள்'),
    'Active route notifications & vehicle telemetry': ('සක්‍රීය මාර්ග සහ වාහන තොරතුරු', 'செயலில் உள்ள பாதை & வாகன தகவல்'),
    'Urgent Pickup Ready • #FH-8841': ('හදිසි ඇණවුම සූදානම් • #FH-8841', 'அவசர பிக்அப் தயார் • #FH-8841'),
    'Farmer K. M. Bandara confirmed 3 Crates (Cabbage & Carrots) ready at Upper Division Gate B, Hakgala.': ('ගොවි කේ. එම්. බණ්ඩාර මහතා කූඩ 3ක් (ගෝවා සහ කැරට්) ඉහළ කොටස B දොරටුවේ සූදානම් බව තහවුරු කළේය.', 'விவசாயி கே. எம். பண்டாரா 3 பெட்டிகள் (முட்டைக்கோஸ் & கேரட்) ஹக்கலவில் தயார் என உறுதிப்படுத்தினார்.'),
    '5m ago': ('මිනි. 5කට පෙර', '5 நிமி. முன்'),
    '15m ago': ('මිනි. 15කට පෙර', '15 நிமி. முன்'),
    '30m ago': ('මිනි. 30කට පෙර', '30 நிமி. முன்'),
    'Pickup Ready': ('ලබාගැනීමට සූදානම්', 'பிக்அப் தயார்'),
    'New Assigned Order • #FH-8850': ('නව ඇණවුම පවරන ලදී • #FH-8850', 'புதிய ஆர்டர் ஒதுக்கப்பட்டது • #FH-8850'),
    'Dispatcher allocated Order #FH-8850: Sunil Perera (Welimada) ➔ Dilani Jayawardena (Dehiwala).': ('බෙදාහැරීම් අංශය #FH-8850 පවරන ලදී: සුනිල් පෙරේරා (වැලිමඩ) ➔ දිලානි ජයවර්ධන (දෙහිවල).', 'அனுப்புநர் #FH-8850 ஒதுக்கினார்: சுனில் பெரேரா (வெலிமட) ➔ திலானி ஜெயவர்தன (தெஹிவளை).'),
    'Assigned': ('පවරන ලදී', 'ஒதுக்கப்பட்டது'),
    'A7 & A4 Route Clear Advisory': ('A7 සහ A4 මාර්ග තත්ත්වය පැහැදිලියි', 'A7 மற்றும் A4 பாதை தெளிவு அறிவிப்பு'),
    'Central Highlands mountain corridors clear of mist and obstacles. Recommended speed: 40 km/h.': ('මධ්‍යම කඳුකර මාර්ග මීදුමෙන් තොරව පැහැදිලිව පවතී. නිර්දේශිත වේගය: පැ.කි.මී. 40.', 'மத்திய மலைநாட்டு பாதைகளில் பனி இல்லை. பரிந்துரைக்கப்பட்ட வேகம்: மணிக்கு 40 கி.மீ.'),
    'Route Clear': ('මාර්ගය පැහැදිලියි', 'பாதை தெளிவு'),
    'Cargo Chiller Safe (4.2°C)': ('ශීතකරණ උෂ්ණත්වය ආරක්ෂිතයි (4.2°C)', 'சரக்கு குளிரூட்டி பாதுகாப்பானது (4.2°C)'),
    'Cold chain integrity verified. Vegetable storage area operating at optimal refrigerated range.': ('එළවළු ගබඩා ශීතකරණය නියමිත උෂ්ණත්වයේ ක්‍රියාත්මක වේ.', 'குளிர் சங்கிலி உறுதிப்படுத்தப்பட்டது. காய்கறி சேமிப்பு உகந்த நிலையில் உள்ளது.'),
    'Chiller Nominal': ('ශීතකරණය සාමාන්‍යයි', 'குளிரூட்டி இயல்பானது'),
    'Mark All as Read': ('සියල්ල කියවූ ලෙස ලකුණු කරන්න', 'அனைத்தையும் படித்ததாக குறிக்கவும்'),
    'Close Notifications': ('දැනුම්දීම් වසන්න', 'அறிවිப்புகளை மூடவும்'),
    'Verified Agri-Logistics Driver': ('සත්‍යාපිත කෘෂි ප්‍රවාහන රියදුරු', 'சரிபார்க்கப்பட்ட விவசாய ஓட்டுநர்'),
    'Dismiss': ('වසන්න', 'மூடு'),
    'Rating': ('ශ්‍රේණිගත කිරීම', 'மதிப்பீடு'),
    'Completed': ('සම්පූර්ණයි', 'முடிந்தது'),
    'Van Reg': ('වාහන ලියාපදිංචිය', 'வாகන பதிவு'),
    'Nuwara Eliya → Kandy → Colombo': ('නුවරඑළිය → මහනුවර → කොළඹ', 'நுவரெலியா → கண்டி → கொழும்பு'),
    'Farm Gate North #2, Nuwara Eliya': ('ගොවිපළ උතුරු දොරටුව #2, නුවරඑළිය', 'பண்ணை வடக்கு வாயில் #2, நுவரெலியா'),
    'Hakgala Valley Farm': ('හග්ගල නිම්න ගොවිපළ', 'ஹக்கல பள்ளத்தாக்கு பண்ணை'),
    'No. 42 Havelock Rd, Colombo 05': ('අංක 42, හැව්ලොක් පාර, කොළඹ 05', 'எண் 42, ஹேவ்லாக் சாலை, கொழும்பு 05'),
    'Drop-off': ('භාරදීම', 'ஒப்படைப்பு'),
    '5 kg (Carrots & Leeks)': ('කි.ග්‍රෑ. 5 (කැරට් සහ ලීක්ස්)', '5 கிலோ (கேரட் & லீக்ஸ்)'),
    '12 kg (Tomatoes & Cabbages)': ('කි.ග්‍රෑ. 12 (තක්කාලි සහ ගෝවා)', '12 கிலோ (தக்காளி & முட்டைக்கோஸ்)'),
    'Welimada Main Collection Depot': ('වැලිමඩ ප්‍රධාන එකතු කිරීමේ ඩිපෝව', 'வெலிமட பிரதான சேகரிப்பு கிடங்கு'),
    'Welimada Hub': ('වැලිමඩ මධ්‍යස්ථානය', 'வெலிமட மையம்'),
    'Dilani Jayawardena': ('දිලානි ජයවර්ධන', 'திலானி ஜெயவர்தன'),
    'Sunil Perera': ('සුනිල් පෙරේරා', 'சுனில் பெரேரா'),
    'K. M. Bandara': ('කේ. එම්. බණ්ඩාර', 'கே. எம். பண்டார'),
    'Bandar Menike (Hakgala)': ('බණ්ඩාර මැණිකේ (හග්ගල)', 'பண்டාර மெனிகே (ஹக்கல)'),
    'Dehiwala Urban Center': ('දෙහිවල නාගරික මධ්‍යස්ථානය', 'தெஹிவளை நகர மையம்'),
    'Details': ('විස්තර', 'விவரங்கள்'),
    'En Route to Pickup': ('භාණ්ඩ ලබාගැනීමට ගමන් කරමින්', 'பிக்அப் நோக்கி பயணிக்கிறது'),
    'Depot Platform Gate #1 / C': ('ඩිපෝ වේදිකා දොරටුව #1 / C', 'கிடங்கு மேடை வாயில் #1 / C'),
    'Farm Gate North #2': ('ගොවිපළ උතුරු දොරටුව #2', 'பண்ணை வடக்கு வாயில் #2'),
    'Welimada Agricultural Zone, Badulla': ('වැලිමඩ කෘෂිකාර්මික කලාපය, බදුල්ල', 'வெலிமட விவசாய மண்டலம், பதுளை'),
    'Hakgala, Nuwara Eliya High Plains': ('හග්ගල, නුවරඑළිය උස්බිම්', 'ஹக்கல, நுவரெலியா உயர் சமவெளி'),
    'Report to Depot Platform 2. Contact depot dispatch coordinator.': ('ඩිපෝ වේදිකාව 2 වෙත වාර්තා කරන්න. සම්බන්ධීකාරක අමතන්න.', 'கிடங்கு மேடை 2 இல் தெரிவிக்கவும். ஒருங்கிணைப்பாளரை தொடர்பு கொள்ளவும்.'),
    'Enter via upper terrace road. Horn once at greenhouse shed.': ('ඉහළ මාර්ගයෙන් ඇතුල් වන්න. හරිතාගාරය අසල නළාව නාද කරන්න.', 'மேல் சாலை வழியாக நுழையவும். பசுமைக்குடில் அருகே ஒலி எழுப்பவும்.'),
    'Urban Wholesale Hub': ('නාගරික තොග මධ්‍යස්ථානය', 'நகர மொத்த விற்பனை மையம்'),
    'No. 15, Station Road': ('අංක 15, ස්ටේෂන් පාර', 'எண் 15, ஸ்டேஷன் சாலை'),
    'No. 42, Havelock Road': ('අංක 42, හැව්ලොක් පාර', 'எண் 42, ஹேவ்லாக் சாலை'),
    'Dehiwala, Western Province': ('දෙහිවල, බස්නාහිර පළාත', 'தெஹிவளை, மேல் மாகாணம்'),
    'Colombo 05, Western Province': ('කොළඹ 05, බස්නාහිර පළාත', 'கொழும்பு 05, மேல் மாகாணம்'),
    '2 Crates • 12.0 kg': ('කූඩ 2 • කි.ග්‍රෑ. 12.0', '2 பெட்டிகள் • 12.0 கிலோ'),
    '2 Crates • 5.0 kg': ('කූඩ 2 • කි.ග්‍රෑ. 5.0', '2 பெட்டிகள் • 5.0 கிலோ'),
    '7 kg • Crate #B1': ('කි.ග්‍රෑ. 7 • කූඩය #B1', '7 கிலோ • பெட்டி #B1'),
    '3 kg • Crate #A1': ('කි.ග්‍රෑ. 3 • කූඩය #A1', '3 கிலோ • பெட்டி #A1'),
    '5 kg • Crate #B2': ('කි.ග්‍රෑ. 5 • කූඩය #B2', '5 கிலோ • பெட்டி #B2'),
    '2 kg • Crate #A2': ('කි.ග්‍රෑ. 2 • කූඩය #A2', '2 கிலோ • பெட்டி #A2'),
    'Est. 35 min': ('ඇස්තමේන්තු මිනි. 35', 'மதிப்பிடப்பட்டது 35 நிமிடம்'),
    'Est. 28 min': ('ඇස්තමේන්තු මිනි. 28', 'மதிப்பிடப்பட்டது 28 நிமிடம்'),
    'Switch Role (Farmer / Buyer Mode)': ('භූමිකාව මාරු කරන්න (ගොවි / ගැනුම්කරු)', 'பங்கை மாற்றவும் (விவசாயி / வாங்குபவர்)'),
    'Verified Agri-Transit Partner': ('සත්‍යාපිත කෘෂි ප්‍රවාහන හවුල්කරු', 'சரிபார்க்கப்பட்ட விவசாய போக்குவரத்து பங்குதாரர்'),
    'Agri-Transit Logistics Partner • Central Highlands': ('කෘෂි ප්‍රවාහන හවුල්කරු • මධ්‍යම කඳුකරය', 'விவசாய போக்குவரத்து பங்குதாரர் • மத்திய மலைநாடு'),
    '340 Reviews': ('සමාලෝචන 340ක්', '340 மதிப்புரைகள்'),
    '6 Yrs': ('වසර 6ක්', '6 ஆண்டுகள்'),
    '1,840+ Trips Finished': ('ගමන් 1,840+ක් සම්පූර්ණයි', '1,840+ பயணங்கள் முடிந்தது'),
    'On Duty': ('සේවයේ යෙදී ඇත', 'பணியில் உள்ளது'),
    'Chilled / Refrigerated Van': ('ශීත කළ / රෙෆ්‍රිජරේටඩ් වෑන්', 'குளிரூட்டப்பட்ட வேன்'),
    'Freshness Guaranteed': ('නැවුම් බව සහතිකයි', 'புத்துணர்ச்சி உறுதி'),
    'Clear Flow': ('බාධාවකින් තොරයි', 'தெளிவான ஓட்டம்'),
    'Highland Transit Route Map': ('කඳුකර ප්‍රවාහන මාර්ග සිතියම', 'மலைநாட்டு போக்குவரத்து பாதை வரைபடம்'),
    'Close Route View': ('මාර්ග සිතියම වසන්න', 'பாதை பார்வையை மூடவும்'),
    'Open Chat': ('සංවාදය අරඹන්න', 'அரட்டை திறக்கவும்'),
    'Origin': ('ආරම්භය', 'தொடக்க இடம்'),
    'Destination': ('ගමනාන්තය', 'சேருமிடம்'),
    'Collection Mode': ('මුදල් අය කිරීමේ ක්‍රමය', 'சேகரிப்பு முறை'),
    'Chat Farmer': ('ගොවියා සමඟ කතාබස්', 'விவசாயியுடன் அரட்டை'),
    'Chat Buyer': ('පාරිභෝගිකයා සමඟ කතාබස්', 'வாங்குபவருடன் அரட்டை'),
    'Verified': ('සත්‍යාපනය කර ඇත', 'சரிபார்க்கப்பட்டது'),
    'Active Shift': ('සක්‍රීය සේවා මුරය', 'செயலில் உள்ள ஷிப்ட்'),
    'Gate Note: ': ('දොරටුවේ සටහන: ', 'வாயில் குறிப்பு: '),
    'Handling: ': ('හැසිරවීම: ', 'கையாளுதல்: '),
    'Pickup by ': ('භාණ්ඩ ලබාගැනීම: ', 'பிக்அப் நேரம்: '),
    ' • Dropoff by ': (' • භාරදීම: ', ' • ஒப்படைப்பு: '),
    '2 NEW': ('නව 2ක්', '2 புதியது'),
    'Optimized Stop Sequence': ('ප්‍රශස්ත නැවතුම් අනුපිළිවෙල', 'உகந்த நிறுத்த வரிசை'),
    'Route scheduled: Stop 1 Hakgala Farm Gate #2 (Bandara), Stop 2 Welimada Main Depot (Sunil).': ('නියමිත මාර්ගය: නැවතුම 1 හග්ගල ගොවිපළ දොරටුව #2 (බණ්ඩාර), නැවතුම 2 වැලිමඩ ප්‍රධාන ඩිපෝව (සුනිල්).', 'திட்டமிடப்பட்ட பாதை: நிறுத்தம் 1 ஹக்கல பண்ணை வாயில் #2 (பண்டார), நிறுத்தம் 2 வெலிமட பிரதான கிடங்கு (சுனில்).'),
    '10m ago': ('මිනි. 10කට පෙර', '10 நிமிடம் முன்'),
    'Manifest': ('ප්‍රවාහන ලේඛනය', 'சரக்கு பட்டியல்'),
    'Buyer Instruction • Chaminda': ('ගැනුම්කරු උපදෙස් • චමින්ද', 'வாங்குபவர் வழிமுறை • சமிந்த'),
    'Drop-off note: "Ring doorbell twice, keep produce in shade at 42 Havelock Rd."': ('භාරදීමේ සටහන: "දෙවරක් සීනුව නාද කරන්න, අංක 42 හැව්ලොක් පාරේ සෙවණේ තබන්න."', 'ஒப்படைப்பு குறிப்பு: "இரண்டு முறை மணி அடிக்கவும், 42 ஹேவ்லாக் சாலையில் நிழலில் வைக்கவும்."'),
    '20m ago': ('මිනි. 20කට පෙර', '20 நிமிடம் முன்'),
    'Buyer Note': ('ගැනුම්කරු සටහන', 'வாங்குபவர் குறிப்பு'),
    'Cash Collection Summary': ('මුදල් එකතු කිරීමේ සාරාංශය', 'பணம் சேகரிப்பு சுருக்கம்'),
    'COD expected on arrival: Rs. 1,760 for Order #FH-8841 and Rs. 2,450 for Order #FH-8850.': ('භාරදීමේදී එකතු කළ යුතු මුදල්: #FH-8841 සඳහා රු. 1,760 සහ #FH-8850 සඳහා රු. 2,450.', 'வந்தடைந்ததும் எதிர்பார்க்கப்படும் பணம்: ஆர்டர் #FH-8841 க்கு ரூ. 1,760 மற்றும் ஆர்டர் #FH-8850 க்கு ரூ. 2,450.'),
    '45m ago': ('මිනි. 45කට පෙර', '45 நிமிடம் முன்'),
    'COD Cash': ('භාරදීමේදී මුදල්', 'COD ரொக்கம்'),
    'Cloud Manifest Synced': ('ක්ලවුඩ් ලේඛනය සමමුහුර්තයි', 'கிளவுட் பட்டியல் ஒத்திசைக்கப்பட்டது'),
    'Both active orders verified and synced with Central Logistics Hub database.': ('සක්‍රීය ඇණවුම් දෙකම මධ්‍යම ප්‍රවාහන දත්ත ගබඩාව සමඟ සමමුහුර්ත කර ඇත.', 'இரண்டு ஆர்டர்களும் மத்திய தளவாட மைய தரவுத்தளத்துடன் ஒத்திசைக்கப்பட்டன.'),
    '1h ago': ('පැය 1කට පෙර', '1 மணி நேரம் முன்'),
    'Database Synced': ('දත්ත සමමුහුර්තයි', 'தரவுத்தளம் ஒத்திசைக்கப்பட்டது'),
    'Net Settlement': ('ශුද්ධ පියවීම', 'நிகர தீர்வு'),
    'Cold Chain Hardware': ('ශීත දාම උපකරණ', 'குளிர் சங்கிலி வன்பொருள்'),
    'Active Telematics Monitoring': ('සක්‍රීය ටෙලිමැටික්ස් අධීක්ෂණය', 'செயலில் உள்ள டெலிமேடிக்ස් கண்காணிப்பு'),
    'Vehicle Model': ('වාහන මාදිලිය', 'வாகன மாடல்'),
    'Cargo Capacity': ('භාණ්ඩ ධාරිතාව', 'சரக்கு கொள்ளளவு'),
    'Climate Sensor': ('දේශගුණික සංවේදකය', 'காலநிலை சென்சார்'),
    'Active (10°C - 16°C) ✓': ('ක්‍රියාකාරී (10°C - 16°C) ✓', 'செயலில் உள்ளது (10°C - 16°C) ✓'),
    'Roadworthy Status': ('මාර්ග ධාවන තත්ත්වය', 'சாலை தகுதி நிலை'),
    'Valid until Nov 2025': ('2025 නොවැම්බර් දක්වා වලංගුයි', 'நவம்பர் 2025 வரை செல்லுபடியாகும்'),
    'DRIVER OPERATIONS': ('රියදුරු මෙහෙයුම්', 'ஓட்டுநர் செயல்பாடுகள்'),
    'Sign Out of Driver Hub': ('රියදුරු මධ්‍යස්ථානයෙන් ඉවත් වන්න', 'ஓட்டுநர் மையத்திலிருந்து வெளியேறவும்'),
    'Farm2Home Driver OS v2.4.12': ('Farm2Home Driver OS v2.4.12', 'Farm2Home Driver OS v2.4.12'),
    'Empowering Sri Lankan Transit & Agri-Cold Chain': ('ශ්‍රී ලාංකීය කෘෂි ශීත දාම ප්‍රවාහනය සවිබල ගන්වමින්', 'இலங்கை விவசாய குளிர் சங்கிலி போக்குவரத்தை மேம்படுத்துகிறது'),
    'Terrain: Welimada Valley Pass': ('භූමි ප්‍රදේශය: වැලිමඩ නිම්න මාර්ගය', 'நிலப்பரப்பு: வெலிமட பள்ளத்தாக்கு வழி'),
    'Terrain: Mountain Pass Road': ('භූමි ප්‍රදේශය: කඳුකර මාර්ගය', 'நிலப்பරப்பு: மலைப்பாதை சாலை'),
    'Hakgala Organic Farm: Central Highlands Pickup Point (A5 Highway)': ('හග්ගල කාබනික ගොවිපළ: මධ්‍යම කඳුකර එකතු කිරීමේ මධ්‍යස්ථානය (A5)', 'ஹக்கல இயற்கை பண்ணை: மத்திய மலைநாட்டு பிக்அப் புள்ளி (A5 நெடுஞ்சாலை)'),
    'Welimada Collection Depot: Central Highlands Collection Point (A5/B509 Highway)': ('වැලිමඩ එකතු කිරීමේ ඩිපෝව: මධ්‍යම කඳුකර එකතු කිරීමේ මධ්‍යස්ථානය (A5/B509)', 'வெலிமட சேகரிப்பு கிடங்கு: மத்திய மலைநாட்டு சேகரிப்பு புள்ளி (A5/B509 நெடுஞ்சாலை)'),
    'In 150m, Turn Right': ('මීටර් 150කින් දකුණට හරවන්න', '150 மீட்டரில் வலதுபுறம் திரும்பவும்'),
    'In 400m, Turn Right': ('මීටර් 400කින් දකුණට හරවන්න', '400 மீட்டரில் வலதுபுறம் திரும்பவும்'),
    'Hakgala Farm Gate #2 Access Rd': ('හග්ගල ගොවිපළ දොරටුව #2 පිවිසුම් මාර්ගය', 'ஹக்கல பண்ணை வாயில் #2 அணுகல் சாலை'),
    'Welimada Depot Platform Gate #1 / C • B322 Highway': ('වැලිමඩ ඩිපෝ වේදිකා දොරටුව #1 / C • B322 මාර්ගය', 'வெலிமட கிடங்கு மேடை வாயில் #1 / C • B322 நெடுஞ்சாலை'),
    'Hakgala Farm Gate #2 Access Rd • Badulla – Nuwara Eliya Rd': ('හග්ගල ගොවිපළ දොරටුව #2 • බදුල්ල – නුවරඑළිය පාර', 'ஹக்கல பண்ணை வாயில் #2 • பதுளை – நுவரெலியா சாலை'),
    'Upcoming: In 150m, Turn Right': ('ඉදිරියට: මීටර් 150කින් දකුණට හරවන්න', 'அடுத்து: 150 மீட்டரில் வலதுபுறம் திரும்பவும்'),
    'Upcoming: In 400m, Turn Right': ('ඉදිරියට: මීටර් 400කින් දකුණට හරවන්න', 'அடுத்து: 400 மீட்டரில் வலதுபுறம் திரும்பவும்'),
    '4 mins • 1.8 km': ('මිනි. 4 • කි.මී. 1.8', '4 நிமிடம் • 1.8 கி.மீ.'),
    '8 mins • 2.1 km': ('මිනි. 8 • කි.මී. 2.1', '8 நிமிடம் • 2.1 கி.மீ.'),
    'Welimada – Badulla Rd': ('වැලිමඩ – බදුල්ල පාර', 'வெலிமட – பதுளை சாலை'),
    'Badulla – Nuwara Eliya Rd': ('බදුල්ල – නුවරඑළිය පාර', 'பதுளை – நுவரெலியா சாலை'),
    'Continue toward Station Rd, Dehiwala': ('දෙහිවල, ස්ටේෂන් පාර දෙසට ගමන් කරන්න', 'தெஹிவளை, ஸ்டேஷன் சாலை நோக்கி தொடரவும்'),
    'Continue on A7 toward Kaduwela /...': ('කඩුවෙල දෙසට A7 ඔස්සේ ඉදිරියට යන්න...', 'கடுவெல நோக்கி A7 இல் தொடரவும்...'),
    'Dehiwala': ('දෙහිවල', 'தெஹிவளை'),
    'Colombo 05': ('කොළඹ 05', 'கொழும்பு 05'),
    '3 Crates Fresh Veg': ('නැවුම් එළවළු කූඩ 3ක්', '3 பெட்டிகள் புதிய காய்கறிகள்'),
    '2 Crates Fresh Veg': ('නැවුම් එළවළු කූඩ 2ක්', '2 பெட்டிகள் புதிய காய்கறிகள்'),
    'via A4 Hwy': ('A4 මාර්ගය ඔස්සේ', 'A4 நெடுஞ்சாலை வழியாக'),
    'via A7 Hwy': ('A7 මාර්ගය ඔස්සේ', 'A7 நெடுஞ்சாலை வழியாக'),
    'Havelock Rd. Colombo 05': ('හැව්ලොක් පාර, කොළඹ 05', 'ஹேவ்லாக் சாலை, கொழும்பு 05'),
    'No. 15, Station Road, Dehiwala': ('අංක 15, ස්ටේෂන් පාර, දෙහිවල', 'எண் 15, ஸ்டேஷன் சாலை, தெஹிவளை'),
    '15 mins early ⚡': ('මිනි. 15ක් කලින් ⚡', '15 நிமிடம் முன்னதாக ⚡'),
    '20 mins early ⚡': ('මිනි. 20ක් කලින් ⚡', '20 நிமிடம் முன்னதாக ⚡'),
    'Rs. 1,760 Collected & Pocketed': ('රු. 1,760 අය කර ගන්නා ලදී', 'ரூ. 1,760 சேகரிக்கப்பட்டது'),
    'Rs. 2,450 Collected & Pocketed': ('රු. 2,450 අය කර ගන්නා ලදී', 'ரூ. 2,450 சேகரிக்கப்பட்டது'),
    'Today, 3:15 PM': ('අද, ප.ව. 3:15', 'இன்று, மாலை 3:15'),
    'Today, 4:10 PM': ('අද, ප.ව. 4:10', 'இன்று, மாலை 4:10'),
    'Ring doorbell twice, keep produce in shade.': ('දෙවරක් සීනුව නාද කරන්න, සෙවණේ තබන්න.', 'இரண்டு முறை மணி அடிக்கவும், நிழலில் வைக்கவும்.'),
    'Leave with security counter or front porch.': ('ආරක්ෂක කවුන්ටරයේ හෝ ඉදිරිපස ආලින්දයේ තබන්න.', 'பாதுகாப்பு கவுண்டரில் அல்லது முன் தாழ்வாரத்தில் விடவும்.'),
    'Strap secured / Ventilated • Stack upright': ('පටි මගින් සවි කර ඇත / වාතාශ්‍රය සහිතයි • කෙළින් තබන්න', 'வார் பொருத்தப்பட்டது / காற்றோட்டமானது • நேராக அடுக்கவும்'),
    'Cool Storage / Ventilated • Keep shaded': ('ශීත ගබඩා / වාතාශ්‍රය සහිතයි • සෙවණේ තබන්න', 'குளிர் சேமிப்பு / காற்றோட்டமானது • நிழலில் வைக்கவும்'),
    'Mountain Carrots': ('කඳුකර කැරට්', 'மலைநாட்டு கேரட்'),
    'Highland Fresh Tomatoes': ('නැවුම් තක්කාලි', 'புதிய தக்காளி'),
    'Welimada Crisp Cabbage': ('වැලිමඩ ගෝවා', 'வெலிமட முட்டைக்கோஸ்'),
    'Welimada Crisp Leeks': ('වැලිමඩ ලීක්ස්', 'வெலிமட லீக்ஸ்'),
    'Cool storage packed': ('ශීත ගබඩාවේ අසුරන ලදී', 'குளிர் சேமிப்பில் அடைக்கப்பட்டது'),
    'Strap secured': ('පටි මගින් සවි කර ඇත', 'வார் மூலம் பாதுகாப்பானது'),
    'Pickup Due in 20m': ('මිනි. 20කින් ලබාගැනීමට ඇත', '20 நிமிடத்தில் பிக்அப் செய்ய வேண்டும்'),
    'Pickup Due in 45m': ('මිනි. 45කින් ලබාගැනීමට ඇත', '45 நிமிடத்தில் பிக்அப் செய்ய வேண்டும்'),
    '1 Crate': ('කූඩ 1ක්', '1 பெட்டி'),
    '2 Crates': ('කූඩ 2ක්', '2 பெட்டிகள்'),
    'Ready for Pickup': ('ලබාගැනීමට සූදානම්', 'பிக்அப் தயார்'),
    'In Transit': ('ප්‍රවාහනයේ', 'போக்குவரத்தில்'),
    'Ready': ('සූදානම්', 'தயார்'),
    'Farmer': ('ගොවියා', 'விவசாயි'),
    'Buyer': ('ගැනුම්කරු', 'வாங்குபவர்'),
    '🌾 Farmer': ('🌾 ගොවි මහතා', '🌾 விவசாயி'),
    '🛒 Buyer': ('🛒 ගැනුම්කරු', '🛒 வாங்குபவர்'),
    'Call Farmer': ('ගොවියාට අමතන්න', 'விவசாயியை அழைக்கவும்'),
    'Direct Message with': ('සෘජු පණිවිඩය:', 'நேரடி செய்தி:'),
    'Active order communication channel for': ('සක්‍රීය ඇණවුම් සන්නිවේදන නාලිකාව:', 'செயலில் உள்ள ஆர்டர் தொடர்பு சேனல்:'),
    'Pickup at Welimada Depot. Cargo temperature sensor active at 4.0°C.': ('වැලිමඩ ඩිපෝවෙන් ලබාගැනීම. භාණ්ඩ උෂ්ණත්ව සංවේදකය 4.0°C හි සක්‍රීයයි.', 'வெலிமட கிடங்கில் பிக்அப். சரக்கு வெப்பநிலை சென்சார் 4.0°C இல் செயலில் உள்ளது.'),
    'Pickup at Hakgala Farm. Temperature sensor active at 4.2°C.': ('හග්ගල ගොවිපළෙන් ලබාගැනීම. උෂ්ණත්ව සංවේදකය 4.2°C හි සක්‍රීයයි.', 'ஹக்கல பண்ணையில் பிக்அப். வெப்பநிலை சென்சார் 4.2°C இல் செயலில் உள்ளது.'),
    'Corridor A5/B509 • Welimada → Dehiwala': ('A5/B509 මාර්ගය • වැලිමඩ → දෙහිවල', 'A5/B509 வழித்தடம் • வெலிமட → தெஹிவளை'),
    'Corridor A5 • Nuwara Eliya → Hakgala': ('A5 මාර්ගය • නුවරඑළිය → හග්ගල', 'A5 வழித்தடம் • நுவரெலியா → ஹக்கல'),
    'Switch Active Role': ('ක්‍රියාකාරී භූමිකාව මාරු කරන්න', 'செயலில் உள்ள பங்கை மாற்றவும்'),
    'Select which portal mode you wish to switch into:': ('ඔබට මාරු වීමට අවශ්‍ය අංශය තෝරන්න:', 'நீங்கள் மாற விரும்பும் போர்டல் பயன்முறையைத் தேர்ந்தெடுக்கவும்:'),
    'Farmer Marketplace Portal': ('ගොවි වෙළඳපොළ අංශය', 'விவசாய சந்தை போர்டல்'),
    'Buyer / Wholesale Portal': ('ගැනුම්කරු / තොග අංශය', 'வாங்குபவர் / மொத்த விற்பனை போர்டல்'),
    'Switched to Farmer Portal': ('ගොවි අංශයට මාරු විය', 'விவசாயி போர்ட்டலுக்கு மாற்றப்பட்டது'),
    'Switched to Buyer Portal': ('ගැනුම්කරු අංශයට මාරු විය', 'வாங்குபவர் போர்ட்டலுக்கு மாற்றப்பட்டது'),
    'Sign Out of Driver Hub?': ('රියදුරු මධ්‍යස්ථානයෙන් ඉවත් වන්නද?', 'ஓட்டுநர் மையத்திலிருந்து வெளியேறவா?'),
    'You will be put offline and will not receive real-time transit dispatch offers until you sign back in.': ('ඔබ නොබැඳි (offline) වන අතර නැවත ඇතුල් වන තෙක් නව ප්‍රවාහන ඇණවුම් නොලැබේ.', 'நீங்கள் ஆஃப்லைனில் வைக்கப்படுவீர்கள், மீண்டும் உள்நுழையும் வரை புதிய ஆர்டர்கள் கிடைக்காது.'),
    'Driver Support & Dispatch Chat': ('රියදුරු සහාය සහ පණිවිඩ සංවාදය', 'ஓட்டுநர் ஆதரவு & அனுப்புதல் அரட்டை'),
    'Instant chat channel with Agri-Dispatch and Corridor Support team.': ('ප්‍රවාහන මෙහෙයුම් කණ්ඩායම සමඟ සෘජු සංවාද නාලිකාව.', 'விவசாய அனுப்புதல் மற்றும் ஆதரவு குழுவுடன் உடனடி அரட்டை.'),
    'Start Chat with Support': ('සහාය සමඟ සංවාදය අරඹන්න', 'ஆதரவுடன் அரட்டையைத் தொடங்குங்கள்'),
    'Commercial Bank LK (****4198)': ('කොමර්ෂල් බැංකුව (****4198)', 'கொமர்ஷல் வங்கி (****4198)'),
    'Welimada Depot Gate #1': ('වැලිමඩ ඩිපෝ දොරටුව #1', 'வெலிமட கிடங்கு வாயில் #1'),
    'En route to Hakgala Farm Gate #2': ('හග්ගල ගොවිපළ දොරටුව #2 වෙත ගමන් කරමින්', 'ஹக்கல பண்ணை வாயில் #2 நோக்கி பயணிக்கிறது'),
    'En route to Welimada Depot Platform Gate #1': ('වැලිමඩ ඩිපෝ වේදිකා දොරටුව #1 වෙත ගමන් කරමින්', 'வெலிமட கிடங்கு மேடை வாயில் #1 நோக்கி பயணிக்கிறது'),
    'Gate North #2 / B': ('උතුරු දොරටුව #2 / B', 'வடக்கு வாயில் #2 / B'),
    'Arrived at Station Rd, Dehiwala • 2 crates verified.\nUpdating delivery status to Completed...': ('දෙහිවල, ස්ටේෂන් පාරට ළඟා විය • කූඩ 2ක් තහවුරුයි.\nභාරදීමේ තත්ත්වය සම්පූර්ණ ලෙස යාවත්කාලීන වේ...', 'தெஹிவளை, ஸ்டேஷன் சாலைக்கு வந்தது • 2 பெட்டிகள் சரிபார்க்கப்பட்டன.\nவிநியோக நிலை முடிந்தது என புதுப்பிக்கப்படுகிறது...'),
    'Arrived at Havelock Rd, Colombo 05 • 3 crates verified.\nUpdating delivery status to Completed...': ('හැව්ලොක් පාර, කොළඹ 05 වෙත ළඟා විය • කූඩ 3ක් තහවුරුයි.\nභාරදීමේ තත්ත්වය සම්පූර්ණ ලෙස යාවත්කාලීන වේ...', 'ஹேவ்லாக் சாலை, கொழும்பு 05க்கு வந்தது • 3 பெட்டிகள் சரிபார்க்கப்பட்டன.\nவிநியோக நிலை முடிந்தது என புதுப்பிக்கப்படுகிறது...'),
    'A4 / COASTAL': ('A4 / වෙරළබඩ', 'A4 / கடலோர'),
    'A7 ROUTE': ('A7 මාර්ගය', 'A7 வழித்தடம்'),
    '42 Havelock Rd, Colombo 05': ('අංක 42 හැව්ලොක් පාර, කොළඹ 05', '42 ஹேவ்லாக் சாலை, கொழும்பு 05'),
    'Call': ('අමතන්න', 'அழைக்கவும்'),
    'Calling': ('ඇමතුමක් ගනිමින්...', 'அழைக்கிறது...'),
    'Chat tab selected': ('සංවාද අංශය තෝරා ගන්නා ලදී', 'அரட்டை தாவல் தேர்ந்தெடுக்கப்பட்டது'),
    'has been saved to your Downloads folder.': ('ඔබගේ බාගැනීම් (Downloads) ෆෝල්ඩරයට සුරකින ලදී.', 'உங்கள் பதிவிறக்கங்கள் கோப்புறையில் சேமிக்கப்பட்டது.'),
    'Total:': ('මුළු මුදල:', 'மொத்தம்:'),
    'Statement': ('ප්‍රකාශනය', 'அறிக்கை'),
    'Central Dispatch': ('මධ්‍යම මෙහෙයුම් අංශය', 'மத்திய அனுப்புதல் பிரிவு'),
    'Bandara (Farmer)': ('බණ්ඩාර (ගොවි මහතා)', 'பண்டார (விவசாயி)'),
    'Chaminda (Buyer)': ('චමින්ද (ගැනුම්කරු)', 'சமிந்த (வாங்குபவர்)'),
    'Hakgala Organic Farm': ('හග්ගල කාබනික ගොවිපළ', 'ஹக்கல இயற்கை பண்ணை'),
    'Support & Dispatch Hub': ('සහාය සහ මෙහෙයුම් මධ්‍යස්ථානය', 'ஆதரவு & அனுப்புதல் மையம்'),
    'Assigned deliveries in Nuwara Eliya - Welimada corridor.': ('නුවරඑළිය - වැලිමඩ මාර්ගයේ බෙදාහැරීම් පවරා ඇත.', 'நுவரெலியா - வெலிமட வழித்தடத்தில் விநியோகங்கள் ஒதுக்கப்பட்டுள்ளன.'),
    'Moving to pickup point #1 at Hakgala Farm.': ('හග්ගල ගොවිපළේ #1 ලබාගැනීමේ ස්ථානයට ගමන් කරමින්.', 'ஹக்கல பண்ணையில் பிக்அப் புள்ளி #1 நோக்கி நகர்கிறது.'),
    'Carrots and Leeks packaged and ready at Farm Gate B.': ('කැරට් සහ ලීක්ස් අසුරා ගොවිපළ B දොරටුවේ සූදානම් කර ඇත.', 'கேரட் மற்றும் லீக்ஸ் பேக் செய்யப்பட்டு பண்ணை வாயில் B இல் தயாராக உள்ளன.'),
    'Approaching farm in 10 mins.': ('මිනිත්තු 10කින් ගොවිපළට ළඟා වේ.', '10 நிமிடங்களில் பண்ணையை அடைகிறது.'),
    'Please leave the crates with security if arrived before 11.': ('පෙරවරු 11ට පෙර පැමිණියහොත් කරුණාකර කූඩ ආරක්ෂක අංශයට භාර දෙන්න.', '11 மணிக்கு முன் வந்தால் தயவுசெய்து பெட்டிகளை பாதுகாப்பிடம் விடவும்.'),
    'Acknowledged, ETA is 10:45 AM.': ('තහවුරු කරගන්නා ලදී, පැමිණෙන වේලාව පෙ.ව. 10:45.', 'ஏற்றுக்கொள்ளப்பட்டது, வருகை நேரம் மு.ப 10:45.'),
    'Corridor A5/B509 • Live': ('A5/B509 මාර්ගය • සජීවී', 'A5/B509 வழித்தடம் • நேரலை'),
    'Welimada Depot': ('වැලිමඩ ඩිපෝව', 'வெலிமட கிடங்கு'),
    'Dehiwala Hub': ('දෙහිවල මධ්‍යස්ථානය', 'தெஹிவளை மையம்'),
    'Nuwara Eliya A5': ('නුවරඑළිය A5', 'நுவரெலியா A5'),
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

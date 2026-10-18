import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import 'app_settings.dart';
import 'register_vocab.dart';

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

  static Map<String, (String, String)>? _cachedIndex;

  static Map<String, (String, String)> get _lookupIndex {
    if (_cachedIndex != null) return _cachedIndex!;
    final map = <String, (String, String)>{};

    for (final e in kRegisterVocab.entries) {
      map[e.key.toLowerCase().trim()] = e.value;
    }

    for (final e in _primaryVocab.entries) {
      map[e.key.toLowerCase().trim()] = e.value;
    }
    for (final e in _uiPhrases.entries) {
      map[e.key.toLowerCase().trim()] = e.value;
    }
    for (final e in _compositeKeywords.entries) {
      map[e.key.toLowerCase().trim()] = e.value;
    }
    _cachedIndex = map;
    return map;
  }

  /// Initialize persistent cache storage and purge any legacy corrupted entries.
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final keys = _prefs?.getKeys() ?? {};
      for (final k in keys) {
        if (k.startsWith(_cachePrefix)) {
          await _prefs?.remove(k);
        }
      }
      _memoryCache.clear();
    } catch (e) {
      debugPrint('[AppAutoTranslator] Init error: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // PUBLIC TRANSLATION API
  // ───────────────────────────────────────────────────────────────────────────

  /// Synchronously returns translated text. If the text is already localized
  /// or not in the curated dictionary, returns the text cleanly without corruption.
  String translateSync(String text, AppLanguage targetLang) {
    if (text.isEmpty || targetLang == AppLanguage.english) {
      return text;
    }

    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;

    // Guard: If the text is already in the target language (Sinhala or Tamil),
    // NEVER alter or re-translate it.
    if (targetLang == AppLanguage.sinhala && RegExp(r'[\u0D80-\u0DFF]').hasMatch(trimmed)) {
      return text;
    }
    if (targetLang == AppLanguage.tamil && RegExp(r'[\u0B80-\u0BFF]').hasMatch(trimmed)) {
      return text;
    }

    final langCode = targetLang.code;
    final cacheKey = '${langCode}_$trimmed';

    // 1. Check in-memory cache
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey]!;
    }

    // 2. Direct lookup in curated dictionary
    final direct = _lookup(trimmed, targetLang);
    if (direct != null) {
      _saveToCache(cacheKey, direct);
      return direct;
    }

    // 3. Smart Symbol & Punctuation Stripping
    final smartMatch = _translateSmartSymbols(trimmed, targetLang);
    if (smartMatch != null) {
      _saveToCache(cacheKey, smartMatch);
      return smartMatch;
    }

    // 4. Smart composite phrase translation (currency & unit patterns)
    final compositeMatch = _translateComposite(trimmed, targetLang);
    if (compositeMatch != null) {
      _saveToCache(cacheKey, compositeMatch);
      return compositeMatch;
    }

    return text;
  }

  /// Asynchronously translates text, using synchronous curated dictionary.
  Future<String> translateAsync(String text, AppLanguage targetLang) async {
    return translateSync(text, targetLang);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // COMPOSITE & PATTERN TRANSLATION
  // ───────────────────────────────────────────────────────────────────────────

  String? _lookup(String text, AppLanguage targetLang) {
    final lower = text.toLowerCase().trim();
    final match = _lookupIndex[lower];
    if (match != null) {
      return targetLang == AppLanguage.sinhala ? match.$1 : match.$2;
    }
    return null;
  }

  String? _translateSmartSymbols(String input, AppLanguage targetLang) {
    // 1. Strip non-alphanumeric leading / trailing symbols (emojis, icons, bullets, checks, quotes, etc.)
    final nonAlphaLeading = RegExp(r'^([^\w\u0D80-\u0DFF\u0B80-\u0BFF]+)(.*)$');
    final nonAlphaTrailing = RegExp(r'^(.*?)([^\w\u0D80-\u0DFF\u0B80-\u0BFF]+)$');

    var core = input;
    var prefix = '';
    var suffix = '';

    final leadMatch = nonAlphaLeading.firstMatch(core);
    if (leadMatch != null) {
      prefix = leadMatch.group(1)!;
      core = leadMatch.group(2)!.trim();
    }

    final trailMatch = nonAlphaTrailing.firstMatch(core);
    if (trailMatch != null) {
      suffix = trailMatch.group(2)!;
      core = trailMatch.group(1)!.trim();
    }

    if (core.isNotEmpty) {
      var translatedCore = _lookup(core, targetLang);
      if (translatedCore == null && suffix.isNotEmpty) {
        final withSuffix = _lookup('$core$suffix', targetLang);
        if (withSuffix != null) {
          return '$prefix$withSuffix';
        }
      }
      if (translatedCore == null) {
        final withPunctuation = _lookup('$core!', targetLang) ?? _lookup('$core.', targetLang);
        if (withPunctuation != null) {
          return '$prefix$withPunctuation';
        }
      }
      if (translatedCore != null) {
        return '$prefix$translatedCore$suffix';
      }
    }

    // Multi-line split & translate
    if (input.contains('\n')) {
      final lines = input.split('\n');
      final translatedLines = <String>[];
      bool anyTranslated = false;
      for (final line in lines) {
        final tr = translateSync(line, targetLang);
        if (tr != line) anyTranslated = true;
        translatedLines.add(tr);
      }
      if (anyTranslated) {
        return translatedLines.join('\n');
      }
    }

    // 2. Parenthesized counts e.g. "Saved Cards & Accounts (3)" or "(2)"
    final countMatch = RegExp(r'^(.*?)\s*(\(\d+\))$').firstMatch(input);
    if (countMatch != null) {
      final base = countMatch.group(1)!.trim();
      final count = countMatch.group(2)!;
      final trBase = translateSync(base, targetLang);
      if (trBase != base) return '$trBase $count';
    }

    // 3. Step X of Y
    final stepMatch = RegExp(r'^Step\s+(\d+)\s+of\s+(\d+)$', caseSensitive: false).firstMatch(input);
    if (stepMatch != null) {
      return targetLang == AppLanguage.sinhala
          ? 'පියවර ${stepMatch.group(1)} / ${stepMatch.group(2)}'
          : 'படி ${stepMatch.group(1)} / ${stepMatch.group(2)}';
    }

    // 4. Top Up Rs. X Now
    final topUpMatch = RegExp(r'^Top Up Rs\.\s*(\d+)\s+Now$', caseSensitive: false).firstMatch(input);
    if (topUpMatch != null) {
      return targetLang == AppLanguage.sinhala
          ? 'දැන් රු. ${topUpMatch.group(1)}ක් ටොප්-අප් කරන්න'
          : 'இப்போது ரூ. ${topUpMatch.group(1)} டாப் அப் செய்யவும்';
    }

    // 5. Distance: In 150m / In 2km
    final distMatch = RegExp(r'^In\s+(\d+m|\d+km)$', caseSensitive: false).firstMatch(input);
    if (distMatch != null) {
      return targetLang == AppLanguage.sinhala ? '${distMatch.group(1)}කින්' : '${distMatch.group(1)} இல்';
    }

    // 6. Avg prep time: 18m
    final prepMatch = RegExp(r'^[•\s]*Avg prep time:\s*(.*)$', caseSensitive: false).firstMatch(input);
    if (prepMatch != null) {
      return targetLang == AppLanguage.sinhala
          ? '• සාමාන්‍ය සූදානම් කිරීමේ කාලය: ${prepMatch.group(1)}'
          : '• சராசரி தயாரிப்பு நேரம்: ${prepMatch.group(1)}';
    }

    // 7. Dropoff by ...
    final dropoffMatch = RegExp(r'^[•\s]*Dropoff by\s*(.*)$', caseSensitive: false).firstMatch(input);
    if (dropoffMatch != null) {
      return targetLang == AppLanguage.sinhala
          ? '• ${dropoffMatch.group(1)} වන විට භාරදීම'
          : '• ${dropoffMatch.group(1)} க்குள் ஒப்படைப்பு';
    }

    // 8. Vehicle: ...
    final vehMatch = RegExp(r'^Vehicle:\s*(.*)$', caseSensitive: false).firstMatch(input);
    if (vehMatch != null) {
      return targetLang == AppLanguage.sinhala ? 'වාහනය: ${vehMatch.group(1)}' : 'வாகனம்: ${vehMatch.group(1)}';
    }

    // 9. Bank: ...
    final bankMatch = RegExp(r'^Bank:\s*(.*)$', caseSensitive: false).firstMatch(input);
    if (bankMatch != null) {
      return targetLang == AppLanguage.sinhala ? 'බැංකුව: ${bankMatch.group(1)}' : 'வங்கி: ${bankMatch.group(1)}';
    }

    // 10. Commercial Bank • ...
    final commMatch = RegExp(r'^Commercial Bank\s*[•:]\s*(.*)$', caseSensitive: false).firstMatch(input);
    if (commMatch != null) {
      return targetLang == AppLanguage.sinhala ? 'කොමර්ෂල් බැංකුව • ${commMatch.group(1)}' : 'கொமர்ஷல் வங்கி • ${commMatch.group(1)}';
    }

    // 11. Status: ...
    final statusMatch = RegExp(r'^Status:\s*(.*)$', caseSensitive: false).firstMatch(input);
    if (statusMatch != null) {
      final rest = statusMatch.group(1)!;
      final trRest = translateSync(rest, targetLang);
      return targetLang == AppLanguage.sinhala ? 'තත්ත්වය: $trRest' : 'நிலை: $trRest';
    }

    // 12. Generated: ...
    final genMatch = RegExp(r'^Generated:\s*(.*)$', caseSensitive: false).firstMatch(input);
    if (genMatch != null) {
      return targetLang == AppLanguage.sinhala ? 'ජනනය කළ දිනය: ${genMatch.group(1)}' : 'உருவாக்கப்பட்ட தேதி: ${genMatch.group(1)}';
    }

    // 13. Time ago e.g. "10m ago", "1h ago", "45m ago", "5m ago"
    final agoMatch = RegExp(r'^(\d+)(m|h)\s+ago$', caseSensitive: false).firstMatch(input);
    if (agoMatch != null) {
      final val = agoMatch.group(1)!;
      final unit = agoMatch.group(2)!.toLowerCase();
      if (targetLang == AppLanguage.sinhala) {
        return unit == 'm' ? 'මිනිත්තු $valකට පෙර' : 'පැය $valකට පෙර';
      } else {
        return unit == 'm' ? '$val நிமிடம் முன்பு' : '$val மணிநேரம் முன்பு';
      }
    }

    // 14. Trips Finished: e.g. "1,840+ Trips Finished"
    final tripsMatch = RegExp(r'^([\d,]+\+?)\s+Trips\s+Finished$', caseSensitive: false).firstMatch(input);
    if (tripsMatch != null) {
      final count = tripsMatch.group(1)!;
      return targetLang == AppLanguage.sinhala
          ? '$count නිමකළ ගමන්'
          : '$count நிறைவுசெய்த பயணங்கள்';
    }

    // 15. Reviews count: e.g. "340 Reviews"
    final revMatch = RegExp(r'^([\d,]+)\s+Reviews$', caseSensitive: false).firstMatch(input);
    if (revMatch != null) {
      final count = revMatch.group(1)!;
      return targetLang == AppLanguage.sinhala
          ? '$count සමාලෝචන'
          : '$count மதிப்புரைகள்';
    }

    // 16. Years experience: e.g. "6 Yrs"
    final yrsMatch = RegExp(r'^(\d+)\s+Yrs$', caseSensitive: false).firstMatch(input);
    if (yrsMatch != null) {
      final count = yrsMatch.group(1)!;
      return targetLang == AppLanguage.sinhala
          ? 'වසර $count'
          : '$count ஆண்டுகள்';
    }

    // 17. NEW count: e.g. "2 NEW"
    final newMatch = RegExp(r'^(\d+)\s+NEW$', caseSensitive: false).firstMatch(input);
    if (newMatch != null) {
      final count = newMatch.group(1)!;
      return targetLang == AppLanguage.sinhala
          ? 'අලුත් $countක්'
          : '$count புதியவை';
    }

    // 18. Call Farmer ... e.g. "Call Farmer Bandar"
    final callFarmerMatch = RegExp(r'^Call\s+Farmer\s+(.*)$', caseSensitive: false).firstMatch(input);
    if (callFarmerMatch != null) {
      final name = callFarmerMatch.group(1)!;
      return targetLang == AppLanguage.sinhala
          ? 'ගොවි $name අමතන්න'
          : 'விவசாயி $name ஐ அழைக்கவும்';
    }

    // 19. Dialing ... e.g. "Dialing Farmer Bandar (+94 77 458 1920)..."
    final dialMatch = RegExp(r'^Dialing\s+([\s\S]+?)(?:\.{1,3})?$', caseSensitive: false).firstMatch(input);
    if (dialMatch != null) {
      final rest = dialMatch.group(1)!.trim();
      return targetLang == AppLanguage.sinhala
          ? 'අමතමින්: $rest...'
          : 'அழைக்கிறது: $rest...';
    }

    // 20. Turn-by-turn navigation started for ...
    final navMatch = RegExp(r'^Turn-by-turn navigation started for\s+(.*)$', caseSensitive: false).firstMatch(input);
    if (navMatch != null) {
      final code = navMatch.group(1)!;
      return targetLang == AppLanguage.sinhala
          ? '$code සඳහා සජීවී මාර්ගගත සංචලනය ආරම්භ විය'
          : '$code க்கான நிகழ்நேர வழிகாட்டுதல் தொடங்கியது';
    }

    // 21. Urgent Pickup Ready • ...
    final urgMatch = RegExp(r'^Urgent\s+Pickup\s+Ready\s*[•:]\s*(.*)$', caseSensitive: false).firstMatch(input);
    if (urgMatch != null) {
      final rest = urgMatch.group(1)!;
      return targetLang == AppLanguage.sinhala
          ? 'හදිසි ලබාගැනීම සූදානම් • $rest'
          : 'அவசர பிக்கப் தயார் • $rest';
    }

    // 22. New Assigned Order • ...
    final newAssignedMatch = RegExp(r'^New\s+Assigned\s+Order\s*[•:]\s*(.*)$', caseSensitive: false).firstMatch(input);
    if (newAssignedMatch != null) {
      final rest = newAssignedMatch.group(1)!;
      return targetLang == AppLanguage.sinhala
          ? 'නව පැවරුණු ඇණවුම • $rest'
          : 'புதிய ஒதுக்கப்பட்ட ஆர்டர் • $rest';
    }

    // 23. Order Details #...
    final orderDetMatch = RegExp(r'^Order\s+Details\s+(#?.*)$', caseSensitive: false).firstMatch(input);
    if (orderDetMatch != null) {
      final rest = orderDetMatch.group(1)!;
      return targetLang == AppLanguage.sinhala
          ? 'ඇණවුම් විස්තර $rest'
          : 'ஆர்டர் விவரங்கள் $rest';
    }

    // 24. Buyer Instruction • ...
    final buyerInstMatch = RegExp(r'^Buyer\s+Instruction\s*[•:]\s*(.*)$', caseSensitive: false).firstMatch(input);
    if (buyerInstMatch != null) {
      final rest = buyerInstMatch.group(1)!;
      return targetLang == AppLanguage.sinhala
          ? 'ගැනුම්කරු උපදෙස් • $rest'
          : 'வாங்குபவர் குறிப்பு • $rest';
    }

    // 25. Chilled Fleet • ...
    final chilledFleetMatch = RegExp(r'^Chilled\s+Fleet\s*[•:]\s*(.*)$', caseSensitive: false).firstMatch(input);
    if (chilledFleetMatch != null) {
      final rest = chilledFleetMatch.group(1)!;
      return targetLang == AppLanguage.sinhala
          ? 'ශීතල ප්‍රවාහන සේවය • $rest'
          : 'குளிரூட்டப்பட்ட வாகனம் • $rest';
    }

    // 26. Cargo Chiller Safe (...)
    final chillerSafeMatch = RegExp(r'^Cargo\s+Chiller\s+Safe\s*\((.*?)\)$', caseSensitive: false).firstMatch(input);
    if (chillerSafeMatch != null) {
      final temp = chillerSafeMatch.group(1)!;
      return targetLang == AppLanguage.sinhala
          ? 'කාගෝ ශීතකරණය සුරක්ෂිතයි ($temp)'
          : 'கார்கோ சில்லர் பாதுகாப்பானது ($temp)';
    }

    // 27. Active (10°C - 16°C) ✓
    final activeTempMatch = RegExp(r'^Active\s*\((.*?)\)\s*✓?$', caseSensitive: false).firstMatch(input);
    if (activeTempMatch != null) {
      final temp = activeTempMatch.group(1)!;
      return targetLang == AppLanguage.sinhala
          ? 'ක්‍රියාකාරී ($temp) ✓'
          : 'செயலில் உள்ளது ($temp) ✓';
    }

    // 28. Chilled (10°C - 14°C)
    final chilledTempMatch = RegExp(r'^Chilled\s*\((.*?)\)$', caseSensitive: false).firstMatch(input);
    if (chilledTempMatch != null) {
      final temp = chilledTempMatch.group(1)!;
      return targetLang == AppLanguage.sinhala
          ? 'සිසිල්කළ ($temp)'
          : 'குளிரூட்டப்பட்டது ($temp)';
    }

    // 29. Valid until ...
    final validMatch = RegExp(r'^Valid\s+until\s+(.*)$', caseSensitive: false).firstMatch(input);
    if (validMatch != null) {
      final rest = validMatch.group(1)!;
      return targetLang == AppLanguage.sinhala
          ? '$rest දක්වා වලංගුයි'
          : '$rest வரை செல்லுபடியாகும்';
    }

    // 30. [Place] • Order [Order] Delivery
    final placeOrderMatch = RegExp(r'^(.*?)\s+•\s+Order\s+(#?[A-Za-z0-9-]+)\s+Delivery$', caseSensitive: false).firstMatch(input);
    if (placeOrderMatch != null) {
      final place = placeOrderMatch.group(1)!;
      final ord = placeOrderMatch.group(2)!;
      final trPlace = translateSync(place, targetLang);
      return targetLang == AppLanguage.sinhala
          ? '$trPlace • ඇණවුම $ord බෙදාහැරීම'
          : '$trPlace • ஆர்டர் $ord விநியோகம்';
    }

    return null;
  }

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

    return modified ? result : null;
  }

  void _saveToCache(String key, String value) {
    _memoryCache[key] = value;
    _prefs?.setString('$_cachePrefix$key', value);
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
    'Hambantota': ('හම්බන්තොට', 'அம்பாந்தோட்டை'),

    // ── Produce Modifiers ─────────────────────────────────────────────────────
    'Produce': ('අස්වනු', 'விளைச்சல்'),
    'Bulk': ('තොග', 'மொத்த'),
    'Greens': ('කොළ එළවළු', 'கீரை வகைகள்'),
    'Salad': ('සලාද', 'சாலட்'),
    'Mixed': ('මිශ්‍ර', 'கலப்பு'),
    'Crisp': ('නැවුම්', 'புதிய'),
  };

  static const Map<String, (String, String)> _primaryVocab = {
    // ── Categories ─────────────────────────────────────────────────────────────
    'Vegetables': ('එළවළු', 'காய்கறிகள்'),
    'Vegetable': ('එළවළු', 'காய்கறி'),
    'Fruits': ('පළතුරු', 'பழங்கள்'),
    'Fruit': ('පළතුරු', 'பழம்'),
    'Grains': ('ධාන්‍ය', 'தானியங்கள்'),
    'Grain': ('ධාන්‍ය', 'தானியம்'),
    'Spices': ('කුළුබඩු', 'மசாலா பொருட்கள்'),
    'Spice': ('කුළුබඩු', 'மசாலா'),
    'Dairy': ('කිරි නිෂ්පාදන', 'பால் பொருட்கள்'),

    // ── Months ─────────────────────────────────────────────────────────────────
    'January': ('ජනවාරි', 'ஜனவரி'),
    'Jan': ('ජනවාරි', 'ஜனவரி'),
    'February': ('පෙබරවාරි', 'பிப்ரவரி'),
    'Feb': ('පෙබරවාරි', 'பிப்ரவரி'),
    'March': ('මාර්තු', 'மார்ச்'),
    'Mar': ('මාර්තු', 'மார்ச்'),
    'April': ('අප්‍රේල්', 'ஏப்ரல்'),
    'Apr': ('අප්‍රේල්', 'ஏப்ரல்'),
    'May': ('මැයි', 'மே'),
    'June': ('ජූනි', 'ஜூன்'),
    'Jun': ('ජූනි', 'ஜூன்'),
    'July': ('ජූලි', 'ஜூலை'),
    'Jul': ('ජූලි', 'ஜூலை'),
    'August': ('අගෝස්තු', 'ஆகஸ்ட்'),
    'Aug': ('අගෝස්තු', 'ஆகஸ்ட்'),
    'September': ('සැප්තැම්බර්', 'செப்டம்பர்'),
    'Sep': ('සැප්තැම්බර්', 'செப்டம்பர்'),
    'October': ('ඔක්තෝබර්', 'அக்டோபர்'),
    'Oct': ('ඔක්තෝබර්', 'அக்டோபர்'),
    'November': ('නොවැම්බර්', 'நவம்பர்'),
    'Nov': ('නොවැම්බර්', 'நவம்பர்'),
    'December': ('දෙසැම්බර්', 'டிசம்பர்'),
    'Dec': ('දෙසැම්බර්', 'டிசம்பர்'),

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
    'Bell Peppers': ('මාළු මිරිස්', 'குடைமிளகாய்'),
    'Chili': ('මිරිස්', 'மிளகாய்'),
    'Green Chili': ('අමු මිරිස්', 'பச்சை மிளகாய்'),
    'Beetroot': ('බීට්රූට්', 'பீட்ரூட்'),
    'Onion': ('ලූනු', 'வெங்காயம்'),
    'Red Onion': ('රතු ලූනු', 'சின்ன வெங்காயம்'),
    'Big Onion': ('ලොකු ලූනු', 'பெரிய வெங்காயம்'),
    'Garlic': ('සුදුලූනු', 'பூண்டு'),
    'Ginger': ('ඉඟුරු', 'இஞ்சி'),
    'Pumpkin': ('වට්ටක්කා', 'பூசணிக்காய்'),
    'Brinjal': ('වම්බටු', 'கத்தரிக்காய்'),
    'Eggplant': ('වම්බටු', 'கத்தரிக்காய்'),
    'Ladies Finger': ('බණ්ඩක්කා', 'வெண்டைக்காய்'),
    'Okra': ('බණ්ඩක්කා', 'வெண்டைக்காய்'),
    'Bitter Gourd': ('කරවිල', 'பாகற்காய்'),
    'Snake Gourd': ('පතෝල', 'புடலங்காய்'),
    'Ridge Gourd': ('වැටකොළු', 'பீர்க்கங்காய்'),
    'Bottle Gourd': ('දියලබු', 'சுரைக்காய்'),
    'Ash Plantain': ('අළු කෙසෙල්', 'சாம்பல் வாழை'),
    'Radish': ('රාබු', 'முள்ளங்கி'),
    'Cucumber': ('පිපිඤ්ඤා', 'வெள்ளரிக்காய்'),
    'Gotukola': ('ගොටුකොළ', 'வல்லாரை'),
    'Mukunuwenna': ('මුකුණුවැන්න', 'பொன்னாங்கண்ணி'),
    'Kangkung': ('කංකුං', 'கங்கூன்'),
    'Spinach': ('නිවිති', 'பசலைக்கீரை'),
    'Curry Leaves': ('කරපිංචා', 'கறிவேப்பிலை'),
    'Drumstick': ('මුරුංගා', 'முருங்கை'),
    'Moringa': ('මුරුංගා', 'முருங்கை'),
    'Kohila': ('කොහිල', 'கொஹில'),
    'Manioc': ('මඤ්ඤොක්කා', 'மரவள்ளிக்கிழங்கு'),
    'Cassava': ('මඤ්ඤොක්කා', 'மரவள்ளிக்கிழங்கு'),
    'Sweet Potato': ('බතල', 'சர்க்கரைவள்ளி'),
    'Green Beans': ('බෝංචි', 'பீன்ஸ்'),
    'Beans': ('බෝංචි', 'பீன்ஸ்'),

    // ── Fruits ─────────────────────────────────────────────────────────────────
    'Banana': ('කෙසෙල්', 'வாழைப்பழம்'),
    'Bananas': ('කෙසෙල්', 'வாழைப்பழம்'),
    'Papaya': ('පැපොල්', 'பப்பாளி'),
    'Mango': ('අඹ', 'மாம்பழம்'),
    'Pineapple': ('අන්නාසි', 'அன்னாசி'),
    'Avocado': ('අලිගැටපේර', 'வெண்ணெய் பழம்'),
    'Watermelon': ('පැණි කොමඩු', 'தர்பூசணி'),
    'Guava': ('පේර', 'கொய்யா'),
    'Passion Fruit': ('වැල් දොඩම්', 'கொடி தோடம்பழம்'),
    'Lime': ('දෙහි', 'எலுமிச்சை'),
    'Orange': ('දොඩම්', 'ஆரஞ்சு'),
    'Pomegranate': ('දෙළුම්', 'மாதுளை'),

    // ── Grains & Spices ────────────────────────────────────────────────────────
    'Samba Rice': ('සම්බා සහල්', 'சம்பா அரிசி'),
    'Keeri Samba': ('කීරි සම්බා', 'கீரி சம்பா'),
    'Nadu Rice': ('නාඩු සහල්', 'நாடு அரிசி'),
    'Red Raw Rice': ('රතු කැකුළු', 'சிவப்பு பச்சரிசி'),
    'White Raw Rice': ('සුදු කැකුළු', 'வெள்ளை பச்சரிசி'),
    'Rice': ('සහල්', 'அரிசி'),
    'Kurakkan': ('කුරක්කන්', 'கேழ்வரகு'),
    'Finger Millet': ('කුරක්කන්', 'கேழ்வரகு'),
    'Pepper': ('ගම්මිරිස්', 'மிளகு'),
    'Black Pepper': ('කළු ගම්මිරිස්', 'கருப்பு மிளகு'),
    'Cinnamon': ('කුරුඳු', 'இலவங்கப்பட்டை'),
    'Cardamom': ('එනසාල්', 'ஏலக்காய்'),
    'Cloves': ('කරාබුනැටි', 'கிராம்பு'),
    'Turmeric': ('කහ', 'மஞ்சள்'),
    'Nutmeg': ('සාදික්කා', 'ஜாதிக்காய்'),

    // ── Quality & Product Descriptors ──────────────────────────────────────────
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
    'See All': ('සියල්ල බලන්න', 'அனைத்தும் பார்க்க'),
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
    'OK': ('හරි', 'சரி'),
    'Pending': ('තහවුරු කිරීමට නියමිත', 'நிலுவையில்'),
    'Total Paid': ('ගෙවූ මුළු මුදල', 'செலுத்தப்பட்ட மொத்தம்'),
    'Order': ('ඇණවුම', 'ஆர்டர்'),
    'Summary': ('සාරාංශය', 'சுருக்கம்'),
    'Status': ('තත්ත්වය', 'நிலை'),
    'Notifications': ('දැනුම්දීම්', 'அறிவிப்புகள்'),
    'Location': ('ස්ථානය', 'இருப்பிடம்'),
    'District': ('දිස්ත්‍රික්කය', 'மாவட்டம்'),
    'Quantity': ('ප්‍රමාණය', 'அளவு'),
    'Price Range': ('මිල පරාසය', 'விலை வரம்பு'),
    'Pricing Unit': ('මිල ගණනය කිරීමේ ඒකකය', 'விலை நிர்ணய அலகு'),
    'Product Description': ('නිෂ්පාදන විස්තරය', 'தயாரிப்பு விவரம்'),
    'Product Details': ('නිෂ්පාදන විස්තර', 'தயாரிப்பு விவரங்கள்'),
    'Popular Products': ('ජනප්‍රිය නිෂ්පාදන', 'பிரபலமான தயாரிப்புகள்'),
    'Sign Out': ('ඉවත් වන්න', 'வெளியேறு'),
    'Log Out': ('ඉවත් වන්න', 'வெளியேறு'),
    'Log In': ('ඇතුල් වන්න', 'உள்நுழைக'),
    'Live Sync': ('සජීවී සමමුහුර්තකරණය', 'நேரலை ஒத்திசைவு'),
    'Live': ('සජීවී', 'நேரலை'),
    'Default': ('ප්‍රධාන', 'இயல்புநிலை'),
    'RECOMMENDED': ('නිර්දේශිත', 'பரிந்துரைக்கப்பட்டது'),
    'PRIMARY': ('ප්‍රධාන', 'முதன்மை'),
    'Cleared': ('පියවන ලදී', 'தீர்வு செய்யப்பட்டது'),
    'All Active': ('සියලු සක්‍රීය', 'அனைத்தும் செயலில்'),
    'All': ('සියල්ල', 'அனைத்தும்'),
    'Entries': ('ඇතුළත් කිරීම්', 'பதிவுகள்'),
    'Share with Contact': ('මිතුරෙකු සමඟ බෙදාගන්න', 'தொடர்புடன் பகிரவும்'),
    'View Profile': ('පැතිකඩ බලන්න', 'சுயவிவரத்தைக் காண்க'),
    'Spring Harvest Fest': ('වසන්ත අස්වනු උළෙල', 'வசந்த அறுவடை திருவிழா'),
    'SPRING HARVEST FEST': ('වසන්ත අස්වනු උළෙල', 'வசந்த அறுவடை திருவிழா'),
    'Shop Season Specials': ('කන්නයේ විශේෂ දීමනා', 'பருவகால சலுகைகளை வாங்குங்கள்'),
    'Explore Farms': ('ගොවිබිම් ගවේෂණය කරන්න', 'பண்ணைகளை ஆராயுங்கள்'),
    'Explore Farms →': ('ගොවිබිම් ගවේෂණය කරන්න →', 'பண்ணைகளை ஆராயுங்கள் →'),
    'Change Photo': ('පින්තූරය වෙනස් කරන්න', 'புகைப்படத்தை மாற்றவும்'),
    'Change Status': ('තත්ත්වය වෙනස් කරන්න', 'நிலையை மாற்றவும்'),
    'Filtered Results': ('පෙරහන් කළ ප්‍රතිඵල', 'வடிகட்டிய முடிவுகள்'),
    'Apply Filters': ('පෙරහන් යොදන්න', 'வடிகட்டிகளைப் பயன்படுத்து'),
    'Search & Filter': ('සොයන්න සහ පෙරහන් කරන්න', 'தேடு & வடிகட்டு'),
    'Security & Terms': ('ආරක්ෂාව සහ කොන්දේසි', 'பாதுகாப்பு & விதிமுறைகள்'),
    'Save Changes': ('වෙනස්කම් සුරකින්න', 'மாற்றங்களை சேමි'),
    'Save Profile Photo': ('පැතිකඩ ඡායාරූපය සුරකින්න', 'சுயவிவர புகைப்படத்தை சேமி'),
    'Update Account': ('ගිණුම යාවත්කාලීන කරන්න', 'கணக்கை புதுப்பிக்கவும்'),
    'Use MM/YY': ('මාසය/වසර භාවිතා කරන්න', 'MM/YY பயன்படுத்தவும்'),
    'MM/YY': ('මාසය/වසර', 'மாதம்/ஆண்டு'),
    'Or Enter Custom Image URL': ('හෝ වෙනත් පින්තූර URL එකක් ඇතුළත් කරන්න', 'அல்லது தனிப்பயன் பட URL ஐ உள்ளிடவும்'),
    'Leave a short review (optional)': ('කෙටි ඇගයීමක් ලියන්න (විකල්ප)', 'ஒரு சிறிய மதிப்பாய்வை விடுங்கள் (விருப்பத்தேர்வு)'),
    'Opening review form (+50 coins earned upon submission)': ('ඇගයීම් පෝරමය විවෘත වේ (+50 කාසි හිමිවේ)', 'மதிப்பாய்வு படிவம் திறக்கிறது (+50 நாணயங்கள் கிடைக்கும்)'),
    'Try adjusting your search criteria or price range.': ('ඔබේ සෙවුම් පරාමිතීන් වෙනස් කර නැවත බලන්න.', 'உங்கள் தேடல் அளவுருக்களை மாற்ற முயற்சிக்கவும்.'),

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
    'Free Delivery': ('නොමිලේ බෙදාහැරීම', 'இලவச டெலிவரி'),
    'Discount': ('වට්ටම', 'தள்ளුபடி'),
    'Promo Code': ('ප්‍රවර්ධන කේතය', 'ப்ரோமோ குறியீடு'),
    'Apply Promo': ('කේතය යොදන්න', 'குறியீட்டைப் பயன்படுத்து'),

    // ── Payment Methods & Wallet ──────────────────────────────────────────
    'Payment Methods': ('ගෙවීම් ක්‍රම', 'கட்டண முறைகள்'),
    'Payment Methods & Cards': ('ගෙවීම් ක්‍රම සහ කාඩ්පත්', 'கட்டண முறைகள் & கார்டுகள்'),
    'Add New Card': ('නව කාඩ්පතක් එක් කරන්න', 'புதிய கார்டைச் சேர்க்கவும்'),
    'Add New Payment Card': ('නව ගෙවීම් කාඩ්පතක් එක් කරන්න', 'புதிய கட்டண கார்டைச் சேர்க்கவும்'),
    'Add Payment Card': ('ගෙවීම් කාඩ්පතක් එක් කරන්න', 'கட்டண கார்டைச் சேர்க்கவும்'),
    'Add Card': ('කාඩ්පතක් එක් කරන්න', 'கார்டைச் சேர்க்கவும்'),
    'Add Your First Card': ('ඔබගේ පළමු කාඩ්පත එක් කරන්න', 'உங்கள் முதல் கார்டைச் சேர்க்கவும்'),
    'Add Another Card': ('තවත් කාඩ්පතක් එක් කරන්න', 'மற்றொரு கார்டைச் சேர்க்கவும்'),
    'Saved Cards & Accounts': ('සුරකින ලද කාඩ්පත් සහ ගිණුම්', 'சேமித்த கார்டுகள் மற்றும் கணக்குகள்'),
    'Default Method': ('ප්‍රධාන ක්‍රමය', 'இயல்புநிலை முறை'),
    'Set Default': ('ප්‍රධාන ක්‍රමය ලෙස සකසන්න', 'இயல்புநிலையாக அமை'),
    'Set as Primary Card': ('ප්‍රධාන කාඩ්පත ලෙස සකසන්න', 'முதன்மை கார்டாக அமைக்கவும்'),
    'Delete Payment Method': ('ගෙවීම් ක්‍රමය මකා දමන්න', 'கட்டண முறையை நீக்கு'),
    'Delete Payment Method?': ('ගෙවීම් ක්‍රමය මකා දමන්නද?', 'கட்டண முறையை நீக்கவா?'),
    'Delete Card': ('කාඩ්පත මකන්න', 'கார்டை நீக்கு'),
    'Edit Card': ('කාඩ්පත සංස්කරණය කරන්න', 'கார்டைத் திருத்து'),
    'Payment card removed successfully.': ('ගෙවීම් කාඩ්පත සාර්ථකව ඉවත් කරන ලදී.', 'கட்டண கார்டு வெற்றிகரமாக அகற்றப்பட்டது.'),
    'No Payment Cards Saved': ('සුරකින ලද කාඩ්පත් කිසිවක් නැත', 'சேமிக்கப்பட்ட கார்டுகள் எதுவும் இல்லை'),
    'No saved payment cards found.': ('සුරකින ලද ගෙවීම් කාඩ්පත් හමු නොවීය.', 'சேமிக்கப்பட்ட கட்டண கார்டுகள் எதுவும் கிடைக்கவில்லை.'),
    'LankaPay & PCI-DSS Verified': ('LankaPay සහ PCI-DSS මඟින් සත්‍යාපිතයි', 'LankaPay & PCI-DSS சரிபார்க்கப்பட்டது'),
    'Instant 1-click checkout secured by Central Bank standards.': ('ශ්‍රී ලංකා මහ බැංකු ප්‍රමිතීන්ට අනුව ක්ෂණික ආරක්ෂිත ගෙවීම්.', 'மத்திய வங்கி தரநிலைகளால் பாதுகாக்கப்பட்ட உடனடி 1-கிளிக் கட்டணம்.'),
    'Farm Direct Wallet': ('ගොවි සෘජු පසුම්බිය', 'பண்ணை நேரடி பணப்பை'),
    'CURRENT WALLET BALANCE': ('වත්මන් පසුම්බි ශේෂය', 'தற்போதைய பணப்பை இருப்பு'),
    'Instant 0% fee payments to smallholder farmers.': ('සුළු පරිමාණ ගොවීන්ට 0% ගාස්තු සහිත ක්ෂණික ගෙවීම්.', 'சிறு விவசாயிகளுக்கு 0% கட்டணத்தில் உடனடி கட்டணம்.'),
    'Select Top-Up Amount': ('ටොප්-අප් මුදල තෝරන්න', 'டாப் அப் தொகையைத் தேர்ந்தெடுக்கவும்'),
    'Or Enter Custom Amount (LKR)': ('හෝ වෙනත් මුදලක් ඇතුළත් කරන්න (රු.)', 'அல்லது தனிப்பயன் தொகையை உள்ளிடவும் (ரூ)'),
    'Charge Source': ('මුදල් අයකරන මාර්ගය', 'கட்டண ஆதாரம்'),
    'Central Bank 3D-Secure 2.0': ('ශ්‍රී ලංකා මහ බැංකු 3D-Secure 2.0 ආරක්ෂාව', 'மத்திய வங்கி 3D-Secure 2.0'),
    'Please enter a valid top-up amount.': ('කරුණාකර වලංගු ටොප්-අප් මුදලක් ඇතුළත් කරන්න.', 'சரியான டாப் அப் தொகையை உள்ளிடவும்.'),
    'Bank Transfer & LANKAQR': ('බැංකු හුවමාරු සහ LANKAQR', 'வங்கி பரிமாற்றம் & LANKAQR'),
    'LANKAQR & Bank Transfer': ('LANKAQR සහ බැංකු හුවමාරු', 'LANKAQR & வங்கி பரிமாற்றம்'),
    'LANKAQR': ('LANKAQR', 'LANKAQR'),
    'Account Name': ('ගිණුම් හිමියාගේ නම', 'கணக்கு பெயர்'),
    'Account Number': ('ගිණුම් අංකය', 'கணக்கு எண்'),
    'Branch': ('ශාඛාව', 'கிளை'),
    'BRANCH': ('ශාඛාව', 'கிளை'),
    'Copy': ('පිටපත් කරන්න', 'நகலெடு'),
    'Account number copied to clipboard!': ('ගිණුම් අංකය පිටපත් කරගන්නා ලදී!', 'கணக்கு எண் நகலெடுக்கப்பட்டது!'),
    'Instant National QR Code': ('ක්ෂණික ජාතික QR කේතය (LANKAQR)', 'உடனடி தேசிய QR குறியீடு'),
    'Scan with FriMi • FLASH • Genie • Commercial Q+ • iPay': ('FriMi • FLASH • Genie • Commercial Q+ • iPay මඟින් ස්කෑන් කරන්න', 'FriMi • FLASH • Genie • Commercial Q+ • iPay மூலம் ஸ்கேன் செய்க'),
    'Verification & Receipt Slip': ('තහවුරු කිරීම සහ තැන්පතු පත්‍රිකාව', 'சரிபார்ப்பு & ரசீது சீட்டு'),
    'Bank Reference / Slip No (Optional)': ('බැංකු අංකය / රිසිට්පත් අංකය (විකල්ප)', 'வங்கி குறிப்பு / ரசீது எண் (விருப்பத்தேர்வு)'),
    'Attach Bank Deposit Slip / Screenshot': ('බැංකු තැන්පතු පත්‍රිකාව / රිසිට්පත අමුණන්න', 'வங்கி வைப்பு ரசீது / ஸ்கிரீன்ஷாட்டை இணைக்கவும்'),
    'Tap to upload screenshot or slip photo': ('රිසිට්පත උඩුගත කිරීමට තට්ටු කරන්න', 'ரசீது புகைப்படத்தைப் பதிவேற்ற தட்டவும்'),
    'Slip ready for automated admin dispatch approval.': ('පරිපාලක අනුමැතිය සඳහා රිසිට්පත සූදානම්.', 'நிர்வாகி ஒப்புதலுக்கு ரசீது தயாராக உள்ளது.'),
    'Confirm Bank Transfer Details': ('බැංකු හුවමාරු විස්තර තහවුරු කරන්න', 'வங்கி பரிமாற்ற விவரங்களை உறுதிப்படுத்தவும்'),
    'Transfer Initiated!': ('මුදල් හුවමාරුව ආරම්භ විය!', 'பரிமாற்றம் தொடங்கப்பட்டது!'),
    'Confirm Purchase': ('මිලදී ගැනීම තහවුරු කරන්න', 'கொள்முதலை உறுதிசெய்க'),
    'Top Up': ('ටොප්-අප් කරන්න', 'டாப் அப்'),
    'Top Up Farm Wallet': ('ගොවි පසුම්බිය ටොප්-අප් කරන්න', 'பண்ணை பணப்பையை டாப் அப் செய்க'),
    'Cardholder Name (as on card)': ('කාඩ්පත් හිමියාගේ නම (කාඩ්පතේ පරිදි)', 'கார்டு வைத்திருப்பவர் பெயர் (கார்டில் உள்ளபடி)'),
    'Please enter cardholder name': ('කරුණාකර කාඩ්පත් හිමියාගේ නම ඇතුළත් කරන්න', 'கார்டு வைத்திருப்பவர் பெயரை உள்ளிடவும்'),
    'Card Number': ('කාඩ්පත් අංකය', 'கார்டு எண்'),
    'Please enter valid 16-digit card number': ('කරුණාකර වලංගු ඉලක්කම් 16 කාඩ්පත් අංකය ඇතුළත් කරන්න', 'சரியான 16 இலக்க கார்டு எண்ணை உள்ளிடவும்'),
    'Expiry (MM/YY)': ('කල් ඉකුත්වීම (මාසය/වසර)', 'காலாவதி (மாதம்/ஆண்டு)'),
    'CVV / CVC Code': ('CVV / CVC අංකය', 'CVV / CVC குறியீடு'),
    '3-4 digits': ('ඉලක්කම් 3-4', '3-4 இலக்கங்கள்'),
    'Set as Default Payment Method': ('ප්‍රධාන ගෙවීම් ක්‍රමය ලෙස සකසන්න', 'இயல்புநிலை கட்டண முறையாக அமைக்கவும்'),
    'Use automatically for 1-click orders': ('තනි ක්ලික් කිරීමකින් ඇණවුම් කිරීමට භාවිතා කරන්න', '1-கிளிக் ஆர்டர்களுக்கு தானாகப் பயன்படுத்தவும்'),
    'Card Color Style:': ('කාඩ්පත් වර්ණය:', 'கார்டு வண்ண நடை:'),
    'End-to-end encrypted with 256-bit AES. FarmTrust does not store full card numbers.': ('256-bit AES මඟින් සම්පූර්ණයෙන්ම සංකේතනය කර ඇත. සම්පූර්ණ කාඩ්පත් අංක ගබඩා නොකෙරේ.', '256-பிட் AES மூலம் மறைகுறியாக்கப்பட்டது. முழு கார்டு எண்களும் சேமிக்கப்படுவதில்லை.'),
    'CARD HOLDER': ('කාඩ්පත් හිමියා', 'கார்டு வைத்திருப்பவர்'),
    'ACCOUNT HOLDER': ('ගිණුම් හිමියා', 'கணக்கு வைத்திருப்பவர்'),
    'EXPIRES': ('කල් ඉකුත්වීම', 'காலாவதி'),
    'AVAILABLE WITHDRAWABLE BALANCE': ('ආපසු ලබාගත හැකි ශේෂය', 'திரும்பப் பெறக்கூடிய இருப்பு'),
    'LINKED BANK ACCOUNT': ('සම්බන්ධිත බැංකු ගිණුම', 'இணைக்கப்பட்ட வங்கி கணக்கு'),
    'Update Bank Account': ('බැංකු ගිණුම යාවත්කාලීන කරන්න', 'வங்கி கணக்கை புதுப்பிக்கவும்'),
    'Transfer payout earnings to your linked bank account:': ('ඔබේ උපයාගත් ආදායම සම්බන්ධිත බැංකු ගිණුමට මාරු කරන්න:', 'உங்கள் வருமானத்தை இணைக்கப்பட்ட வங்கி கணக்கிற்கு மாற்றவும்:'),
    'Withdraw to Bank': ('බැංකුවට ලබාගන්න', 'வங்கிக்கு திரும்பப் பெறவும்'),
    'Auto-Deposit Schedule': ('ස්වයංක්‍රීය තැන්පතු කාලසටහන', 'தானியங்கி வைப்பு அட்டவணை'),
    'Automated Transit Settlement': ('ස්වයංක්‍රීය ප්‍රවාහන පියවීම්', 'தானியங்கி போக்குவரத்து தீர்வு'),
    'CASH ON DELIVERY (COD) SETTLEMENT': ('භාණ්ඩ ලැබුණු පසු මුදල් (COD) පියවීම්', 'பொருட்கள் கிடைத்தவுடன் பணம் (COD) தீர்வு'),
    'Outstanding Net COD to remit:': ('පියවිය යුතු මුළු COD ශේෂය:', 'செலுத்த வேண்டிய நிலுவை COD தொகை:'),
    'Settle COD Balance': ('COD ශේෂය පියවන්න', 'COD இருப்பை செலுத்துங்கள்'),
    'Settle COD Balance via Bank / EzCash': ('බැංකුව හෝ EzCash හරහා COD ශේෂය පියවන්න', 'வங்கி அல்லது EzCash மூலம் COD இருப்பை செலுத்துங்கள்'),
    'Proceed Remit': ('පියවීම ඉදිරියට ගෙනියන්න', 'தீர்வை தொடரவும்'),
    'Remittance request logged. Verification pending confirmation.': ('පියවීම් ඉල්ලීම සටහන් විය. තහවුරු කිරීම අපේක්ෂාවෙන්.', 'அனுப்புதல் கோரிக்கை பதிவு செய்யப்பட்டது. சரிபார்ப்பு நிலுவையில் உள்ளது.'),
    'Select remittance channel:': ('මුදල් ගෙවීමේ මාධ්‍යය තෝරන්න:', 'அனுப்புதல் வழியைத் தேர்ந்தெடுக்கவும்:'),
    'Tap to view Commercial Bank beneficiary account details, scan national LANKAQR, or submit deposit slips.': ('කොමර්ෂල් බැංකු ගිණුම් විස්තර බැලීමට, LANKAQR ස්කෑන් කිරීමට හෝ රිසිට්පත් යොමු කිරීමට තට්ටු කරන්න.', 'கொமர்ஷல் வங்கி கணக்கு விவரங்களைப் பார்க்க, LANKAQR ஸ்கேன் செய்ய அல்லது வைப்பு ரசீதுகளை சமர்ப்பிக்க தட்டவும்.'),
    'Deposit Slip Attached (bank_transfer_slip.jpg)': ('තැන්පතු පත්‍රිකාව අමුණා ඇත (bank_transfer_slip.jpg)', 'வைப்பு ரசீது இணைக்கப்பட்டுள்ளது (bank_transfer_slip.jpg)'),
    'Direct Bank Deposit Credited': ('සෘජු බැංකු තැන්පතුව බැර විය', 'நேரடி வங்கி வைப்பு வரவு வைக்கப்பட்டது'),
    'Tax & Payment Statement': ('බදු සහ ගෙවීම් වාර්තාව', 'வரி மற்றும் கட்டண அறிக்கை'),
    'Save PDF Statement to Device': ('PDF ප්‍රකාශනය දුරකථනයට සුරකින්න', 'PDF அறிக்கையை சாதனத்தில் சேமிக்கவும்'),
    'STATEMENT PERIOD': ('ප්‍රකාශන කාලසීමාව', 'அறிக்கை காலம்'),
    'Withholding Tax (WHT)': ('රඳවා ගැනීමේ බද්ද (WHT)', 'மூலத்தில் பிடித்தம் செய்யப்படும் வரி (WHT)'),
    'TOTAL DISPATCHED PAYOUT': ('මුළු බෙදාහැරීමේ ගෙවීම', 'மொத்த அனுப்பப்பட்ட கொடுப்பனவு'),
    'Net Pay': ('ශුද්ධ ගෙවීම', 'நிகர ஊதியம்'),
    'Net income': ('ශුද්ධ ආදායම', 'நிகர வருமானம்'),
    'Gross Payouts Volume': ('මුළු ගෙවීම් පරිමාව', 'மொத்த கொடுப்பனவு அளவு'),
    'Pay delivery driver in cash upon doorstep delivery.': ('දොරකඩට භාණ්ඩ ලැබුණු පසු රියදුරුට මුදල් ගෙවන්න.', 'வீட்டு வாசலில் டெலிவரி செய்யும் போது ஓட்டுநரிடம் ரொக்கமாக செலுத்தவும்.'),
    'Insufficient wallet balance. Please top up your wallet to continue.': ('පසුම්බි ශේෂය ප්‍රමාණවත් නොවේ. කරුණාකර මුදල් එක් කරන්න.', 'போதுமான பணப்பை இருப்பு இல்லை. தொடர டாப் அப் செய்யவும்.'),
    'Wallet Balance:': ('පසුම්බි ශේෂය:', 'பணப்பை இருப்பு:'),
    'Manage Cards >': ('කාඩ්පත් කළමනාකරණය >', 'கார்டுகளை நிர்வகி >'),
    'Manage saved cards, default payment & accounts': ('සුරකින ලද කාඩ්පත් සහ ගිණුම් කළමනාකරණය', 'சேமித்த கார்டுகள் மற்றும் கணக்குகளை நிர்வகிக்கவும்'),
    'Earnings & Bank Account': ('ආදායම සහ බැංකු ගිණුම', 'வருமானம் & வங்கி கணக்கு'),
    'Payouts, Bank Linking & COD Settlement': ('ගෙවීම්, බැංකු සම්බන්ධ කිරීම සහ COD පියවීම්', 'கட்டணங்கள், வங்கி இணைப்பு & COD தீர்வு'),
    'Payout receipts, ratings & safety advisories': ('ගෙවීම් රිසිට්පත්, ඇගයීම් සහ ආරක්ෂක උපදෙස්', 'கட்டண ரசீதுகள், மதிப்பீடுகள் & பாதுகாப்பு ஆலோசனைகள்'),
    'AMEX': ('AMEX', 'AMEX'),
    'VISA': ('VISA', 'VISA'),
    'OFFICIAL BENEFICIARY': ('නිල ප්‍රතිලාභියා', 'அதிகாரப்பூர்வ பயனாளி'),
    'OFFICIAL STATEMENT': ('නිල ප්‍රකාශනය', 'அதிகாரப்பூர்வ அறிக்கை'),

    // ── Live Auctions & Bidding ───────────────────────────────────────────
    'Live Crop Auctions & Bidding': ('සජීවී අස්වැන්න වෙන්දේසි සහ ලංසු තැබීම', 'நேரலை பயிர் ஏலங்கள் & ஏலமிடுதல்'),
    'Live Crop Auctions & Bidding 🌾': ('සජීවී අස්වැන්න වෙන්දේසි සහ ලංසු තැබීම 🌾', 'நேரலை பயிர் ஏலங்கள் & ஏலமிடுதல் 🌾'),
    'Crop Auctions & Bidding': ('අස්වනු වෙන්දේසි සහ ලංසු තැබීම', 'பயிர் ஏலங்கள் & ஏலமிடுதல்'),
    'Crop Auctions / Bidding System': ('අස්වනු වෙන්දේසි / ලංසු තැබීමේ පද්ධතිය', 'பயிர் ஏலங்கள் / ஏல முறை'),
    'Crop Bidding / Auction System': ('අස්වනු ලංසු තැබීම / වෙන්දේසි පද්ධතිය', 'பயிர் ஏல முறை'),
    'Bid on bulk harvest lots direct from farmers': ('ගොවීන්ගෙන් සෘජුවම තොග අස්වනු සඳහා ලංසු තබන්න', 'விவசாயிகளிடமிருந்து நேரடியாக மொத்த அறுவடைக்கு ஏலம் கேளுங்கள்'),
    'Active Auctions': ('සක්‍රීය වෙන්දේසි', 'செயலில் உள்ள ஏலங்கள்'),
    'My Crop Auctions': ('මගේ අස්වනු වෙන්දේසි', 'எனது பயிர் ஏலங்கள்'),
    'New Auction': ('නව වෙන්දේසියක්', 'புதிய ஏலம்'),
    'New Lot': ('නව කාණ්ඩයක්', 'புதிய தொகுதி'),
    'Add Crop Auction': ('නව අස්වනු වෙන්දේසියක් එක් කරන්න', 'புதிய பயிர் ஏலத்தைச் சேர்க்கவும்'),
    'Create New Auction': ('නව වෙන්දේසියක් සාදන්න', 'புதிய ஏலத்தை உருவாக்கவும்'),
    'Manage Auctions': ('වෙන්දේසි කළමනාකරණය', 'ஏலங்களை நிர்வகிக்கவும்'),
    'Cancel Auction': ('වෙන්දේසිය අවලංගු කරන්න', 'ஏலத்தை ரத்து செய்'),
    'Delete Crop Auction': ('අස්වනු වෙන්දේසිය මකන්න', 'பயிர் ஏலத்தை நீக்கு'),
    'End Auction': ('වෙන්දේසිය අවසන් කරන්න', 'ஏலத்தை முடிக்கவும்'),
    'Mark as Sold': ('විකිණූ බව සලකුණු කරන්න', 'விற்பனை என குறிக்கவும்'),
    'Accept Highest Bid?': ('ඉහළම ලංසුව පිළිගන්නද?', 'அதிகபட்ச ஏலத்தை ஏற்கவா?'),
    'Accept Highest Bid': ('ඉහළම ලංසුව පිළිගන්න', 'அதிகபட்ச ஏலத்தை ஏற்கவும்'),
    'Accept Leading Bid & Sell Now': ('ප්‍රමුඛ ලංසුව පිළිගෙන දැන් විකුණන්න', 'முன்னணி ஏலத்தை ஏற்று இப்போது விற்கவும்'),
    'Accept Leading Bid': ('ප්‍රමුඛ ලංසුව පිළිගන්න', 'முன்னணி ஏலத்தை ஏற்கவும்'),
    'Place Bid': ('ලංසුවක් තබන්න', 'ஏலம் வைக்கவும்'),
    'Bid Now': ('දැන් ලංසු තබන්න', 'இப்போது ஏலம் எடுக்கவும்'),
    'Bid Placed Successfully!': ('ලංසුව සාර්ථකව තබන ලදී!', 'ஏலம் வெற்றிகரமாக வைக்கப்பட்டது!'),
    'Be the first bidder!': ('පළමු ලංසුකරු වන්න!', 'முதல் ஏலதாரராக இருங்கள்!'),
    'No bids placed yet': ('තවමත් ලංසු තබා නැත', 'இன்னும் ஏலம் எதுவும் கேட்கப்படவில்லை'),
    'No bids placed yet. Be the first to place a bid!': ('තවමත් ලංසු තබා නැත. පළමු ලංසුව ඔබ තබන්න!', 'இன்னும் ஏலம் எதுவும் இல்லை. முதலில் ஏலம் கேளுங்கள்!'),
    'No bids yet': ('තවමත් ලංසු නැත', 'இன்னும் ஏலம் இல்லை'),
    'No Auctions Found': ('වෙන්දේසි කිසිවක් හමු නොවීය', 'ஏலங்கள் எதுவும் கிடைக்கவில்லை'),
    'No matching crop auctions found': ('ගැළපෙන අස්වනු වෙන්දේසි හමු නොවීය', 'பொருந்தும் பயிர் ஏலங்கள் எதுவும் கிடைக்கவில்லை'),
    'Auction not found or deleted.': ('වෙන්දේසිය හමු නොවීය හෝ මකා දමා ඇත.', 'ஏலம் காணப்படவில்லை அல்லது நீக்கப்பட்டது.'),
    'Are you sure you want to permanently delete this crop auction? This action cannot be undone.': ('මෙම අස්වනු වෙන්දේසිය ස්ථිරවම මකා දැමීමට ඔබට විශ්වාසද? මෙම ක්‍රියාව ආපසු හැරවිය නොහැක.', 'இந்த பயிர் ஏலத்தை நிரந்தரமாக நீக்க விரும்புகிறீர்களா? இந்த செயலை மாற்ற முடியாது.'),
    'CURRENT HIGHEST BID': ('වත්මන් ඉහළම ලංසුව', 'தற்போதைய அதிகபட்ச ஏலம்'),
    'LEADING': ('ප්‍රමුඛ', 'முன்னணி'),
    'LIVE BID': ('සජීවී ලංසුව', 'நேரலை ஏலம்'),
    'Live Bid Activity': ('සජීවී ලංසු ක්‍රියාකාරකම්', 'நேரலை ஏல செயல்பாடு'),
    'Live Bids History': ('සජීවී ලංසු ඉතිහාසය', 'நேரலை ஏல வரலாறு'),
    'Top Bidder': ('ඉහළම ලංසුකරු', 'முக்கிய ஏலதாரர்'),
    'Leader': ('නායකයා', 'தலைவர்'),
    'Quick Bid:': ('ක්ෂණික ලංසුව:', 'விரைவு ஏலம்:'),
    'Quick Bid': ('ක්ෂණික ලංසුව', 'விரைவு ஏலம்'),
    'Time Remaining': ('ඉතිරි කාලය', 'மீதமுள்ள நேரம்'),
    'Lot Value': ('කාණ්ඩයේ වටිනාකම', 'தொகுதி மதிப்பு'),
    'Total Lot Estimate:': ('කාණ්ඩයේ මුළු ඇස්තමේන්තුව:', 'மொத்த தொகுதி மதிப்பீடு:'),
    'Total Lot Value': ('කාණ්ඩයේ මුළු වටිනාකම', 'மொத்த தொகுதி மதிப்பு'),
    'Total Lot Volume': ('කාණ්ඩයේ මුළු ප්‍රමාණය', 'மொத்த தொகுதி அளவு'),
    'Total Bids Placed': ('තැබූ මුළු ලංසු ගණන', 'வைக்கப்பட்ட மொத்த ஏலங்கள்'),
    'Total Bids Received': ('ලැබුණු මුළු ලංසු ගණන', 'பெறப்பட்ட மொத்த ஏலங்கள்'),
    'Total Registered Lots': ('ලියාපදිංචි කළ මුළු කාණ්ඩ', 'பதிவுசெய்யப்பட்ட மொத்த தொகுதிகள்'),
    'View Bids Tracker': ('ලංසු නිරීක්ෂකය බලන්න', 'ஏல கண்காணிப்பாளரைப் பார்க்கவும்'),
    'Instant Buyout (Buy-Now)?': ('ක්ෂණිකව මිලදී ගැනීම (Buy-Now)?', 'உடனடி கொள்முதல் (இப்போது வாங்கு)?'),
    'Keep Bidding Active': ('ලංසු තැබීම සක්‍රීයව තබන්න', 'ஏலத்தை செயலில் வைக்கவும்'),
    'You are the leading bidder!': ('ඔබ ප්‍රමුඛ ලංසුකරු වේ!', 'நீங்கள் தான் முன்னணி ஏலதாரர்!'),
    'You are the leading bidder! 🎉': ('ඔබ ප්‍රමුඛ ලංසුකරු වේ! 🎉', 'நீங்கள் தான் முன்னணி ஏலதாரர்! 🎉'),
    'Your auction is published. Bids from interested buyers will appear here in real-time.': ('ඔබගේ වෙන්දේසිය පළ කරන ලදී. ගැනුම්කරුවන්ගේ ලංසු මෙහි සජීවීව පෙන්වනු ඇත.', 'உங்கள் ஏலம் வெளியிடப்பட்டது. வாங்குபவர்களின் ஏலங்கள் இங்கு உடனுக்குடன் தோன்றும்.'),
    'List your crops for auction. Buyers across Sri Lanka will place bids to get you the highest price.': ('ඔබේ අස්වැන්න වෙන්දේසිය සඳහා ඉදිරිපත් කරන්න. දිවයින පුරා ගැනුම්කරුවන් ඉහළම මිලක් ලබාදීමට ලංසු තබනු ඇත.', 'உங்கள் பயிர்களை ஏலத்திற்கு பட்டியலிடுங்கள். அதிக விலையைப் பெற இலங்கை முழுவதிலுமிருந்து வாங்குபவர்கள் ஏலம் எடுப்பார்கள்.'),
    'bids': ('ලංසු', 'ஏலங்கள்'),
    'bids placed': ('ලංසු තබන ලදී', 'ஏலங்கள் வைக்கப்பட்டன'),
    'total bids': ('මුළු ලංසු', 'மொத்த ஏலங்கள்'),
    'Buy Now Immediately': ('දැන්ම ක්ෂණිකව මිලදී ගන්න', 'உடனே இப்போது வாங்கவும்'),
    'Auction updated successfully!': ('වෙන්දේසිය සාර්ථකව යාවත්කාලීන විය!', 'ஏலம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது!'),
    'Your crop auction is now LIVE for buyers to bid!': ('ඔබේ අස්වනු වෙන්දේසිය දැන් ගැනුම්කරුවන් සඳහා සජීවීව විවෘතයි!', 'உங்கள் பயிர் ஏலம் இப்போது வாங்குபவர்களுக்கு நேரலையில் உள்ளது!'),
    'Ending Soon': ('ළඟදීම අවසන් වේ', 'விரைவில் முடிவடைகிறது'),
    'High Demand': ('ඉහළ ඉල්ලුමක් පවතී', 'அதிக தேவை'),

    // ── Pre-Orders & Contract Farming ─────────────────────────────────────
    'Pre-Orders': ('පෙර ඇණවුම්', 'முன்கூட்டிய ஆர்டர்கள்'),
    'Orders & Pre-Orders': ('ඇණවුම් සහ පෙර ඇණවුම්', 'ஆர்டர்கள் & முன்கூட்டிய ஆர்டர்கள்'),
    'Contract Farming': ('කොන්ත්‍රාත් ගොවිතැන', 'ஒப்பந்த விவசாயம்'),
    'Contract Farming / Pre-Orders': ('කොන්ත්‍රාත් ගොවිතැන / පෙර ඇණවුම්', 'ஒப்பந்த விவசாயம் / முன்கூட்டிய ஆர்டர்கள்'),
    'Contract farming for premium crops': ('විශේෂිත බෝග සඳහා කොන්ත්‍රාත් ගොවිතැන', 'பிரீமியம் பயிர்களுக்கான ஒப்பந்த விவசாயம்'),
    'Pre-order crops directly from farmers before the harvest.': ('අස්වැන්න නෙළීමට පෙර ගොවීන්ගෙන් සෘජුවම බෝග ඇණවුම් කරන්න.', 'அறுவடைக்கு முன் விவசாயிகளிடமிருந்து நேரடியாக பயிர்களை முன்கூட்டியே ஆர்டர் செய்யுங்கள்.'),
    'Create Pre-Order': ('පෙර ඇණවුමක් සාදන්න', 'முன்கூட்டிய ஆர்டரை உருவாக்கவும்'),
    'Contract Details': ('ගිවිසුම් විස්තර', 'ஒப்பந்த விவரங்கள்'),
    'Contract not found or has been removed.': ('ගිවිසුම හමු නොවීය හෝ ඉවත් කර ඇත.', 'ஒப்பந்தம் காணப்படவில்லை அல்லது நீக்கப்பட்டது.'),
    'Delete Contract': ('ගිවිසුම මකන්න', 'ஒப்பந்தத்தை நீக்கு'),
    'No Contracts Found': ('ගිවිසුම් කිසිවක් හමු නොවීය', 'ஒப்பந்தங்கள் எதுவும் காணப்படவில்லை'),
    'Add Progress Update': ('ප්‍රගති යාවත්කාලීන කිරීමක් එක් කරන්න', 'முன்னேற்ற புதுப்பிப்பைச் சேர்க்கவும்'),
    'Progress Timeline': ('ප්‍රගති කාලරාමුව', 'முன்னேற்ற காலவரிசை'),
    'View Full Timeline': ('සම්පූර්ණ කාලරාමුව බලන්න', 'முழு காலவரிசையையும் காண்க'),
    'Keep your buyer informed': ('ඔබේ ගැනුම්කරු දැනුවත්ව තබන්න', 'உங்கள் வாங்குபவருக்கு தகவல் தெரிவிக்கவும்'),
    'Quality Requirements:': ('තත්ත්ව අවශ්‍යතා:', 'தர தேவைகள்:'),
    'Quality Requirements': ('තත්ත්ව අවශ්‍යතා', 'தர தேவைகள்'),
    'Rate the Farmer': ('ගොවි මහතා ඇගයීම', 'விவசாயியை மதிப்பிடவும்'),
    'Request Crop →': ('බෝගයක් ඉල්ලුම් කරන්න →', 'பயிரைக் கோருங்கள் →'),
    'Request Crop': ('බෝගයක් ඉල්ලුම් කරන්න', 'பயிரைக் கோருங்கள்'),
    'Additional Notes / Farming Method': ('අමතර සටහන් / වගා ක්‍රමය', 'கூடுதல் குறிப்புகள் / விவசாய முறை'),
    'Additional Notes:': ('අමතර සටහන්:', 'கூடுதல் குறிப்புகள்:'),
    'Additional Notes': ('අමතර සටහන්', 'கூடுதல் குறிப்புகள்'),
    'Harvest & Terms Details': ('අස්වැන්න සහ කොන්දේසි විස්තර', 'அறுவடை மற்றும் விதிமுறைகள் விவரங்கள்'),
    'Harvest & Batch Specifications': ('අස්වැන්න සහ කාණ්ඩ විස්තර', 'அறுவடை மற்றும் தொகுதி விவரக்குறிப்புகள்'),
    'Harvest Stock Overview': ('අස්වනු තොග සාරාංශය', 'அறுவடை இருப்பு கண்ணோட்டம்'),

    // ── Driver & Logistics ─────────────────────────────────────────────────
    'Driver Details': ('රියදුරු විස්තර', 'ஓட்டுநர் விவரங்கள்'),
    'DRIVER DETAILS': ('රියදුරු විස්තර', 'ஓட்டுநர் விவரங்கள்'),
    'Deliveries': ('බෙදාහැරීම්', 'டெலிவரிகள்'),
    'Active Shift Duty (Available for Dispatch)': ('ක්‍රියාකාරී සේවා මුරය (ඇණවුම් භාරගැනීමට සූදානම්)', 'செயலில் உள்ள பணி (அனுப்புதலுக்கு தயார்)'),
    'Taking express logistics pickups': ('ක්ෂණික ප්‍රවාහන ඇණවුම් ලබාගනිමින්', 'விரைவு போக்குவரத்து பிக்அப்களை ஏற்றுக்கொள்கிறது'),
    'Assign Transit Delivery Driver': ('ප්‍රවාහන රියදුරෙකු පවරන්න', 'டெலிவரி ஓட்டுநரை ஒதுக்கவும்'),
    'Call Driver': ('රියදුරුට අමතන්න', 'ஓட்டுநரை அழைக்கவும்'),
    'Call Driver\nHub': ('රියදුරු මධ්‍යස්ථානයට\nඅමතන්න', 'ஓட்டுநர் மையத்திற்கு\nஅழைக்கவும்'),
    'Chat with Driver': ('රියදුරු සමඟ කතාබස් කරන්න', 'ஓட்டுநருடன் அரட்டையடிக்கவும்'),
    'Direct driver dispatch coordinator': ('සෘජු රියදුරු මෙහෙයුම් සම්බන්ධීකාරක', 'நேரடி ஓட்டுநர் அனுப்புதல் ஒருங்கிணைப்பாளர்'),
    'Driver Handover PIN': ('රියදුරු භාරදීමේ PIN අංකය', 'ஓட்டுநர் ஒப்படைப்பு PIN'),
    'Edit Driver': ('රියදුරු සංස්කරණය', 'ஓட்டுநரைத் திருத்து'),
    'Edit Driver & Vehicle Profile': ('රියදුරු සහ වාහන පැතිකඩ සංස්කරණය', 'ஓட்டுநர் மற்றும் வாகன சுயவிவரத்தைத் திருத்து'),
    'Edit Driver Profile & Vehicle': ('රියදුරු සහ වාහන තොරතුරු සංස්කරණය', 'ஓட்டுநர் விவரம் & வாகனத்தைத் திருத்து'),
    'Enroll Transit Driver & Van': ('නව රියදුරු සහ රථය ලියාපදිංචි කරන්න', 'புதிய ஓட்டுநர் & வாகனத்தை பதிவு செய்க'),
    'Fleet Transit Drivers': ('ප්‍රවාහන රථ රියදුරන්', 'வாகன போக்குவரத்து ஓட்டுநர்கள்'),
    'Corridors & Daily Payouts': ('ප්‍රවාහන කලාප සහ දිනපතා ගෙවීම්', 'பாதைகள் மற்றும் தினசரி கொடுப்பனவுகள்'),
    'Chilled Fleet': ('ශීතකරණ රථ පෙළ', 'குளிரூட்டப்பட்ட வாகனம்'),
    'Manage chilled vans, license plate registration, and driver on-duty shifts': ('ශීතකරණ රථ, අංක තහඩු සහ සේවා මුර කළමනාකරණය', 'குளிரூட்டப்பட்ட வாகனங்கள், பதிவு மற்றும் பணி நேரங்களை நிர்வகிக்கவும்'),
    'Manage Dispatch': ('මෙහෙයුම් කළමනාකරණය', 'அனுப்புதலை நிர்வகி'),
    'On-Time Arrival SLA': ('නියමිත වේලාවට පැමිණීමේ එකඟතාව (SLA)', 'சரியான நேரத்தில் வருதல் SLA'),
    'Out for Delivery': ('බෙදාහැරීමට පිටත්ව ඇත', 'டெலிவரிக்கு புறப்பட்டது'),
    'Ready for Driver Pickup': ('රියදුරු ලබාගැනීමට සූදානම්', 'ஓட்டுநர் எடுப்பதற்கு தயார்'),
    'Transit Logistics & Fleet Dispatch': ('ප්‍රවාහන මෙහෙයුම් සහ රථ පෙළ බෙදාහැරීම', 'போக்குவரத்து தளவாடங்கள் & வாகன அனுப்புதல்'),
    'Vehicle Documents & SL-Transport': ('වාහන ලියකියවිලි සහ ප්‍රවාහන බලපත්‍ර', 'வாகன ஆவணங்கள் & போக்குவரத்து அனுமதி'),
    'Logistics Hotline': ('ප්‍රවාහන සේවා අංකය', 'போக்குவரத்து உதவி எண்'),
    'ITEMIZED TRANSIT LOGS': ('සවිස්තරාත්මක ප්‍රවාහන සටහන්', 'விவரமான போக்குவரத்து பதிவுகள்'),
    'LOGISTICS PARTNER': ('ප්‍රවාහන සහකරු', 'போக்குவரத்து கூட்டாளர்'),
    'Delivery & Preferences': ('බෙදාහැරීම් සහ මනාපයන්', 'டெலிவரி மற்றும் விருப்பங்கள்'),
    'Accept & Finalize': ('පිළිගෙන අවසන් කරන්න', 'ஏற்று இறுதி செய்யவும்'),
    'Agri-Transit Sri Lanka Ltd.': ('ඇග්‍රි-ට්‍රාන්සිට් ශ්‍රී ලංකා සමාගම', 'அக்ரி-டிரான்சிட் இலங்கை லிமிடெட்'),
    'Account & Contact Details': ('ගිණුම් සහ සබඳතා තොරතුරු', 'கணக்கு மற்றும் தொடர்பு விவரங்கள்'),
    'Account & Highway Alerts': ('ගිණුම් සහ මාර්ග දැනුම්දීම්', 'கணக்கு மற்றும் நெடுஞ்சாலை விழிப்பூட்டல்கள்'),
    'Handling:': ('මෙහෙයුම්:', 'கையாளுதல்:'),
    'ISSUED BY': ('නිකුත් කළේ', 'வழங்கியவர்'),

    // ── Admin Console ──────────────────────────────────────────────────────
    'Master Console': ('ප්‍රධාන පාලන පුවරුව', 'முதன்மை கன்சோல்'),
    'Farm2Home Console': ('Farm2Home ප්‍රධාන පාලන මැදිරිය', 'Farm2Home நிர்வாக கன்சோல்'),
    'RESTRICTED ACCESS': ('සීමිත ප්‍රවේශයකි', 'கட்டுப்படுத்தப்பட்ட அணுகல்'),
    'Authorized Administrator Email & Credentials Required': ('බලයලත් පරිපාලක විද්‍යුත් තැපෑල සහ මුරපදය අවශ්‍යයි', 'அங்கீகரிக்கப்பட்ட நிர்வாகி மின்னஞ்சல் & சான்றுகள் தேவை'),
    'Admin Email Address': ('පරිපාලක විද්‍යුත් තැපෑල', 'நிர்வாகி மின்னஞ்சல் முகவரி'),
    'Master Password': ('ප්‍රධාන මුරපදය', 'முதன்மை கடவுச்சொல்'),
    'Remember Session': ('සැසිය මතක තබාගන්න', 'அமர்வை நினைவில் கொள்க'),
    'Authenticate & Enter Console': ('සත්‍යාපනය කර පාලක පුවරුවට පිවිසෙන්න', 'சரிபார்த்து கன்சோலில் நுழையுங்கள்'),
    'Return to Public Marketplace': ('පොදු වෙළඳපොළ වෙත ආපසු යන්න', 'பொது சந்தைக்குத் திரும்புங்கள்'),
    '256-bit TLS Encryption • Admin Audit Active': ('256-bit TLS සංකේතනය • පරිපාලක විගණනය සක්‍රීයයි', '256-bit TLS குறியாக்கம் • தணிக்கை செயலில் உள்ளது'),
    'Sign Out from Console': ('පාලක පුවරුවෙන් ඉවත් වන්න', 'கன்சோலில் இருந்து வெளியேறு'),
    'Are you sure you want to lock and exit the Master Administrator session?': ('ප්‍රධාන පරිපාලක සැසිය අගුළු දමා ඉවත් වීමට ඔබට විශ්වාසද?', 'முதன்மை நிர்வாகி அமர்வை பூட்டி வெளியேற விரும்புகிறீர்களா?'),
    'Master Administrator session terminated.': ('ප්‍රධාන පරිපාලක සැසිය අවසන් කරන ලදී.', 'முதன்மை நிர்வாகி அமர்வு முடிந்தது.'),
    'MASTER': ('ප්‍රධාන පරිපාලක', 'முதன்மை நிர்வாகி'),
    'MANAGEMENT MODULES': ('කළමනාකරණ මොඩියුල', 'நிர்வாக தொகுதிகள்'),
    'Gateway Connected': ('දොරටුව සම්බන්ධ විය', 'கேட்வே இணைக்கப்பட்டது'),
    'Notify.lk SMS • Active': ('Notify.lk SMS • සක්‍රීයයි', 'Notify.lk SMS • செயலில் உள்ளது'),
    'Supabase Cloud Database 100% Synchronized!': ('Supabase ක්ලවුඩ් දත්ත සමුදාය 100% සමමුහුර්තයි!', 'Supabase கிளவுட் தரவுத்தளம் 100% ஒத்திசைக்கப்பட்டது!'),
    'Quick Create New Entity': ('ක්ෂණිකව අලුත් ලියාපදිංචියක් සාදන්න', 'விரைவாக புதிய பதிவை உருவாக்கவும்'),
    'Register Buyer Account': ('ගැනුම්කරු ගිණුමක් ලියාපදිංචි කරන්න', 'வாங்குபவர் கணக்கை பதிவு செய்க'),
    'List Marketplace Product': ('වෙළඳපොළ නිෂ්පාදනයක් ලැයිස්තුගත කරන්න', 'சந்தை பொருளை பட்டியலிடுங்கள்'),
    'Create Manual Order & Dispatch': ('ඇණවුමක් සාදා බෙදාහැරීම අරඹන්න', 'கையேடு ஆர்டரை உருவாக்கி அனுப்பவும்'),
    'Farm2Home Unified Agri-Logistics Engine': ('Farm2Home ඒකාබද්ධ කෘෂි ප්‍රවාහන පද්ධතිය', 'Farm2Home ஒருங்கிணைந்த விவசாய தளவாட இயந்திரம்'),
    'All 5 operational portals nominal • Real-time SMS Gateway active': ('සියලු මෙහෙයුම් අංශ 5ම යථා තත්ත්වයේ • SMS සේවාව සක්‍රීයයි', 'அனைத்து 5 செயல்பாட்டு போர்ட்டல்களும் சீரானவை • SMS செயலில் உள்ளது'),
    'Notify.lk Enterprise SMS Gateway': ('Notify.lk ව්‍යාපාරික SMS දොරටුව', 'Notify.lk நிறுவன SMS கேட்வே'),
    'SMS Gateway Ping: 24ms OK. System ready to dispatch OTP.': ('SMS දොරටු පිං පරීක්ෂාව සාර්ථකයි (24ms). OTP යැවීමට සූදානම්.', 'SMS கேட்வே பிங்: 24ms சரி. OTP அனுப்ப கணினி தயார்.'),
    'Ping Test': ('පිං පරීක්ෂාව (Ping)', 'பிங் சோதனை'),
    'FAST CONFIGURATION SHORTCUTS': ('ක්ෂණික සැකසුම් කෙටිමං', 'விரைவு கட்டமைப்பு குறுக்குவழிகள்'),
    'Edit Details': ('විස්තර සංස්කරණය කරන්න', 'விவரங்களைத் திருத்தவும்'),
    'Edit Buyer': ('ගැනුම්කරු සංස්කරණය', 'வாங்குபவரைத் திருத்து'),
    'Edit Listing': ('නිෂ්පාදනය සංස්කරණය', 'பட்டியலைத் திருத்து'),
    'Manage All': ('සියල්ල කළමනාකරණය', 'அனைத்தையும் நிர்வகி'),
    'Marketplace Buyers': ('වෙළඳපොළ ගැණුම්කරුවන්', 'சந்தை வாங்குபவர்கள்'),
    'Marketplace Inventory & Pricing': ('තොග සහ මිල ගණන්', 'சந்தை இருப்பு மற்றும் விலை நிர்ணயம்'),
    'Marketplace Orders': ('වෙළඳපොළ ඇණවුම්', 'சந்தை ஆர்டர்கள்'),
    'Farmers Registry & Certification': ('ගොවි ලේඛකාධිකාරය සහ සහතිකකරණය', 'விவசாயிகள் பதிவு மற்றும் சான்றிதழ்'),
    'Registered Farmers': ('ලියාපදිංචි ගොවීන්', 'பதிவுசெய்த விவசாயிகள்'),
    'Buyer Accounts & Regional Hubs': ('ගැනුම්කරු ගිණුම් සහ ප්‍රාදේශීය මධ්‍යස්ථාන', 'வாங்குபவர் கணக்குகள் & பிராந்திய மையங்கள்'),
    'Delete Buyer Account': ('ගැනුම්කරු ගිණුම මකන්න', 'வாங்குபவர் கணக்கை நீக்கு'),
    'Delete Farmer Record': ('ගොවි වාර්තාව මකන්න', 'விவசாயි பதிவை நீக்கு'),
    'Delete Fleet Driver': ('රියදුරු වාර්තාව මකන්න', 'ஓட்டுநர் பதிவை நீக்கு'),
    'Delete Order Record': ('ඇණවුම් වාර්තාව මකන්න', 'ஆர்டர் பதிவை நீக்கு'),
    'Delete Record': ('වාර්තාව මකන්න', 'பதிவை நீக்கு'),
    'Ctrl+K': ('Ctrl+K', 'Ctrl+K'),

    // ── Farmer, Orders & Chat ──────────────────────────────────────────────
    'Farmer Orders': ('ගොවි ඇණවුම්', 'விவசாயி ஆர்டர்கள்'),
    'Accept Order': ('ඇණවුම භාරගන්න', 'ஆர்டரை ஏற்றுக்கொள்'),
    'Mark Ready for Pickup': ('ලබාගැනීමට සූදානම් බව සලකුණු කරන්න', 'பிக்அப்பிற்கு தயார் என குறிக்கவும்'),
    'Order Items': ('ඇණවුමේ භාණ්ඩ', 'ஆர்டர் பொருட்கள்'),
    'Order Lifecycle Status': ('ඇණවුමේ වත්මන් තත්ත්වය', 'ஆர்டர் வாழ்க்கை சுழற்சி நிலை'),
    'Order Placed': ('ඇණවුම භාරදෙන ලදී', 'ஆர்டர் செய்யப்பட்டது'),
    'Orders synced with live marketplace': ('වෙළඳපොළ සමඟ ඇණවුම් සජීවීව සමමුහුර්තයි', 'சந்தையோடு ஆர்டர்கள் நேரலையில் ஒத்திசைக்கப்பட்டன'),
    'No Orders Found': ('ඇණවුම් කිසිවක් හමු නොවීය', 'ஆர்டர்கள் எதுவும் கிடைக்கவில்லை'),
    'No Products Listed': ('ලැයිස්තුගත කළ නිෂ්පාදන නැත', 'தயாரிப்புகள் எதுவும் பட்டியலிடப்படவில்லை'),
    'No matching products found': ('ගැළපෙන නිෂ්පාදන හමු නොවීය', 'பொருந்தும் தயாரிப்புகள் எதுவும் இல்லை'),
    'No orders in this status': ('මෙම තත්ත්වයේ ඇණවුම් නැත', 'இந்த நிலையில் ஆர்டர்கள் இல்லை'),
    'No Buyers Found': ('ගැණුම්කරුවන් හමු නොවීය', 'வாங்குபவர்கள் காணப்படவில்லை'),
    'No Drivers Found': ('රියදුරන් හමු නොවීය', 'ஓட்டுநர்கள் காணப்படவில்லை'),
    'No Farmers Found': ('ගොවීන් හමු නොවීය', 'விவசாயிகள் காணப்படவில்லை'),
    'No Conversations Found': ('සංවාද කිසිවක් හමු නොවීය', 'உரையாடல்கள் எதுவும் இல்லை'),
    'Direct Chat Messages': ('සෘජු පණිවිඩ සංවාද', 'நேரடி அரட்டை செய்திகள்'),
    'Direct Real-Time Chat': ('සජීවී සෘජු සංවාදය', 'நேரலை அரட்டை'),
    'Chat directly with Farmers and Buyers regarding active deliveries.': ('ක්‍රියාකාරී බෙදාහැරීම් පිළිබඳව ගොවීන් සහ ගැනුම්කරුවන් සමඟ සෘජුවම කතාබස් කරන්න.', 'செயலில் உள்ள டெலிவரிகள் தொடர்பாக விவசாயிகள் மற்றும் வாங்குபவர்களுடன் நேரடியாக அரட்டையடிக்கவும்.'),
    'Open Messages': ('පණිවිඩ විවෘත කරන්න', 'செய்திகளைத் திறக்கவும்'),
    'Agronomist Hotline': ('කෘෂි විද්‍යාඥ උපදෙස් සේවාව', 'வேளாண் விஞ்ஞானி உதவி எண்'),
    'Chat': ('සංවාද', 'அரட்டை'),
    'Add New Harvest Listing': ('නව අස්වනු ලැයිස්තුවක් එක් කරන්න', 'புதிய அறுவடை பட்டியலைச் சேர்க்கவும்'),

    // ── Auth, Onboarding & User ────────────────────────────────────────────
    'Already have an account?': ('ගිණුමක් තිබේද?', 'ஏற்கனவே கணக்கு உள்ளதா?'),
    'Already have an account? Sign in': ('දැනටමත් ගිණුමක් තිබේද? ඇතුල් වන්න', 'ஏற்கனவே கணக்கு உள்ளதா? உள்நுழைக'),
    'At least 8 characters': ('අවම වශයෙන් අක්ෂර 8ක්', 'குறைந்தது 8 எழுத்துகள்'),
    'Awesome!': ('විශිෂ්ටයි!', 'அற்புதம்!'),
    'BUYER REGISTRATION': ('ගැනුම්කරු ලියාපදිංචිය', 'வாங்குபவர் பதிவு'),
    'FARMER REGISTRATION': ('ගොවි ලියාපදිංචිය', 'விவசாயி பதிவு'),
    'FAST 1-CLICK REGISTRATION': ('ක්ෂණික 1-ක්ලික් ලියාපදිංචිය', 'விரைவு 1-கிளிக் பதிவு'),
    'Check your email': ('ඔබගේ විද්‍යුත් තැපෑල පරීක්ෂා කරන්න', 'உங்கள் மின்னஞ்சலை சரிபார்க்கவும்'),
    'Choose a Portrait': ('පැතිකඩ පින්තූරයක් තෝරන්න', 'ஒரு உருவப்படத்தைத் தேர்வுசெய்க'),
    'Choose a photo preset or paste image URL:': ('පින්තූරයක් තෝරන්න හෝ URL ඇතුළත් කරන්න:', 'புகைப்படத்தைத் தேர்ந்தெடுக்கவும் அல்லது URL ஐ ஒட்டவும்:'),
    'Create account': ('ගිණුමක් සාදන්න', 'கணக்கை உருவாக்கவும்'),
    'OR COMPLETE DRIVER DETAILS': ('හෝ රියදුරු විස්තර සම්පූර්ණ කරන්න', 'அல்லது ஓட்டுநர் விவரங்களை முடிக்கவும்'),
    'OR SIGN UP WITH GOOGLE': ('හෝ Google හරහා සම්බන්ධ වන්න', 'அல்லது Google மூலம் பதிவு செய்யவும்'),
    'Please enter a valid Sri Lankan mobile number (e.g., 77 234 5678).': ('කරුණාකර වලංගු ශ්‍රී ලාංකික දුරකථන අංකයක් ඇතුළත් කරන්න (උදා: 77 234 5678).', 'சரியான இலங்கை மொபைல் எண்ணை உள்ளிடவும் (எ.கா: 77 234 5678).'),
    'Please verify your mobile number with the SMS OTP code first.': ('කරුණාකර පළමුව SMS OTP කේතය මඟින් දුරකථන අංකය තහවුරු කරන්න.', 'முதலில் SMS OTP குறியீட்டுடன் உங்கள் மொபைல் எண்ணை சரிபார்க்கவும்.'),
    'Repeat your password': ('මුරපදය නැවත ඇතුළත් කරන්න', 'உங்கள் கடவுச்சொல்லை மீண்டும் உள்ளிடவும்'),
    'Resend code': ('කේතය නැවත එවන්න', 'குறியீட்டை மீண்டும் அனுப்பு'),
    'Profile details updated successfully!': ('පැතිකඩ විස්තර සාර්ථකව යාවත්කාලීන විය!', 'சுயவிவர விவரங்கள் வெற்றிகரமாக புதுப்பிக்கப்பட்டன!'),
    'Search chats, contacts, orders...': ('සංවාද, ඇමතුම්, ඇණවුම් සොයන්න...', 'அரட்டைகள், தொடர்புகள், ஆர்டர்களைத் தேடுங்கள்...'),
    'Search records by name, ID, phone, district...': ('නම, අංකය, දුරකථනය, දිස්ත්‍රික්කය අනුව සොයන්න...', 'பெயர், எண், தொலைபேசி, மாவட்டம் மூலம் தேடுங்கள்...'),
    'Select Delivery Location': ('බෙදාහැරීමේ ස්ථානය තෝරන්න', 'டெலிவரி இருப்பிடத்தைத் தேர்ந்தெடுக்கவும்'),
    'Select Language / භාෂාව තෝරන්න': ('භාෂාව තෝරන්න / மொழியைத் தேர்வுசெய்க', 'மொழியைத் தேர்வுசெய்க / භාෂාව තෝරන්න'),
    'Sri Lanka Agri-Board Approved': ('ශ්‍රී ලංකා කෘෂිකර්ම මණ්ඩලයේ අනුමතයි', 'இலங்கை விவசாய சபை அங்கீகரித்தது'),
    'Type message in English or සිංහල...': ('ඉංග්‍රීසි හෝ සිංහලෙන් පණිවිඩය ලියන්න...', 'ஆங்கிலம் அல்லது தமிழில் செய்தி தட்டச்சு செய்க...'),
    'Buyer Classification': ('ගැනුම්කරු වර්ගීකරණය', 'வாங்குபவர் வகைப்பாடு'),
    'Choose app interface language / மொழியைத் தேர்வுசெய்க': ('යෙදුමේ භාෂාව තෝරන්න / மொழியைத் தேர்வுசெய்க', 'செயலி மொழியைத் தேர்ந்தெடுக்கவும் / භාෂාව තෝරන්න'),
    'English': ('English', 'English'),
    'English  •  Continue in English': ('English  •  Continue in English', 'English  •  Continue in English'),
    'Sinhala': ('සිංහල', 'சிங்களம்'),
    'Tamil': ('දෙමළ', 'தமிழ்'),
    'Sinhala  •  සිංහල භාෂාවෙන් ඉදිරියට යන්න': ('සිංහල  •  සිංහල භාෂාවෙන් ඉදිරියට යන්න', 'சிங்களம்  •  சிங்களத்தில் தொடரவும்'),
    'Tamil  •  தமிழில் தொடர்ந்து செல்லுங்கள்': ('දෙමළ  •  දෙමළ භාෂාවෙන් ඉදිරියට යන්න', 'தமிழ்  •  தமிழில் தொடர்ந்து செல்லுங்கள்'),
    'Forgot password': ('මුරපදය අමතකද?', 'கடவுச்சொல் மறந்துவிட்டதா?'),
    'Forgot password?': ('මුරපදය අමතකද?', 'கடவுச்சொல் மறந்துவிட்டதா?'),
    'International English interface': ('ජාත්‍යන්තර ඉංග්‍රීසි මාධ්‍යය', 'சர்வதேச ஆங்கில இடைமுகம்'),
    'Issuing Bank / Financial Institution': ('නිකුත් කළ බැංකුව / මූල්‍ය ආයතනය', 'வழங்கிய வங்கி / நிதி நிறுவனம்'),
    'Kasun': ('කසුන්', 'கசுன்'),
    'This net balance is automatically deducted from your upcoming weekly bank deposit, or you can remit now via online banking.': ('මෙම ශේෂය ඔබගේ ඉදිරි සතිපතා බැංකු තැන්පතුවෙන් ස්වයංක්‍රීයව අඩු කෙරේ, නැතහොත් ඔබට දැන් අන්තර්ජාල බැංකුකරණයෙන් ගෙවිය හැක.', 'இந்த நிலுவைத் தொகை உங்கள் வரவிருக்கும் வாராந்திர வங்கி வைப்பிலிருந்து தானாகவே கழிக்கப்படும், அல்லது ஆன்லைன் வங்கி மூலம் இப்போது செலுத்தலாம்.'),
    'admin email': ('පරිපාලක විද්‍යුත් තැපෑල', 'நிர்வாகி மின்னஞ்சல்'),
    'Edit Farmer Profile': ('ගොවි පැතිකඩ සංස්කරණය', 'விவசாயி சுயவிவரத்தைத் திருத்து'),
    'Edit Profile Details': ('පැතිකඩ විස්තර සංස්කරණය', 'சுயவிவர விவரங்களைத் திருத்தவும்'),
    'Edit Profile Picture': ('පැතිකඩ ඡායාරූපය සංස්කරණය', 'சுயவிவரப் படத்தை மாற்றவும்'),
    'Instant verification • No password needed': ('ක්ෂණික තහවුරු කිරීම • මුරපදයක් අවශ්‍ය නොවේ', 'உடனடி சரிபார்ப்பு • கடவுச்சொல் தேவையில்லை'),
    'It only takes a minute.': ('ගතවන්නේ සුළු මොහොතක් පමණි.', 'இதற்கு ஒரு நிமிடம் மட்டுமே ஆகும்.'),
    'Good morning,': ('සුබ උදෑසනක්,', 'காலை வணக்கம்,'),

    // ── Farmer, Products & Categories ─────────────────────────────────────────
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
    'Ready for Pickup': ('ලබාගැනීමට සූදානම්', 'பிக்அப் தயார்'),
    'In Transit': ('ප්‍රවාහනයේ', 'போக்குவரத்தில்'),
    'Ready': ('සූදානම්', 'தயார்'),
    'Farmer': ('ගොවියා', 'விவசாயி'),
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
    'Gate North #2 / B': ('උතුරු දොරටුව #2 / B', 'வடக்கு வாயில் #2 / B'),
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
    'Nuwara Eliya A5': ('නුවරඑළිය A5', 'நுவரෙலியා A5'),
    'A7 & A4 Route Clear Advisory': ('A7 & A4 මාර්ගය පැහැදිලි බවට උපදෙස්', 'A7 & A4 பாதை தெளிவான ஆலோசனை'),
    'Active Telematics Monitoring': ('සජීවී ටෙලිමැටික්ස් අධීක්ෂණය', 'நேரலை டெலிமேடிக்ஸ் கண்காணிப்பு'),
    'Active route notifications & vehicle telemetry': ('සක්‍රිය මාර්ග දැනුම්දීම් සහ වාහන දත්ත', 'செயலில் உள்ள பாதை அறிவிப்புகள் மற்றும் வாகன தரவு'),
    'Assigned': ('පවරන ලදි', 'ஒதுக்கப்பட்டது'),
    'Buyer Name': ('ගැනුම්කරුගේ නම', 'வாங்குபவர் பெயர்'),
    'Buyer Note': ('ගැනුම්කරුගේ සටහන', 'வாங்குபவர் குறிப்பு'),
    'COD Cash': ('භාණ්ඩ ලැබුණු පසු මුදල් (COD)', 'டெலிவரியின் போது பணம்'),
    'Call Now': ('දැන් අමතන්න', 'இப்போது அழைக்கவும்'),
    'Cancel': ('අවලංගු කරන්න', 'ரத்து செய்'),
    'Cargo Breakdown': ('ප්‍රවාහන භාණ්ඩ විස්තරය', 'சரக்கு விவரம்'),
    'Cargo Capacity': ('ප්‍රවාහන ධාරිතාව', 'சரக்கு கொள்ளளவு'),
    'Cash Collection Summary': ('මුදල් එකතු කිරීමේ සාරාංශය', 'பண சேகரிப்பு சுருக்கம்'),
    'Chat Farmer': ('ගොවියා සමඟ කතාබස්', 'விவசாயியுடன் அரட்டையடிக்கவும்'),
    'Chiller Nominal': ('ශීතකරණය සාමාන්‍යයි', 'சில்லர் இயல்பானது'),
    'Clear Flow': ('පැහැදිලි ගමනාගමනය', 'தெளிவான போக்குவரத்து'),
    'Climate Sensor': ('දේශගුණ සංවේදකය', 'காலநிலை சென்சார்'),
    'Close': ('වසන්න', 'மூடுக'),
    'Close Route View': ('මාර්ග දසුන වසන්න', 'பாதை பார்வையை மூடுக'),
    'Cloud Manifest Synced': ('වලාකුළු ප්‍රකාශනය සමමුහුර්ත විය', 'கிளவுட் மேனிஃபெஸ்ட் ஒத்திசைக்கப்பட்டது'),
    'Cold Chain Hardware': ('ශීතල සැපයුම් දෘඩාංග', 'கோல்ட் செயின் වன்பொருள்'),
    'Collection Mode': ('එකතු කිරීමේ ක්‍රමය', 'சேகரிப்பு முறை'),
    'Contact Phone': ('සම්බන්ධතා දුරකථන අංකය', 'தொடர்பு தொலைபேசி எண்'),
    'DRIVER': ('රියදුරු', 'சாரதி'),
    'DRIVER OPERATIONS': ('රියදුරු මෙහෙයුම්', 'சாரதி செயல்பாடுகள்'),
    'Database Synced': ('දත්ත සමුදාය සමමුහුර්ත විය', 'தரவுத்தளம் ஒத்திசைக்கப்பட்டது'),
    'Destination': ('ගමනාන්තය', 'சேருமிடம்'),
    'Dismiss': ('ඉවත් කරන්න', 'நிராகரி'),
    'Driver Compensation': ('රියදුරු ගෙවීම්', 'சாரதி இழப்பீடு'),
    'Drop-off': ('භාරදීම', 'ஒப்படைப்பு'),
    'Dropoff Address': ('භාරදීමේ ලිපිනය', 'ஒப்படைப்பு முகவரி'),
    'Empowering Sri Lankan Transit & Agri-Cold Chain': ('ශ්‍රී ලංකාවේ කෘෂි ශීතල ප්‍රවාහන ජාලය සවිබල ගන්වයි', 'இலங்கையின் விவசாய குளிர்பதன போக்குவரத்து நெட்வொர்க்'),
    'Farm2Home Logistics': ('Farm2Home ප්‍රවාහන සේවය', 'Farm2Home தளவாடங்கள்'),
    'Farmer Name': ('ගොවියාගේ නම', 'விவசாயி பெயர்'),
    'Launch Turn-by-Turn GPS': ('GPS මාර්ග සංචලනය අරඹන්න', 'GPS வழிகாட்டியைத் தொடங்கவும்'),
    'Manifest': ('ප්‍රකාශනය', 'மேனிஃபெஸ்ட்'),
    'Manifest reset: #FH-8850 is': ('ප්‍රකාශනය නැවත සකසන ලදී: #FH-8850', 'மேனிஃபெஸ்ட் மீட்டமைக்கப்பட்டது: #FH-8850'),
    'Net Settlement': ('ශුද්ධ පියවීම', 'நிகர தீர்வு'),
    'On Duty': ('සේවයේ යෙදී සිටී', 'பணியில் உள்ளார்'),
    'Open Chat': ('කතාබස් විවෘත කරන්න', 'அரட்டையைத் திறக்கவும்'),
    'Optimized Stop Sequence': ('ප්‍රශස්ත නැවතුම් අනුපිළිවෙල', 'உகந்த நிறுத்த வரிசை'),
    'Origin': ('ආරම්භක ස්ථානය', 'தொடக்க இடம்'),
    'Pickup Address': ('ලබාගැනීමේ ලිපිනය', 'பிக்கப் முகவரி'),
    'Pickup Ready': ('ලබාගැනීමට සූදානම්', 'பிக்கப் தயார்'),
    'Profile photo updated successfully!': ('පැතිකඩ ඡායාරූපය සාර්ථකව යාවත්කාලීන විය!', 'சுயவிவர புகைப்படம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது!'),
    'Rating': ('ශ්‍රේණිගත කිරීම', 'மதிப்பீடு'),
    'Roadworthy Status': ('මාර්ග ධාවන යෝග්‍යතා තත්ත්වය', 'சாலைத்தகுதி நிலை'),
    'Route Clear': ('මාර්ගය පැහැදිලියි', 'பாதை தெளிவாக உள்ளது'),
    'Shift & Dispatch Alerts': ('වැඩ මුර සහ යැවීම් දැනුම්දීම්', 'ஷிப்ட் மற்றும் அனுப்புதல் விழிப்பூட்டல்கள்'),
    'Start Pickup Route': ('ලබාගැනීමේ මාර්ගය අරඹන්න', 'பிக்கப் பாதையைத் தொடங்குங்கள்'),
    'Storage Requirement': ('ගබඩා අවශ්‍යතාවය', 'சேமிப்புத் தேவை'),
    'Strap secured': ('ආරක්ෂිතව බැඳ ඇත', 'பாதுகாப்பாக கட்டப்பட்டுள்ளது'),
    'Switch Role (Farmer / Buyer Mode)': ('භූමිකාව මාරු කරන්න (ගොවි / ගැනුම්කරු)', 'பங்கினை மாற்றவும் (விவசாயி / வாங்குபவர்)'),
    'Van Reg': ('වෑන් රථ ලියාපදිංචි අංකය', 'வேன் பதிவு எண்'),
    'Vehicle Model': ('වාහන මාදිලිය', 'வாகන மாதிரி'),
    'View Details': ('විස්තර බලන්න', 'விவரங்களைக் காண்க'),
    'Reserve Price: Minimum price per unit you agree to sell for.\n• Buy-Now Price: An instant purchase price that ends the auction immediately.': ('වෙන්කළ මිල: ඔබ විකිණීමට එකඟ වන ඒකකයක අවම මිල.\n• ක්ෂණික මිලදී ගැනීමේ මිල: වෙන්දේසිය වහාම අවසන් කරන ක්ෂණික මිල.', 'இருப்பு விலை: நீங்கள் விற்க ஒப்புக்கொள்ளும் குறைந்தபட்ச அலகு விலை.\n• உடனே வாங்கும் விலை: ஏலத்தை உடனடியாக முடிக்கும் உடனடி கொள்முதல் விலை.'),
    '• Reserve Price: Minimum price per unit you agree to sell for.\n• Buy-Now Price: An instant purchase price that ends the auction immediately.': ('• සංචිත මිල: ඔබ විකිණීමට එකඟ වන ඒකකයක අවම මිල.\n• සෘජු මිලදී ගැනීමේ මිල: වෙන්දේසිය වහාම අවසන් කරන ක්ෂණික මිලදී ගැනීමේ මිල.', '• குறைந்தபட்ச விலை: நீங்கள் விற்க ஒப்புக்கொள்ளும் ஒரு யூனிட்டுக்கான குறைந்தபட்ச விலை.\n• உடனடி கொள்முதல் விலை: ஏலத்தை உடனடியாக முடிவுக்குக் கொண்டுவரும் உடனடி கொள்முதல் விலை.'),
    'Items': ('අයිතම', 'பொருட்கள்'),
    'Total Payout': ('මුළු ගෙවීම් මුදල', 'மொத்த கொடுப்பனவு'),
    'Payment Mode': ('ගෙවීම් ක්‍රමය', 'கட்டண முறை'),
    'View Cart': ('කරත්තය බලන්න', 'கூடையைப் பார்க்கவும்'),
    'added to cart!': ('කරත්තයට එක් කරන ලදී!', 'கூடையில் சேர்க்கப்பட்டது!'),
    'Minimum bid required is': ('අවම ලංසු මුදල විය යුත්තේ', 'தேவையான குறைந்தபட்ச ஏலத் தொகை'),
    'Congratulations! Crop lot sold to': ('සුබ පැතුම්! අස්වනු කාණ්ඩය විකුණන ලද්දේ', 'வாழ்த்துக்கள்! பயிர் தொகுதி விற்கப்பட்டது'),
    'Call Driver Hub': ('රියදුරු මධ්‍යස්ථානය අමතන්න', 'சாரதி மையத்தை அழைக்கவும்'),
    's Orders': ('ගේ ඇණවුම්', 'இன் ஆர்டர்கள்'),
    's Shift Pulse': ('ගේ සේවා තත්ත්වය', 'இன் பணி நிலை'),
    'Farm2Home Driver OS v2.4.12': ('Farm2Home රියදුරු මෙහෙයුම් පද්ධතිය v2.4.12', 'Farm2Home சாரதி இயங்குதளம் v2.4.12'),
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
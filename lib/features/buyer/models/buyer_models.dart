import 'package:flutter/material.dart';
import '../../../core/localization/app_settings.dart';
import '../../cart/models/cart_item_model.dart';

class BuyerProduct {
  const BuyerProduct({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.unit,
    required this.rating,
    required this.reviewsCount,
    required this.availableStock,
    required this.farmerName,
    required this.farmLocation,
    required this.farmName,
    required this.harvestTime,
    this.dispatchVia = 'Cold Transit Van 04',
    required this.imageUrl,
    required this.category,
    this.badge,
    this.badgeColor,
    required this.description,
    this.isOrganic = false,
    this.tags = const [],
    this.farmerAvatarUrl = 'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=400&auto=format&fit=crop&q=80',
    this.farmerBio = 'Cultivating highland produce using 100% natural and sustainable farming methods in Hakgala valley.',
    this.secondaryPrice,
    this.secondaryUnit,
  });

  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String unit;
  final double rating;
  final int reviewsCount;
  final String availableStock;
  final String farmerName;
  final String farmLocation;
  final String farmName;
  final String harvestTime;
  final String dispatchVia;
  final String imageUrl;
  final String category;
  final String? badge;
  final Color? badgeColor;
  final String description;
  final bool isOrganic;
  final List<String> tags;
  final String farmerAvatarUrl;
  final String farmerBio;
  final double? secondaryPrice;
  final String? secondaryUnit;

  String get formattedPrice => 'Rs. ${price.toStringAsFixed(0)}';
  String get formattedOriginalPrice => originalPrice != null ? 'Rs. ${originalPrice!.toStringAsFixed(0)}' : '';
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  int get discountPercent => hasDiscount ? (((originalPrice! - price) / originalPrice!) * 100).round() : 0;
}

class BuyerFarmer {
  const BuyerFarmer({
    required this.name,
    required this.farmName,
    required this.location,
    required this.altitude,
    required this.rating,
    required this.reviewsCount,
    required this.yearsExperience,
    required this.bio,
    required this.ordersFulfilled,
    required this.onTimeRate,
    required this.directTrace,
    required this.avatarUrl,
    required this.landscapeUrl,
    required this.phone,
    this.isCertifiedOrganic = true,
  });

  final String name;
  final String farmName;
  final String location;
  final String altitude;
  final double rating;
  final int reviewsCount;
  final String yearsExperience;
  final String bio;
  final String ordersFulfilled;
  final String onTimeRate;
  final String directTrace;
  final String avatarUrl;
  final String landscapeUrl;
  final String phone;
  final bool isCertifiedOrganic;

  static const defaultFarmer = BuyerFarmer(
    name: 'K. M. Bandara',
    farmName: 'Hakgala Valley Organic Gardens',
    location: 'Nuwara Eliya',
    altitude: '1,868m alt',
    rating: 4.9,
    reviewsCount: 450,
    yearsExperience: '19 yrs',
    bio: 'We cultivate fresh vegetables in the cool hills of Hakgala using sustainable and organic tradition methods passed down 3 generations. Our harvest reaches your kitchen within 12 hours of picking.',
    ordersFulfilled: '1,420+',
    onTimeRate: '98.4%',
    directTrace: '100%',
    avatarUrl: 'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=400&auto=format&fit=crop&q=80',
    landscapeUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=1000&auto=format&fit=crop&q=80',
    phone: '076 323 8225',
    isCertifiedOrganic: true,
  );
}

class BuyerCategoryItem {
  const BuyerCategoryItem({
    required this.id,
    required this.name,
    required this.itemCountText,
    required this.description,
    required this.imageUrl,
    this.badge,
    this.badgeColor,
    this.actionText = 'Browse fresh picks ->',
  });

  final String id;
  final String name;
  final String itemCountText;
  final String description;
  final String imageUrl;
  final String? badge;
  final Color? badgeColor;
  final String actionText;
}

class BuyerFilterCriteria {
  const BuyerFilterCriteria({
    this.category = 'All',
    this.priceRange = const RangeValues(50, 2000),
    this.region = 'All Sri Lanka',
    this.freshHarvestOnly = false,
    this.certifiedOrganicOnly = false,
    this.directFarmDispatch = false,
    this.sortBy = 'Distance (Closest Farm First)',
    this.searchQuery = '',
  });

  final String category;
  final RangeValues priceRange;
  final String region;
  final bool freshHarvestOnly;
  final bool certifiedOrganicOnly;
  final bool directFarmDispatch;
  final String sortBy;
  final String searchQuery;

  int get activeFiltersCount {
    int count = 0;
    if (category != 'All' && category.isNotEmpty) count++;
    if (priceRange.start > 50 || priceRange.end < 2000) count++;
    if (region != 'All Sri Lanka' && region.isNotEmpty) count++;
    if (freshHarvestOnly) count++;
    if (certifiedOrganicOnly) count++;
    if (directFarmDispatch) count++;
    if (searchQuery.trim().isNotEmpty) count++;
    return count;
  }

  BuyerFilterCriteria copyWith({
    String? category,
    RangeValues? priceRange,
    String? region,
    bool? freshHarvestOnly,
    bool? certifiedOrganicOnly,
    bool? directFarmDispatch,
    String? sortBy,
    String? searchQuery,
  }) {
    return BuyerFilterCriteria(
      category: category ?? this.category,
      priceRange: priceRange ?? this.priceRange,
      region: region ?? this.region,
      freshHarvestOnly: freshHarvestOnly ?? this.freshHarvestOnly,
      certifiedOrganicOnly: certifiedOrganicOnly ?? this.certifiedOrganicOnly,
      directFarmDispatch: directFarmDispatch ?? this.directFarmDispatch,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// ── Product Localization Dictionaries & Extensions ─────────────────────────

const Map<String, (String, String)> _productNames = {
  // Vegetables
  'prod_carrot_1': ('නුවරඑළිය උඩරට කැරට්', 'நுவரெலியா மலைநாட்டு கேரட்'),
  'prod_tomato_1': ('දඹුල්ල ඉදුණු රතු තක්කාලි', 'தம்புள்ளை தக்காளி'),
  'prod_leeks_1': ('කාබනික වැලිමඩ ලීක්ස්', 'இயற்கை வெலிமடை லீக்ஸ்'),
  'prod_capsicum_1': ('මහනුවර මාළු මිරිස්', 'கண்டி குடைமிளகாய்'),
  'prod_potato_1': ('නුවරඑළිය අල', 'நுவரெலியா உருளைக்கிழங்கு'),
  'prod_baby_carrot_1': ('පැණි බේබි කැරට්', 'இனிப்பு பேபி கேரட்'),
  'prod_cabbage_1': ('හක්ගල රතු ගෝවා', 'ஹக்கல ஊதா முட்டைகோஸ்'),
  'prod_beetroot_1': ('නුවරඑළිය බීට්රූට්', 'நுவரெலியா பீட்ரூட்'),
  'prod_pumpkin_1': ('දඹුල්ල පැණි වට්ටක්කා', 'தம்புள்ளை இனிப்பு பூசணி'),
  'prod_green_beans_1': ('වැලිමඩ බෝංචි', 'வெலிமடை பச்சை பீன்ஸ்'),
  'prod_eggplant_1': ('යාපනයේ වම්බටු', 'யாழ்ப்பாண கத்தரிக்காய்'),
  'prod_cucumber_1': ('නැවුම් පිපිඤ්ඤා', 'புதிய வெள்ளரிக்காய்'),
  'prod_broccoli_1': ('නැවුම් කොළ බ්‍රොකොලි', 'பச்சை ப்ரோக்கோலி'),
  // Fruits
  'prod_avocado_1': ('බටර් අලිගැටපේර', 'வெண்ணெய் அவகேடோ'),
  'prod_papaya_1': ('රෙඩ් ලේඩි පැපොල්', 'ரெட் லேடி பப்பாளி'),
  'prod_mango_1': ('යාපනයේ කාර්තකොලොම්බන් අඹ', 'யாழ்ப்பாண கறுத்தக்கொழும்பு மாம்பழம்'),
  'prod_banana_1': ('ඇඹුල් කෙසෙල්', 'புளிப்பு வாழைப்பழம்'),
  'prod_pineapple_1': ('ගම්පහ පැණි අන්නාසි', 'கம்பஹா இனிப்பு அன்னாசி'),
  'prod_passion_1': ('පැෂන් ෆෘට්', 'பழச்சாறு பாஷன் பழம்'),
  'prod_king_coconut_1': ('තැඹිලි', 'செவ்விளநீர்'),
  'prod_guava_1': ('රෝස පේර', 'ரோஸ் கொய்யா'),
  'prod_watermelon_1': ('පැණි කොමඩු', 'இனிப்பு தர்பூசணி'),
  // Grains & Rice
  'prod_keeri_samba_1': ('කීරි සම්බා සහල්', 'கீரி சம்பா அரிசி'),
  'prod_rathdel_1': ('සාම්ප්‍රදායික රත්දැල් රතු කැකුළු', 'பாரம்பரிய ரத்தெல் சிவப்பு அரிசி'),
  'prod_kurakkan_1': ('පිරිසිදු කුරක්කන් පිටි', 'தூய குரக்கன் மாவு'),
  'prod_suwandel_1': ('සුවඳැල් පාරම්පරික සහල්', 'சுவந்தெல் பாரம்பரிய அரிசி'),
  // Spices & Herbs
  'prod_cinnamon_1': ('සැබෑ ලංකා කුරුඳු පොතු', 'தூய சிலோன் இலவங்கப்பட்டை'),
  'prod_green_chili_1': ('දඹුල්ල අමුමිරිස්', 'தம்புள்ளை பச்சை மிளகாய்'),
  'prod_black_pepper_1': ('මාතලේ කළු ගම්මිරිස්', 'மாத்தளை கருப்பு மிளகு'),
  'prod_cardamom_1': ('උඩරට කරදමුංගු', 'மலைநாட்டு ஏலக்காய்'),
  'prod_cloves_1': ('සම්පූර්ණ කරාබුනැටි', 'முழு கிராம்பு'),
  // Organic & Traditional
  'prod_gotukola_1': ('කාබනික ගොටුකොළ', 'இயற்கை வல்லாரை'),
  'prod_kiri_ala_1': ('දේශීය කිරි අල', 'நாட்டு சேப்பங்கிழங்கு'),
  'prod_moringa_1': ('යාපනයේ මුරුංගා කරල්', 'யாழ்ப்பாண முருங்கைக்காய்'),
  'prod_sweet_potato_1': ('දේශීය රතු බතල', 'பாரம்பரிய சர்க்கரைவள்ளிக்கிழங்கு'),
  // Dairy & Farm Fresh
  'prod_curd_1': ('රුහුණු මීකිරි (හට්ටි)', 'ருஹுணு எருமைத் தயிர்'),
  'prod_honey_1': ('ස්වාභාවික වන මීපැණි', 'இயற்கை காட்டுத் தேன்'),
  'prod_eggs_1': ('ගම්බිත්තර (10 ඇසුරුම)', 'நாட்டுக்கோழி முட்டை'),
  'prod_kitul_1': ('මොරවක කිතුල් පැණි', 'மொரவக்க கித்துள் பாகு'),
};

const Map<String, (String, String)> _nameKeywordsMap = {
  'Carrot': ('කැරට්', 'கேரட்'),
  'Tomato': ('තක්කාලි', 'தக்காளி'),
  'Leek': ('ලීක්ස්', 'லீக்ஸ்'),
  'Capsicum': ('මාළු මිරිස්', 'குடைமிளகாய்'),
  'Potato': ('අල', 'உருளைக்கிழங்கு'),
  'Cabbage': ('ගෝවා', 'முட்டைகோஸ்'),
  'Beetroot': ('බීට්රූට්', 'பீட்ரூட்'),
  'Pumpkin': ('වට්ටක්කා', 'பூசணி'),
  'Bean': ('බෝංචි', 'பீன்ஸ்'),
  'Eggplant': ('වම්බටු', 'கத்தரிக்காய்'),
  'Cucumber': ('පිපිඤ්ඤා', 'வெள்ளரிக்காய்'),
  'Broccoli': ('බ්‍රොකොලි', 'ப்ரோக்கோலி'),
  'Avocado': ('අලිගැටපේර', 'அவகேடோ'),
  'Papaya': ('පැපොල්', 'பப்பாளி'),
  'Mango': ('අඹ', 'மாம்பழம்'),
  'Banana': ('කෙසෙල්', 'வாழைப்பழம்'),
  'Pineapple': ('අන්නාසි', 'அன்னாசி'),
  'Coconut': ('තැඹිලි', 'செவ்விளநீர்'),
  'Guava': ('පේර', 'கொய்யா'),
  'Watermelon': ('කොමඩු', 'தர்பூசணி'),
  'Rice': ('සහල්', 'அரிசி'),
  'Samba': ('සම්බා සහල්', 'சம்பா அரிசி'),
  'Kurakkan': ('කුරක්කන් පිටි', 'குரக்கன் மாவு'),
  'Cinnamon': ('කුරුඳු පොතු', 'இலவங்கப்பட்டை'),
  'Chili': ('අමුමිරිස්', 'பச்சை மிளகாய்'),
  'Pepper': ('ගම්මිරිස්', 'மிளகு'),
  'Cardamom': ('කරදමුංගු', 'ஏலக்காய்'),
  'Clove': ('කරාබුනැටි', 'கிராம்பு'),
  'Gotukola': ('ගොටුකොළ', 'வல்லாரை'),
  'Moringa': ('මුරුංගා', 'முருங்கை'),
  'Sweet Potato': ('බතල', 'சர்க்கரைவள்ளிக்கிழங்கு'),
  'Curd': ('මීකිරි', 'தயிர்'),
  'Honey': ('මීපැණි', 'தேன்'),
  'Egg': ('බිත්තර', 'முட்டைகள்'),
  'Treacle': ('කිතුල් පැණි', 'கித்துள் பாகு'),
};

extension LocalizedBuyerProduct on BuyerProduct {
  String localizedName(AppLanguage lang) {
    if (lang == AppLanguage.english) return name;
    final map = _productNames[id];
    if (map != null) {
      return lang == AppLanguage.sinhala ? map.$1 : map.$2;
    }
    for (final entry in _nameKeywordsMap.entries) {
      if (name.toLowerCase().contains(entry.key.toLowerCase())) {
        return lang == AppLanguage.sinhala ? entry.value.$1 : entry.value.$2;
      }
    }
    return AppAutoTranslator.instance.translateSync(name, lang);
  }

  String localizedUnit(AppLanguage lang) {
    if (lang == AppLanguage.english) return unit;
    if (unit == '1 kg') return lang == AppLanguage.sinhala ? '1 කි.ග්‍රෑ' : '1 கி.கி';
    if (unit == '500g') return lang == AppLanguage.sinhala ? '500 ග්‍රෑ' : '500 கிராம்';
    if (unit.contains('5 kg')) return lang == AppLanguage.sinhala ? '5 කි.ග්‍රෑ මල්ල' : '5 கி.கி பை';
    if (unit.contains('100g')) return lang == AppLanguage.sinhala ? '100 ග්‍රෑ' : '100 கிராம்';
    if (unit.toLowerCase().contains('bundle')) return lang == AppLanguage.sinhala ? '1 මිටිය' : '1 கட்டு';
    if (unit.toLowerCase().contains('pot')) return lang == AppLanguage.sinhala ? '1 හට්ටිය' : '1 சட்டி';
    if (unit.toLowerCase().contains('bottle')) return lang == AppLanguage.sinhala ? 'බෝතලය' : 'பாட்டில்';
    if (unit.toLowerCase().contains('nut')) return lang == AppLanguage.sinhala ? '1 ගෙඩිය' : '1 காய்';
    return AppAutoTranslator.instance.translateSync(unit, lang);
  }

  String localizedCategory(AppLanguage lang) {
    if (lang == AppLanguage.english) return category;
    final lower = category.toLowerCase();
    if (lower.contains('veg')) return lang == AppLanguage.sinhala ? 'එළවළු' : 'காய்கறிகள்';
    if (lower.contains('fruit')) return lang == AppLanguage.sinhala ? 'පලතුරු' : 'பழங்கள்';
    if (lower.contains('grain') || lower.contains('rice')) return lang == AppLanguage.sinhala ? 'ධාන්‍ය සහ සහල්' : 'தானியங்கள் & அரிசி';
    if (lower.contains('spice') || lower.contains('herb')) return lang == AppLanguage.sinhala ? 'කුළුබඩු සහ ඖෂධ පැළෑටි' : 'மசாலா மற்றும் மூலிகைகள்';
    if (lower.contains('organic') || lower.contains('trad')) return lang == AppLanguage.sinhala ? 'කාබනික සහ දේශීය' : 'இயற்கை & பாரம்பரிய';
    if (lower.contains('dairy') || lower.contains('fresh')) return lang == AppLanguage.sinhala ? 'කිරි සහ නැවුම් නිෂ්පාදන' : 'பால் & புதிய பொருட்கள்';
    return AppAutoTranslator.instance.translateSync(category, lang);
  }

  String? localizedBadge(AppLanguage lang) {
    if (badge == null) return null;
    if (lang == AppLanguage.english) return badge;
    final b = badge!.toLowerCase();
    if (b.contains('picked today') || b.contains('today')) {
      return lang == AppLanguage.sinhala ? 'අද නෙළූ නැවුම් අස්වැන්න' : 'இன்று பறிக்கப்பட்டது';
    }
    if (b.contains('just in')) {
      return lang == AppLanguage.sinhala ? 'දැන්ම ලැබුණු' : 'புதிய வரவு';
    }
    if (b.contains('100% organic') || b.contains('organic')) {
      return lang == AppLanguage.sinhala ? '100% කාබනික' : '100% இயற்கை';
    }
    if (b.contains('tree ripened')) {
      return lang == AppLanguage.sinhala ? 'ගසේ ඉදුණු' : 'மரத்தில் பழுத்தது';
    }
    if (b.contains('export grade')) {
      return lang == AppLanguage.sinhala ? 'අපනයන තත්ත්වයේ' : 'ஏற்றுமதி தரம்';
    }
    if (b.contains('daily pick') || b.contains('fresh pick')) {
      return lang == AppLanguage.sinhala ? 'දෛනික අස්වැන්න' : 'தினசரி அறுவடை';
    }
    if (b.contains('best value')) {
      return lang == AppLanguage.sinhala ? 'ඉහළම වටිනාකම' : 'சிறந்த மதிப்பு';
    }
    return badge;
  }
}

extension LocalizedBuyerCategoryItem on BuyerCategoryItem {
  String localizedName(AppLanguage lang) {
    if (lang == AppLanguage.english) return name;
    final lower = name.toLowerCase();
    if (lower.contains('veg')) return lang == AppLanguage.sinhala ? 'එළවළු' : 'காய்கறிகள்';
    if (lower.contains('fruit')) return lang == AppLanguage.sinhala ? 'පලතුරු' : 'பழங்கள்';
    if (lower.contains('grain') || lower.contains('rice')) return lang == AppLanguage.sinhala ? 'ධාන්‍ය සහ සහල්' : 'தானியங்கள் & அரிசி';
    if (lower.contains('spice') || lower.contains('herb')) return lang == AppLanguage.sinhala ? 'කුළුබඩු සහ ඖෂධ පැළෑටි' : 'மசாலா සහ மூலிகைகள்';
    if (lower.contains('organic') || lower.contains('trad')) return lang == AppLanguage.sinhala ? 'කාබනික සහ දේශීය' : 'இயற்கை & பாரம்பரிய';
    if (lower.contains('dairy') || lower.contains('fresh')) return lang == AppLanguage.sinhala ? 'කිරි සහ නැවුම් නිෂ්පාදන' : 'பால் & புதிய பொருட்கள்';
    return name;
  }

  String localizedDescription(AppLanguage lang) {
    if (lang == AppLanguage.english) return description;
    final lower = name.toLowerCase();
    if (lower.contains('veg')) {
      return lang == AppLanguage.sinhala
          ? 'කැරට්, තක්කාලි, ලීක්ස්, මාළු මිරිස්, බ්‍රොකොලි සහ නැවුම් පලා වර්ග'
          : 'கேரட், தக்காளி, லீக்ஸ், குடைமிளகாய் & பண்ணை காய்கறிகள்';
    }
    if (lower.contains('fruit')) {
      return lang == AppLanguage.sinhala
          ? 'අලිගැටපේර, පැපොල්, කාර්තකොලොම්බන් අඹ, අන්නාසි සහ තැඹිලි'
          : 'அவகேடோ, பப்பாளி, மாம்பழம், அன்னாசி மற்றும் செவ்விளநீர்';
    }
    if (lower.contains('grain') || lower.contains('rice')) {
      return lang == AppLanguage.sinhala
          ? 'කීරි සම්බා, සාම්ප්‍රදායික රත්දැල් රතු කැකුළු, සුවඳැල් සහ කුරක්කන්'
          : 'கீரி சம்பா, பாரம்பரிய சிவப்பு அரிசி, சுவந்தெல் மற்றும் குரக்கன்';
    }
    if (lower.contains('spice') || lower.contains('herb')) {
      return lang == AppLanguage.sinhala
          ? 'සැබෑ ලංකා කුරුඳු, කළු ගම්මිරිස්, කරාබුනැටි සහ එනසාල්'
          : 'தூய சிலோன் இலவங்கப்பட்டை, கருப்பு மிளகு, கிராம்பு & ஏலக்காய்';
    }
    if (lower.contains('organic') || lower.contains('trad')) {
      return lang == AppLanguage.sinhala
          ? 'සහතික කළ කාබනික ගොටුකොළ, දේශීය කිරි අල, මුරුංගා සහ බතල'
          : 'சான்றளிக்கப்பட்ட இயற்கை வல்லாரை, முருங்கை மற்றும் கிழங்கு';
    }
    if (lower.contains('dairy') || lower.contains('fresh')) {
      return lang == AppLanguage.sinhala
          ? 'රුහුණු මීකිරි, ස්වාභාවික වන මීපැණි, ගම්බිත්තර සහ කිතුල් පැණි'
          : 'எருமைத் தயிர், இயற்கை காட்டுத் தேன், முட்டை & கித்துள் பாகு';
    }
    return AppAutoTranslator.instance.translateSync(description, lang);
  }

  String localizedActionText(AppLanguage lang) {
    return switch (lang) {
      AppLanguage.sinhala => 'නැවුම් අස්වැන්න බලන්න ->',
      AppLanguage.tamil => 'விளைச்சலைப் பார்க்கவும் ->',
      AppLanguage.english => actionText,
    };
  }

  String? localizedBadge(AppLanguage lang) {
    if (badge == null) return null;
    if (lang == AppLanguage.english) return badge;
    final b = badge!.toLowerCase();
    if (b.contains('daily pick')) return lang == AppLanguage.sinhala ? 'දෛනික අස්වැන්න' : 'தினசரி அறுவடை';
    if (b.contains('tree ripened')) return lang == AppLanguage.sinhala ? 'ගසේ ඉදුණු' : 'மரத்தில் பழுத்தது';
    if (b.contains('export grade')) return lang == AppLanguage.sinhala ? 'අපනයන තත්ත්වයේ' : 'ஏற்றுமதி தரம்';
    if (b.contains('100% bio') || b.contains('bio')) return lang == AppLanguage.sinhala ? '100% කාබනික' : '100% இயற்கை';
    return badge;
  }

  String localizedItemCount(AppLanguage lang) {
    final count = itemCountText.split(' ').first;
    if (lang == AppLanguage.english) return itemCountText;
    if (lang == AppLanguage.sinhala) return '$count ක් ඇත';
    return '$count பொருட்கள்';
  }
}

extension LocalizedCartItem on CartItem {
  String localizedName(AppLanguage lang) {
    if (lang == AppLanguage.english) return name;
    final map = _productNames[id];
    if (map != null) return lang == AppLanguage.sinhala ? map.$1 : map.$2;
    for (final entry in _nameKeywordsMap.entries) {
      if (name.toLowerCase().contains(entry.key.toLowerCase())) {
        return lang == AppLanguage.sinhala ? entry.value.$1 : entry.value.$2;
      }
    }
    return AppAutoTranslator.instance.translateSync(name, lang);
  }

  String localizedUnit(AppLanguage lang) {
    if (lang == AppLanguage.english) return unit;
    final u = unit.toLowerCase();
    if (u.contains('kg')) return lang == AppLanguage.sinhala ? '/කි.ග්‍රෑ' : '/கி.கி';
    if (u.contains('bundle')) return lang == AppLanguage.sinhala ? '/මිටිය' : '/கட்டு';
    if (u.contains('pack')) return lang == AppLanguage.sinhala ? '/ඇසුරුම' : '/பாக்கெட்';
    if (u.contains('bottle')) return lang == AppLanguage.sinhala ? '/බෝතලය' : '/பாட்டில்';
    if (u.contains('pot')) return lang == AppLanguage.sinhala ? '/හට්ටිය' : '/சட்டி';
    if (u.contains('item') || u.contains('each')) return lang == AppLanguage.sinhala ? '/එකක්' : '/ஒன்று';
    return AppAutoTranslator.instance.translateSync(unit, lang);
  }
}



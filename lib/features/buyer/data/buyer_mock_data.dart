import 'package:flutter/material.dart';
import '../models/buyer_models.dart';

class BuyerMockData {
  // ── Farmers ──────────────────────────────────────────────────────────
  static const BuyerFarmer primaryFarmer = BuyerFarmer(
    name: 'K. M. Bandara',
    farmName: 'Hakgala Valley Organic Gardens',
    location: 'Nuwara Eliya',
    altitude: '1,868m alt',
    rating: 4.9,
    reviewsCount: 450,
    yearsExperience: '19 yrs',
    bio: 'We cultivate fresh highland vegetables in the cool mist of Hakgala using sustainable and organic traditional methods passed down 3 generations. Our harvest reaches your kitchen within 12 hours of picking.',
    ordersFulfilled: '1,420+',
    onTimeRate: '98.4%',
    directTrace: '100%',
    avatarUrl: 'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=400&auto=format&fit=crop&q=80',
    landscapeUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=1000&auto=format&fit=crop&q=80',
    phone: '076 323 8225',
    isCertifiedOrganic: true,
  );

  static const BuyerFarmer farmerSunil = BuyerFarmer(
    name: 'Sunil Perera',
    farmName: 'Dambulla Agro Greenlands',
    location: 'Dambulla',
    altitude: '160m alt',
    rating: 4.8,
    reviewsCount: 310,
    yearsExperience: '14 yrs',
    bio: 'Specializing in sun-ripened dry zone vegetables including juicy red tomatoes and golden sweet pumpkins, harvested at peak maturity with direct transit delivery.',
    ordersFulfilled: '980+',
    onTimeRate: '97.2%',
    directTrace: '100%',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
    landscapeUrl: 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=1000&auto=format&fit=crop&q=80',
    phone: '077 412 9081',
    isCertifiedOrganic: false,
  );

  static const BuyerFarmer farmerTharmalingam = BuyerFarmer(
    name: 'S. Tharmalingam',
    farmName: 'Jaffna Heritage Orchards',
    location: 'Jaffna',
    altitude: '15m alt',
    rating: 4.9,
    reviewsCount: 220,
    yearsExperience: '25 yrs',
    bio: 'Famed for authentic Karthacolomban sweet mangoes, tender purple eggplants, and indigenous moringa leaves nurtured on the fertile red calcic soils of Jaffna.',
    ordersFulfilled: '640+',
    onTimeRate: '99.1%',
    directTrace: '100%',
    avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&auto=format&fit=crop&q=80',
    landscapeUrl: 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=1000&auto=format&fit=crop&q=80',
    phone: '071 884 5623',
    isCertifiedOrganic: true,
  );

  // ── 1. VEGETABLES ─────────────────────────────────────────────────────
  static const BuyerProduct carrotProduct = BuyerProduct(
    id: 'prod_carrot_1',
    name: 'Nuwara Eliya Highland Carrots',
    price: 380.0,
    originalPrice: 420.0,
    unit: '1 kg',
    rating: 4.9,
    reviewsCount: 142,
    availableStock: '45 kg',
    farmerName: 'K. M. Bandara',
    farmLocation: 'Nuwara Eliya',
    farmName: 'Hakgala Green Valley Farm',
    harvestTime: 'Today, 5:30 AM',
    dispatchVia: 'Cold Transit Van 04',
    imageUrl: 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=800&auto=format&fit=crop&q=80',
    category: 'Vegetables',
    badge: 'Picked Today 5:30 AM',
    badgeColor: Color(0xFF1E8342),
    description: 'Crisp, sweet mountain-grown carrots harvested early morning in Nuwara Eliya. Free from synthetic chemicals, washed with mountain spring water and packed in eco-friendly aerated crates.',
    isOrganic: true,
    tags: ['Spring Washed', 'Zero Chemical', 'Aerated Box'],
    secondaryPrice: 190.0,
    secondaryUnit: '500g',
  );

  static const BuyerProduct tomatoProduct = BuyerProduct(
    id: 'prod_tomato_1',
    name: 'Dambulla Ripe Red Tomatoes',
    price: 260.0,
    originalPrice: 300.0,
    unit: '1 kg',
    rating: 4.6,
    reviewsCount: 92,
    availableStock: '60 kg',
    farmerName: 'Sunil Perera',
    farmLocation: 'Dambulla',
    farmName: 'Dambulla Central Farmlands',
    harvestTime: 'Today, 6:00 AM',
    dispatchVia: 'Ventilated Crate Van 02',
    imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=800&auto=format&fit=crop&q=80',
    category: 'Vegetables',
    badge: 'Just In',
    badgeColor: Color(0xFFFF6B35),
    description: 'Sun-ripened red tomatoes picked early morning in Dambulla farmlands. Thick fleshed, juicy, and naturally sweet, perfect for curries and fresh salads.',
    isOrganic: false,
    tags: ['Sun Ripened', 'Farm Gate Price'],
    secondaryPrice: 135.0,
    secondaryUnit: '500g',
  );

  static const BuyerProduct leeksProduct = BuyerProduct(
    id: 'prod_leeks_1',
    name: 'Organic Welimada Leeks',
    price: 310.0,
    originalPrice: 350.0,
    unit: '1 kg',
    rating: 4.7,
    reviewsCount: 58,
    availableStock: '28 kg',
    farmerName: 'Welimada Green Coop',
    farmLocation: 'Welimada',
    farmName: 'Welimada Highland Valley',
    harvestTime: 'Today, 6:15 AM',
    dispatchVia: 'Direct Farm Dispatch',
    imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=800&auto=format&fit=crop&q=80',
    category: 'Vegetables',
    badge: '100% Organic',
    badgeColor: Color(0xFF10B981),
    description: 'Fresh crisp leeks grown in organic hill-slope compost. Zero synthetic sprays, packed in eco-friendly bamboo leaf bundles with thick white stems.',
    isOrganic: true,
    tags: ['Highland Leeks', 'Direct Harvest'],
  );

  static const BuyerProduct capsicumProduct = BuyerProduct(
    id: 'prod_capsicum_1',
    name: 'Kandy Green Bell Capsicum',
    price: 490.0,
    originalPrice: 540.0,
    unit: '1 kg',
    rating: 4.8,
    reviewsCount: 34,
    availableStock: '22 kg',
    farmerName: 'Mahinda Alwis',
    farmLocation: 'Kandy',
    farmName: 'Peradeniya Agro Farms',
    harvestTime: 'Today, 6:30 AM',
    dispatchVia: 'Cool Van Hub 01',
    imageUrl: 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=800&auto=format&fit=crop&q=80',
    category: 'Vegetables',
    badge: 'Grade-A Highland',
    badgeColor: Color(0xFF0284C7),
    description: 'Crispy crunchy bell capsicums with rich vitamin C content. Grown under semi-controlled shade net conditions in Peradeniya microclimate.',
    isOrganic: false,
    tags: ['Grade-A Highland', 'Crisp Harvest'],
  );

  static const BuyerProduct potatoProduct = BuyerProduct(
    id: 'prod_potato_1',
    name: 'Keppetipola Mountain Potatoes',
    price: 420.0,
    unit: '1 kg',
    rating: 4.8,
    reviewsCount: 65,
    availableStock: '80 kg',
    farmerName: 'Ranjith Silva',
    farmLocation: 'Keppetipola',
    farmName: 'Keppetipola Mountain Terraces',
    harvestTime: 'Yesterday, 4:00 PM',
    imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=800&auto=format&fit=crop&q=80',
    category: 'Vegetables',
    badge: 'Highland Soil',
    badgeColor: Color(0xFF8B5CF6),
    description: 'Golden highland potatoes with high dry matter and earthy aroma. Ideal for boiling, curries, and roasts with thin golden skin.',
    tags: ['Highland Soil', 'Long Shelf Life'],
  );

  static const BuyerProduct babyCarrotsProduct = BuyerProduct(
    id: 'prod_baby_carrot_1',
    name: 'Organic Sweet Baby Carrots',
    price: 520.0,
    unit: '1 kg',
    rating: 4.8,
    reviewsCount: 42,
    availableStock: '28 kg',
    farmerName: 'K. M. Bandara',
    farmLocation: 'Nuwara Eliya',
    farmName: 'Nuwara Eliya Bio Reserve',
    harvestTime: 'Today, 6:00 AM',
    imageUrl: 'https://images.unsplash.com/photo-1447175008436-054170c2e979?w=800&auto=format&fit=crop&q=80',
    category: 'Vegetables',
    badge: '100% Organic',
    badgeColor: Color(0xFF10B981),
    description: 'Tender miniature carrots picked young for supreme sweetness and raw snacking. Washed and ready to eat.',
    isOrganic: true,
  );

  static const BuyerProduct redCabbageProduct = BuyerProduct(
    id: 'prod_red_cabbage_1',
    name: 'Hakgala Fresh Red Cabbage',
    price: 420.0,
    unit: '1 kg head',
    rating: 4.7,
    reviewsCount: 29,
    availableStock: '35 heads',
    farmerName: 'K. M. Bandara',
    farmLocation: 'Nuwara Eliya',
    farmName: 'Hakgala Valley Organic Gardens',
    harvestTime: 'Today, 6:00 AM',
    imageUrl: 'https://images.unsplash.com/photo-1598030304671-5aa1d6f21128?w=800&auto=format&fit=crop&q=80',
    category: 'Vegetables',
    badge: 'Antioxidant Rich',
    badgeColor: Color(0xFF9333EA),
    description: 'Dense violet heads with crunch and peppery sweetness, harvested upon confirmation from high altitude beds.',
    isOrganic: true,
  );

  static const BuyerProduct beetrootProduct = BuyerProduct(
    id: 'prod_beetroot_1',
    name: 'Highland Crimson Beetroot',
    price: 290.0,
    unit: '1 kg',
    rating: 4.6,
    reviewsCount: 47,
    availableStock: '40 kg',
    farmerName: 'K. M. Bandara',
    farmLocation: 'Nuwara Eliya',
    farmName: 'Hakgala Valley Organic Gardens',
    harvestTime: 'Today, 5:45 AM',
    imageUrl: 'https://images.unsplash.com/photo-1525607551316-4a8e16d1f9ba?w=800&auto=format&fit=crop&q=80',
    category: 'Vegetables',
    badge: 'Earthy & Sweet',
    badgeColor: Color(0xFFE11D48),
    description: 'Fresh crimson beetroot roots rich in natural nitrates and sweetness. Perfect for fresh juice or Sri Lankan tempered beetroot curry.',
    isOrganic: true,
  );

  static const BuyerProduct pumpkinProduct = BuyerProduct(
    id: 'prod_pumpkin_1',
    name: 'Dambulla Golden Pumpkin (Wattakka)',
    price: 210.0,
    originalPrice: 240.0,
    unit: '1 kg cut',
    rating: 4.7,
    reviewsCount: 38,
    availableStock: '55 kg',
    farmerName: 'Sunil Perera',
    farmLocation: 'Dambulla',
    farmName: 'Dambulla Central Farmlands',
    harvestTime: 'Today, 7:00 AM',
    imageUrl: 'https://images.unsplash.com/photo-1506917728037-b6af01a7d403?w=800&auto=format&fit=crop&q=80',
    category: 'Vegetables',
    badge: 'Dry Zone Sweet',
    badgeColor: Color(0xFFF59E0B),
    description: 'Deep golden, buttery Sri Lankan Wattakka grown in sunny Dambulla. High beta-carotene and naturally creamy texture when cooked in coconut milk.',
    tags: ['Dry Zone Sweet', 'Creamy Curry'],
  );

  static const BuyerProduct greenBeansProduct = BuyerProduct(
    id: 'prod_beans_1',
    name: 'Matale Fresh Green Beans (Bonchi)',
    price: 360.0,
    unit: '1 kg',
    rating: 4.8,
    reviewsCount: 52,
    availableStock: '30 kg',
    farmerName: 'Chaminda Senanayake',
    farmLocation: 'Matale',
    farmName: 'Riverston View Estate',
    harvestTime: 'Today, 6:00 AM',
    imageUrl: 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=800&auto=format&fit=crop&q=80',
    category: 'Vegetables',
    badge: 'Tender Stringless',
    badgeColor: Color(0xFF16A34A),
    description: 'Hand-picked young green beans with a clean snap and no tough strings. Grown along misty valley slopes in Matale.',
    tags: ['Hand Picked', 'Super Fresh'],
  );

  static const BuyerProduct eggplantProduct = BuyerProduct(
    id: 'prod_eggplant_1',
    name: 'Jaffna Glossy Purple Eggplant',
    price: 280.0,
    unit: '1 kg',
    rating: 4.7,
    reviewsCount: 41,
    availableStock: '35 kg',
    farmerName: 'S. Tharmalingam',
    farmLocation: 'Jaffna',
    farmName: 'Jaffna Heritage Orchards',
    harvestTime: 'Yesterday, 5:00 PM',
    imageUrl: 'https://images.unsplash.com/photo-1623910298114-1e5b8aa32a67?w=800&auto=format&fit=crop&q=80',
    category: 'Vegetables',
    badge: 'Tender Flesh',
    badgeColor: Color(0xFF7C3AED),
    description: 'Deep purple glossy Jaffna wambatu with tender seeds and melt-in-mouth flesh. Essential for traditional moju and curries.',
    tags: ['Heritage Variety', 'Zero Waste'],
  );

  static const BuyerProduct cucumberProduct = BuyerProduct(
    id: 'prod_cucumber_1',
    name: 'Crisp Field Salad Cucumber',
    price: 190.0,
    unit: '1 kg',
    rating: 4.6,
    reviewsCount: 30,
    availableStock: '45 kg',
    farmerName: 'Mahinda Alwis',
    farmLocation: 'Kandy',
    farmName: 'Peradeniya Agro Farms',
    harvestTime: 'Today, 6:30 AM',
    imageUrl: 'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=800&auto=format&fit=crop&q=80',
    category: 'Vegetables',
    badge: 'Cooling Hydration',
    badgeColor: Color(0xFF0284C7),
    description: 'Crisp, refreshing, thin-skinned field cucumbers loaded with water and minerals. Perfect for cooling summer salads.',
  );

  static const BuyerProduct broccoliProduct = BuyerProduct(
    id: 'prod_broccoli_1',
    name: 'Nuwara Eliya Fresh Broccoli',
    price: 680.0,
    originalPrice: 750.0,
    unit: '1 kg',
    rating: 4.9,
    reviewsCount: 36,
    availableStock: '18 kg',
    farmerName: 'K. M. Bandara',
    farmLocation: 'Nuwara Eliya',
    farmName: 'Hakgala Green Valley Farm',
    harvestTime: 'Today, 5:30 AM',
    imageUrl: 'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=800&auto=format&fit=crop&q=80',
    category: 'Vegetables',
    badge: 'Highland Premium',
    badgeColor: Color(0xFF15803D),
    description: 'Compact deep-green florets grown in Nuwara Eliya mountain climate. Crisp stalks and zero pesticide residue.',
    isOrganic: true,
  );

  // ── 2. FRUITS ─────────────────────────────────────────────────────────
  static const BuyerProduct avocadoProduct = BuyerProduct(
    id: 'prod_avocado_1',
    name: 'Kandy Butter Avocados',
    price: 510.0,
    originalPrice: 580.0,
    unit: '1 kg',
    rating: 4.9,
    reviewsCount: 78,
    availableStock: '32 kg',
    farmerName: 'Mahinda Alwis',
    farmLocation: 'Kandy',
    farmName: 'Hantana Foothill Orchard',
    harvestTime: 'Today, 7:00 AM',
    imageUrl: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=800&auto=format&fit=crop&q=80',
    category: 'Fruits',
    badge: 'Butter Rich',
    badgeColor: Color(0xFF059669),
    description: 'Creamy buttery purple-green avocados grown in the lush microclimate of Hantana. Zero fibrous strings, tree-ripened perfection.',
    tags: ['Butter Texture', 'Tree Ripened'],
    secondaryPrice: 260.0,
    secondaryUnit: '500g',
  );

  static const BuyerProduct papayaProduct = BuyerProduct(
    id: 'prod_papaya_1',
    name: 'Embilipitiya Red Lady Papaya',
    price: 240.0,
    unit: '1 kg',
    rating: 4.8,
    reviewsCount: 64,
    availableStock: '50 kg',
    farmerName: 'Kamal Wickramasinghe',
    farmLocation: 'Embilipitiya',
    farmName: 'Walawe Basin Fruit Gardens',
    harvestTime: 'Today, 6:00 AM',
    imageUrl: 'https://images.unsplash.com/photo-1517282009859-f000ec3b26fe?w=800&auto=format&fit=crop&q=80',
    category: 'Fruits',
    badge: 'Sun Sweetened',
    badgeColor: Color(0xFFEA580C),
    description: 'Deep crimson-orange flesh with rich natural sugars, hand-harvested from Walawe basin. Sweet, juicy, and rich in digestive papain.',
    tags: ['Tree Ripened', 'Super Sweet'],
  );

  static const BuyerProduct mangoProduct = BuyerProduct(
    id: 'prod_mango_1',
    name: 'Jaffna Karthacolomban Mangoes',
    price: 650.0,
    originalPrice: 720.0,
    unit: '1 kg',
    rating: 4.9,
    reviewsCount: 110,
    availableStock: '40 kg',
    farmerName: 'S. Tharmalingam',
    farmLocation: 'Jaffna',
    farmName: 'Jaffna Heritage Orchards',
    harvestTime: 'Yesterday, 3:00 PM',
    imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=800&auto=format&fit=crop&q=80',
    category: 'Fruits',
    badge: 'Queen of Mangoes',
    badgeColor: Color(0xFFD97706),
    description: 'The prized aromatic Karthacolomban mango of Jaffna. Honey-like sweetness, vibrant yellow-orange meat, and irresistible fragrance.',
    tags: ['Aromatic Gold', 'Naturally Ripened'],
  );

  static const BuyerProduct bananaProduct = BuyerProduct(
    id: 'prod_banana_1',
    name: 'Golden Cavendish Bananas (Ambul/Cavendish)',
    price: 290.0,
    unit: '1 kg bunch',
    rating: 4.7,
    reviewsCount: 85,
    availableStock: '60 bunches',
    farmerName: 'Sarath Jayawardena',
    farmLocation: 'Kurunegala',
    farmName: 'Wayamba Organic Groves',
    harvestTime: 'Today, 6:30 AM',
    imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=800&auto=format&fit=crop&q=80',
    category: 'Fruits',
    badge: 'Naturally Ripened',
    badgeColor: Color(0xFFCA8A04),
    description: 'Sun-warmed golden bananas ripened without calcium carbide. Creamy, nutritious, and high in potassium for daily energy.',
    isOrganic: true,
  );

  static const BuyerProduct pineappleProduct = BuyerProduct(
    id: 'prod_pineapple_1',
    name: 'Mirigama Sweet Mauritius Pineapple',
    price: 320.0,
    unit: '1 large fruit (1.2kg)',
    rating: 4.8,
    reviewsCount: 55,
    availableStock: '30 fruits',
    farmerName: 'Anura Kumara',
    farmLocation: 'Gampaha',
    farmName: 'Mirigama Pine Ridge',
    harvestTime: 'Today, 7:00 AM',
    imageUrl: 'https://images.unsplash.com/photo-1550258987-190a2d41a8ba?w=800&auto=format&fit=crop&q=80',
    category: 'Fruits',
    badge: 'High Brix Sweet',
    badgeColor: Color(0xFFEAB308),
    description: 'Golden yellow ripe pineapple with balanced tart-sweet burst. Grown on red laterite soil ideal for high sugar concentration.',
  );

  static const BuyerProduct passionFruitProduct = BuyerProduct(
    id: 'prod_passion_1',
    name: 'Badulla Sweet Purple Passion Fruit',
    price: 450.0,
    unit: '1 kg (approx 12-14)',
    rating: 4.8,
    reviewsCount: 39,
    availableStock: '25 kg',
    farmerName: 'Welimada Green Coop',
    farmLocation: 'Badulla',
    farmName: 'Badulla Highland Orchards',
    harvestTime: 'Yesterday Morning',
    imageUrl: 'https://images.unsplash.com/photo-1589533610925-1cffc309ebaa?w=800&auto=format&fit=crop&q=80',
    category: 'Fruits',
    badge: 'Exotic Aroma',
    badgeColor: Color(0xFF9333EA),
    description: 'Juicy, fragrant purple passion fruit bursting with aromatic pulp and crunchy edible seeds. Perfect for natural juices.',
    isOrganic: true,
  );

  static const BuyerProduct kingCoconutProduct = BuyerProduct(
    id: 'prod_king_coconut_1',
    name: 'Fresh King Coconut (Thambili)',
    price: 150.0,
    unit: '1 fresh nut',
    rating: 5.0,
    reviewsCount: 140,
    availableStock: '80 nuts',
    farmerName: 'Kamal Wickramasinghe',
    farmLocation: 'Kalutara',
    farmName: 'Bentota Riverbank Palms',
    harvestTime: 'Today, 6:00 AM',
    imageUrl: 'https://images.unsplash.com/photo-1544894079-e81a9eb1da8b?w=800&auto=format&fit=crop&q=80',
    category: 'Fruits',
    badge: 'Pure Electrolyte',
    badgeColor: Color(0xFFEA580C),
    description: 'Natural golden Sri Lankan King Coconut plucked fresh from coastal palms. Pure, sweet, isotonic water to instantly beat the tropical heat.',
    tags: ['100% Natural Drink', 'Tree Cut Today'],
  );

  static const BuyerProduct guavaProduct = BuyerProduct(
    id: 'prod_guava_1',
    name: 'Kalutara Sweet Bangkok Guava',
    price: 310.0,
    unit: '1 kg',
    rating: 4.6,
    reviewsCount: 28,
    availableStock: '30 kg',
    farmerName: 'Nishantha Fernando',
    farmLocation: 'Kalutara',
    farmName: 'Kalutara Fruit Groves',
    harvestTime: 'Today, 6:45 AM',
    imageUrl: 'https://images.unsplash.com/photo-1536511135706-027f311c1d81?w=800&auto=format&fit=crop&q=80',
    category: 'Fruits',
    badge: 'Vitamin C Boost',
    badgeColor: Color(0xFF16A34A),
    description: 'Crisp, fragrant white-flesh guava with minimal seeds. Loaded with 4x the vitamin C of an orange.',
  );

  static const BuyerProduct watermelonProduct = BuyerProduct(
    id: 'prod_watermelon_1',
    name: 'Monaragala Sunshine Watermelon',
    price: 180.0,
    unit: '1 kg cut',
    rating: 4.7,
    reviewsCount: 43,
    availableStock: '70 kg',
    farmerName: 'Sarath Jayawardena',
    farmLocation: 'Monaragala',
    farmName: 'Wellawaya Sunshine Plains',
    harvestTime: 'Yesterday Afternoon',
    imageUrl: 'https://images.unsplash.com/photo-1589984662646-e7b2e4959493?w=800&auto=format&fit=crop&q=80',
    category: 'Fruits',
    badge: 'Summer Sweet',
    badgeColor: Color(0xFFE11D48),
    description: 'Deep ruby red watermelon with sweet crisp bite and juicy coolness. Grown on the sun-drenched plains of Wellawaya.',
  );

  // ── 3. GRAINS & RICE ──────────────────────────────────────────────────
  static const BuyerProduct keeriSambaProduct = BuyerProduct(
    id: 'prod_keeri_samba_1',
    name: 'Polonnaruwa Keeri Samba Rice',
    price: 320.0,
    originalPrice: 350.0,
    unit: '1 kg pack',
    rating: 4.9,
    reviewsCount: 165,
    availableStock: '150 kg',
    farmerName: 'Jayalath Bandara',
    farmLocation: 'Polonnaruwa',
    farmName: 'Parakrama Samudra Fields',
    harvestTime: 'Cured Batch 04',
    imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=800&auto=format&fit=crop&q=80',
    category: 'Grains & Rice',
    badge: 'Aromatic Fine Grain',
    badgeColor: Color(0xFF16A34A),
    description: 'Tiny pearl-white grains of genuine Sri Lankan Keeri Samba. Milled carefully from dry zone paddy and naturally aged for fluffy, non-sticky cooking.',
    tags: ['Aged Rice', 'Festive Quality'],
  );

  static const BuyerProduct rathdelRiceProduct = BuyerProduct(
    id: 'prod_rathdel_1',
    name: 'Anuradhapura Rathdel Traditional Red Rice',
    price: 380.0,
    unit: '1 kg pack',
    rating: 4.9,
    reviewsCount: 92,
    availableStock: '80 kg',
    farmerName: 'Anuradhapura Heritage Growers',
    farmLocation: 'Anuradhapura',
    farmName: 'Rajata Heritage Paddy Groves',
    harvestTime: 'New Season Milling',
    imageUrl: 'https://images.unsplash.com/photo-1536304929831-ee1ca9d44906?w=800&auto=format&fit=crop&q=80',
    category: 'Grains & Rice',
    badge: 'Ancient Heirloom',
    badgeColor: Color(0xFFB91C1C),
    description: 'Ancestral heirloom red rice celebrated for its medicinal properties and low glycemic index. High in bran antioxidants and iron.',
    isOrganic: true,
    tags: ['Low GI', '100% Organic Heritage'],
  );

  static const BuyerProduct kurakkanFlourProduct = BuyerProduct(
    id: 'prod_kurakkan_1',
    name: 'Organic Stone-Ground Kurakkan Flour',
    price: 420.0,
    unit: '1 kg pack',
    rating: 4.8,
    reviewsCount: 71,
    availableStock: '65 kg',
    farmerName: 'Monaragala Co-op',
    farmLocation: 'Monaragala',
    farmName: 'Monaragala Chena Organic Project',
    harvestTime: 'Freshly Milled',
    imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&auto=format&fit=crop&q=80',
    category: 'Grains & Rice',
    badge: 'Superfood Millet',
    badgeColor: Color(0xFF78350F),
    description: 'Pure Finger Millet (Kurakkan) flour milled on stone granaries. Gluten-friendly, rich in calcium and dietary fiber for traditional roti and porridge.',
    isOrganic: true,
  );

  static const BuyerProduct suwandelRiceProduct = BuyerProduct(
    id: 'prod_suwandel_1',
    name: 'Suwandel Fragrant Heirloom White Rice',
    price: 460.0,
    unit: '1 kg pack',
    rating: 4.9,
    reviewsCount: 60,
    availableStock: '50 kg',
    farmerName: 'Anuradhapura Heritage Growers',
    farmLocation: 'Anuradhapura',
    farmName: 'Rajata Heritage Paddy Groves',
    harvestTime: 'Aged Season',
    imageUrl: 'https://images.unsplash.com/photo-1596704017254-9b121068fb31?w=800&auto=format&fit=crop&q=80',
    category: 'Grains & Rice',
    badge: 'Ayurvedic Scented',
    badgeColor: Color(0xFF0D9488),
    description: 'Exquisitely fragrant indigenous white rice named for its natural pleasing aroma (Suwanda). Traditionally served at royalty feasts.',
    isOrganic: true,
  );

  // ── 4. SPICES & HERBS ─────────────────────────────────────────────────
  static const BuyerProduct ceylonCinnamonProduct = BuyerProduct(
    id: 'prod_cinnamon_1',
    name: 'Pure Ceylon Alba Cinnamon Quills',
    price: 1450.0,
    originalPrice: 1600.0,
    unit: '250g pack',
    rating: 5.0,
    reviewsCount: 130,
    availableStock: '45 packs',
    farmerName: 'Rohan Gunawardena',
    farmLocation: 'Galle',
    farmName: 'Koggala Cinnamon Terraces',
    harvestTime: 'Hand-Peeled This Week',
    imageUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=800&auto=format&fit=crop&q=80',
    category: 'Spices & Herbs',
    badge: 'Alba Grade Export',
    badgeColor: Color(0xFFD97706),
    description: 'The thinnest, most delicate pencil quills of true Ceylon Cinnamon (Cinnamomum Verum). Delicate sweetness, low coumarin, hand-rolled by master peelers.',
    isOrganic: true,
    tags: ['True Cinnamon', 'Zero Cassia', 'Export Standard'],
  );

  static const BuyerProduct greenChiliProduct = BuyerProduct(
    id: 'prod_chili_1',
    name: 'Matale Fresh Green Chillies',
    price: 180.0,
    unit: '250g pack',
    rating: 4.7,
    reviewsCount: 62,
    availableStock: '40 packs',
    farmerName: 'Chaminda Senanayake',
    farmLocation: 'Matale',
    farmName: 'Riverston View Estate',
    harvestTime: 'Today, 6:00 AM',
    imageUrl: 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=800&auto=format&fit=crop&q=80',
    category: 'Spices & Herbs',
    badge: 'Spicy Fresh',
    badgeColor: Color(0xFFEF4444),
    description: 'Pungent, vibrant spicy green chillies hand-picked at dawn. Bold heat and crisp snap for tempering and curries.',
    tags: ['Hot & Pungent', 'Direct Field'],
  );

  static const BuyerProduct blackPepperProduct = BuyerProduct(
    id: 'prod_pepper_1',
    name: 'Matale Whole Black Peppercorns (Grade 1)',
    price: 890.0,
    unit: '500g pack',
    rating: 4.9,
    reviewsCount: 88,
    availableStock: '55 packs',
    farmerName: 'Chaminda Senanayake',
    farmLocation: 'Matale',
    farmName: 'Riverston View Estate',
    harvestTime: 'Sun Dried This Month',
    imageUrl: 'https://images.unsplash.com/photo-1509358271058-acd22cc93898?w=800&auto=format&fit=crop&q=80',
    category: 'Spices & Herbs',
    badge: 'High Piperine',
    badgeColor: Color(0xFF1E293B),
    description: 'Intensely pungent whole black pepper grown on the hillsides of Matale. High essential oil concentration and clean natural drying.',
    isOrganic: true,
  );

  static const BuyerProduct cardamomProduct = BuyerProduct(
    id: 'prod_cardamom_1',
    name: 'Welimada Whole Green Cardamom (LG1)',
    price: 1850.0,
    unit: '100g pack',
    rating: 4.9,
    reviewsCount: 49,
    availableStock: '30 packs',
    farmerName: 'Welimada Green Coop',
    farmLocation: 'Welimada',
    farmName: 'Welimada Highland Valley',
    harvestTime: 'Shade Cured',
    imageUrl: 'https://images.unsplash.com/photo-1615485500704-8e990f9900f7?w=800&auto=format&fit=crop&q=80',
    category: 'Spices & Herbs',
    badge: 'Plump Green Pods',
    badgeColor: Color(0xFF059669),
    description: 'Plump, aromatic green cardamom pods harvested from high mountain understory forests. Sweet floral camphor notes.',
  );

  static const BuyerProduct clovesProduct = BuyerProduct(
    id: 'prod_cloves_1',
    name: 'Handpicked Ceylon Whole Cloves',
    price: 950.0,
    unit: '250g pack',
    rating: 4.8,
    reviewsCount: 37,
    availableStock: '35 packs',
    farmerName: 'Chaminda Senanayake',
    farmLocation: 'Matale',
    farmName: 'Riverston View Estate',
    harvestTime: 'Sun Dried',
    imageUrl: 'https://images.unsplash.com/photo-1579705745811-a32bef785ec0?w=800&auto=format&fit=crop&q=80',
    category: 'Spices & Herbs',
    badge: 'Rich Eugenol',
    badgeColor: Color(0xFF9A3412),
    description: 'Aromatic flower buds hand-plucked before flowering, fully intact heads with sweet pungent warmth.',
    isOrganic: true,
  );

  // ── 5. ORGANIC & TRADITIONAL ──────────────────────────────────────────
  static const BuyerProduct gotukolaProduct = BuyerProduct(
    id: 'prod_gotukola_1',
    name: 'Organic Gotukola Bundle (Centella)',
    price: 80.0,
    unit: '1 bundle',
    rating: 4.9,
    reviewsCount: 104,
    availableStock: '60 bundles',
    farmerName: 'Kandy Greens',
    farmLocation: 'Kandy',
    farmName: 'Riverbank Organic Herbal Grove',
    harvestTime: 'Today, 5:00 AM',
    imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800&auto=format&fit=crop&q=80',
    category: 'Organic & Traditional',
    badge: '100% Bio Spring Fed',
    badgeColor: Color(0xFF10B981),
    description: 'Indigenous Centella Asiatica harvested alongside pure mountain spring water streams. Celebrated in Ayurveda for brain vitality and longevity.',
    isOrganic: true,
    tags: ['Pure Spring Fed', 'Traditional Herbal'],
  );

  static const BuyerProduct kiriAlaProduct = BuyerProduct(
    id: 'prod_kiri_ala_1',
    name: 'Traditional Kiri Ala (Indigenous Taro Yam)',
    price: 380.0,
    unit: '1 kg',
    rating: 4.8,
    reviewsCount: 42,
    availableStock: '28 kg',
    farmerName: 'Anuradhapura Heritage Growers',
    farmLocation: 'Anuradhapura',
    farmName: 'Rajata Heritage Paddy Groves',
    harvestTime: 'Fresh Dug Yesterday',
    imageUrl: 'https://images.unsplash.com/photo-1596560548464-f010549b84d7?w=800&auto=format&fit=crop&q=80',
    category: 'Organic & Traditional',
    badge: 'Heirloom Yam',
    badgeColor: Color(0xFF854D0E),
    description: 'Soft, creamy traditional indigenous tuber. Boils to melt-in-mouth consistency, traditionally enjoyed with spicy lunu miris and grated coconut.',
    isOrganic: true,
  );

  static const BuyerProduct moringaProduct = BuyerProduct(
    id: 'prod_moringa_1',
    name: 'Organic Fresh Moringa Leaves (Murunga Kola)',
    price: 120.0,
    unit: '1 bundle (250g)',
    rating: 4.9,
    reviewsCount: 56,
    availableStock: '40 bundles',
    farmerName: 'S. Tharmalingam',
    farmLocation: 'Jaffna',
    farmName: 'Jaffna Heritage Orchards',
    harvestTime: 'Today, 6:00 AM',
    imageUrl: 'https://images.unsplash.com/photo-1515543237350-b3eea1ec8082?w=800&auto=format&fit=crop&q=80',
    category: 'Organic & Traditional',
    badge: 'Nutrient Powerhouse',
    badgeColor: Color(0xFF15803D),
    description: 'Tender green drumstick tree leaves harvested from natural tree crowns. Packed with plant protein, calcium, iron, and multivitamin vitality.',
    isOrganic: true,
  );

  static const BuyerProduct sweetPotatoProduct = BuyerProduct(
    id: 'prod_batala_1',
    name: 'Purple Heirloom Sweet Potato (Batala)',
    price: 320.0,
    unit: '1 kg',
    rating: 4.7,
    reviewsCount: 39,
    availableStock: '35 kg',
    farmerName: 'Sarath Jayawardena',
    farmLocation: 'Kurunegala',
    farmName: 'Wayamba Organic Groves',
    harvestTime: 'Yesterday Morning',
    imageUrl: 'https://images.unsplash.com/photo-1596097635121-14b63b7a0c19?w=800&auto=format&fit=crop&q=80',
    category: 'Organic & Traditional',
    badge: 'Antioxidant Tuber',
    badgeColor: Color(0xFF7E22CE),
    description: 'Naturally sweet purple-fleshed yams grown in organic soil without chemical fertilizers. Delicious boiled or baked.',
    isOrganic: true,
  );

  // ── 6. DAIRY & FARM FRESH ─────────────────────────────────────────────
  static const BuyerProduct buffaloCurdProduct = BuyerProduct(
    id: 'prod_curd_1',
    name: 'Ruhuna Traditional Buffalo Curd in Clay Pot',
    price: 420.0,
    originalPrice: 460.0,
    unit: '1 clay pot (900g)',
    rating: 4.9,
    reviewsCount: 185,
    availableStock: '50 pots',
    farmerName: 'Ruhuna Dairy Co-op',
    farmLocation: 'Tissamaharama',
    farmName: 'Tissamaharama Grassland Dairy',
    harvestTime: 'Set Fresh Today 4:00 AM',
    dispatchVia: 'Chilled Daily Crate',
    imageUrl: 'https://images.unsplash.com/photo-1571212515416-fef01fc43637?w=800&auto=format&fit=crop&q=80',
    category: 'Dairy & Farm Fresh',
    badge: 'Clay Pot Set',
    badgeColor: Color(0xFF16A34A),
    description: 'Thick, creamy, velvety 100% pure buffalo curd set inside natural terracotta earthenware. No gelatin, no powdered milk, unadulterated artisanal perfection.',
    tags: ['Terracotta Pot', 'Pure Buffalo Milk', 'Chilled Delivery'],
  );

  static const BuyerProduct beeHoneyProduct = BuyerProduct(
    id: 'prod_honey_1',
    name: 'Pure Wild Forest Bee Honey (Mee Peni)',
    price: 1650.0,
    originalPrice: 1800.0,
    unit: '750ml glass bottle',
    rating: 5.0,
    reviewsCount: 96,
    availableStock: '30 bottles',
    farmerName: 'Nilgala Forest Apiaries',
    farmLocation: 'Bibile',
    farmName: 'Nilgala Forest Edge Reserve',
    harvestTime: 'Season Extraction',
    imageUrl: 'https://images.unsplash.com/photo-1558642452-9d2a7deb7f62?w=800&auto=format&fit=crop&q=80',
    category: 'Dairy & Farm Fresh',
    badge: '100% Raw Wild Honey',
    badgeColor: Color(0xFFD97706),
    description: 'Pure, raw, unpasteurized multifloral wild bee honey sustainably gathered from dry zone medicinal flora. Rich amber hue and complex natural aroma.',
    isOrganic: true,
    tags: ['Raw & Unheated', 'Zero Sugar Added'],
  );

  static const BuyerProduct farmEggsProduct = BuyerProduct(
    id: 'prod_eggs_1',
    name: 'Ambewela Free-Range Farm Brown Eggs',
    price: 580.0,
    unit: 'Pack of 10 eggs',
    rating: 4.8,
    reviewsCount: 112,
    availableStock: '70 packs',
    farmerName: 'Ambewela Foothill Farm',
    farmLocation: 'Nuwara Eliya',
    farmName: 'Ambewela Valley Pastures',
    harvestTime: 'Gathered Today, 6:00 AM',
    imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=800&auto=format&fit=crop&q=80',
    category: 'Dairy & Farm Fresh',
    badge: 'Golden Yolk Pasture',
    badgeColor: Color(0xFFF59E0B),
    description: 'Vibrant golden yolk eggs from pasture-roaming hens fed whole grains, fresh grass, and spring water. Packed in protective pulp cartons.',
    tags: ['Pasture Raised', 'Rich Omega-3'],
  );

  static const BuyerProduct kitulTreacleProduct = BuyerProduct(
    id: 'prod_kitul_1',
    name: 'Sinharaja Pure Organic Kitul Treacle (Peni)',
    price: 1200.0,
    unit: '750ml glass bottle',
    rating: 4.9,
    reviewsCount: 84,
    availableStock: '40 bottles',
    farmerName: 'Sinharaja Border Farms',
    farmLocation: 'Deniyaya',
    farmName: 'Deniyaya Rainforest Edge',
    harvestTime: 'Simmered This Week',
    imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3d5d6281691?w=800&auto=format&fit=crop&q=80',
    category: 'Dairy & Farm Fresh',
    badge: 'Slow Boiled Pure Sap',
    badgeColor: Color(0xFF78350F),
    description: 'Genuine artisan treacle made strictly by slow-boiling pure sap tapped from Caryota urens palms bordering Sinharaja rainforest. Divine pairing with buffalo curd.',
    isOrganic: true,
  );

  // ── All Products Master Catalog ───────────────────────────────────────
  static List<BuyerProduct> get allProducts => [
    // Vegetables
    carrotProduct,
    tomatoProduct,
    leeksProduct,
    capsicumProduct,
    potatoProduct,
    babyCarrotsProduct,
    redCabbageProduct,
    beetrootProduct,
    pumpkinProduct,
    greenBeansProduct,
    eggplantProduct,
    cucumberProduct,
    broccoliProduct,
    // Fruits
    avocadoProduct,
    papayaProduct,
    mangoProduct,
    bananaProduct,
    pineappleProduct,
    passionFruitProduct,
    kingCoconutProduct,
    guavaProduct,
    watermelonProduct,
    // Grains & Rice
    keeriSambaProduct,
    rathdelRiceProduct,
    kurakkanFlourProduct,
    suwandelRiceProduct,
    // Spices & Herbs
    ceylonCinnamonProduct,
    greenChiliProduct,
    blackPepperProduct,
    cardamomProduct,
    clovesProduct,
    // Organic & Traditional
    gotukolaProduct,
    kiriAlaProduct,
    moringaProduct,
    sweetPotatoProduct,
    // Dairy & Farm Fresh
    buffaloCurdProduct,
    beeHoneyProduct,
    farmEggsProduct,
    kitulTreacleProduct,
  ];

  // Daily Harvest Deals for Home Screen
  static List<BuyerProduct> get dailyDeals => [
    carrotProduct,
    tomatoProduct,
    avocadoProduct,
    mangoProduct,
    buffaloCurdProduct,
  ];

  // Popular Right Now for Home Screen
  static List<BuyerProduct> get popularProducts => [
    potatoProduct,
    papayaProduct,
    keeriSambaProduct,
    ceylonCinnamonProduct,
    gotukolaProduct,
    greenChiliProduct,
    kingCoconutProduct,
    farmEggsProduct,
  ];

  // Primary Farmer's active products (K. M. Bandara)
  static List<BuyerProduct> get bandaraProducts => [
    carrotProduct,
    leeksProduct,
    redCabbageProduct,
    beetrootProduct,
    babyCarrotsProduct,
    broccoliProduct,
  ];

  // Categories list with dynamic accurate representations
  static List<BuyerCategoryItem> get categories => [
    BuyerCategoryItem(
      id: 'cat_veg',
      name: 'Vegetables',
      itemCountText: '${allProducts.where((p) => p.category == 'Vegetables').length} fresh picks',
      description: 'Carrots, Tomatoes, Leeks, Capsicum, Broccoli & Farm Greens',
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&auto=format&fit=crop&q=80',
      badge: 'Daily Pick',
      badgeColor: const Color(0xFF16A34A),
      actionText: 'Browse fresh picks ->',
    ),
    BuyerCategoryItem(
      id: 'cat_fruit',
      name: 'Fruits',
      itemCountText: '${allProducts.where((p) => p.category == 'Fruits').length} varieties available',
      description: 'Avocados, Papaya, Karthacolomban Mangoes, Pineapple & King Coconut',
      imageUrl: 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=400&auto=format&fit=crop&q=80',
      badge: 'Tree Ripened',
      badgeColor: const Color(0xFFEA580C),
      actionText: 'Explore juicy fruits ->',
    ),
    BuyerCategoryItem(
      id: 'cat_grains',
      name: 'Grains & Rice',
      itemCountText: '${allProducts.where((p) => p.category == 'Grains & Rice').length} staple options',
      description: 'Keeri Samba, Traditional Rathdel Red Rice, Suwandel & Kurakkan',
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&auto=format&fit=crop&q=80',
      actionText: 'View staples ->',
    ),
    BuyerCategoryItem(
      id: 'cat_spices',
      name: 'Spices & Herbs',
      itemCountText: '${allProducts.where((p) => p.category == 'Spices & Herbs').length} aromatic items',
      description: 'Pure Ceylon Cinnamon, Black Peppercorns, Cloves & Cardamom',
      imageUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400&auto=format&fit=crop&q=80',
      badge: 'Export Grade',
      badgeColor: const Color(0xFFD97706),
      actionText: 'Browse spices ->',
    ),
    BuyerCategoryItem(
      id: 'cat_organic',
      name: 'Organic & Traditional',
      itemCountText: '${allProducts.where((p) => p.category == 'Organic & Traditional').length} certified picks',
      description: 'Certified Organic Gotukola, Indigenous Kiri Ala, Moringa & Batala',
      imageUrl: 'https://images.unsplash.com/photo-1509358271058-acd22cc93898?w=400&auto=format&fit=crop&q=80',
      badge: '100% Bio',
      badgeColor: const Color(0xFF10B981),
      actionText: 'Discover wellness ->',
    ),
    BuyerCategoryItem(
      id: 'cat_dairy',
      name: 'Dairy & Farm Fresh',
      itemCountText: '${allProducts.where((p) => p.category == 'Dairy & Farm Fresh').length} farm staples',
      description: 'Clay pot buffalo curd, wild forest bee honey, eggs & Kitul treacle',
      imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400&auto=format&fit=crop&q=80',
      actionText: 'Browse fresh farm dairy ->',
    ),
  ];

  // ── Smart Search & Filter Methods ─────────────────────────────────────
  static List<BuyerProduct> filterProducts(BuyerFilterCriteria criteria) {
    return allProducts.where((p) {
      // 1. Category check
      if (criteria.category != 'All' && criteria.category.isNotEmpty) {
        final matchesCat = p.category.toLowerCase().contains(criteria.category.toLowerCase()) ||
            criteria.category.toLowerCase().contains(p.category.toLowerCase());
        if (!matchesCat) return false;
      }

      // 2. Search query check
      if (criteria.searchQuery.trim().isNotEmpty) {
        final q = criteria.searchQuery.trim().toLowerCase();
        final matchesQuery = p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.farmerName.toLowerCase().contains(q) ||
            p.farmLocation.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchesQuery) return false;
      }

      // 3. Price range check
      if (p.price < criteria.priceRange.start || p.price > criteria.priceRange.end) {
        return false;
      }

      // 4. Region check
      if (criteria.region != 'All Sri Lanka' && criteria.region.isNotEmpty) {
        if (!p.farmLocation.toLowerCase().contains(criteria.region.toLowerCase())) {
          return false;
        }
      }

      // 5. Fresh harvest toggle (Today/Yesterday)
      if (criteria.freshHarvestOnly) {
        final harvest = p.harvestTime.toLowerCase();
        if (!harvest.contains('today') && !harvest.contains('fresh')) {
          return false;
        }
      }

      // 6. Certified Organic toggle
      if (criteria.certifiedOrganicOnly && !p.isOrganic) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        if (criteria.sortBy.contains('Low to High')) {
          return a.price.compareTo(b.price);
        } else if (criteria.sortBy.contains('High to Low')) {
          return b.price.compareTo(a.price);
        } else if (criteria.sortBy.contains('Highest Rated')) {
          return b.rating.compareTo(a.rating);
        } else if (criteria.sortBy.contains('Newest')) {
          final aToday = a.harvestTime.toLowerCase().contains('today') ? 1 : 0;
          final bToday = b.harvestTime.toLowerCase().contains('today') ? 1 : 0;
          return bToday.compareTo(aToday);
        }
        return 0;
      });
  }

  static List<BuyerProduct> searchProducts(String query, {String? category}) {
    return filterProducts(
      BuyerFilterCriteria(
        searchQuery: query,
        category: category ?? 'All',
      ),
    );
  }

  static List<BuyerProduct> getProductsByCategory(String category) {
    if (category.toLowerCase() == 'all' || category.isEmpty) {
      return allProducts;
    }
    return allProducts.where((p) {
      return p.category.toLowerCase() == category.toLowerCase() ||
          p.category.toLowerCase().contains(category.toLowerCase()) ||
          category.toLowerCase().contains(p.category.toLowerCase());
    }).toList();
  }

  static List<BuyerProduct> getFarmerProducts(String farmerName) {
    final list = allProducts.where((p) => p.farmerName.toLowerCase() == farmerName.toLowerCase()).toList();
    if (list.isEmpty) {
      return bandaraProducts;
    }
    return list;
  }
}

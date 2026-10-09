import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../services/driver_firestore_service.dart';
import '../services/driver_profile_manager.dart';
import 'deliveries_screen.dart';
import 'delivery_history_screen.dart';
import 'driver_chat_screen.dart';
import 'driver_dashboard_screen.dart';
import 'driver_profile_photo_data.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_router.dart';
import '../../../services/auth_service.dart';

/// Pixel-perfect Driver Profile Screen matching the reference mockup.
///
/// Features:
/// 1. Verified Agri-Transit Partner Profile Hero Card
/// 2. Cold Chain Hardware & Telematics Monitoring Specs
/// 3. Driver Operations Menu with:
///    - Delivery History & Statements
///    - Earnings & Bank Account (Comprehensive Bank Linking, Withdrawals,
///      Auto-Deposit Scheduling, and Cash on Delivery [COD] Settlement Balance)
///    - Vehicle Documents & SL-Transport
///    - Language Switcher (English / සිංහල / தமிழ்)
///    - App Notifications & Highway Alerts
/// 4. Switch Role (Farmer / Buyer Mode) & Sign Out
/// 5. Bottom Navigation Bar synced with Driver Dashboard & Deliveries
class DriverProfileScreen extends StatefulWidget {
  final String? driverId;
  final String? driverName;
  final String? vehicleType;
  final String? plateNumber;
  final String? bankName;
  final String? accountNumber;
  final String? cargoCapacity;
  final String? licenseNumber;
  final String? phone;

  const DriverProfileScreen({
    super.key,
    this.driverId,
    this.driverName,
    this.vehicleType,
    this.plateNumber,
    this.bankName,
    this.accountNumber,
    this.cargoCapacity,
    this.licenseNumber,
    this.phone,
  });

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  // Current Bank Account State
  String _bankName = 'Commercial Bank of Ceylon PLC';
  String _accountNumber = '8004 1293 4198';
  String _maskedAccount = 'Commercial Bank LK (****4198)';
  String _accountHolder = 'Ranjith Subha Udhasanak';
  String _phone = '+94 77 123 4567';
  String _branch = 'Nuwara Eliya (Branch 042)';
  String _vehicleType = 'Chilled / Refrigerated Van';
  String _plateNumber = 'NC-4982';
  String _cargoCapacity = '1,200 kg';
  String _licenseNumber = 'B-8492019';
  String _selectedLanguage = 'English';
  bool _hasUnreadNotifications = true;

  @override
  void initState() {
    super.initState();
    DriverProfileManager.instance.addListener(_onProfileManagerUpdated);
    _syncFromManager();

    if (widget.phone != null && widget.phone!.trim().isNotEmpty) {
      _phone = widget.phone!.trim();
    }

    if (widget.driverName != null && widget.driverName!.trim().isNotEmpty) {
      _accountHolder = widget.driverName!.trim();
    }
    if (widget.vehicleType != null && widget.vehicleType!.trim().isNotEmpty) {
      _vehicleType = widget.vehicleType!.trim();
    }
    if (widget.plateNumber != null && widget.plateNumber!.trim().isNotEmpty) {
      _plateNumber = widget.plateNumber!.trim();
    }
    if (widget.bankName != null && widget.bankName!.trim().isNotEmpty) {
      _bankName = widget.bankName!.trim();
    }
    if (widget.accountNumber != null && widget.accountNumber!.trim().isNotEmpty) {
      _accountNumber = widget.accountNumber!.trim();
    }
    if (widget.cargoCapacity != null && widget.cargoCapacity!.trim().isNotEmpty) {
      _cargoCapacity = widget.cargoCapacity!.trim();
    }
    if (widget.licenseNumber != null && widget.licenseNumber!.trim().isNotEmpty) {
      _licenseNumber = widget.licenseNumber!.trim();
    }
    final last4 = _accountNumber.length >= 4
        ? _accountNumber.substring(_accountNumber.length - 4)
        : _accountNumber;
    _maskedAccount = '$_bankName (****$last4)';

    _loadDriverProfile();
  }

  @override
  void dispose() {
    DriverProfileManager.instance.removeListener(_onProfileManagerUpdated);
    super.dispose();
  }

  void _onProfileManagerUpdated() {
    if (mounted) {
      _syncFromManager();
    }
  }

  void _syncFromManager() {
    final d = DriverProfileManager.instance.driver;
    setState(() {
      if (d.fullName.isNotEmpty) _accountHolder = d.fullName;
      if (d.mobileNumber.isNotEmpty) _phone = d.mobileNumber;
      if (d.vehicleType.isNotEmpty) _vehicleType = d.vehicleType;
      if (d.plateNumber.isNotEmpty) _plateNumber = d.plateNumber;
      if (d.cargoCapacity.isNotEmpty) _cargoCapacity = d.cargoCapacity;
      if (d.licenseNumber.isNotEmpty) _licenseNumber = d.licenseNumber;
      if (d.bankName.isNotEmpty) _bankName = d.bankName;
      if (d.accountNumber.isNotEmpty) {
        _accountNumber = d.accountNumber;
        final last4 = d.accountNumber.length >= 4
            ? d.accountNumber.substring(d.accountNumber.length - 4)
            : d.accountNumber;
        _maskedAccount = '$_bankName (****$last4)';
      }
    });
  }

  Future<void> _loadDriverProfile() async {
    try {
      final driver = await DriverFirestoreService().getDashboardDriver(widget.driverId);
      if (driver != null && mounted) {
        setState(() {
          if (driver.fullName.isNotEmpty) _accountHolder = driver.fullName;
          if (driver.vehicleType.isNotEmpty) _vehicleType = driver.vehicleType;
          if (driver.plateNumber.isNotEmpty) _plateNumber = driver.plateNumber;
          if (driver.bankName.isNotEmpty) _bankName = driver.bankName;
          if (driver.cargoCapacity.isNotEmpty) _cargoCapacity = driver.cargoCapacity;
          if (driver.licenseNumber.isNotEmpty) _licenseNumber = driver.licenseNumber;
          if (driver.accountNumber.isNotEmpty) {
            _accountNumber = driver.accountNumber;
            final last4 = driver.accountNumber.length >= 4
                ? driver.accountNumber.substring(driver.accountNumber.length - 4)
                : driver.accountNumber;
            _maskedAccount = '${driver.bankName} (****$last4)';
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading driver profile from Firestore: $e');
    }
  }

  // Financial Balances State
  double _availablePayoutBalance = 28450.00;
  final double _tripPayouts = 24150.00;
  final double _directTips = 2800.00;
  final double _highlandBonuses = 1500.00;

  // COD & Settlement State
  final double _codCollectedCash = 14250.00;
  final double _driverCommissionOffset = 5650.00;
  double get _netCodSettlementBalance => _codCollectedCash - _driverCommissionOffset;

  // Auto-Deposit Settings
  bool _autoDepositEnabled = true;
  final String _autoDepositFrequency = 'Weekly (Every Monday)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: _buildTopAppBar(context),
      body: Column(
        children: [
          // Scrollable Profile Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // 0. Driver & Vehicle Cover Banner (Profile ekt uda photo)
                  _buildDriverCoverBanner(),
                  const SizedBox(height: 14),

                  // 1. Driver Profile Hero Card (Ranjith Subha Udhasanak)
                  _buildProfileHeroCard(),
                  const SizedBox(height: 14),

                  // 2. Cold Chain Hardware & Telematics Card
                  _buildColdChainHardwareCard(),
                  const SizedBox(height: 16),

                  // 3. DRIVER OPERATIONS Section Header & Tiles
                  _buildDriverOperationsSection(context),
                  const SizedBox(height: 18),

                  // 4. Role Switch & Sign Out Buttons
                  _buildActionButtons(context),
                  const SizedBox(height: 16),

                  // 5. Version & OS Footer
                  _buildFooter(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Navigation Bar (Profile Active)
          _buildBottomNavBar(context),
        ],
      ),
    );
  }

  // ── Top App Bar ────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildTopAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          // Green Brand Icon Container
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF006B44),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.home_filled,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 9),

          // Brand Name
          Text(
            'Farm2Home',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 8),

          // DRIVER Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'DRIVER'.trAuto(context),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF047857),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      actions: [
        const Center(child: AppLanguagePill()),
        const SizedBox(width: 6),
        // Notification Bell Icon with Red Dot Indicator
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF1E293B),
                  size: 24,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showNotificationSheet(context);
                },
              ),
              if (_hasUnreadNotifications)
                Positioned(
                  right: 12,
                  top: 13,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFF1F5F9),
          height: 1,
        ),
      ),
    );
  }

  // ── 0. Driver & Vehicle Cover Banner ───────────────────────────────────────
  Widget _buildDriverCoverBanner() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBBF7D0).withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF065F46).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.5),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // High Resolution Full Photo of Driver with Delivery Van
            Image.memory(
              kDriverProfileCoverBytes,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.1),
            ),

            // Subtle dark-to-transparent gradient overlays for readable badges
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.40),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),

            // Top Row: Vehicle Reg Badge & Active Status Pill
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Vehicle Badge Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFA7F3D0).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_shipping_rounded,
                          color: Color(0xFFA7F3D0),
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$_plateNumber • ${_vehicleType.trAuto(context)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Active Duty Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'On Duty'.trAuto(context),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Info: Driver Name & Region Title
            Positioned(
              bottom: 12,
              left: 14,
              right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _accountHolder.trAuto(context),
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                      shadows: const [
                        Shadow(color: Colors.black87, blurRadius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF34D399),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Agri-Transit Logistics Partner • Central Highlands'.trAuto(context),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFE2E8F0),
                          shadows: const [
                            Shadow(color: Colors.black87, blurRadius: 3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 1. Driver Profile Hero Card ────────────────────────────────────────────
  Widget _buildProfileHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8FDF2),
            Color(0xFFF6FDF9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBBF7D0).withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF065F46).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Avatar with Green Border Ring & Van Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFA7F3D0),
                    width: 2.5,
                  ),
                  color: const Color(0xFFDCFCE7),
                ),
                child: Center(
                  child: ClipOval(
                    child: SizedBox(
                      width: 74,
                      height: 74,
                      child: Image.memory(
                        kDriverProfilePhotoBytes,
                        fit: BoxFit.cover,
                        alignment: const Alignment(0, -0.2),
                      ),
                    ),
                  ),
                ),
              ),

              // Small circular green van badge at bottom right
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFF047857),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Driver Name
          Text(
            _accountHolder.trAuto(context),
            style: TextStyle(
              fontSize: 17.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),

          // Verified Agri-Transit Partner Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF047857),
                  size: 13,
                ),
                const SizedBox(width: 5),
                Text(
                  'Verified Agri-Transit Partner'.trAuto(context),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Refrigerated Van • WP NC-4982
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFF64748B),
                size: 13,
              ),
              const SizedBox(width: 5),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 12.5,
                    color: const Color(0xFF64748B),
                  ),
                  children: [
                    TextSpan(text: '${_vehicleType.trAuto(context)} • '),
                    TextSpan(
                      text: _plateNumber,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Cards Row: 4.95 (340 Reviews) & 6 Yrs (1,840+ Trips Finished)
          Row(
            children: [
              // Rating Stat Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFF59E0B),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.95',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '340 Reviews'.trAuto(context),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Experience Stat Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.verified_outlined,
                            color: Color(0xFF059669),
                            size: 17,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '6 Yrs'.trAuto(context),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '1,840+ Trips Finished'.trAuto(context),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Edit Profile Details Button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: _showEditDriverProfileModal,
              icon: const Icon(Icons.edit_note_rounded, size: 18, color: Color(0xFF047857)),
              label: Text(
                'Edit Profile Details'.trAuto(context),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF047857),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFA7F3D0), width: 1.2),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Cold Chain Hardware Card ────────────────────────────────────────────
  Widget _buildColdChainHardwareCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row: Cold Chain Hardware
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDFAF3),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.sensors_rounded,
                    color: Color(0xFF059669),
                    size: 19,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cold Chain Hardware'.trAuto(context),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Active Telematics Monitoring'.trAuto(context),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Spec 1: Vehicle Model
          _buildHardwareSpecRow(
            icon: Icons.local_shipping_outlined,
            label: 'Vehicle Model'.trAuto(context),
            value: '${_vehicleType.trAuto(context)} ($_plateNumber)',
            valueColor: const Color(0xFF0F172A),
          ),
          const SizedBox(height: 12),

          // Spec 2: Cargo Capacity
          _buildHardwareSpecRow(
            icon: Icons.inventory_2_outlined,
            label: 'Cargo Capacity'.trAuto(context),
            value: (_cargoCapacity.isNotEmpty ? _cargoCapacity : '1,200 kg').trAuto(context),
            valueColor: const Color(0xFF0F172A),
          ),
          const SizedBox(height: 12),

          // Spec 3: Climate Sensor -> Active (10°C - 16°C) ✓
          _buildHardwareSpecRow(
            icon: Icons.device_thermostat_rounded,
            label: 'Climate Sensor'.trAuto(context),
            value: 'Active (10°C - 16°C) ✓'.trAuto(context),
            valueColor: const Color(0xFF059669),
            isBold: true,
          ),
          const SizedBox(height: 12),

          // Spec 4: Roadworthy Status -> Valid until Nov 2025
          _buildHardwareSpecRow(
            icon: Icons.verified_user_outlined,
            label: 'Roadworthy Status'.trAuto(context),
            value: 'Valid until Nov 2025'.trAuto(context),
            valueColor: const Color(0xFF059669),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareSpecRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF10B981),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ── 3. DRIVER OPERATIONS Section ───────────────────────────────────────────
  Widget _buildDriverOperationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'DRIVER OPERATIONS'.trAuto(context),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.8,
            ),
          ),
        ),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Tile 0: Edit Driver Profile & Vehicle
              _buildOperationTile(
                icon: Icons.person_outline_rounded,
                iconBg: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF047857),
                title: 'Edit Driver Profile & Vehicle'.trAuto(context),
                subtitle: '$_accountHolder • $_plateNumber',
                subtitleColor: const Color(0xFF64748B),
                onTap: _showEditDriverProfileModal,
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),

              // Tile 1: Delivery History & Statements
              _buildOperationTile(
                icon: Icons.history_rounded,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                title: context.tr.deliveryHistoryTitle,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DeliveryHistoryScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),

              // Tile 2: Earnings & Bank Account (⭐ MAIN REQUEST FEATURE)
              _buildOperationTile(
                icon: Icons.account_balance_rounded,
                iconBg: const Color(0xFFEEF2FF),
                iconColor: const Color(0xFF6366F1),
                title: context.tr.earningsAndBankTitle,
                subtitle: _maskedAccount.trAuto(context),
                subtitleColor: const Color(0xFF94A3B8),
                highlightBorder: true,
                onTap: () => _showEarningsAndBankSheet(context),
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),

              // Tile 3: Vehicle Documents & SL-Transport
              _buildOperationTile(
                icon: Icons.description_outlined,
                iconBg: const Color(0xFFF5F3FF),
                iconColor: const Color(0xFF8B5CF6),
                title: context.tr.vehicleDocsTitle,
                onTap: () => _showVehicleDocumentsSheet(context),
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),

              // Tile 4: Language / සිංහල / தமிழ்
              Builder(
                builder: (context) {
                  final activeLang = context.watch<AppSettings>().language ?? AppLanguage.english;
                  return _buildOperationTile(
                    icon: Icons.translate_rounded,
                    iconBg: const Color(0xFFECFDF5),
                    iconColor: const Color(0xFF10B981),
                    title: '${context.tr.language} / Language',
                    subtitle: '${activeLang.nativeName} (${activeLang.englishName})',
                    subtitleColor: const Color(0xFF059669),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            activeLang.glyph,
                            style: AppTheme.fontStyle(
                              activeLang,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF047857),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF047857),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    onTap: () => showAppLanguageSheet(context),
                  );
                },
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),

              // Tile 5: App Notifications & Highway Alerts
              _buildOperationTile(
                icon: Icons.notifications_active_outlined,
                iconBg: const Color(0xFFFFF7ED),
                iconColor: const Color(0xFFF97316),
                title: context.tr.appNotificationsTitle,
                trailing: _hasUnreadNotifications
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '2 NEW'.trAuto(context),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      )
                    : null,
                onTap: () => _showNotificationSheet(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOperationTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    Widget? trailing,
    bool highlightBorder = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 19,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.fontStyle(
                      context.currentLanguage,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTheme.fontStyle(
                        context.currentLanguage,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor ?? const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }

  // ── 4. Role Switch & Sign Out Buttons ───────────────────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Button 1: Switch Role (Farmer / Buyer Mode)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showRoleSwitchSheet(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDCFCE7),
              foregroundColor: const Color(0xFF065F46),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.swap_horiz_rounded,
                  size: 20,
                  color: Color(0xFF065F46),
                ),
                const SizedBox(width: 8),
                Text(
                  'Switch Role (Farmer / Buyer Mode)'.trAuto(context),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF065F46),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Button 2: Sign Out of Driver Hub
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showSignOutConfirmation(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEE2E2),
              foregroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  size: 18,
                  color: Color(0xFFDC2626),
                ),
                const SizedBox(width: 8),
                Text(
                  'Sign Out of Driver Hub'.trAuto(context),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── 5. Footer ──────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Farm2Home Driver OS v2.4.12',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Empowering Sri Lankan Transit & Agri-Cold Chain'.trAuto(context),
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  // ── Bottom Navigation Bar ──────────────────────────────────────────────────
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Dashboard
            _buildNavItem(
              index: 0,
              icon: Icons.grid_view_rounded,
              label: context.tr.navHome,
              isSelected: false,
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const DriverDashboardScreen(),
                  ),
                  (route) => route.isFirst,
                );
              },
            ),

            // Deliveries
            _buildNavItem(
              index: 1,
              icon: Icons.fact_check_outlined,
              label: context.tr.navDeliveries,
              isSelected: false,
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const DeliveriesScreen(),
                  ),
                );
              },
            ),

            // Chat
            _buildNavItem(
              index: 2,
              icon: Icons.chat_bubble_outline_rounded,
              label: context.tr.navChat,
              isSelected: false,
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => DriverChatScreen(
                      driverId: widget.driverId,
                      driverName: widget.driverName,
                      vehicleType: widget.vehicleType,
                      plateNumber: widget.plateNumber,
                      bankName: widget.bankName,
                      accountNumber: widget.accountNumber,
                      cargoCapacity: widget.cargoCapacity,
                      licenseNumber: widget.licenseNumber,
                    ),
                  ),
                );
              },
            ),

            // Profile (Active)
            _buildNavItem(
              index: 3,
              icon: Icons.person_rounded,
              label: context.tr.navProfile,
              isSelected: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const activeColor = Color(0xFF065F46);
    const inactiveColor = Color(0xFF94A3B8);

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 3),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ⭐ EDIT DRIVER & VEHICLE PROFILE MODAL SHEET
  // ===========================================================================
  void _showEditDriverProfileModal() {
    final driver = DriverProfileManager.instance.driver;
    final nameCtrl = TextEditingController(text: _accountHolder);
    final phoneCtrl = TextEditingController(
      text: driver.mobileNumber.isNotEmpty ? driver.mobileNumber : _phone,
    );
    final licenseCtrl = TextEditingController(text: _licenseNumber);
    final vehicleCtrl = TextEditingController(text: _vehicleType);
    final plateCtrl = TextEditingController(text: _plateNumber);
    final capacityCtrl = TextEditingController(text: _cargoCapacity);
    final bankCtrl = TextEditingController(text: _bankName);
    final accountCtrl = TextEditingController(text: _accountNumber);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Driver & Vehicle Profile'.trAuto(context),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Legal Name
                _buildDriverEditField(
                  controller: nameCtrl,
                  label: 'Full Legal Name',
                  hint: 'e.g. Ranjith Subha Udhasanak',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),

                // Phone Number
                _buildDriverEditField(
                  controller: phoneCtrl,
                  label: 'Phone Number',
                  hint: 'e.g. 077 123 4567',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                ),
                const SizedBox(height: 12),

                // License Number
                _buildDriverEditField(
                  controller: licenseCtrl,
                  label: 'Driving License Number',
                  hint: 'e.g. B-8492019',
                  prefixIcon: Icons.badge_outlined,
                ),
                const SizedBox(height: 12),

                // Vehicle Type & Plate Number
                Row(
                  children: [
                    Expanded(
                      child: _buildDriverEditField(
                        controller: vehicleCtrl,
                        label: 'Vehicle Type',
                        hint: 'e.g. Refrigerated Van',
                        prefixIcon: Icons.local_shipping_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDriverEditField(
                        controller: plateCtrl,
                        label: 'Plate Number',
                        hint: 'e.g. NC-4982',
                        prefixIcon: Icons.pin_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Cargo Capacity
                _buildDriverEditField(
                  controller: capacityCtrl,
                  label: 'Cargo Capacity',
                  hint: 'e.g. 1,200 kg',
                  prefixIcon: Icons.inventory_2_outlined,
                ),
                const SizedBox(height: 12),

                // Bank Details
                Row(
                  children: [
                    Expanded(
                      child: _buildDriverEditField(
                        controller: bankCtrl,
                        label: 'Bank Name',
                        hint: 'e.g. Commercial Bank',
                        prefixIcon: Icons.account_balance_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDriverEditField(
                        controller: accountCtrl,
                        label: 'Account Number',
                        hint: 'e.g. 8004 1293',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.credit_card_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Save Changes Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      final newName = nameCtrl.text.trim();
                      final newPhone = phoneCtrl.text.trim();
                      final newLicense = licenseCtrl.text.trim();
                      final newVehicle = vehicleCtrl.text.trim();
                      final newPlate = plateCtrl.text.trim();
                      final newCapacity = capacityCtrl.text.trim();
                      final newBank = bankCtrl.text.trim();
                      final newAccount = accountCtrl.text.trim();

                      Navigator.pop(ctx);

                      await DriverProfileManager.instance.updateProfile(
                        fullName: newName.isNotEmpty ? newName : null,
                        mobileNumber: newPhone.isNotEmpty ? newPhone : null,
                        licenseNumber: newLicense.isNotEmpty ? newLicense : null,
                        vehicleType: newVehicle.isNotEmpty ? newVehicle : null,
                        plateNumber: newPlate.isNotEmpty ? newPlate : null,
                        cargoCapacity: newCapacity.isNotEmpty ? newCapacity : null,
                        bankName: newBank.isNotEmpty ? newBank : null,
                        accountNumber: newAccount.isNotEmpty ? newAccount : null,
                      );

                      if (mounted) {
                        setState(() {
                          if (newName.isNotEmpty) _accountHolder = newName;
                          if (newPhone.isNotEmpty) _phone = newPhone;
                          if (newVehicle.isNotEmpty) _vehicleType = newVehicle;
                          if (newPlate.isNotEmpty) _plateNumber = newPlate;
                          if (newCapacity.isNotEmpty) _cargoCapacity = newCapacity;
                          if (newLicense.isNotEmpty) _licenseNumber = newLicense;
                          if (newBank.isNotEmpty) _bankName = newBank;
                          if (newAccount.isNotEmpty) {
                            _accountNumber = newAccount;
                            final last4 = newAccount.length >= 4
                                ? newAccount.substring(newAccount.length - 4)
                                : newAccount;
                            _maskedAccount = '$_bankName (****$last4)';
                          }
                        });
                      }

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Profile details updated successfully!'.trAuto(context)),
                          backgroundColor: const Color(0xFF047857),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF047857),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save Changes'.trAuto(context),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverEditField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.trAuto(context),
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: const Color(0xFF047857)) : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF047857), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // ⭐ EARNINGS & BANK ACCOUNT COMPLETE SYSTEM MODAL SHEET
  // ===========================================================================
  void _showEarningsAndBankSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.90,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Drag handle
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 46,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Sheet Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Earnings & Bank Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Payouts, Bank Linking & COD Settlement',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFFF1F5F9)),

                // Scrollable Body with 3 Distinct Cards
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 1. LINKED BANK ACCOUNT CARD (Commercial Bank LK) ─
                        _buildBankCardSection(ctx, setModalState),
                        const SizedBox(height: 18),

                        // ── 2. EARNINGS & WITHDRAW / AUTO-DEPOSIT ───────────
                        _buildPayoutWithdrawalSection(ctx, setModalState),
                        const SizedBox(height: 18),

                        // ── 3. CASH ON DELIVERY (COD) & SETTLEMENT BALANCE ──
                        _buildCodSettlementSection(ctx, setModalState),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 1. Linked Bank Account Section (Dark Navy Credit Card Style)
  Widget _buildBankCardSection(BuildContext context, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LINKED BANK ACCOUNT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF94A3B8),
                letterSpacing: 0.6,
              ),
            ),
            InkWell(
              onTap: () => _showUpdateBankDialog(context, setModalState),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      size: 13,
                      color: Color(0xFF047857),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Update Account',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Premium Dark Bank Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF064E3B), // Forest emerald
                Color(0xFF065F46),
                Color(0xFF047857),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF064E3B).withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bank Name & Verification Chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _bankName,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFFA7F3D0),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFA7F3D0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Masked Account Number
              Text(
                '•••• •••• •••• ${_accountNumber.length >= 4 ? _accountNumber.substring(_accountNumber.length - 4) : _accountNumber}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Account Holder & Branch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACCOUNT HOLDER',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA7F3D0),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        _accountHolder,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'BRANCH',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA7F3D0),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        _branch,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Earnings & Withdrawal / Auto-Deposit Section
  Widget _buildPayoutWithdrawalSection(BuildContext context, StateSetter setModalState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AVAILABLE WITHDRAWABLE BALANCE',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Cleared',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF047857),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Balance Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Rs. ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                _availablePayoutBalance.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF065F46),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Earnings Breakdown Pill Items
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildBreakdownRow('🚚 Trip Transit Payouts', 'Rs. ${_tripPayouts.toStringAsFixed(2)}'),
                const SizedBox(height: 6),
                _buildBreakdownRow('💝 Direct Buyer Tips', 'Rs. ${_directTips.toStringAsFixed(2)}'),
                const SizedBox(height: 6),
                _buildBreakdownRow('⚡ Highland & On-Time Bonuses', 'Rs. ${_highlandBonuses.toStringAsFixed(2)}'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Primary Button: Withdraw Funds to Bank
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () => _showWithdrawDialog(context, setModalState),
              icon: const Icon(Icons.arrow_upward_rounded, size: 18),
              label: Text(
                'Withdraw Funds to $_bankName',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF064E3B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),

          // Auto-Deposit Frequency Settings Row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.autorenew_rounded,
                  color: Color(0xFF047857),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-Deposit Schedule',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      _autoDepositFrequency,
                      style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _autoDepositEnabled,
                activeTrackColor: const Color(0xFFA7F3D0),
                activeThumbColor: const Color(0xFF064E3B),
                onChanged: (val) {
                  setModalState(() {
                    _autoDepositEnabled = val;
                  });
                  setState(() {
                    _autoDepositEnabled = val;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        val ? 'Auto-Deposit enabled for weekly payout.' : 'Auto-Deposit paused.',
                        style: TextStyle(),
                      ),
                      backgroundColor: const Color(0xFF064E3B),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Cash on Delivery (COD) & Settlement Section
  Widget _buildCodSettlementSection(BuildContext context, StateSetter setModalState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Soft warm amber tint
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.payments_outlined,
                    color: Color(0xFFD97706),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'CASH ON DELIVERY (COD) SETTLEMENT',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF92400E),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE68A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Settlement Breakdown
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              children: [
                _buildBreakdownRow(
                  '💵 COD Cash in Hand (from Buyers)',
                  'Rs. ${_codCollectedCash.toStringAsFixed(2)}',
                  valueBold: true,
                ),
                const SizedBox(height: 6),
                _buildBreakdownRow(
                  '🛡️ Driver Transit Fees Offset',
                  '- Rs. ${_driverCommissionOffset.toStringAsFixed(2)}',
                  valueColor: const Color(0xFF047857),
                ),
                const Divider(height: 14, color: Color(0xFFF1F5F9)),
                _buildBreakdownRow(
                  'Net Balance to Remit Platform',
                  'Rs. ${_netCodSettlementBalance.toStringAsFixed(2)}',
                  valueBold: true,
                  valueColor: const Color(0xFFB45309),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Explanatory note
          Text(
            '💡 This net balance is automatically deducted from your upcoming weekly bank deposit, or you can remit now via online banking.',
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF78350F),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Settle Balance Button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: () => _showSettleBalanceDialog(context, setModalState),
              icon: const Icon(Icons.handshake_outlined, size: 16, color: Color(0xFFB45309)),
              label: Text(
                'Settle COD Balance via Bank / EzCash',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB45309),
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFF59E0B)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String value, {
    bool valueBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF475569),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // ── Dialog: Update Bank Account ────────────────────────────────────────────
  void _showUpdateBankDialog(BuildContext context, StateSetter parentSetState) {
    final bankCtrl = TextEditingController(text: _bankName);
    final accountCtrl = TextEditingController(text: _accountNumber);
    final holderCtrl = TextEditingController(text: _accountHolder);
    final branchCtrl = TextEditingController(text: _branch);

    showDialog(
      context: context,
      builder: (dlgContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFEDFAF3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance, color: Color(0xFF064E3B), size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Update Bank Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextInput('Bank Name', bankCtrl, 'Commercial Bank, BOC, etc.'),
              const SizedBox(height: 10),
              _buildTextInput('Account Number', accountCtrl, '12-digit account number'),
              const SizedBox(height: 10),
              _buildTextInput('Account Holder Name', holderCtrl, 'Full Name as in Passbook'),
              const SizedBox(height: 10),
              _buildTextInput('Branch Name & Code', branchCtrl, 'Branch location'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (accountCtrl.text.trim().isNotEmpty) {
                final newAcc = accountCtrl.text.trim();
                final last4 = newAcc.length >= 4 ? newAcc.substring(newAcc.length - 4) : newAcc;
                final newBank = bankCtrl.text.trim();

                parentSetState(() {
                  _bankName = newBank;
                  _accountNumber = newAcc;
                  _accountHolder = holderCtrl.text.trim();
                  _branch = branchCtrl.text.trim();
                  _maskedAccount = '$newBank (****$last4)';
                });

                setState(() {
                  _bankName = newBank;
                  _accountNumber = newAcc;
                  _accountHolder = holderCtrl.text.trim();
                  _branch = branchCtrl.text.trim();
                  _maskedAccount = '$newBank (****$last4)';
                });

                Navigator.pop(dlgContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Bank account updated and verified successfully!',
                      style: TextStyle(),
                    ),
                    backgroundColor: const Color(0xFF064E3B),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF064E3B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save & Verify'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Dialog: Withdraw Funds ─────────────────────────────────────────────────
  void _showWithdrawDialog(BuildContext context, StateSetter parentSetState) {
    final amountCtrl = TextEditingController(text: _availablePayoutBalance.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (dlgContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Withdraw to Bank',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer payout earnings to your linked bank account:',
              style: TextStyle(fontSize: 12, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance, size: 16, color: Color(0xFF064E3B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_bankName (****${_accountNumber.length >= 4 ? _accountNumber.substring(_accountNumber.length - 4) : _accountNumber})',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Enter Amount (LKR):',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                prefixText: 'Rs. ',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Instant CEFT / SLIPS Transfer • Fee: Rs. 0.00',
              style: TextStyle(fontSize: 11, color: const Color(0xFF047857)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgContext),
            child: Text('Cancel', style: TextStyle()),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(amountCtrl.text.trim()) ?? 0;
              if (val > 0 && val <= _availablePayoutBalance) {
                parentSetState(() {
                  _availablePayoutBalance -= val;
                });
                setState(() {
                  _availablePayoutBalance -= val;
                });
                Navigator.pop(dlgContext);
                _showWithdrawSuccessDialog(context, val);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF064E3B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm Transfer'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawSuccessDialog(BuildContext context, double amount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF047857), size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              'Transfer Initiated!',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Rs. ${amount.toStringAsFixed(2)} has been successfully dispatched to your $_bankName account.\nReference: #WT-89412',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF064E3B),
                foregroundColor: Colors.white,
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialog: Settle COD Balance ─────────────────────────────────────────────
  void _showSettleBalanceDialog(BuildContext context, StateSetter parentSetState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Settle COD Balance',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Outstanding Net COD to remit:',
              style: TextStyle(fontSize: 12, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 4),
            Text(
              'Rs. ${_netCodSettlementBalance.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFB45309),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select remittance channel:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildRemitOption('$_bankName Direct Transfer / CEFT', Icons.account_balance),
            const SizedBox(height: 6),
            _buildRemitOption('EzCash / mCash Merchant Code 4492', Icons.phone_android),
            const SizedBox(height: 6),
            _buildRemitOption('Auto-Offset from Next Monday Payout', Icons.autorenew),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: TextStyle()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Remittance request logged. Verification pending confirmation.',
                    style: TextStyle(),
                  ),
                  backgroundColor: const Color(0xFF064E3B),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF064E3B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Proceed Remit'),
          ),
        ],
      ),
    );
  }

  Widget _buildRemitOption(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF064E3B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ── Supporting Sheets ──────────────────────────────────────────────────────

  void _showVehicleDocumentsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Vehicle Documents & SL-Transport',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            _buildDocRow('Driver License Number', _licenseNumber.isNotEmpty ? '$_licenseNumber ✓' : 'B-8492019 ✓'),
            _buildDocRow('Registered Vehicle', '$_vehicleType ($_plateNumber) ✓'),
            _buildDocRow('Revenue License (WP)', 'Valid until Nov 2025 ✓'),
            _buildDocRow('Commercial Goods Transit Permit', 'Approved & Active ✓'),
            _buildDocRow('Cold Chain Agro Sanitation Pass', 'Grade A Certified ✓'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocRow(String title, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: const Color(0xFF334155))),
          Text(status, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF059669))),
        ],
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          Widget buildLanguageOption({
            required String id,
            required String flag,
            required String title,
            required String nativeName,
            required String subtitle,
          }) {
            final isSelected = _selectedLanguage == title || _selectedLanguage == nativeName;
            return InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                final appLang = id == 'si'
                    ? AppLanguage.sinhala
                    : id == 'ta'
                        ? AppLanguage.tamil
                        : AppLanguage.english;
                context.read<AppSettings>().setLanguage(appLang);
                setSheetState(() {
                  _selectedLanguage = title;
                });
                setState(() {
                  _selectedLanguage = title;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            id == 'si'
                                ? 'භාෂාව සිංහල (Sinhala) ලෙස සාර්ථකව තෝරාගන්නා ලදී'
                                : id == 'ta'
                                    ? 'மொழி தமிழ் (Tamil) என வெற்றிகரமாக தேர்ந்தெடுக்கப்பட்டது'
                                    : 'Language set to English successfully',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF064E3B),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Flag / Code badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFD1FAE5) : const Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          flag,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? const Color(0xFF065F46) : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Language titles
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                nativeName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '($title)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? const Color(0xFF059669) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Radio indicator
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? const Color(0xFF059669) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF059669) : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Center(
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.translate_rounded,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Language / භාෂාව තෝරන්න',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Choose app interface language / மொழியைத் தேர்வுசெய்க',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                buildLanguageOption(
                  id: 'en',
                  flag: 'EN',
                  title: 'English',
                  nativeName: 'English',
                  subtitle: 'International English interface',
                ),
                buildLanguageOption(
                  id: 'si',
                  flag: 'සිං',
                  title: 'Sinhala',
                  nativeName: 'සිංහල',
                  subtitle: 'ශ්‍රී ලංකා දේශීය සිංහල මාධ්‍යය',
                ),
                buildLanguageOption(
                  id: 'ta',
                  flag: 'த',
                  title: 'Tamil',
                  nativeName: 'தமிழ்',
                  subtitle: 'இலங்கை தமிழ் மொழி இடைமுகம்',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.78,
            ),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top drag pill
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header Row
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.notifications_active_outlined,
                          color: Color(0xFF047857),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account & Highway Alerts',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Payout receipts, ratings & safety advisories',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_hasUnreadNotifications)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '2 NEW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Notifications List
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildProfileAlertTile(
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: const Color(0xFF059669),
                        iconBg: const Color(0xFFD1FAE5),
                        title: 'Direct Bank Deposit Credited',
                        message: 'Trip payout of Rs. 1,450 for Order #FH-8841 credited to Commercial Bank account (•••• 4198).',
                        time: '15m ago',
                        badge: 'Payout Settled',
                        badgeColor: const Color(0xFF047857),
                        badgeBg: const Color(0xFFDCFCE7),
                        isUnread: true,
                        onTap: () {
                          Navigator.pop(ctx);
                        },
                      ),
                      _buildProfileAlertTile(
                        icon: Icons.star_rounded,
                        iconColor: const Color(0xFFD97706),
                        iconBg: const Color(0xFFFEF3C7),
                        title: 'Driver Excellence Bonus (+Rs. 500)',
                        message: 'Congratulations! 5.0 ★ rating and 100% on-time delivery maintained across 12 consecutive orders.',
                        time: '1h ago',
                        badge: 'Top Tier Bonus',
                        badgeColor: const Color(0xFFB45309),
                        badgeBg: const Color(0xFFFEF3C7),
                        isUnread: true,
                        onTap: () {
                          Navigator.pop(ctx);
                        },
                      ),
                      _buildProfileAlertTile(
                        icon: Icons.cloud_sync_rounded,
                        iconColor: const Color(0xFF0284C7),
                        iconBg: const Color(0xFFE0F2FE),
                        title: 'Highland Weather Advisory',
                        message: 'A7 Nuwara Eliya highway is clear of landslides. Evening mist anticipated near Hakgala curves after 5:30 PM.',
                        time: '3h ago',
                        badge: 'Road Safety',
                        badgeColor: const Color(0xFF0369A1),
                        badgeBg: const Color(0xFFE0F2FE),
                        isUnread: false,
                        onTap: () {
                          Navigator.pop(ctx);
                        },
                      ),
                      _buildProfileAlertTile(
                        icon: Icons.build_circle_outlined,
                        iconColor: const Color(0xFF64748B),
                        iconBg: const Color(0xFFF1F5F9),
                        title: 'Reefer Chiller Calibration Due',
                        message: 'Routine van temperature calibration recommended in 12 days. Current compressor integrity is 100%.',
                        time: 'Yesterday',
                        badge: 'Fleet Maintenance',
                        badgeColor: const Color(0xFF475569),
                        badgeBg: const Color(0xFFF1F5F9),
                        isUnread: false,
                        onTap: () {
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Bottom button: Mark all as read / Dismiss
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasUnreadNotifications = false;
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF064E3B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _hasUnreadNotifications ? 'Mark All as Read' : 'Close Notifications',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileAlertTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String message,
    required String time,
    required String badge,
    required Color badgeColor,
    required Color badgeBg,
    required bool isUnread,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFF9FDFB) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread ? const Color(0xFFA7F3D0) : const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.only(left: 6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF059669),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: const Color(0xFF475569),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: badgeColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRoleSwitchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF047857), size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              'Switch Active Role'.trAuto(context),
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Select which portal mode you wish to switch into:'.trAuto(context),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 18),
            ListTile(
              tileColor: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.eco_rounded, color: Color(0xFF059669)),
              title: Text('Farmer Marketplace Portal'.trAuto(context), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Switched to Farmer Portal'.trAuto(context), style: TextStyle())),
                );
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              tileColor: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF2563EB)),
              title: Text('Buyer / Wholesale Portal'.trAuto(context), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Switched to Buyer Portal'.trAuto(context), style: TextStyle())),
                );
              },
            ),

          ],
        ),
      ),
    );
  }

  void _showSignOutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out of Driver Hub?'.trAuto(context),
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          'You will be put offline and will not receive real-time transit dispatch offers until you sign back in.'.trAuto(context),
          style: TextStyle(fontSize: 12.5, color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'.trAuto(context), style: TextStyle()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await const AuthService().signOut();
              } catch (_) {}
              if (!context.mounted) return;
              await context.settings.clearRole();
              if (context.mounted) {
                context.go(AppRoutes.roleSelection);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: Text('Sign Out'.trAuto(context)),
          ),
        ],
      ),
    );
  }

  void _showDriverChatSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent_rounded, color: Color(0xFF047857), size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              'Driver Support & Dispatch Chat'.trAuto(context),
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Instant chat channel with Agri-Dispatch and Corridor Support team.'.trAuto(context),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DriverChatScreen(
                        driverId: widget.driverId,
                        driverName: widget.driverName,
                        vehicleType: widget.vehicleType,
                        plateNumber: widget.plateNumber,
                        bankName: widget.bankName,
                        accountNumber: widget.accountNumber,
                        cargoCapacity: widget.cargoCapacity,
                        licenseNumber: widget.licenseNumber,
                        initialThreadId: 'dispatch',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF064E3B),
                  foregroundColor: Colors.white,
                ),
                child: Text('Start Chat with Support'.trAuto(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

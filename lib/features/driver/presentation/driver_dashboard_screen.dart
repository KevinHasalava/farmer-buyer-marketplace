import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'deliveries_screen.dart';
import 'delivery_details_screen.dart';
import 'driver_chat_screen.dart';
import 'driver_profile_photo_data.dart';
import 'driver_profile_screen.dart';
import 'pickup_navigation_map_data.dart';
import '../services/driver_firestore_service.dart';
import '../services/driver_profile_manager.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/premium/premium_widgets.dart';

/// Pixel-perfect Driver Dashboard Screen matching the Farm2Home Driver reference design.
class DriverDashboardScreen extends StatefulWidget {
  final String? driverId;
  final String? driverName;
  final String? vehicleType;
  final String? plateNumber;
  final String? bankName;
  final String? accountNumber;
  final String? cargoCapacity;
  final String? licenseNumber;

  const DriverDashboardScreen({
    super.key,
    this.driverId,
    this.driverName,
    this.vehicleType,
    this.plateNumber,
    this.bankName,
    this.accountNumber,
    this.cargoCapacity,
    this.licenseNumber,
  });

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedNavIndex = 0;
  bool _isOnDuty = true;
  late AnimationController _transitPulseController;
  late Animation<double> _transitPulseAnimation;

  // Firestore READ (R) state for Driver Dashboard
  String? _currentDriverId;
  String _driverName = 'Ranjith';
  String _vehicleType = 'Farm Van';
  String _plateNumber = 'NC-4982';
  String _vehicleInfo = 'Farm Van NC-4982 • Active Shift';
  String _bankName = 'Commercial Bank of Ceylon';
  String _accountNumber = '8004 1293 4198';
  String _cargoCapacity = '1,200 kg';
  String _licenseNumber = 'B-8492019';
  int _scheduledDeliveries = 6;
  int _deliveredToday = 4;
  double _netEarnings = 7850.0;
  String _activeOrderId = '#FH-8841';
  String _activeFarmerName = 'Farmer Bandar';
  String _activeFarmLocation = 'Hakgala Organic Farm';
  double _activeEstPayout = 1450.0;
  String _activeCargoItem = '5 kg Fresh Carrots & Leeks';
  String _activeCrate = 'Crate #C';
  String _activePickupLocation = 'Upper Division Gate B, Hakgala Rd';
  bool _isLoadingDashboard = false;
  bool _hasUnreadNotifications = true;

  @override
  void initState() {
    super.initState();
    _transitPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _transitPulseAnimation = CurvedAnimation(
      parent: _transitPulseController,
      curve: Curves.easeOut,
    );

    DriverProfileManager.instance.addListener(_onDriverProfileChanged);
    _syncFromProfileManager();

    if (widget.driverName != null && widget.driverName!.trim().isNotEmpty) {
      _driverName = widget.driverName!.trim();
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
    if (widget.plateNumber != null && widget.plateNumber!.trim().isNotEmpty) {
      _vehicleInfo = '$_vehicleType $_plateNumber • Active Shift';
    }
    _loadDashboardData();
  }

  void _onDriverProfileChanged() {
    if (mounted) {
      _syncFromProfileManager();
    }
  }

  void _syncFromProfileManager() {
    final d = DriverProfileManager.instance.driver;
    if (d.fullName.isNotEmpty) {
      setState(() {
        _driverName = d.fullName;
        if (d.vehicleType.isNotEmpty) _vehicleType = d.vehicleType;
        if (d.plateNumber.isNotEmpty) _plateNumber = d.plateNumber;
        _vehicleInfo = '$_vehicleType $_plateNumber • Active Shift';
        if (d.bankName.isNotEmpty) _bankName = d.bankName;
        if (d.accountNumber.isNotEmpty) _accountNumber = d.accountNumber;
        if (d.cargoCapacity.isNotEmpty) _cargoCapacity = d.cargoCapacity;
        if (d.licenseNumber.isNotEmpty) _licenseNumber = d.licenseNumber;
      });
    }
  }

  /// READ (R) operation: Fetch driver document, shift stats, and active order from Cloud Firestore
  Future<void> _loadDashboardData() async {
    setState(() => _isLoadingDashboard = true);
    try {
      final driver = await DriverFirestoreService().getDashboardDriver(widget.driverId);
      if (driver != null && mounted) {
        setState(() {
          _currentDriverId = driver.id;
          _isOnDuty = driver.isOnDuty;
          if (driver.fullName.isNotEmpty) _driverName = driver.fullName;
          if (driver.vehicleType.isNotEmpty) _vehicleType = driver.vehicleType;
          if (driver.plateNumber.isNotEmpty) {
            _plateNumber = driver.plateNumber;
            _vehicleInfo = '${driver.vehicleType} ${driver.plateNumber} • Active Shift';
          }
          if (driver.bankName.isNotEmpty) _bankName = driver.bankName;
          if (driver.accountNumber.isNotEmpty) _accountNumber = driver.accountNumber;
          if (driver.cargoCapacity.isNotEmpty) _cargoCapacity = driver.cargoCapacity;
          if (driver.licenseNumber.isNotEmpty) _licenseNumber = driver.licenseNumber;
          _scheduledDeliveries = driver.scheduledDeliveries;
          _deliveredToday = driver.deliveredToday;
          _netEarnings = driver.netEarnings;
          _activeOrderId = driver.activeOrderId;
          _activeFarmerName = driver.activeFarmerName;
          _activeFarmLocation = driver.activeFarmLocation;
          _activeEstPayout = driver.activeEstPayout;
          _activeCargoItem = driver.activeCargoItem;
          _activeCrate = driver.activeCrate;
          _activePickupLocation = driver.activePickupLocation;
        });
      }
    } catch (e) {
      debugPrint('Error loading driver dashboard from Firestore: $e');
    } finally {
      if (mounted) setState(() => _isLoadingDashboard = false);
    }
  }

  String _formatEarnings(double val) {
    final intVal = val.toInt();
    final str = intVal.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  }

  @override
  void dispose() {
    DriverProfileManager.instance.removeListener(_onDriverProfileChanged);
    _transitPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(),

            // Main Scrollable Dashboard Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting & On-Duty Section
                    _buildGreetingSection(),
                    const SizedBox(height: 14),

                    // Urgent / Active Order Card
                    _buildUrgentOrderCard(),
                    const SizedBox(height: 18),

                    // Today's Shift Pulse Section
                    _buildShiftPulseSection(),
                    const SizedBox(height: 16),

                    // Corridor Route Map Section
                    _buildCorridorRouteMapCard(),
                    const SizedBox(height: 14),

                    // Cargo Chiller Section
                    _buildCargoChillerCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // ── Top App Bar ────────────────────────────────────────────────────────────
  Widget _buildTopAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // App Logo Icon Box matching Splash Loading Screen
          const AppBrandLogo(size: 38, hasGlow: false),
          const SizedBox(width: 10),

          // Brand Name + DRIVER Badge
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppBrandWordmark(fontSize: 17, isLight: false),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'DRIVER'.trAuto(context),
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF065F46),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Language Switcher Pill
          const AppLanguagePill(),
          const SizedBox(width: 6),

          // Notification Bell with Badge
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              _showNotificationDialog();
            },
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF475569),
                    size: 24,
                  ),
                ),
                if (_hasUnreadNotifications)
                  Positioned(
                    top: 5,
                    right: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Profile Avatar Icon
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DriverProfileScreen(
                    driverId: _currentDriverId ?? widget.driverId,
                    driverName: _driverName,
                    vehicleType: _vehicleType,
                    plateNumber: _plateNumber,
                    bankName: _bankName,
                    accountNumber: _accountNumber,
                    cargoCapacity: _cargoCapacity,
                    licenseNumber: _licenseNumber,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFA7F3D0),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.memory(
                  kDriverProfilePhotoBytes,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDriverFirstName() {
    final name = _driverName.trim();
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      return parts.first;
    }
    return 'Ranjith';
  }

  // ── Greeting & Shift Status ────────────────────────────────────────────────
  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Subtitle label
            Expanded(
              child: Text(
                context.tr.highlandAgriCorridor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.fontStyle(
                  context.currentLanguage,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // On Duty Status Pill (Interactive toggle - UPDATE - U)
            GestureDetector(
              onTap: () async {
                HapticFeedback.mediumImpact();
                final newDuty = !_isOnDuty;
                setState(() {
                  _isOnDuty = newDuty;
                });

                // UPDATE (U) operation: Live update in Cloud Firestore
                final targetId = _currentDriverId ?? widget.driverId;
                if (targetId != null && targetId.isNotEmpty) {
                  try {
                    await DriverFirestoreService().updateDutyStatus(targetId, newDuty);
                  } catch (e) {
                    debugPrint('Error updating duty status in Firestore: $e');
                  }
                }

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      newDuty ? context.tr.dutyOn : context.tr.dutyOff,
                      style: AppTheme.fontStyle(context.currentLanguage),
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor:
                        newDuty ? const Color(0xFF065F46) : const Color(0xFF475569),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isOnDuty ? const Color(0xFFF0FDF4) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isOnDuty ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _isOnDuty ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isOnDuty ? '• ${context.tr.online}' : '• ${context.tr.offline}',
                      style: AppTheme.fontStyle(
                        context.currentLanguage,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _isOnDuty ? const Color(0xFF065F46) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Main Greeting
        Text(
          '${context.tr.hello}, ${_getDriverFirstName()}',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 3),

        // Vehicle & Active Shift line
        Row(
          children: [
            const Icon(
              Icons.badge_outlined,
              size: 15,
              color: Color(0xFF64748B),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                _vehicleInfo.trAuto(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Urgent / Active Pickup Order Card ───────────────────────────────────────
  Widget _buildUrgentOrderCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDFAF3),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFA7F3D0).withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF047857).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Urgent Pill + Order ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Urgent Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text(
                      context.tr.urgentPickup,
                      style: AppTheme.fontStyle(
                        context.currentLanguage,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),

              // Order Number
              Text(
                _activeOrderId,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Farmer Info & Payout Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // White rounded icon box
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_shipping_rounded,
                    color: Color(0xFF059669),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Farmer Name and distance
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _activeFarmerName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                        ),
                        children: [
                          TextSpan(text: '${_activeFarmLocation.trAuto(context)} • '),
                          TextSpan(
                            text: '2.4 km away'.trAuto(context),
                            style: const TextStyle(
                              color: Color(0xFF047857),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Est. Payout
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Est. Payout'.trAuto(context),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 1),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Rs. \n',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF065F46),
                            height: 1.0,
                          ),
                        ),
                        TextSpan(
                          text: _activeEstPayout.toInt().toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF064E3B),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Inner White Card: Pickup & Dropoff Location + Cargo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Pickup Location
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.store_mall_directory_outlined,
                        size: 16,
                        color: Color(0xFF059669),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PICKUP LOCATION'.trAuto(context),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _activePickupLocation.trAuto(context),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Dropoff Location
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DROPOFF BUYER'.trAuto(context),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Chaminda Perera • Havelock Rd, Colombo'.trAuto(context),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Cargo info + Crate Tag
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🥕', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 6),
                          Text(
                            _activeCargoItem.trAuto(context),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                        ),
                        child: Text(
                          _activeCrate.trAuto(context),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Primary Button: Start Pickup Route
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DeliveryDetailsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF064E3B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.tr.startRoute,
                    style: AppTheme.fontStyle(
                      context.currentLanguage,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Secondary Action Buttons Row
          Row(
            children: [
              // View Details Button
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DeliveryDetailsScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E293B),
                      side: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: Color(0xFF475569),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          context.tr.viewDetails,
                          style: AppTheme.fontStyle(
                            context.currentLanguage,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Call Farmer Button
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showCallFarmerModal();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF065F46),
                      side: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: Color(0xFF065F46),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${context.tr.call} ${context.tr.farmer}',
                          style: AppTheme.fontStyle(
                            context.currentLanguage,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF065F46),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Today's Shift Pulse Section ───────────────────────────────────────────
  Widget _buildShiftPulseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Shift Pulse".trAuto(context),
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              '66% Completed'.trAuto(context),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Two Stat Cards Row
        Row(
          children: [
            // Card 1: 6 Scheduled
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon + Badge Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.local_shipping_outlined,
                              color: Color(0xFF059669),
                              size: 18,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+2 peak'.trAuto(context),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Number
                    Text(
                      '$_scheduledDeliveries ${'Scheduled'.trAuto(context)}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Subtitle
                    Text(
                      '$_deliveredToday ${'Delivered Today'.trAuto(context)}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Card 2: Rs. 7,850 Net Earnings
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon + Badge Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.payments_outlined,
                              color: Color(0xFF059669),
                              size: 18,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+1.2k tips'.trAuto(context),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Number
                    Text(
                      'Rs. ${_formatEarnings(_netEarnings)}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF059669),
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Subtitle
                    Text(
                      context.tr.todaysEarnings,
                      style: TextStyle(
                        fontSize: 11.5,
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
      ],
    );
  }

  // ── Corridor Route Map Section ─────────────────────────────────────────────
  Widget _buildCorridorRouteMapCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Header Row: Title + A7 Highway Clear Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.map_outlined,
                    size: 18,
                    color: Color(0xFF059669),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Corridor Route Map'.trAuto(context),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7EF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'A7 Highway Clear'.trAuto(context),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Map Visual Graphic Container with Real Map & Live Transit Highlight
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 125,
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Vehicle position coordinates: X ~ 33.3%, Y ~ 61.1%
                  final vehicleCenterX = constraints.maxWidth * 0.333;
                  final vehicleCenterY = constraints.maxHeight * 0.611;

                  return Stack(
                    children: [
                      // Real 2x High-Resolution Central Highlands Map
                      Positioned.fill(
                        child: Image.memory(
                          kPickupNavigationMapBytes,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),

                      // Live Pulse Radar Wave on the vehicle
                      AnimatedBuilder(
                        animation: _transitPulseAnimation,
                        builder: (context, child) {
                          final waveRadius =
                              12 + (_transitPulseAnimation.value * 18);
                          final waveAlpha = (1.0 - _transitPulseAnimation.value)
                              .clamp(0.0, 1.0);

                          return Positioned(
                            left: vehicleCenterX - waveRadius,
                            top: vehicleCenterY - waveRadius,
                            child: IgnorePointer(
                              child: Container(
                                width: waveRadius * 2,
                                height: waveRadius * 2,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF059669)
                                        .withValues(alpha: waveAlpha * 0.8),
                                    width: 2,
                                  ),
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: waveAlpha * 0.2),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Live Transit Status Pill: Highlighted at center-bottom
                      Positioned(
                        bottom: 8,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F3627)
                                .withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF34D399)
                                  .withValues(alpha: 0.4),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF34D399),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Live Transit: 38 km/h'.trAuto(context),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Waypoint Pill: Top Right
                      Positioned(
                        top: 8,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Hakgala Corridor'.trAuto(context),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ── Cargo Chiller Status Card ──────────────────────────────────────────────
  Widget _buildCargoChillerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.tune_rounded,
                color: Color(0xFF059669),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cargo Chiller: 12°C'.trAuto(context),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Target 10°C - 14°C • Veg Safe'.trAuto(context),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Optimal Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7EF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
            ),
            child: Text(
              'Optimal'.trAuto(context),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF059669),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Navigation Bar ──────────────────────────────────────────────────
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.local_shipping,
            label: context.tr.navHome,
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.shopping_bag_outlined,
            label: context.tr.navDeliveries,
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.chat_bubble_outline_rounded,
            label: context.tr.navChat,
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.person_outline_rounded,
            label: context.tr.navProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedNavIndex == index;
    const activeColor = Color(0xFF065F46);
    const inactiveColor = Color(0xFF94A3B8);

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        if (index == 1) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const DeliveriesScreen(),
            ),
          );
          return;
        }
        if (index == 2) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DriverChatScreen(
                driverId: _currentDriverId ?? widget.driverId,
                driverName: _driverName,
                vehicleType: _vehicleType,
                plateNumber: _plateNumber,
                bankName: _bankName,
                accountNumber: _accountNumber,
                cargoCapacity: _cargoCapacity,
                licenseNumber: _licenseNumber,
              ),
            ),
          );
          return;
        }
        if (index == 3) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DriverProfileScreen(
                driverId: _currentDriverId ?? widget.driverId,
                driverName: _driverName,
                vehicleType: _vehicleType,
                plateNumber: _plateNumber,
                bankName: _bankName,
                accountNumber: _accountNumber,
                cargoCapacity: _cargoCapacity,
                licenseNumber: _licenseNumber,
              ),
            ),
          );
          return;
        }
        setState(() {
          _selectedNavIndex = index;
        });

        if (index != 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$label tab selected',
                style: TextStyle(),
              ),
              duration: const Duration(seconds: 1),
              backgroundColor: const Color(0xFF065F46),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
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
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Interactive Modals & Sheets ────────────────────────────────────────────

  void _showStartRouteModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFEDFAF3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.navigation_rounded,
                color: Color(0xFF065F46),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start Pickup Route'.trAuto(context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Route to Hakgala Organic Farm (2.4 km)\nDispatch order #FH-8841 is marked as active.'.trAuto(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Turn-by-turn navigation started for #FH-8841'.trAuto(context),
                        style: TextStyle(),
                      ),
                      backgroundColor: const Color(0xFF064E3B),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF064E3B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Launch Turn-by-Turn GPS'.trAuto(context),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetailsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Details #FH-8841'.trAuto(context),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Ready for Pickup'.trAuto(context),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF047857),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Farmer Name'.trAuto(context), 'Bandar Menike (Hakgala)'.trAuto(context)),
            _buildDetailRow('Contact Phone'.trAuto(context), '+94 77 458 1920'),
            _buildDetailRow('Pickup Address'.trAuto(context), 'Upper Division Gate B, Hakgala Rd'.trAuto(context)),
            _buildDetailRow('Buyer Name'.trAuto(context), 'Chaminda Perera'.trAuto(context)),
            _buildDetailRow('Dropoff Address'.trAuto(context), 'Havelock Rd, Colombo 05'.trAuto(context)),
            _buildDetailRow('Cargo Breakdown'.trAuto(context), '5 kg Fresh Carrots, Leeks (Crate #C)'.trAuto(context)),
            _buildDetailRow('Storage Requirement'.trAuto(context), 'Chilled (10°C - 14°C)'.trAuto(context)),
            _buildDetailRow('Driver Compensation'.trAuto(context), 'Rs. 1,450.00'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Close'.trAuto(context),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCallFarmerModal() {
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
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F8F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_in_talk_rounded,
                color: Color(0xFF065F46),
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Call Farmer Bandar'.trAuto(context),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '+94 77 458 1920 • Hakgala Organic Farm'.trAuto(context),
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel'.trAuto(context),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Dialing Farmer Bandar (+94 77 458 1920)...'.trAuto(context),
                            style: TextStyle(),
                          ),
                          backgroundColor: const Color(0xFF064E3B),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.call, size: 18),
                    label: Text(
                      'Call Now'.trAuto(context),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF064E3B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDialog() {
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
                            'Shift & Dispatch Alerts'.trAuto(context),
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Active route notifications & vehicle telemetry'.trAuto(context),
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
                          '2 NEW'.trAuto(context),
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
                      _buildNotificationItem(
                        icon: Icons.agriculture_rounded,
                        iconColor: const Color(0xFF059669),
                        iconBg: const Color(0xFFD1FAE5),
                        title: 'Urgent Pickup Ready • #FH-8841'.trAuto(context),
                        message: 'Farmer K. M. Bandara confirmed 3 Crates (Cabbage & Carrots) ready at Upper Division Gate B, Hakgala.'.trAuto(context),
                        time: '5m ago'.trAuto(context),
                        badge: 'Pickup Ready'.trAuto(context),
                        badgeColor: const Color(0xFF047857),
                        badgeBg: const Color(0xFFDCFCE7),
                        isUnread: true,
                        onTap: () {
                          Navigator.pop(ctx);
                        },
                      ),
                      _buildNotificationItem(
                        icon: Icons.local_shipping_rounded,
                        iconColor: const Color(0xFF0284C7),
                        iconBg: const Color(0xFFE0F2FE),
                        title: 'New Assigned Order • #FH-8850'.trAuto(context),
                        message: 'Dispatcher allocated Order #FH-8850: Sunil Perera (Welimada) ➔ Dilani Jayawardena (Dehiwala).'.trAuto(context),
                        time: '15m ago'.trAuto(context),
                        badge: 'Assigned'.trAuto(context),
                        badgeColor: const Color(0xFF0369A1),
                        badgeBg: const Color(0xFFE0F2FE),
                        isUnread: true,
                        onTap: () {
                          Navigator.pop(ctx);
                        },
                      ),
                      _buildNotificationItem(
                        icon: Icons.alt_route_rounded,
                        iconColor: const Color(0xFF059669),
                        iconBg: const Color(0xFFD1FAE5),
                        title: 'A7 & A4 Route Clear Advisory'.trAuto(context),
                        message: 'Central Highlands mountain corridors clear of mist and obstacles. Recommended speed: 40 km/h.'.trAuto(context),
                        time: '30m ago'.trAuto(context),
                        badge: 'Route Clear'.trAuto(context),
                        badgeColor: const Color(0xFF047857),
                        badgeBg: const Color(0xFFDCFCE7),
                        isUnread: false,
                        onTap: () {
                          Navigator.pop(ctx);
                        },
                      ),
                      _buildNotificationItem(
                        icon: Icons.ac_unit_rounded,
                        iconColor: const Color(0xFF2563EB),
                        iconBg: const Color(0xFFDBEAFE),
                        title: 'Cargo Chiller Safe (4.2°C)'.trAuto(context),
                        message: 'Cold chain integrity verified. Vegetable storage area operating at optimal refrigerated range.'.trAuto(context),
                        time: '1h ago'.trAuto(context),
                        badge: 'Chiller Nominal'.trAuto(context),
                        badgeColor: const Color(0xFF1D4ED8),
                        badgeBg: const Color(0xFFDBEAFE),
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
                      (_hasUnreadNotifications ? 'Mark All as Read' : 'Close Notifications').trAuto(context),
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

  Widget _buildNotificationItem({
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
                              badge.trAuto(context),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: badgeColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            time.trAuto(context),
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

  void _showProfileDialog() {
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
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFF064E3B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _driverName,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              '${'Verified Agri-Logistics Driver'.trAuto(ctx)} • ID #${_currentDriverId != null && _currentDriverId!.length >= 4 ? _currentDriverId!.substring(0, 4).toUpperCase() : 'DRV-4091'}',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProfileStat('Rating'.trAuto(ctx), '4.9 ★'),
                  _buildProfileStat('Completed'.trAuto(ctx), '342'),
                  _buildProfileStat('Van Reg'.trAuto(ctx), _plateNumber),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF064E3B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Dismiss'.trAuto(ctx),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}


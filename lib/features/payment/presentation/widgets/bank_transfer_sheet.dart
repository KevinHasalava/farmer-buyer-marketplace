import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/auto_translator.dart';

/// Modal bottom sheet displaying Bank Transfer details, LANKAQR code, and Slip Upload
class BankTransferSheet extends StatefulWidget {
  final String? initialReference;
  final bool initialSlipAttached;

  const BankTransferSheet({
    super.key,
    this.initialReference,
    this.initialSlipAttached = false,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    String? initialReference,
    bool initialSlipAttached = false,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BankTransferSheet(
        initialReference: initialReference,
        initialSlipAttached: initialSlipAttached,
      ),
    );
  }

  @override
  State<BankTransferSheet> createState() => _BankTransferSheetState();
}

class _BankTransferSheetState extends State<BankTransferSheet> {
  static const Color _forestGreen = Color(0xFF0F3D24);
  static const Color _textDark = Color(0xFF0F172A);

  late TextEditingController _refController;
  late bool _slipAttached;

  final String _bankName = 'Commercial Bank PLC';
  final String _accountName = 'FarmTrust Marketplace (Pvt) Ltd';
  final String _accountNumber = '1000 4829 18';
  final String _branch = 'Kollupitiya Super Branch (Code: 018)';

  @override
  void initState() {
    super.initState();
    _refController = TextEditingController(text: widget.initialReference ?? '');
    _slipAttached = widget.initialSlipAttached;
  }

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  void _copyAccountNumber() {
    Clipboard.setData(ClipboardData(text: _accountNumber.replaceAll(' ', '')));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account number copied to clipboard!'.trAuto(context)),
        backgroundColor: _forestGreen,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleSlipAttachment() {
    HapticFeedback.selectionClick();
    setState(() => _slipAttached = !_slipAttached);
    if (_slipAttached && _refController.text.trim().isEmpty) {
      _refController.text = 'SLIP-${DateTime.now().millisecondsSinceEpoch % 100000}';
    }
  }

  void _submit() {
    Navigator.pop(context, {
      'reference': _refController.text.trim(),
      'slipAttached': _slipAttached,
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_rounded, color: Color(0xFF2563EB), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Bank Transfer & LANKAQR'.trAuto(context),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Official Bank Account Card with Copy Button
                  Container(
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
                              _bankName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'OFFICIAL BENEFICIARY',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('Account Name'.trAuto(context), _accountName),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account Number'.trAuto(context),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _accountNumber,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: _forestGreen,
                                    letterSpacing: 1.5,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F3D24),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onPressed: _copyAccountNumber,
                              icon: const Icon(Icons.copy_rounded, size: 14),
                              label: Text('Copy'.trAuto(context), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow('Branch'.trAuto(context), _branch),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Central Bank LANKAQR Visual Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'LANKAQR',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Instant National QR Code'.trAuto(context),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // QR Code Graphic container
                        Container(
                          width: 140,
                          height: 140,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Realistic QR Graphic simulation
                              Icon(Icons.qr_code_2_rounded, size: 120, color: Colors.grey.shade900),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0F3D24),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text('🌾', style: TextStyle(fontSize: 14)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),
                        Text(
                          'Scan with FriMi • FLASH • Genie • Commercial Q+ • iPay'.trAuto(context),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. Bank Slip Upload & Transaction Reference
                  Text(
                    'Verification & Receipt Slip'.trAuto(context),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Reference field
                  TextFormField(
                    controller: _refController,
                    decoration: InputDecoration(
                      labelText: 'Bank Reference / Slip No (Optional)'.trAuto(context),
                      hintText: 'e.g. TXN-829104',
                      prefixIcon: const Icon(Icons.tag_rounded, color: Color(0xFF0F3D24), size: 20),
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
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Interactive Slip Attachment Box
                  GestureDetector(
                    onTap: _toggleSlipAttachment,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _slipAttached ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _slipAttached ? const Color(0xFF15803D) : const Color(0xFFE2E8F0),
                          width: _slipAttached ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: _slipAttached ? const Color(0xFFDCFCE7) : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _slipAttached ? Icons.check_circle_rounded : Icons.receipt_long_rounded,
                              color: _slipAttached ? const Color(0xFF15803D) : Colors.grey.shade700,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _slipAttached
                                      ? 'Deposit Slip Attached (bank_transfer_slip.jpg)'.trAuto(context)
                                      : 'Attach Bank Deposit Slip / Screenshot'.trAuto(context),
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: _slipAttached ? const Color(0xFF14532D) : _textDark,
                                  ),
                                ),
                                Text(
                                  _slipAttached
                                      ? 'Slip ready for automated admin dispatch approval.'.trAuto(context)
                                      : 'Tap to upload screenshot or slip photo'.trAuto(context),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: _slipAttached ? const Color(0xFF166534) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _slipAttached ? Icons.done : Icons.file_upload_outlined,
                            color: _slipAttached ? const Color(0xFF15803D) : const Color(0xFF64748B),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _forestGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _submit,
                      child: Text(
                        'Confirm Bank Transfer Details'.trAuto(context),
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
      ],
    );
  }
}

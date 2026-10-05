import 'package:flutter/material.dart';

class AutoTopUpConfig {
  final bool isEnabled;
  final double threshold;
  final double reloadAmount;

  const AutoTopUpConfig({
    required this.isEnabled,
    this.threshold = 100.0,
    this.reloadAmount = 500.0,
  });
}

class AutoTopUpBottomSheet extends StatefulWidget {
  final bool initialEnabled;
  final double initialThreshold;
  final double initialReloadAmount;

  const AutoTopUpBottomSheet({
    super.key,
    this.initialEnabled = false,
    this.initialThreshold = 100.0,
    this.initialReloadAmount = 500.0,
  });

  static Future<AutoTopUpConfig?> show(
    BuildContext context, {
    bool isEnabled = false,
    double threshold = 100.0,
    double reloadAmount = 500.0,
  }) {
    return showModalBottomSheet<AutoTopUpConfig>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AutoTopUpBottomSheet(
        initialEnabled: isEnabled,
        initialThreshold: threshold,
        initialReloadAmount: reloadAmount,
      ),
    );
  }

  @override
  State<AutoTopUpBottomSheet> createState() => _AutoTopUpBottomSheetState();
}

class _AutoTopUpBottomSheetState extends State<AutoTopUpBottomSheet> {
  late bool _isAutoTopUpEnabled;
  bool _isSaving = false;
  late final TextEditingController _thresholdController;
  late final TextEditingController _reloadAmountController;

  @override
  void initState() {
    super.initState();
    _isAutoTopUpEnabled = widget.initialEnabled;
    _thresholdController = TextEditingController(
      text: widget.initialThreshold.toStringAsFixed(2),
    );
    _reloadAmountController = TextEditingController(
      text: widget.initialReloadAmount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    _reloadAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle pill
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.sync_rounded,
                      color: Color(0xFFD97706),
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto Top-Up Settings',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E242F),
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Automatically reload when balance drops low',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Enable Auto Top-Up Card
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _isAutoTopUpEnabled = !_isAutoTopUpEnabled;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enable Auto Top-Up',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E242F),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isAutoTopUpEnabled
                                ? 'Automatic wallet refills enabled'
                                : 'Manual UPI top-ups only',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Custom Pill Toggle Switch
                    GestureDetector(
                      key: const Key('auto_top_up_toggle'),
                      onTap: () {
                        setState(() {
                          _isAutoTopUpEnabled = !_isAutoTopUpEnabled;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 50,
                        height: 28,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: _isAutoTopUpEnabled
                              ? const Color(0xFF8D9BAE)
                              : const Color(0xFFEBE6F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isAutoTopUpEnabled
                                ? const Color(0xFF8D9BAE)
                                : const Color(0xFF64748B),
                            width: 1.5,
                          ),
                        ),
                        alignment: _isAutoTopUpEnabled
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isAutoTopUpEnabled
                                ? const Color(0xFF182236)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Note Banner appears only when switch is ON
            if (_isAutoTopUpEnabled) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEFCE8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFFDE68A),
                    width: 1,
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Note: Automatic top-up starts as soon as your bank mandate is authorized.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF92400E),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Input 1: Top up when balance falls below (₹)
            TextField(
              controller: _thresholdController,
              enabled: _isAutoTopUpEnabled,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: _isAutoTopUpEnabled
                    ? const Color(0xFF1E242F)
                    : const Color(0xFF475569),
              ),
              decoration: InputDecoration(
                labelText: 'Top up when balance falls below (₹)',
                labelStyle: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _isAutoTopUpEnabled
                      ? const Color(0xFF1E242F)
                      : const Color(0xFF64748B),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: true,
                fillColor: _isAutoTopUpEnabled
                    ? Colors.white
                    : const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _isAutoTopUpEnabled
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF0F1E36),
                    width: 1.5,
                  ),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Icon(
                    Icons.south_west_rounded,
                    color: _isAutoTopUpEnabled
                        ? const Color(0xFF1E242F)
                        : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 46,
                  minHeight: 20,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Input 2: Amount to add automatically (₹)
            TextField(
              controller: _reloadAmountController,
              enabled: _isAutoTopUpEnabled,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: _isAutoTopUpEnabled
                    ? const Color(0xFF1E242F)
                    : const Color(0xFF475569),
              ),
              decoration: InputDecoration(
                labelText: 'Amount to add automatically (₹)',
                labelStyle: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _isAutoTopUpEnabled
                      ? const Color(0xFFD97706)
                      : const Color(0xFF64748B),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: true,
                fillColor: _isAutoTopUpEnabled
                    ? Colors.white
                    : const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _isAutoTopUpEnabled
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFD97706),
                    width: 1.5,
                  ),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Icon(
                    Icons.north_east_rounded,
                    color: _isAutoTopUpEnabled
                        ? const Color(0xFFD97706)
                        : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 46,
                  minHeight: 20,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Bottom Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (_isSaving) return;
                  setState(() {
                    _isSaving = true;
                  });
                  await Future.delayed(const Duration(seconds: 2));
                  if (!context.mounted) return;
                  final parsedThreshold =
                      double.tryParse(_thresholdController.text.trim()) ?? 100.0;
                  final parsedReload =
                      double.tryParse(_reloadAmountController.text.trim()) ?? 500.0;
                  Navigator.pop(
                    context,
                    AutoTopUpConfig(
                      isEnabled: _isAutoTopUpEnabled,
                      threshold: parsedThreshold,
                      reloadAmount: parsedReload,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF131D31),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Auto Top-Up Settings',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

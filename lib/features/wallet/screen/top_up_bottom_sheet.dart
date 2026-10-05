import 'package:flutter/material.dart';
import 'razorpay_checkout_screen.dart';

class TopUpBottomSheet extends StatefulWidget {
  const TopUpBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TopUpBottomSheet(),
    );
  }

  @override
  State<TopUpBottomSheet> createState() => _TopUpBottomSheetState();
}

class _TopUpBottomSheetState extends State<TopUpBottomSheet> {
  int _selectedAmount = 500;
  late final TextEditingController _amountController;
  final List<int> _presetAmounts = const [500, 1000, 1500, 2000];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '500.00');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onSelectPreset(int amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = '$amount.00';
    });
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
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF3F8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add_card_rounded,
                    color: Color(0xFF1E293B),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Up Wallet',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E242F),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Add funds to your Floret balance',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8C95A6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Section Title: Select Amount (₹500 - ₹2,000)
          const Text(
            'Select Amount (₹500 - ₹2,000)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E242F),
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 14),

          // Presets Grid / Rows
          // Row 1: ₹500, ₹1000, ₹1500
          Row(
            children: [
              Expanded(child: _buildPresetButton(_presetAmounts[0])),
              const SizedBox(width: 10),
              Expanded(child: _buildPresetButton(_presetAmounts[1])),
              const SizedBox(width: 10),
              Expanded(child: _buildPresetButton(_presetAmounts[2])),
            ],
          ),
          const SizedBox(height: 10),
          // Row 2: ₹2000
          Row(
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width - 60) / 3,
                child: _buildPresetButton(_presetAmounts[3]),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Custom Amount Box with Cutout/Label Border
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (val) {
              setState(() {
                final parsed = double.tryParse(val)?.toInt();
                if (parsed != null && _presetAmounts.contains(parsed)) {
                  _selectedAmount = parsed;
                } else {
                  _selectedAmount = 0;
                }
              });
            },
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E242F),
            ),
            decoration: InputDecoration(
              labelText: 'Custom Amount (₹)',
              labelStyle: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 8),
                child: Text(
                  '₹',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFCBD5E1),
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFCBD5E1),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF1E293B),
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Bottom Action Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final amountText = _amountController.text.trim();
                final amount = double.tryParse(amountText) ?? 500.00;
                final navigator = Navigator.of(context);
                navigator.pop();
                navigator.push(
                  MaterialPageRoute(
                    settings: const RouteSettings(
                      name: RazorpayCheckoutScreen.routeName,
                    ),
                    builder: (_) => RazorpayCheckoutScreen(amount: amount),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Proceed to Pay ₹${_amountController.text.isNotEmpty ? _amountController.text : "500.00"}',
                style: const TextStyle(
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
    );
  }

  Widget _buildPresetButton(int amount) {
    final isSelected = _selectedAmount == amount;

    return GestureDetector(
      onTap: () => _onSelectPreset(amount),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              '₹$amount',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF1E242F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

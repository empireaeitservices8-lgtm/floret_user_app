import 'package:flutter/material.dart';
import 'wallet_screen.dart';

class RazorpayCheckoutScreen extends StatefulWidget {
  static const String routeName = '/razorpay_checkout';

  final double amount;
  final String orderId;

  const RazorpayCheckoutScreen({
    super.key,
    this.amount = 500.00,
    this.orderId = 'order_u6Fx1O',
  });

  @override
  State<RazorpayCheckoutScreen> createState() => _RazorpayCheckoutScreenState();
}

class _RazorpayCheckoutScreenState extends State<RazorpayCheckoutScreen> {
  int _selectedPaymentMethod = 0; // 0: UPI / QR, 1: Card, 2: NetBanking, 3: Wallets
  int _selectedAppIndex = 0; // 0: Google Pay, 1: PhonePe, 2: Paytm, 3: BHIM UPI
  String _selectedBank = 'HDFC';
  String _selectedWallet = 'Mobikwik';

  late final TextEditingController _vpaController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _cardExpiryController;
  late final TextEditingController _cardCvvController;
  late final TextEditingController _cardHolderController;

  bool _isProcessing = false;

  void _onClosePressed() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: WalletScreen.routeName),
          builder: (_) => const WalletScreen(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _vpaController = TextEditingController(text: 'user@okaxis');
    _cardNumberController =
        TextEditingController(text: '4532 8921 0041 9823');
    _cardExpiryController = TextEditingController(text: '08/28');
    _cardCvvController = TextEditingController(text: '•••');
    _cardHolderController = TextEditingController(text: 'VALUED USER');
  }

  @override
  void dispose() {
    _vpaController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  void _onPayPressed() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment gateway communication
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });

    // Show success dialog
    _showPaymentSuccessDialog();
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dlgContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFE6F8ED),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E242F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${widget.amount.toStringAsFixed(2)} has been successfully credited to your Floret Wallet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dlgContext); // close dialog
                  _onClosePressed(); // return to Floret Wallet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F1E36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedAmount = '₹${widget.amount.toStringAsFixed(2)}';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Browser / Webview Header Bar
            _buildWebviewHeader(context),

            // 2. Razorpay Dark Navy Merchant Header
            _buildMerchantHeader(formattedAmount),

            // 3. Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Payment Method Tabs (UPI/QR, Card, NetBanking, Wallets)
                    _buildPaymentMethodTabs(),

                    // Main Payment Method Details Card (UPI / Card / NetBanking / Wallets)
                    _buildPaymentDetailsCard(),

                    const SizedBox(height: 20),

                    // Action Button: PAY VIA RAZORPAY
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _onPayPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F1E36),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF64748B),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.shield_outlined,
                                      size: 19,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'PAY $formattedAmount VIA RAZORPAY',
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Security & Compliance Footer
                    _buildSecurityFooter(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Webview URL header bar matching design
  Widget _buildWebviewHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            key: const Key('razorpay_cross_icon'),
            onTap: _onClosePressed,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                color: Color(0xFF1E242F),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // URL Capsule
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.lock_rounded,
                    color: Color(0xFF10B981),
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'https://api.razorpay.co...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF64748B),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // SECURE Pill Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1E36),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  color: Color(0xFF10B981),
                  size: 6,
                ),
                SizedBox(width: 4),
                Text(
                  'SECURE',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Razorpay Dark Navy Merchant Header matching screenshot
  Widget _buildMerchantHeader(String formattedAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF071F3D),
            Color(0xFF0D325E),
          ],
        ),
      ),
      child: Row(
        children: [
          // Floret Logo in white square container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.local_florist_rounded,
                color: Color(0xFF10B981),
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Merchant Details
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Floret Technologies',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Wallet Balance Top-Up',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // Price and Order ID
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formattedAmount,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Order ID: ${widget.orderId}',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Payment Method Tabs (UPI/QR, Card, NetBanking, Wallets)
  Widget _buildPaymentMethodTabs() {
    final methods = [
      {'title': 'UPI / QR', 'icon': Icons.qr_code_2_rounded},
      {'title': 'Card', 'icon': Icons.credit_card_outlined},
      {'title': 'NetBanking', 'icon': Icons.account_balance_outlined},
      {'title': 'Wallets', 'icon': Icons.account_balance_wallet_outlined},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: List.generate(methods.length, (index) {
          final isSel = _selectedPaymentMethod == index;
          final method = methods[index];

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPaymentMethod = index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFF0F1E36) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      method['icon'] as IconData,
                      size: 20,
                      color: isSel ? Colors.white : const Color(0xFF64748B),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      method['title'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // 4. Payment Details Card Switcher
  Widget _buildPaymentDetailsCard() {
    switch (_selectedPaymentMethod) {
      case 1:
        return _buildCardView();
      case 2:
        return _buildNetBankingView();
      case 3:
        return _buildWalletsView();
      case 0:
      default:
        return _buildUPIView();
    }
  }

  // 4A. Tab 0: UPI / QR Details Card
  Widget _buildUPIView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instant Pay via Apps Title
          const Text(
            'Instant Pay via Apps',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 14),

          // 4 Apps in a Row
          _buildAppsRow(),

          const SizedBox(height: 18),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 18),

          // Or Enter VPA / UPI ID Title
          const Text(
            'Or Enter VPA / UPI ID',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 12),

          // VPA Input Box
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFCBD5E1),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.alternate_email_rounded,
                  color: Color(0xFF1E242F),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _vpaController,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E242F),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter UPI ID (e.g. user@okaxis)',
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Scan QR info banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F0),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFC6F0DC),
                width: 1,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Scan QR code with any UPI App to complete payment',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF065F46),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4B. Tab 1: Card View matching Image 1
  Widget _buildCardView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dark Credit / Debit Card Graphic
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF151F2E),
                  Color(0xFF0F1723),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Type & Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CREDIT / DEBIT CARD',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    // Gold Card Icon matching Image 1
                    const Icon(
                      Icons.credit_card_rounded,
                      color: Color(0xFFFBBF24),
                      size: 26,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Card Number display
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _cardNumberController.text.isNotEmpty
                        ? _cardNumberController.text
                        : '4532 8921 0041 9823',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.4,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Bottom Row: Card Holder & Expires
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CARD HOLDER',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _cardHolderController.text.isNotEmpty
                              ? _cardHolderController.text
                              : 'VALUED USER',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'EXPIRES',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _cardExpiryController.text.isNotEmpty
                              ? _cardExpiryController.text
                              : '08/28',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 1. Card Number Input Field
          _buildCardInputField(
            label: 'Card Number',
            controller: _cardNumberController,
            prefixIcon: Icons.credit_card_rounded,
          ),

          const SizedBox(height: 16),

          // 2. Expiry & CVV Row
          Row(
            children: [
              Expanded(
                child: _buildCardInputField(
                  label: 'Expiry (MM/YY)',
                  controller: _cardExpiryController,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildCardInputField(
                  label: 'CVV',
                  controller: _cardCvvController,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3. Cardholder Name Input Field
          _buildCardInputField(
            label: 'Cardholder Name',
            controller: _cardHolderController,
          ),
        ],
      ),
    );
  }

  Widget _buildCardInputField({
    required String label,
    required TextEditingController controller,
    IconData? prefixIcon,
  }) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E242F),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: Color(0xFF64748B),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0F1E36), width: 1.5),
        ),
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(
                  prefixIcon,
                  color: const Color(0xFF1E242F),
                  size: 22,
                ),
              )
            : null,
        prefixIconConstraints: prefixIcon != null
            ? const BoxConstraints(minWidth: 46, minHeight: 22)
            : null,
      ),
    );
  }

  // 4C. Tab 2: NetBanking View matching Image 2
  Widget _buildNetBankingView() {
    final banks = [
      'HDFC',
      'ICICI',
      'SBI',
      'Axis',
      'Kotak',
      'PNB',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Popular Bank',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 16),
          // 3x2 Grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildBankButton(banks[0])),
                  const SizedBox(width: 10),
                  Expanded(child: _buildBankButton(banks[1])),
                  const SizedBox(width: 10),
                  Expanded(child: _buildBankButton(banks[2])),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildBankButton(banks[3])),
                  const SizedBox(width: 10),
                  Expanded(child: _buildBankButton(banks[4])),
                  const SizedBox(width: 10),
                  Expanded(child: _buildBankButton(banks[5])),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankButton(String bankName) {
    final isSelected = _selectedBank == bankName;
    return GestureDetector(
      onTap: () => setState(() => _selectedBank = bankName),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F1E36) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F1E36) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            bankName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : const Color(0xFF1E242F),
            ),
          ),
        ),
      ),
    );
  }

  // 4D. Tab 3: Wallets View matching Image 3
  Widget _buildWalletsView() {
    final wallets = [
      'Mobikwik',
      'Freecharge',
      'Airtel Money',
      'JioMoney',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(wallets.length, (index) {
          final wallet = wallets[index];
          final isSelected = _selectedWallet == wallet;

          return GestureDetector(
            onTap: () => setState(() => _selectedWallet = wallet),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  // Custom Radio Button
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0F1E36)
                            : const Color(0xFF475569),
                        width: 2.2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF0F1E36),
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 24),
                  Text(
                    wallet,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242F),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // 4 Apps Row (Google Pay, PhonePe, Paytm, BHIM UPI)
  Widget _buildAppsRow() {
    final apps = [
      {
        'title': 'Google Pay',
        'icon': 'G',
        'color': const Color(0xFF4285F4),
        'isText': true,
      },
      {
        'title': 'PhonePe',
        'icon': Icons.payment_rounded,
        'color': const Color(0xFF6739B7),
        'isText': false,
      },
      {
        'title': 'Paytm',
        'icon': Icons.account_balance_rounded,
        'color': const Color(0xFF00BAF2),
        'isText': false,
      },
      {
        'title': 'BHIM UPI',
        'icon': Icons.grid_view_rounded,
        'color': const Color(0xFFF58220),
        'isText': false,
      },
    ];

    return Row(
      children: List.generate(apps.length, (index) {
        final isSel = _selectedAppIndex == index;
        final app = apps[index];

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedAppIndex = index),
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: EdgeInsets.only(right: index == apps.length - 1 ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFFF0F6FF) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSel
                      ? const Color(0xFF388AF6)
                      : const Color(0xFFE2E8F0),
                  width: isSel ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Icon
                  if (app['isText'] == true)
                    Text(
                      app['icon'] as String,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: app['color'] as Color,
                      ),
                    )
                  else
                    Icon(
                      app['icon'] as IconData,
                      size: 20,
                      color: app['color'] as Color,
                    ),
                  const SizedBox(height: 6),
                  Text(
                    app['title'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel
                          ? const Color(0xFF1E242F)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // 5. Security & Compliance Footer
  Widget _buildSecurityFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 14,
              ),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  '256-Bit SSL Encrypted • PCI-DSS Compliant Gateway',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Powered by Razorpay Payment Solutions',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

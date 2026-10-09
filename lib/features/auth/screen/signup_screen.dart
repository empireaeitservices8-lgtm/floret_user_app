import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodel/signup_view_model.dart';
import 'safai_logo_widget.dart';
import 'login_screen.dart';
import '../../home/screen/home_screen.dart';
import '../../wallet/screen/razorpay_checkout_screen.dart';

class SignupScreen extends StatefulWidget {
  static const String routeName = '/signup';
  static const String route = '/signup';

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final SignupViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = SignupViewModel();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    }
  }

  void _onBackArrowPressed() {
    if (_viewModel.currentStep == 1 && _viewModel.isOtpSent) {
      _viewModel.resetOtpState();
      return;
    }
    _viewModel.goToPreviousStep(
      onExitFlow: () {
        _onLoginPressed();
      },
    );
  }

  // -------------------------------------------------------------
  // LOCATE ON MAP MODAL
  // -------------------------------------------------------------
  void _showLocateOnMapSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                  const Text(
                    'Locate on Live Map',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E242F),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Simulated Interactive Map Container
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Grid background
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFE2E8F0), Color(0xFFD5DEE8)],
                            ),
                          ),
                          child: CustomPaint(
                            painter: _MapGridPainter(),
                          ),
                        ),
                      ),
                    ),
                    // Center Map Pin
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E242F),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    // Floating Badge
                    Positioned(
                      top: 14,
                      left: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.gps_fixed_rounded,
                              size: 18,
                              color: Color(0xFF238B42),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Kacheri, Nedumangadu, Thiruvananthapuram 695541',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E242F),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Selected Coordinates',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '8.6015° N, 76.9995° E • Thiruvananthapuram, Kerala',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E242F),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E242F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon:
                      const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: const Text(
                    'Confirm Location',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    _viewModel.setMapLocation(
                      street: 'Door No. 12, Kacheri Junction',
                      city: 'Nedumangadu',
                      state: 'Kerala',
                      district: 'Thiruvananthapuram',
                      localBody: 'Nedumangadu Municipality',
                      ward: '9 - KACHERI',
                      zipCode: '695541',
                      lat: 8.6015,
                      lng: 76.9995,
                    );
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Address autofilled from Map!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // SELECTION BOTTOM SHEET
  // -------------------------------------------------------------
  void _showSelectionSheet({
    required String title,
    required List<String> items,
    required ValueChanged<String> onSelect,
    String? selectedValue,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.only(top: 14, bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E242F),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = selectedValue == item;
                    return InkWell(
                      onTap: () {
                        onSelect(item);
                        Navigator.pop(sheetContext);
                      },
                      splashColor: Colors.black.withValues(alpha: 0.05),
                      highlightColor: Colors.black.withValues(alpha: 0.03),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: const Color(0xFF1E242F),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_rounded,
                                color: Color(0xFF1E242F),
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // REGISTRATION SUCCESS DIALOG
  // -------------------------------------------------------------
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final regRes = _viewModel.registrationResponse;
        final isCommercial =
            regRes?.accountType?.toLowerCase() == 'commercial' ||
                _viewModel.accountType == 'Commercial';
        final requiresPayment = regRes?.requiresPayment ?? isCommercial;
        final message = regRes?.message ??
            (isCommercial
                ? 'Welcome to Safai 365! Your commercial account registration has been initialized.'
                : 'Welcome to Safai 365! Your account registration has been completed successfully.');

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF238B42).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF238B42),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Registration Complete!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E242F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                if (requiresPayment) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E242F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pushNamed(
                          context,
                          RazorpayCheckoutScreen.routeName,
                        );
                      },
                      child: Text(
                        'Pay Registration Fee (₹${regRes?.totalAmount.toInt() ?? 1000})',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        HomeScreen.routeName,
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Pay Later & Go to Home',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E242F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          HomeScreen.routeName,
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Go to Home',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // BUILD SCREEN
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFEFF1F5),
                  Color(0xFFE2E6EC),
                  Color(0xFFCCD2DA),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: Consumer<SignupViewModel>(
                                builder: (context, vm, child) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Main Elevated Card
                                      _buildMainCard(vm),

                                      const SizedBox(height: 24),

                                      // Footer: Already have an account? Login
                                      _buildFooter(),
                                      const SizedBox(height: 12),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // MAIN ELEVATED CARD
  // -------------------------------------------------------------
  Widget _buildMainCard(SignupViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 32,
            spreadRadius: 0,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo & Powered by
          const SafaiLogoWidget(height: 52),
          const SizedBox(height: 10),
          const Text(
            'Powered by Floret Technologies',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 18),

          // Header Navigation Row: Back Arrow + Step Indicator
          _buildStepHeader(vm),

          const SizedBox(height: 14),

          // 3-Bar Progress Indicator
          _buildStepProgressBar(vm.currentStep),

          const SizedBox(height: 22),

          // Step Specific View
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _buildCurrentStepView(vm),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP HEADER (Back arrow & Pill)
  // -------------------------------------------------------------
  Widget _buildStepHeader(SignupViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Back arrow button
        InkWell(
          onTap: _onBackArrowPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              size: 26,
              color: Color(0xFF1E242F),
            ),
          ),
        ),

        // Step Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Step ${vm.currentStep} of 3',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E242F),
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 3-BAR PROGRESS INDICATOR
  // -------------------------------------------------------------
  Widget _buildStepProgressBar(int step) {
    return Row(
      children: [
        Expanded(child: _buildBarSegment(active: step >= 1)),
        const SizedBox(width: 8),
        Expanded(child: _buildBarSegment(active: step >= 2)),
        const SizedBox(width: 8),
        Expanded(child: _buildBarSegment(active: step >= 3)),
      ],
    );
  }

  Widget _buildBarSegment({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 4.5,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF1E242F) : const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }

  // -------------------------------------------------------------
  // CURRENT STEP SWITCHER
  // -------------------------------------------------------------
  Widget _buildCurrentStepView(SignupViewModel vm) {
    switch (vm.currentStep) {
      case 1:
        return _buildStep1View(vm);
      case 2:
        return _buildStep2View(vm);
      case 3:
        return _buildStep3View(vm);
      default:
        return _buildStep1View(vm);
    }
  }

  // =============================================================
  // STEP 1: MOBILE VERIFICATION (Image 1 & Image with inline OTP)
  // =============================================================
  Widget _buildStep1View(SignupViewModel vm) {
    return Column(
      key: const ValueKey('step_1_view'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Mobile Verification',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E242F),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        // Subtitle
        const Text(
          'Verify your mobile number via OTP to get started',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: Color(0xFF757D8A),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 22),

        // Error Banner if validation or OTP failed
        if (vm.step1ErrorMessage != null) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8E8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              vm.step1ErrorMessage!,
              style: const TextStyle(
                color: Color(0xFFE02424),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],

        if (!vm.isOtpSent) ...[
          // State A: Mobile Number Input
          const Text(
            'Mobile Number',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E242F),
            ),
          ),
          const SizedBox(height: 8),

          // Input Field
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2E5EB),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(
                  Icons.stay_current_portrait_rounded,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: vm.phoneController,
                    focusNode: vm.phoneFocusNode,
                    keyboardType: TextInputType.phone,
                    cursorColor: const Color(0xFF1E242F),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (val) {
                      vm.clearStep1Error();
                      vm.onMobileChanged(val);
                    },
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E242F),
                    ),
                    decoration: const InputDecoration(
                      hintText: '10-digit mobile number',
                      hintStyle: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                if (vm.mobileNumber.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      size: 18,
                      color: Color(0xFF9CA3AF),
                    ),
                    onPressed: () {
                      vm.phoneController.clear();
                      vm.onMobileChanged('');
                    },
                  ),
                const SizedBox(width: 4),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Send OTP Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E242F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: vm.isLoading
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();
                      vm.sendOtp(
                        onSuccess: () {
                          // Inline OTP fields will now be shown automatically!
                        },
                        onError: (msg) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(msg),
                              backgroundColor: const Color(0xFFDE202B),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
              child: vm.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Send OTP',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ] else ...[
          // State B: Inline OTP verification exactly as in the user's screenshot
          // Row: Mobile Number + Change Phone
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mobile Number',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E242F),
                ),
              ),
              GestureDetector(
                onTap: () {
                  vm.resetOtpState();
                },
                child: const Text(
                  'Change Phone',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E242F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Locked Mobile Number Box with +91
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2E5EB),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(
                  Icons.stay_current_portrait_rounded,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 12),
                Text(
                  '+91${vm.mobileNumber.isNotEmpty ? vm.mobileNumber : '8281014133'}',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E242F),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Row: Verification Code (OTP) + Resend OTP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Verification Code (OTP)',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E242F),
                ),
              ),
              GestureDetector(
                onTap: vm.resendCountdown == 0
                    ? () {
                        vm.resendOtp(
                          onSuccess: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('OTP resent successfully'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          onError: (err) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(err),
                                backgroundColor: const Color(0xFFDE202B),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        );
                      }
                    : null,
                child: Text(
                  vm.resendCountdown > 0
                      ? 'Resend OTP (${vm.resendCountdown}s)'
                      : 'Resend OTP',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: vm.resendCountdown == 0
                        ? const Color(0xFF1E242F)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // OTP Input Box with Envelope-Check icon & dark outline border
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF1E242F),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: vm.otpController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    cursorColor: const Color(0xFF1E242F),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    onChanged: (val) => vm.clearStep1Error(),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E242F),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter 4-digit OTP',
                      hintStyle: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Verify & Continue Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E242F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: vm.isLoading
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();
                      vm.verifyOtp(
                        otp: vm.otpController.text.trim(),
                        onSuccess: () {
                          // Moves to Step 2
                        },
                        onError: (msg) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(msg),
                              backgroundColor: const Color(0xFFDE202B),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
              child: vm.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Verify & Continue',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }

  // =============================================================
  // STEP 2: PROFILE & ACCOUNT TYPE (Images 2, 3, 4)
  // =============================================================
  Widget _buildStep2View(SignupViewModel vm) {
    final isCommercial = vm.accountType == 'Commercial';

    return Column(
      key: const ValueKey('step_2_view'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Profile & Account Type',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E242F),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        // Subtitle
        const Text(
          'Tell us your name and account usage type',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: Color(0xFF757D8A),
          ),
        ),
        const SizedBox(height: 18),

        // Error Banner (Screenshot 3)
        if (vm.step2ErrorMessage != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8E8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              vm.step2ErrorMessage!,
              style: const TextStyle(
                color: Color(0xFFE02424),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        // First Name & Last Name Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'First Name',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: vm.firstNameController,
                    hintText: 'First na...',
                    prefixIcon: Icons.badge_outlined,
                    onChanged: (val) => vm.clearStep2Error(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Last Name',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: vm.lastNameController,
                    hintText: 'Last na...',
                    prefixIcon: Icons.badge_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Account Type Label
        const Text(
          'Account Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E242F),
          ),
        ),
        const SizedBox(height: 10),

        // Account Type Selection Cards (Residential / Commercial)
        Row(
          children: [
            Expanded(
              child: _buildAccountTypeCard(
                title: 'Residential',
                icon: Icons.home_rounded,
                isSelected: vm.accountType == 'Residential',
                onTap: () => vm.setAccountType('Residential'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAccountTypeCard(
                title: 'Commercial',
                icon: Icons.apartment_rounded,
                isSelected: vm.accountType == 'Commercial',
                onTap: () => vm.setAccountType('Commercial'),
              ),
            ),
          ],
        ),

        // Commercial Details (Fee & MOU Upload) - Image 4
        if (isCommercial) ...[
          const SizedBox(height: 20),

          // Commercial Registration Fee Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Commercial Registration Fee',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E242F),
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Registration Fee',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₹1,000.00',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E242F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Fee',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E242F),
                      ),
                    ),
                    Text(
                      '₹1,000.00',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E242F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // MOU Document (Required)
          const Text(
            'MOU Document (Required)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E242F),
            ),
          ),
          const SizedBox(height: 10),

          // Upload Card
          InkWell(
            onTap: () {
              vm.pickMouDocument(
                onError: (err) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(err),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: vm.mouFileName != null
                      ? const Color(0xFF238B42)
                      : const Color(0xFFE2E5EB),
                  width: vm.mouFileName != null ? 1.5 : 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      vm.mouFileName != null
                          ? Icons.description_rounded
                          : Icons.upload_file_rounded,
                      size: 22,
                      color: vm.mouFileName != null
                          ? const Color(0xFF238B42)
                          : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vm.mouFileName != null
                              ? vm.mouFileName!
                              : 'Upload MOU Document',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: vm.mouFileName != null
                                ? const Color(0xFF238B42)
                                : const Color(0xFF1E242F),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vm.mouFileName != null
                              ? 'File attached successfully'
                              : 'Select a PDF or image of your signed MOU',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF757D8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (vm.mouFileName != null)
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                      onPressed: vm.removeMouDocument,
                    )
                  else
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Color(0xFF94A3B8),
                    ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Continue to Address Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E242F),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              vm.proceedToStep3();
            },
            child: const Text(
              'Continue to Address',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =============================================================
  // STEP 3: ADDRESS & CONFIRMATION (Image 5)
  // =============================================================
  Widget _buildStep3View(SignupViewModel vm) {
    return Column(
      key: const ValueKey('step_3_view'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtitle at top of step 3
        const Text(
          'Provide your address for waste collection pickup',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: Color(0xFF757D8A),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),

        // Error Banner if validation fails
        if (vm.step3ErrorMessage != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8E8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              vm.step3ErrorMessage!,
              style: const TextStyle(
                color: Color(0xFFE02424),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        // Locate on Map Card
        InkWell(
          onTap: () => _showLocateOnMapSheet(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFE2E8F0),
                  child: Icon(
                    Icons.map_rounded,
                    size: 22,
                    color: Color(0xFF1E242F),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Locate on Map',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E242F),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Choose location precisely on live map',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF757D8A),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: Color(0xFF1E242F),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Street Address
        const Text(
          'Street Address',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E242F),
          ),
        ),
        const SizedBox(height: 8),
        _buildInputField(
          controller: vm.streetAddressController,
          hintText: 'Enter street name & house nu...',
          prefixIcon: Icons.home_outlined,
        ),

        const SizedBox(height: 16),

        // City
        const Text(
          'City',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E242F),
          ),
        ),
        const SizedBox(height: 8),
        _buildInputField(
          controller: vm.cityController,
          hintText: 'Enter city',
          prefixIcon: Icons.location_city_rounded,
        ),

        const SizedBox(height: 16),

        // State & District Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'State',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdownButton(
                    text: vm.selectedState ?? 'Select Sta...',
                    hasValue: vm.selectedState != null,
                    onTap: () {
                      _showSelectionSheet(
                        title: 'Select State',
                        items: vm.availableStates,
                        selectedValue: vm.selectedState,
                        onSelect: (val) => vm.setStateSelection(val),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'District',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdownButton(
                    text: vm.selectedDistrict ?? 'Select Sta...',
                    hasValue: vm.selectedDistrict != null,
                    onTap: () {
                      if (vm.selectedState == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select state first'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      _showSelectionSheet(
                        title: 'Select District',
                        items: vm.availableDistricts,
                        selectedValue: vm.selectedDistrict,
                        onSelect: (val) => vm.setDistrictSelection(val),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Local Body & Ward Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Local Body',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdownButton(
                    text: vm.selectedLocalBody ?? 'Select Dis...',
                    hasValue: vm.selectedLocalBody != null,
                    onTap: () {
                      if (vm.selectedDistrict == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select district first'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      _showSelectionSheet(
                        title: 'Select Local Body',
                        items: vm.availableLocalBodies,
                        selectedValue: vm.selectedLocalBody,
                        onSelect: (val) => vm.setLocalBodySelection(val),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ward',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdownButton(
                    text: vm.selectedWard ?? 'Select Lo...',
                    hasValue: vm.selectedWard != null,
                    onTap: () {
                      if (vm.selectedLocalBody == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select local body first'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      _showSelectionSheet(
                        title: 'Select Ward',
                        items: vm.availableWards,
                        selectedValue: vm.selectedWard,
                        onSelect: (val) => vm.setWardSelection(val),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Zip / Postal Code
        const Text(
          'Zip / Postal Code',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E242F),
          ),
        ),
        const SizedBox(height: 8),
        _buildInputField(
          controller: vm.zipCodeController,
          hintText: 'Enter zip code',
          prefixIconWidget: Container(
            margin: const EdgeInsets.only(left: 12, right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF94A3B8), width: 1.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '123',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),

        const SizedBox(height: 16),

        // Terms and Conditions Checkbox
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: vm.agreeToTerms,
                activeColor: const Color(0xFF1E242F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                onChanged: vm.toggleTerms,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => vm.toggleTerms(!vm.agreeToTerms),
                child: const Text(
                  'I have read and agree to the terms and conditions of Safai 365 waste app',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // Complete Registration Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E242F),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: vm.isLoading
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    vm.completeRegistration(
                      onSuccess: _showSuccessDialog,
                      onError: (err) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(err),
                            backgroundColor: const Color(0xFFDE202B),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  },
            child: vm.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Complete Registration',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // REUSABLE HELPER WIDGETS
  // -------------------------------------------------------------
  Widget _buildAccountTypeCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 84,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAEFF5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF1E242F) : const Color(0xFFE2E5EB),
            width: isSelected ? 1.6 : 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? const Color(0xFF1E242F)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF1E242F)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    Widget? prefixIconWidget,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E5EB),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          if (prefixIconWidget != null)
            prefixIconWidget
          else if (prefixIcon != null) ...[
            const SizedBox(width: 12),
            Icon(
              prefixIcon,
              size: 19,
              color: const Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
          ] else
            const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              onChanged: onChanged,
              enabled: true,
              cursorColor: const Color(0xFF1E242F),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E242F),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildDropdownButton({
    required String text,
    required VoidCallback onTap,
    bool hasValue = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE2E5EB),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w500,
                  color: hasValue
                      ? const Color(0xFF1E242F)
                      : const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // FOOTER: Already have an account? Login
  // -------------------------------------------------------------
  Widget _buildFooter() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5A6275),
          ),
        ),
        GestureDetector(
          onTap: _onLoginPressed,
          child: const Text(
            'Login',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E242F),
            ),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// MAP GRID PAINTER FOR SIMULATED MAP
// -------------------------------------------------------------
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.0;

    // Draw grid lines
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw simulated road lines
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.6),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.35, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:floret_app/viewmodels/otp_viewmodel.dart';
import 'safai_logo_widget.dart';
import 'signup_screen.dart';
import '../../home/screen/home_screen.dart';

class OtpScreen extends StatefulWidget {
  static const String routeName = '/otp';
  final String mobileNumber;

  const OtpScreen({
    super.key,
    this.mobileNumber = '9995723146',
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  int _resendCountdown = 30;
  Timer? _timer;
  bool _isOtpFocused = false;
  late final OtpViewModel _otpViewModel;

  @override
  void initState() {
    super.initState();
    _otpViewModel = OtpViewModel();
    _startTimer();
    _otpFocusNode.addListener(() {
      setState(() {
        _isOtpFocused = _otpFocusNode.hasFocus;
      });
    });
  }

  void _startTimer() {
    _resendCountdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    _otpViewModel.dispose();
    super.dispose();
  }

  bool get _isOtpValid => _otpController.text.trim().length == 4;

  void _onVerifyPressed() async {
    final String otp = _otpController.text.trim();
    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 4-digit OTP'),
          backgroundColor: Color(0xFFDE202B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final String formattedPhone =
        OtpViewModel.formatPhoneNumber(widget.mobileNumber);

    // Call verifyOtp in OtpViewModel
    final bool success = await _otpViewModel.verifyOtp(formattedPhone, otp);

    if (!mounted) return;

    if (success) {
      final verifyResponse = _otpViewModel.verifyOtpResponse;
      final bool isRegistered = verifyResponse?.isRegistered ?? false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            verifyResponse?.message ??
                'OTP verified successfully. You can now proceed.',
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Handle is_registered:
      if (isRegistered) {
        // User is already registered -> Continue to Login / Home screen flow
        Navigator.pushNamedAndRemoveUntil(
          context,
          HomeScreen.routeName,
          (route) => false,
        );
      } else {
        // New user -> Navigate to registration / profile setup screen
        Navigator.pushNamed(
          context,
          SignupScreen.routeName,
        );
      }
    } else {
      // Show user-friendly error message from ViewModel
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _otpViewModel.verifyErrorMessage ??
                'Invalid OTP. Please check and try again.',
          ),
          backgroundColor: const Color(0xFFDE202B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onResendPressed() async {
    if (_resendCountdown > 0) return;
    _otpController.clear();
    _startTimer();

    final String formattedPhone =
        OtpViewModel.formatPhoneNumber(widget.mobileNumber);
    await _otpViewModel.sendOtp(formattedPhone);

    if (!mounted) return;
    final String displayMobile =
        widget.mobileNumber.isNotEmpty ? widget.mobileNumber : '9995723146';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New OTP sent to $displayMobile'),
        backgroundColor: const Color(0xFF238B42),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onSignUpPressed() {
    Navigator.pushNamed(context, SignupScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final String displayMobile =
        widget.mobileNumber.isNotEmpty ? widget.mobileNumber : '9995723146';

    return ChangeNotifierProvider.value(
      value: _otpViewModel,
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
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Floating White Card
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    36,
                                    24,
                                    32,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0F172A)
                                            .withValues(alpha: 0.08),
                                        blurRadius: 32,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 12),
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFF0F172A)
                                            .withValues(alpha: 0.03),
                                        blurRadius: 10,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Safai Logo
                                      const SafaiLogoWidget(height: 56),

                                      const SizedBox(height: 20),

                                      // Powered by Floret Technologies
                                      const Text(
                                        'Powered by Floret Technologies',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF6B7280),
                                          letterSpacing: 0.2,
                                        ),
                                      ),

                                      const SizedBox(height: 14),

                                      // Welcome Back Heading
                                      const Text(
                                        'Welcome Back',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 27,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1E242F),
                                          letterSpacing: -0.4,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      // Subtitle
                                      const Text(
                                        'Login to manage your waste sustainably',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF757D8A),
                                          height: 1.3,
                                        ),
                                      ),

                                      const SizedBox(height: 28),

                                      // Mobile Number Label
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Mobile Number',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1E242F),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      // Filled Mobile Number Box with Edit Pencil Icon
                                      Container(
                                        height: 54,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: const Color(0xFF1E242F),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(width: 14),
                                            const Icon(
                                              Icons.phone_android_rounded,
                                              size: 20,
                                              color: Color(0xFF5A6275),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              '+91',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF1E242F),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                displayMobile,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1E242F),
                                                  letterSpacing: 0.8,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  Navigator.pop(context),
                                              behavior:
                                                  HitTestBehavior.opaque,
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 12,
                                                ),
                                                child: Icon(
                                                  Icons.edit_outlined,
                                                  size: 19,
                                                  color: Color(0xFF1E242F),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // Enter OTP & Resend OTP Row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Enter OTP',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1E242F),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: _resendCountdown == 0
                                                ? _onResendPressed
                                                : null,
                                            child: Text(
                                              _resendCountdown > 0
                                                  ? 'Resend OTP (${_resendCountdown}s)'
                                                  : 'Resend OTP',
                                              style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w700,
                                                color: _resendCountdown == 0
                                                    ? const Color(0xFF1E242F)
                                                    : const Color(0xFF94A3B8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 10),

                                      // Enter OTP code Input Box
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        height: 54,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: _isOtpFocused
                                                ? const Color(0xFF1E242F)
                                                : const Color(0xFFE2E5EB),
                                            width:
                                                _isOtpFocused ? 1.5 : 1.2,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(width: 14),
                                            const Icon(
                                              Icons.mark_email_read_outlined,
                                              size: 20,
                                              color: Color(0xFF5A6275),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: TextField(
                                                controller: _otpController,
                                                focusNode: _otpFocusNode,
                                                keyboardType:
                                                    TextInputType.number,
                                                cursorColor:
                                                    const Color(0xFF1E242F),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                      4),
                                                ],
                                                onChanged: (val) {
                                                  setState(() {});
                                                },
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1E242F),
                                                  letterSpacing: 1.2,
                                                ),
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: 'Enter 4-digit OTP',
                                                  hintStyle: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFF9CA3AF),
                                                    letterSpacing: 0,
                                                  ),
                                                  border: InputBorder.none,
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  errorBorder:
                                                      InputBorder.none,
                                                  disabledBorder:
                                                      InputBorder.none,
                                                  filled: false,
                                                  fillColor: Colors.transparent,
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (_otpController.text.isNotEmpty)
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.clear,
                                                  size: 18,
                                                  color: Color(0xFF9CA3AF),
                                                ),
                                                onPressed: () {
                                                  _otpController.clear();
                                                  setState(() {});
                                                },
                                              ),
                                            const SizedBox(width: 6),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // Verify & Login Button
                                      Consumer<OtpViewModel>(
                                        builder: (context, otpVm, child) {
                                          final bool isBusy = otpVm.isVerifyingOtp;
                                          return InkWell(
                                            onTap: isBusy
                                                ? null
                                                : _onVerifyPressed,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 250),
                                              height: 54,
                                              decoration: BoxDecoration(
                                                color: _isOtpValid
                                                    ? const Color(0xFF1E242F)
                                                    : const Color(0xFFE5E7EB),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                boxShadow: _isOtpValid
                                                    ? [
                                                        BoxShadow(
                                                          color: const Color(
                                                                  0xFF1E242F)
                                                              .withValues(
                                                                  alpha: 0.25),
                                                          blurRadius: 16,
                                                          offset:
                                                              const Offset(0, 6),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: Center(
                                                child: isBusy
                                                    ? const SizedBox(
                                                        width: 22,
                                                        height: 22,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2.4,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            'Verify & Login',
                                                            style: TextStyle(
                                                              fontSize: 15.5,
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                              color: _isOtpValid
                                                                  ? Colors.white
                                                                  : const Color(
                                                                      0xFF757D8A),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Icon(
                                                            Icons
                                                                .arrow_forward_rounded,
                                                            size: 18,
                                                            color: _isOtpValid
                                                                ? Colors.white
                                                                : const Color(
                                                                    0xFF757D8A),
                                                          ),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 36),

                                // Don't have an account? Sign Up footer
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment:
                                      WrapCrossAlignment.center,
                                  children: [
                                    const Text(
                                      "Don't have an account? ",
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF5A6275),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _onSignUpPressed,
                                      child: const Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1E242F),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
}

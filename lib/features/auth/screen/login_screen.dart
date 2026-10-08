import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodel/login_view_model.dart';
import 'safai_logo_widget.dart';
import 'otp_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  static const String route = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginViewModel _viewModel;
  bool _isInputFocused = false;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
    _viewModel.phoneFocusNode.addListener(() {
      setState(() {
        _isInputFocused = _viewModel.phoneFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onSendOtpPressed() {
    FocusScope.of(context).unfocus();
    _viewModel.sendOtp(
      onSuccess: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              mobileNumber: _viewModel.mobileNumber,
            ),
          ),
        );
      },
      onError: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFDE202B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _onSignUpPressed() {
    Navigator.pushNamed(context, SignupScreen.routeName);
  }

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
                                  // Elevated Center Card
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
                                        // Safai 360 Logo
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

                                        // Mobile Number Field Label
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

                                        // Mobile Input Field
                                        Consumer<LoginViewModel>(
                                          builder: (context, vm, child) {
                                            return AnimatedContainer(
                                              duration:
                                                  const Duration(milliseconds: 200),
                                              height: 54,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: _isInputFocused
                                                      ? const Color(0xFF1E242F)
                                                      : const Color(0xFFE2E5EB),
                                                  width: _isInputFocused
                                                      ? 1.5
                                                      : 1.2,
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
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF1E242F),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: TextField(
                                                      controller:
                                                          vm.phoneController,
                                                      focusNode:
                                                          vm.phoneFocusNode,
                                                      keyboardType:
                                                          TextInputType.phone,
                                                      cursorColor:
                                                          const Color(0xFF1E242F),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly,
                                                        LengthLimitingTextInputFormatter(
                                                            10),
                                                      ],
                                                      onChanged:
                                                          vm.onMobileChanged,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0xFF1E242F),
                                                        letterSpacing: 0.8,
                                                      ),
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText:
                                                            '10-digit mobile number',
                                                        hintStyle: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              Color(0xFF9CA3AF),
                                                          letterSpacing: 0,
                                                        ),
                                                        border:
                                                            InputBorder.none,
                                                        enabledBorder:
                                                            InputBorder.none,
                                                        focusedBorder:
                                                            InputBorder.none,
                                                        errorBorder:
                                                            InputBorder.none,
                                                        disabledBorder:
                                                            InputBorder.none,
                                                        filled: false,
                                                        fillColor:
                                                            Colors.transparent,
                                                        isDense: true,
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                          vertical: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  if (vm.mobileNumber.isNotEmpty)
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.clear,
                                                        size: 18,
                                                        color:
                                                            Color(0xFF9CA3AF),
                                                      ),
                                                      onPressed: () {
                                                        vm.phoneController
                                                            .clear();
                                                        vm.onMobileChanged('');
                                                      },
                                                    ),
                                                  const SizedBox(width: 6),
                                                ],
                                              ),
                                            );
                                          },
                                        ),

                                        const SizedBox(height: 20),

                                        // Send OTP Button
                                        Consumer<LoginViewModel>(
                                          builder: (context, vm, child) {
                                            final bool isActive =
                                                vm.isValidMobile;
                                            return InkWell(
                                              onTap: vm.isLoading
                                                  ? null
                                                  : _onSendOtpPressed,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 250),
                                                height: 54,
                                                decoration: BoxDecoration(
                                                  color: isActive
                                                      ? const Color(0xFF1E242F)
                                                      : const Color(0xFFE5E7EB),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  boxShadow: isActive
                                                      ? [
                                                          BoxShadow(
                                                            color: const Color(
                                                                    0xFF1E242F)
                                                                .withValues(
                                                                    alpha: 0.25),
                                                            blurRadius: 16,
                                                            offset: const Offset(
                                                                0, 6),
                                                          ),
                                                        ]
                                                      : null,
                                                ),
                                                child: Center(
                                                  child: vm.isLoading
                                                      ? SizedBox(
                                                          width: 22,
                                                          height: 22,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2.4,
                                                            color: isActive
                                                                ? Colors.white
                                                                : const Color(
                                                                    0xFF757D8A),
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
                                                              'Send OTP',
                                                              style: TextStyle(
                                                                fontSize: 15.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: isActive
                                                                    ? Colors
                                                                        .white
                                                                    : const Color(
                                                                        0xFF757D8A),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Icon(
                                                              Icons
                                                                  .arrow_forward_rounded,
                                                              size: 18,
                                                              color: isActive
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/screen/home_screen.dart';
import '../../settings/screen/settings_screen.dart';
import 'profile_screen.dart';
import '../viewmodel/contact_support_view_model.dart';
import '../../../widgets/app_bottom_nav_bar.dart';

class ContactSupportScreen extends StatefulWidget {
  static const String routeName = '/contact_support';

  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  late final ContactSupportViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ContactSupportViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, SettingsScreen.routeName);
    } else if (index == 2) {
      bool foundProfile = false;
      Navigator.popUntil(context, (route) {
        if (route.settings.name == ProfileScreen.routeName) {
          foundProfile = true;
          return true;
        }
        return route.isFirst;
      });
      if (!foundProfile && context.mounted) {
        Navigator.pushReplacementNamed(context, ProfileScreen.routeName);
      }
    }
  }

  void _onSubmitMessage() {
    FocusScope.of(context).unfocus();
    _viewModel.submitMessage(
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent successfully! We will get back to you soon.'),
            backgroundColor: Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onError: (errorMsg) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: const Color(0xFFDE202B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: Column(
          children: [
            // Dark Header with Back Button and "We're Here to Help!" Banner
            _buildHeader(context),

            // Scrollable & Responsive Content
            Expanded(
              child: Consumer<ContactSupportViewModel>(
                builder: (context, vm, child) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final double maxWidth = constraints.maxWidth > 580
                          ? 580
                          : constraints.maxWidth;

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. 2x2 Contact Option Cards
                                _buildContactOptionsGrid(vm),

                                const SizedBox(height: 18),

                                // 2. Office Hours Banner
                                _buildOfficeHoursBanner(),

                                const SizedBox(height: 24),

                                // 3. Send Us a Message Section
                                const Text(
                                  'Send Us a Message',
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E242F),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Contact Form
                                _buildContactForm(vm),

                                const SizedBox(height: 32),

                                // 4. Bottom Branding
                                Center(
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Safai 365',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1E242F),
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Powered by Floret Technologies',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF8C96A6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  // 1. Top Bar + Nested "We're Here to Help!" White Card
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1B2332),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Title & Back Button Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Contact Support',
                        style: TextStyle(
                          fontSize: 19.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // White banner card nestled inside the dark navy header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "We're Here to Help!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E242F),
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 20,
                          color: Color(0xFF1E242F),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Have questions or need assistance with your waste collection? Reach out to our support team anytime.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF757D8A),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. 2x2 Grid of Contact Options: Call Us, Email Us, WhatsApp, Our Office
  Widget _buildContactOptionsGrid(ContactSupportViewModel vm) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildContactCard(
                icon: Icons.phone_rounded,
                iconColor: const Color(0xFF2563EB),
                iconBgColor: const Color(0xFFEFF6FF),
                title: 'Call Us',
                subtitle: '92920 23601',
                onTap: vm.makePhoneCall,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildContactCard(
                icon: Icons.email_rounded,
                iconColor: const Color(0xFF1E242F),
                iconBgColor: const Color(0xFFE2E8F0),
                title: 'Email Us',
                subtitle: 'florettechnologies@gma...',
                onTap: vm.sendEmail,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildContactCard(
                icon: Icons.chat_rounded,
                iconColor: const Color(0xFF16A34A),
                iconBgColor: const Color(0xFFDCFCE7),
                title: 'WhatsApp',
                subtitle: '92920 23601',
                onTap: vm.openWhatsApp,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildContactCard(
                icon: Icons.location_on_rounded,
                iconColor: const Color(0xFFEA580C),
                iconBgColor: const Color(0xFFFFEDD5),
                title: 'Our Office',
                subtitle: 'Ernakulam, Kerala',
                onTap: vm.openOfficeLocation,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E242F),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8C96A6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Office Hours Banner
  Widget _buildOfficeHoursBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2332),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(
                Icons.access_time_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Office Hours',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Mon – Sat: 8:00 AM – 6:00 PM',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Sunday: Closed',
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
    );
  }

  // 4. Send Us a Message Form
  Widget _buildContactForm(ContactSupportViewModel vm) {
    return Column(
      children: [
        // Name & Phone Row (Responsive)
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 320) {
              return Column(
                children: [
                  _buildValidatedField(
                    controller: vm.nameController,
                    hintText: 'Your Name',
                    icon: Icons.person_outline_rounded,
                    errorMessage: vm.nameError,
                    onChanged: vm.onNameChanged,
                  ),
                  const SizedBox(height: 12),
                  _buildValidatedField(
                    controller: vm.phoneController,
                    hintText: 'Phone',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildValidatedField(
                    controller: vm.nameController,
                    hintText: 'Your Name',
                    icon: Icons.person_outline_rounded,
                    errorMessage: vm.nameError,
                    onChanged: vm.onNameChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildValidatedField(
                    controller: vm.phoneController,
                    hintText: 'Phone',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),

        // Email Address
        _buildValidatedField(
          controller: vm.emailController,
          hintText: 'Email Address',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          errorMessage: vm.emailError,
          onChanged: vm.onEmailChanged,
        ),
        const SizedBox(height: 12),

        // Inquiry Type Dropdown
        _buildInquiryDropdown(vm),
        const SizedBox(height: 12),

        // Subject
        _buildValidatedField(
          controller: vm.subjectController,
          hintText: 'Subject',
          icon: Icons.subject_rounded,
          errorMessage: vm.subjectError,
          onChanged: vm.onSubjectChanged,
        ),
        const SizedBox(height: 12),

        // Message
        _buildValidatedField(
          controller: vm.messageController,
          hintText: 'Write your message here...',
          icon: Icons.chat_bubble_outline_rounded,
          maxLines: 4,
          errorMessage: vm.messageError,
          onChanged: vm.onMessageChanged,
        ),
        const SizedBox(height: 20),

        // Send Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: vm.isLoading ? null : _onSubmitMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E242F),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: vm.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'SEND MESSAGE',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildValidatedField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? errorMessage,
    ValueChanged<String>? onChanged,
  }) {
    final bool hasError = errorMessage != null && errorMessage.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFDE202B)
                  : const Color(0xFFE2E8F0),
              width: hasError ? 1.4 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: maxLines > 1 ? 12 : 4,
          ),
          child: Row(
            crossAxisAlignment:
                maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: maxLines > 1 ? 4 : 0),
                child: Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E242F),
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 5),
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: Color(0xFF9E3A3A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInquiryDropdown(ContactSupportViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: vm.selectedInquiry,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF94A3B8),
            size: 22,
          ),
          selectedItemBuilder: (context) {
            return vm.inquiryTypes.map((type) {
              return Row(
                children: [
                  const Icon(
                    Icons.category_outlined,
                    size: 19,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E242F),
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: vm.inquiryTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(
                type,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E242F),
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              vm.setInquiryType(val);
            }
          },
        ),
      ),
    );
  }

  // 5. Bottom Navigation Bar
  Widget _buildBottomNav(BuildContext context) {
    return AppBottomNavigationBar(
      currentIndex: 2,
      onTap: (index) => _onBottomNavTapped(context, index),
    );
  }
}

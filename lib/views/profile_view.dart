import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/screen/login_screen.dart';
import '../models/profile_model.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileView extends StatefulWidget {
  static const String routeName = '/profile_view';

  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileViewModel _localViewModel;

  @override
  void initState() {
    super.initState();
    _localViewModel = ProfileViewModel();

    // Fetch profile once after widget frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProfile();
    });
  }

  void _fetchProfile() {
    final vm = _getViewModel();
    vm.getProfile(
      onUnauthorized: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            backgroundColor: Color(0xFFDE202B),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginScreen.routeName,
          (route) => false,
        );
      },
    );
  }

  ProfileViewModel _getViewModel() {
    try {
      return Provider.of<ProfileViewModel>(context, listen: false);
    } catch (_) {
      return _localViewModel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _localViewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          title: const Text(
            'User Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E242F),
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E242F),
        ),
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            // 1. Loading State
            if (viewModel.isLoading && viewModel.profile == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF1E242F),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading profile...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              );
            }

            // 2. Error State (When no profile is available)
            if (viewModel.errorMessage != null && viewModel.profile == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          size: 38,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        viewModel.isUnauthorized
                            ? 'Session Expired'
                            : 'Unable to Load Profile',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E242F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        viewModel.errorMessage ??
                            'Something went wrong. Please try again.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (viewModel.isUnauthorized)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              LoginScreen.routeName,
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.login, size: 18),
                          label: const Text('Go to Login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E242F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _fetchProfile,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E242F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }

            final profile = viewModel.profile;
            if (profile == null) {
              return const SizedBox.shrink();
            }

            // 3. Success State: Display Profile Details
            return RefreshIndicator(
              onRefresh: () async => viewModel.getProfile(),
              color: const Color(0xFF1E242F),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Header Card
                    _buildProfileHeaderCard(profile),

                    const SizedBox(height: 20),

                    // Personal Information Section
                    _buildSectionCard(
                      title: 'Personal Information',
                      children: [
                        _buildInfoRow(
                          icon: Icons.person_outline_rounded,
                          label: 'Full Name',
                          value: profile.fullName,
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          icon: Icons.badge_outlined,
                          label: 'Username',
                          value: profile.user?.username ?? '—',
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: profile.displayEmail,
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                          value: profile.phoneNumber ?? '—',
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          icon: Icons.tag_rounded,
                          label: 'User ID',
                          value: '${profile.user?.id ?? profile.id ?? "—"}',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Account & Address Information Section
                    _buildSectionCard(
                      title: 'Account & Location Details',
                      children: [
                        _buildInfoRow(
                          icon: Icons.account_circle_outlined,
                          label: 'Account Type',
                          value: profile.accountType != null
                              ? profile.accountType!.toUpperCase()
                              : 'RESIDENTIAL',
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          icon: Icons.description_outlined,
                          label: 'MOU Status',
                          value: profile.mouStatus ?? 'N/A',
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Address',
                          value: profile.formattedAddress,
                        ),
                        if (profile.district != null &&
                            profile.district!.isNotEmpty) ...[
                          _buildDivider(),
                          _buildInfoRow(
                            icon: Icons.map_outlined,
                            label: 'District',
                            value: profile.district!,
                          ),
                        ],
                        if (profile.state != null &&
                            profile.state!.isNotEmpty) ...[
                          _buildDivider(),
                          _buildInfoRow(
                            icon: Icons.public_outlined,
                            label: 'State',
                            value: profile.state!,
                          ),
                        ],
                        _buildDivider(),
                        _buildInfoRow(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Registration Fee',
                          value: profile.registrationFeePaid == true
                              ? 'Paid'
                              : 'Pending',
                          valueColor: profile.registrationFeePaid == true
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Logout Button
                    OutlinedButton.icon(
                      onPressed: () async {
                        await viewModel.logout();
                        if (!context.mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          LoginScreen.routeName,
                          (route) => false,
                        );
                      },
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFDC2626),
                        size: 20,
                      ),
                      label: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFFCA5A5),
                          width: 1.2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(ProfileModel profile) {
    final initials = profile.fullName.isNotEmpty
        ? profile.fullName[0].toUpperCase()
        : 'U';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E242F),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E242F).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFF334155),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.phoneNumber ?? 'No phone number',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF16A34A),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    profile.accountType?.toUpperCase() ?? 'RESIDENTIAL',
                    style: const TextStyle(
                      color: Color(0xFF4ADE80),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
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

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E242F),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF1E242F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 12,
      thickness: 0.8,
      color: Color(0xFFF1F5F9),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/booking_view_model.dart';
import 'book_pickup_screen.dart';

class DisposalConsoleScreen extends StatefulWidget {
  static const String routeName = '/disposal_console';

  final BookingViewModel? viewModel;

  final String? pickupOption;

  const DisposalConsoleScreen({
    super.key,
    this.viewModel,
    this.pickupOption,
  });

  @override
  State<DisposalConsoleScreen> createState() => _DisposalConsoleScreenState();
}

class _DisposalConsoleScreenState extends State<DisposalConsoleScreen> {
  late final BookingViewModel _viewModel;
  bool _internalViewModel = false;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
    } else {
      _viewModel = BookingViewModel();
      _internalViewModel = true;
    }
    if (widget.pickupOption != null) {
      _viewModel.setPickupOption(widget.pickupOption!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      _viewModel.setPickupOption(args);
    }
  }

  @override
  void dispose() {
    if (_internalViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFBFD),
        body: SafeArea(
          child: Consumer<BookingViewModel>(
            builder: (context, vm, child) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back Button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A)
                                        .withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.chevron_left_rounded,
                                  color: Color(0xFF1E242F),
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Step Capsule & Segmented Progress Bar
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAEAEA),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'STEP 1 OF 3',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E242F),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              if (vm.pickupOption == 'Commercial & Bulk Dispatch') ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Commercial & Bulk',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0369A1),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 12),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: Container(
                                    height: 4,
                                    color: const Color(0xFFEAEAEA),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: 0.45,
                                      child: Container(
                                        color: const Color(0xFF182236),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Header Title & Subtitle
                          const Text(
                            'Disposal Console',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E242F),
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Define waste categories and estimate your sustainability impact.',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF8C97AC),
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Category Cards List
                          ...vm.categories.map(
                            (cat) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _buildCategoryCard(
                                cat: cat,
                                onChanged: (val) {
                                  vm.toggleCategory(cat.id, val);
                                },
                              ),
                            ),
                          ),

                          // Disposal Guideline Banner (Only when Sanitary Waste is ON)
                          if (vm.isSanitarySelected) ...[
                            const SizedBox(height: 4),
                            _buildDisposalGuidelineBanner(),
                            const SizedBox(height: 14),
                          ],

                          const SizedBox(height: 8),

                          // Live Impact Projection Card
                          _buildLiveImpactProjectionCard(vm),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Button: Continue to Schedule
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: vm.hasSelectedCategory
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookPickupScreen(
                                      viewModel: vm,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: vm.hasSelectedCategory
                              ? const Color(0xFF131D31)
                              : const Color(0xFF8D93A0),
                          disabledBackgroundColor: const Color(0xFF8D93A0),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue to Schedule',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: vm.hasSelectedCategory
                                    ? Colors.white
                                    : const Color(0xFFCAD0DB),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: vm.hasSelectedCategory
                                  ? Colors.white
                                  : const Color(0xFFCAD0DB),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Waste Category Card with active navy border when ON
  Widget _buildCategoryCard({
    required dynamic cat,
    required ValueChanged<bool> onChanged,
  }) {
    final bool isSelected = cat.isSelected;

    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF182236)
                : const Color(0xFFF1F5F9),
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: cat.iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  cat.icon,
                  color: cat.iconColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Category Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E242F),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    cat.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Switch toggle
            _buildCustomSwitch(
              value: isSelected,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  // Custom sleek switch matching Image 1 & 2
  Widget _buildCustomSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: value ? const Color(0xFF8D9BAE) : Colors.white,
          border: Border.all(
            color: value ? const Color(0xFF8D9BAE) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value ? const Color(0xFF182236) : const Color(0xFFB0B8C5),
          ),
        ),
      ),
    );
  }

  // Disposal Guideline Banner matching Image 2
  Widget _buildDisposalGuidelineBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: 1.2,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFFEAB308),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Disposal Guideline',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E242F),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Please pack sanitary waste in a sealed leak-proof bag before handing it to the collector.',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF475569),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // Live Impact Projection Card
  Widget _buildLiveImpactProjectionCard(BookingViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Impact Projection',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E242F),
                ),
              ),
              if (vm.hasSelectedCategory)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F8ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 6,
                        color: Color(0xFF16A34A),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF16A34A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Carbon Offset
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.park_rounded,
                          color: Color(0xFF16A34A),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Carbon Offset',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vm.carbonOffsetFormatted,
                          style: const TextStyle(
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

              // Points Est.
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.star_rounded,
                          color: Color(0xFFD97706),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Points Est.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vm.pointsXPFormatted,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

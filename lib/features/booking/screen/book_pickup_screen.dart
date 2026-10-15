import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/services/api_client.dart';
import 'package:floret_app/services/api_endpoints.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import '../viewmodel/booking_view_model.dart';
import '../repos/booking_repository.dart';
import 'receipt_ticket_screen.dart';
import '../../profile/model/order_model.dart';
import '../../map/screen/location_picker_map_screen.dart';

class BookPickupScreen extends StatefulWidget {
  static const String routeName = '/book_pickup';

  final BookingViewModel? viewModel;

  const BookPickupScreen({super.key, this.viewModel});

  @override
  State<BookPickupScreen> createState() => _BookPickupScreenState();
}

class _BookPickupScreenState extends State<BookPickupScreen> {
  late final BookingViewModel _viewModel;
  bool _internalViewModel = false;
  final BookingRepository _repo = BookingRepository();

  DateTime? _selectedDate;
  String _pickupDateText = '';
  bool _hasSubmittedDate = false;
  bool _hasSubmittedLocation = false;
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _collectorNotesController =
      TextEditingController();
  bool _isConfirming = false;

  bool _isZipValid(String zip) {
    final clean = zip.trim().replaceAll(' ', '');
    return clean.isNotEmpty && RegExp(r'^\d{6}$').hasMatch(clean);
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = null;
    _pickupDateText = '';
    _hasSubmittedDate = false;
    _hasSubmittedLocation = false;
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
    } else {
      _viewModel = BookingViewModel();
      _internalViewModel = true;
    }
  }

  @override
  void dispose() {
    _landmarkController.dispose();
    _collectorNotesController.dispose();
    if (_internalViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  String _formatLongDate(DateTime d) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dayName = days[d.weekday - 1];
    final dayNum = d.day.toString().padLeft(2, '0');
    final monthName = months[d.month - 1];
    return '$dayName, $dayNum $monthName ${d.year}';
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
                  // Top Stepper Header
                  _buildTopHeader(context, vm),

                  // Main Content based on step
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: vm.currentStep == 0
                          ? _buildContactStep(context, vm)
                          : vm.currentStep == 1
                              ? _buildLocationStep(context, vm)
                              : _buildScheduleStep(context, vm),
                    ),
                  ),

                  // Bottom Action Buttons
                  _buildBottomBar(context, vm),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Top Bar & Stepper matching Images 3, 4, 5
  Widget _buildTopHeader(BuildContext context, BookingViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row with Back Button and Title
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (vm.currentStep > 0) {
                    vm.goBackStep();
                  } else {
                    Navigator.pop(context);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: Color(0xFF1E242F),
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Book Pickup',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E242F),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Horizontal Stepper Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Step 1: Contact (always has checkmark in dark circle as per Image 3)
              _buildStepIndicator(
                label: 'Contact',
                isCompleted: true,
                stepNumber: '1',
                isActive: true,
              ),

              // Divider
              Container(
                width: 28,
                height: 1.5,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: const Color(0xFFE2E8F0),
              ),

              // Step 2: Location (has tick mark when on or past Location step as per Image 4)
              _buildStepIndicator(
                label: 'Location',
                isCompleted: vm.locationCompleted || vm.currentStep >= 1,
                stepNumber: '2',
                isActive: vm.currentStep >= 1,
              ),

              // Divider
              Container(
                width: 28,
                height: 1.5,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: const Color(0xFFE2E8F0),
              ),

              // Step 3: Schedule
              _buildStepIndicator(
                label: 'Schedule',
                isCompleted: vm.scheduleCompleted || vm.currentStep == 2,
                stepNumber: '3',
                isActive: vm.currentStep == 2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Individual Step item in Stepper
  Widget _buildStepIndicator({
    required String label,
    required bool isCompleted,
    required String stepNumber,
    required bool isActive,
  }) {
    final bool showTick = isCompleted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: showTick || isActive
                ? const Color(0xFF182236)
                : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: showTick
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  )
                : Text(
                    stepNumber,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : const Color(0xFF94A3B8),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: showTick || isActive ? FontWeight.w700 : FontWeight.w500,
            color: showTick || isActive
                ? const Color(0xFF1E242F)
                : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  // ================= STEP 0: CONTACT DETAILS (Image 3) =================
  Widget _buildContactStep(BuildContext context, BookingViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Contact Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E242F),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 20),

        // Full Name
        _buildFieldLabel('Full Name'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: vm.fullNameController,
          hintText: 'Enter full name',
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 20),

        // Contact Number
        _buildFieldLabel('Contact Number'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: vm.contactNumberController,
          hintText: 'Enter contact number',
          prefixIcon: Icons.smartphone_rounded,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _openMapLocationPicker(BookingViewModel vm) async {
    final result = await Navigator.push<SelectedLocationResult>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerMapScreen(
          confirmButtonText: 'Confirm & Save Address',
        ),
      ),
    );

    if (result == null || !mounted) return;

    vm.setMapLocation(
      address: result.street.isNotEmpty
          ? result.street
          : result.fullAddress,
      city: result.city,
      state: result.state,
      district: result.district,
      localBody: result.localBody,
      ward: result.ward,
      zipCode: result.zipCode,
      lat: result.latitude,
      lng: result.longitude,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address selected from map successfully!'),
        backgroundColor: Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ================= STEP 1: LOCATION DETAILS (Images 4 & 5) =================
  Widget _buildLocationStep(BuildContext context, BookingViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Location Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E242F),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),

        // Segmented Tabs: Saved Addresses vs New Address
        Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // Saved Addresses Tab
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Show SnackBar requested by user
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'no saved adress found.please add a new address',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Color(0xFF1E242F),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 3),
                      ),
                    );
                    vm.setAddressTab(0);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    decoration: BoxDecoration(
                      color: vm.selectedAddressTab == 0
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: vm.selectedAddressTab == 0
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0F172A)
                                    .withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Saved Addresses',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: vm.selectedAddressTab == 0
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: vm.selectedAddressTab == 0
                            ? const Color(0xFF1E242F)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ),

              // New Address Tab
              Expanded(
                child: GestureDetector(
                  onTap: () => vm.setAddressTab(1),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    decoration: BoxDecoration(
                      color: vm.selectedAddressTab == 1
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: vm.selectedAddressTab == 1
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0F172A)
                                    .withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'New Address',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: vm.selectedAddressTab == 1
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: vm.selectedAddressTab == 1
                            ? const Color(0xFF1E242F)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Locate on Map Card
        GestureDetector(
          onTap: () => _openMapLocationPicker(vm),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.map_outlined,
                      color: Color(0xFF182236),
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
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF1E242F),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Pickup Address
        _buildFieldLabel('Pickup Address'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: vm.pickupAddressController,
          hintText: 'Enter street name & house number',
          prefixIcon: Icons.home_work_outlined,
          hasError: _hasSubmittedLocation &&
              vm.pickupAddressController.text.trim().isEmpty,
          errorText: 'Please enter pickup address',
          onChanged: (_) {
            if (_hasSubmittedLocation) setState(() {});
          },
        ),
        const SizedBox(height: 18),

        // City
        _buildFieldLabel('City'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: vm.cityController,
          hintText: 'Enter city',
          prefixIcon: Icons.location_city_outlined,
          hasError: _hasSubmittedLocation &&
              vm.cityController.text.trim().isEmpty,
          errorText: 'Please enter city',
          onChanged: (_) {
            if (_hasSubmittedLocation) setState(() {});
          },
        ),
        const SizedBox(height: 18),

        // State Dropdown
        _buildFieldLabel('State'),
        const SizedBox(height: 8),
        _buildDropdownSelector(
          currentValue: vm.selectedState,
          hint: 'Select state',
          hasError: _hasSubmittedLocation &&
              (vm.selectedState == null || vm.selectedState!.isEmpty),
          errorText: 'Please select state',
          onTap: () => _showSelectionSheet(
            title: 'Select State',
            items: _repo.getAvailableStates(),
            onSelect: (state) {
              vm.setStateSelection(state);
              if (_hasSubmittedLocation) setState(() {});
            },
          ),
        ),
        const SizedBox(height: 18),

        // District Dropdown
        _buildFieldLabel('District', isRequired: false),
        const SizedBox(height: 8),
        _buildDropdownSelector(
          currentValue: vm.selectedDistrict,
          hint: vm.selectedState == null ? 'Select State first' : 'Select District',
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
              items: _repo.getDistrictsForState(vm.selectedState!),
              onSelect: (district) => vm.setDistrictSelection(district),
            );
          },
        ),
        const SizedBox(height: 18),

        // Local Body Dropdown
        _buildFieldLabel('Local Body', isRequired: false),
        const SizedBox(height: 8),
        _buildDropdownSelector(
          currentValue: vm.selectedLocalBody,
          hint: vm.selectedDistrict == null
              ? 'Select District first'
              : 'Select Local Body',
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
              items: _repo.getLocalBodies(vm.selectedDistrict!),
              onSelect: (lb) => vm.setLocalBodySelection(lb),
            );
          },
        ),
        const SizedBox(height: 18),

        // Ward (Optional) Dropdown
        _buildFieldLabel('Ward (Optional)', isRequired: false),
        const SizedBox(height: 8),
        _buildDropdownSelector(
          currentValue: vm.selectedWard,
          hint: vm.selectedLocalBody == null
              ? 'Select Local Body first'
              : 'Select Ward',
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
              items: _repo.getWards(vm.selectedLocalBody!),
              onSelect: (ward) => vm.setWardSelection(ward),
            );
          },
        ),
        const SizedBox(height: 18),

        // Zip / Postal Code
        _buildFieldLabel('Zip / Postal Code'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: vm.zipCodeController,
          hintText: 'Enter zip code',
          prefixIcon: Icons.markunread_mailbox_outlined,
          keyboardType: TextInputType.number,
          hasError: _hasSubmittedLocation &&
              !_isZipValid(vm.zipCodeController.text.trim()),
          errorText: vm.zipCodeController.text.trim().isEmpty
              ? 'Please enter zip / postal code'
              : 'Please enter a valid 6-digit zip code',
          onChanged: (_) {
            if (_hasSubmittedLocation) setState(() {});
          },
        ),
        const SizedBox(height: 22),

        // Save this address to my profile toggle (Image 5)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Save this address to my profile',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242F),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Allows you to quickly reuse this address for future bookings',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => vm.setSaveToProfile(!vm.saveToProfile),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 28,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: vm.saveToProfile
                      ? const Color(0xFF8D9BAE)
                      : Colors.white,
                  border: Border.all(
                    color: vm.saveToProfile
                        ? const Color(0xFF8D9BAE)
                        : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                alignment: vm.saveToProfile
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: vm.saveToProfile
                        ? const Color(0xFF182236)
                        : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ================= STEP 2: SCHEDULE DETAILS =================
  Widget _buildScheduleStep(BuildContext context, BookingViewModel vm) {
    final selectedCategories =
        vm.categories.where((c) => c.isSelected).toList();
    final itemsText = selectedCategories.isNotEmpty
        ? selectedCategories
            .map((c) =>
                c.id == 'sanitary' ? 'Sanitary waste' : c.title.toLowerCase())
            .join(', ')
        : 'Sanitary waste';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Error / Alert banner matching Image (shown when date is not yet selected)
        if (_selectedDate == null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8E8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0x80FCA5A5),
                width: 1,
              ),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFE05368),
                  size: 22,
                ),
                SizedBox(width: 12),
                Text(
                  'Please select Pickup Date',
                  style: TextStyle(
                    color: Color(0xFFE05368),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Section Title: Schedule Pickup
        const Text(
          'Schedule Pickup',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E242F),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 18),

        // Pickup Date *
        RichText(
          text: const TextSpan(
            text: 'Pickup Date ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E242F),
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(
                  color: Color(0xFFE05368),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Date Picker field
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF182236),
                      onPrimary: Colors.white,
                      onSurface: Color(0xFF1E242F),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
                final d = picked.day.toString().padLeft(2, '0');
                final m = picked.month.toString().padLeft(2, '0');
                final y = picked.year.toString();
                _pickupDateText = '$d-$m-$y';
                _hasSubmittedDate = false;
              });
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (_hasSubmittedDate && _selectedDate == null)
                    ? const Color(0xFFE05368)
                    : const Color(0xFF182236),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
                const SizedBox(width: 14),
                Text(
                  _pickupDateText.isNotEmpty
                      ? _pickupDateText
                      : 'Select Pickup Date',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: _pickupDateText.isNotEmpty
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: _pickupDateText.isNotEmpty
                        ? const Color(0xFF1E242F)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_hasSubmittedDate && _selectedDate == null) ...[
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'Please select a valid pickup date',
              style: TextStyle(
                color: Color(0xFFE05368),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),

        // Landmark (Optional)
        const Text(
          'Landmark (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E242F),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFF1F5F9),
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _landmarkController,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E242F),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter nearby landmark',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Collector Notes (Optional)
        const Text(
          'Collector Notes (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E242F),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 110),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFF1F5F9),
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.sticky_note_2_outlined,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _collectorNotesController,
                  minLines: 3,
                  maxLines: 5,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E242F),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Any special instructions for the collector',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Booking Summary Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF1F5F9),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Summary',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E242F),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 1.2,
                color: const Color(0xFF1E242F),
                margin: const EdgeInsets.only(bottom: 12),
              ),
              RichText(
                text: TextSpan(
                  text: 'Items: ',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: itemsText,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF1E242F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Bottom action bar
  Widget _buildBottomBar(BuildContext context, BookingViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Row(
        children: [
          // Back button on Step 1 & 2
          if (vm.currentStep > 0) ...[
            GestureDetector(
              onTap: () => vm.goBackStep(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF1E242F),
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Main Continue Button
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isConfirming
                    ? null
                    : () async {
                        if (vm.currentStep == 0) {
                          vm.proceedToLocation();
                        } else if (vm.currentStep == 1) {
                          final addr = vm.pickupAddressController.text.trim();
                          final city = vm.cityController.text.trim();
                          final state = vm.selectedState;
                          final zip = vm.zipCodeController.text.trim();

                          final bool isAddressValid = addr.isNotEmpty;
                          final bool isCityValid = city.isNotEmpty;
                          final bool isStateValid =
                              state != null && state.isNotEmpty;
                          final bool isZipValid = _isZipValid(zip);

                          if (!isAddressValid ||
                              !isCityValid ||
                              !isStateValid ||
                              !isZipValid) {
                            setState(() {
                              _hasSubmittedLocation = true;
                            });
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Please fill all required location details correctly',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                backgroundColor: const Color(0xFFE05368),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            return;
                          }
                          vm.proceedToSchedule();
                        } else {
                          // Validation: ensure pickup date is selected before confirming
                          if (_selectedDate == null) {
                            setState(() {
                              _hasSubmittedDate = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Please select Pickup Date before proceeding',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                backgroundColor: const Color(0xFFE05368),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            _isConfirming = true;
                          });

                          final selectedCategories = vm.categories
                              .where((c) => c.isSelected)
                              .toList();
                          final wasteTypeText = selectedCategories.isNotEmpty
                              ? selectedCategories
                                  .map((c) => c.id == 'sanitary'
                                      ? 'Sanitary waste'
                                      : c.title.toLowerCase())
                                  .join(', ')
                              : 'Sanitary waste';

                          final scheduledDate =
                              _selectedDate ?? DateTime.now();
                          final formattedDate =
                              '${scheduledDate.year.toString().padLeft(4, '0')}-${scheduledDate.month.toString().padLeft(2, '0')}-${scheduledDate.day.toString().padLeft(2, '0')}';
                          final displayDate =
                              '${scheduledDate.day.toString().padLeft(2, '0')}-${scheduledDate.month.toString().padLeft(2, '0')}-${scheduledDate.year.toString()}';

                          debugPrint(
                              ' Selected Date Slot: $displayDate, Time Slot: 9:00 AM – 12:00 PM');
                          debugPrint(
                              '[AddressScreen] Submitting Booking with Pickup Date: $formattedDate');

                          final email =
                              await SpHelper.getString(sp_keys.keyEmail) ??
                                  await SpHelper.getString('email') ??
                                  '';

                          final requestData = <String, dynamic>{
                            'full_name': vm.fullNameController.text.trim(),
                            'email': email,
                            'contact_number':
                                vm.contactNumberController.text.trim(),
                            'street': vm.pickupAddressController.text.trim(),
                            'city': vm.cityController.text.trim(),
                            'zip_code': vm.zipCodeController.text.trim(),
                            'state': (vm.selectedState != null &&
                                    vm.selectedState!.isNotEmpty)
                                ? vm.selectedState!
                                : 'Kerala',
                            'district': vm.selectedDistrict ?? '',
                            'localbody': vm.selectedLocalBody ?? '',
                            'ward_name': vm.selectedWard ?? '',
                            'pickup_date': formattedDate,
                            'pickup_time_slot': '9:00 AM – 12:00 PM',
                            'items_description': _collectorNotesController
                                    .text.trim().isNotEmpty
                                ? _collectorNotesController.text.trim()
                                : 'General household waste',
                            'waste_type': wasteTypeText,
                            'landmark': _landmarkController.text.trim(),
                          };

                          dynamic backendId;
                          try {
                            final response = await ApiClient().post(
                              ApiEndpoints.pickups,
                              data: requestData,
                            );
                            if (response.data is Map) {
                              backendId = response.data['id'];
                            }
                          } catch (e) {
                            debugPrint('[BookPickupScreen] Error creating pickup: $e');
                          }

                          if (!mounted || !context.mounted) return;
                          setState(() {
                            _isConfirming = false;
                          });

                          // Save order so it appears in Order History
                          final bookingId = backendId != null
                              ? 'WC-$backendId'
                              : OrderStore.instance.generateBookingId();
                          final addr = vm.pickupAddressController.text.trim();
                          final city = vm.cityController.text.trim();
                          final shortAddress = [addr, city]
                              .where((s) => s.isNotEmpty)
                              .join(', ');

                          OrderStore.instance.addOrder(
                            OrderModel(
                              bookingId: bookingId,
                              wasteType: wasteTypeText,
                              pickupDate: scheduledDate,
                              address: shortAddress.isNotEmpty
                                  ? shortAddress
                                  : 'Paruthippara, Thiruvananthapuram',
                              fullAddress: shortAddress.isNotEmpty
                                  ? '$shortAddress${vm.zipCodeController.text.isNotEmpty ? ' - ${vm.zipCodeController.text}' : ''}'
                                  : 'KRAA/11, Paruthippara,\nThiruvananthapuram - 695015',
                              contact: vm.fullNameController.text.isNotEmpty
                                  ? vm.fullNameController.text
                                  : 'User',
                            ),
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReceiptTicketScreen(
                                bookingId: bookingId,
                                date: _formatLongDate(scheduledDate),
                                wasteType: wasteTypeText,
                                pickupAddress: vm
                                        .pickupAddressController.text.isNotEmpty
                                    ? '${vm.pickupAddressController.text}, ${vm.cityController.text.isNotEmpty ? vm.cityController.text : "Thiruvananthapuram"} - ${vm.zipCodeController.text.isNotEmpty ? vm.zipCodeController.text : "695015"}'
                                    : 'KRAA/11, Paruthippara,\nThiruvananthapuram - 695015',
                                contact: vm.fullNameController.text.isNotEmpty &&
                                        vm.contactNumberController.text.isNotEmpty
                                    ? '${vm.fullNameController.text} (${vm.contactNumberController.text})'
                                    : (vm.fullNameController.text.isNotEmpty
                                        ? vm.fullNameController.text
                                        : (vm.contactNumberController.text.isNotEmpty
                                            ? vm.contactNumberController.text
                                            : 'User')),
                              ),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF131D31),
                  disabledBackgroundColor: const Color(0xFF131D31),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isConfirming && vm.currentStep == 2
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            vm.currentStep == 2
                                ? 'Confirm Scheduling'
                                : 'Continue',
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Label with red asterisk
  Widget _buildFieldLabel(String label, {bool isRequired = true}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E242F),
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              color: Color(0xFFE05368),
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
            ),
          ),
      ],
    );
  }

  // Input Field Container matching design
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool hasError = false,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFE05368)
                  : const Color(0xFFF1F5F9),
              width: hasError ? 1.5 : 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E242F),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                prefixIcon,
                color: const Color(0xFF94A3B8),
                size: 20,
              ),
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF94A3B8),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (hasError && errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Color(0xFFE05368),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Dropdown selector matching Images 4 & 5
  Widget _buildDropdownSelector({
    required String? currentValue,
    required String hint,
    required VoidCallback onTap,
    bool hasError = false,
    String? errorText,
  }) {
    final bool hasValue = currentValue != null && currentValue.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasError
                    ? const Color(0xFFE05368)
                    : const Color(0xFFF1F5F9),
                width: hasError ? 1.5 : 1.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    hasValue ? currentValue : hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                      color: hasValue
                          ? const Color(0xFF1E242F)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (hasError && errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Color(0xFFE05368),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showSelectionSheet({
    required String title,
    required List<String> items,
    required ValueChanged<String> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      builder: (sheetContext) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E242F),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: items
                    .map(
                      (item) => ListTile(
                        title: Text(
                          item,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E242F),
                          ),
                        ),
                        onTap: () {
                          onSelect(item);
                          Navigator.pop(sheetContext);
                        },
                        contentPadding: EdgeInsets.zero,
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

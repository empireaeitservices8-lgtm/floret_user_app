import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../booking/repos/booking_repository.dart';
import '../viewmodel/address_view_model.dart';

class SavedAddressesScreen extends StatefulWidget {
  static const String routeName = '/saved_addresses';

  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  late final AddressViewModel _viewModel;
  final BookingRepository _bookingRepo = BookingRepository();

  @override
  void initState() {
    super.initState();
    _viewModel = AddressViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<String?> _showWardPicker({
    required BuildContext context,
    required String localBody,
    String? selectedWard,
  }) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (pickerContext) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Ward',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242F),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(pickerContext),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _bookingRepo.fetchWards(localBody),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF1E242F),
                          ),
                        ),
                      );
                    }
                    final items =
                        snapshot.data ?? _bookingRepo.getWards(localBody);
                    if (items.isEmpty) {
                      return const Center(
                        child: Text(
                          'No wards available',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: Color(0xFFF1F5F9),
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isSelected = item == selectedWard;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          title: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF1E242F)
                                  : const Color(0xFF475569),
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Color(0xFF1E242F),
                                  size: 20,
                                )
                              : null,
                          onTap: () => Navigator.pop(pickerContext, item),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
    );
  }

  Future<String?> _showSelectionPicker({
    required BuildContext context,
    required String title,
    required List<String> items,
    String? selectedItem,
  }) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (pickerContext) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242F),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(pickerContext),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: Color(0xFFF1F5F9),
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item == selectedItem;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      title: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF1E242F)
                              : const Color(0xFF475569),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Color(0xFF1E242F),
                              size: 20,
                            )
                          : null,
                      onTap: () => Navigator.pop(pickerContext, item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
    );
  }

  void _showAddAddressBottomSheet(BuildContext context) {
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final zipController = TextEditingController();
    String? selectedState;
    String? selectedDistrict;
    String? selectedLocalBody;
    String? selectedWard;
    bool isDefault = _viewModel.addresses.isEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                bottomInset > 0 ? bottomInset + 16 : 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Center drag handle
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
                  const SizedBox(height: 16),

                  // Header: Add New Address & Close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add New Address',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E242F),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF1E242F),
                          size: 22,
                        ),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Scrollable form fields matching screenshot
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Street Address & House No
                          _buildModernFieldContainer(
                            child: TextField(
                              controller: streetController,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E242F),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Street Address & House No',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF94A3B8),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 2. City
                          _buildModernFieldContainer(
                            child: TextField(
                              controller: cityController,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E242F),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'City',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF94A3B8),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 3. State
                          _buildDropdownField(
                            label: selectedState ?? 'State',
                            isSelected: selectedState != null,
                            onTap: () async {
                              final picked = await _showSelectionPicker(
                                context: context,
                                title: 'Select State',
                                items: _bookingRepo.getAvailableStates(),
                                selectedItem: selectedState,
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  selectedState = picked;
                                  selectedDistrict = null;
                                  selectedLocalBody = null;
                                  selectedWard = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),

                          // 4. Select State first / District
                          _buildDropdownField(
                            label: selectedDistrict ??
                                (selectedState != null
                                    ? 'District'
                                    : 'Select State first'),
                            isSelected: selectedDistrict != null,
                            onTap: () async {
                              if (selectedState == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select State first'),
                                    duration: Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              final districts =
                                  _bookingRepo.getDistrictsForState(selectedState!);
                              final picked = await _showSelectionPicker(
                                context: context,
                                title: 'Select District',
                                items: districts,
                                selectedItem: selectedDistrict,
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  selectedDistrict = picked;
                                  selectedLocalBody = null;
                                  selectedWard = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),

                          // 5. Select District first / Local Body
                          _buildDropdownField(
                            label: selectedLocalBody ??
                                (selectedDistrict != null
                                    ? 'Local Body'
                                    : 'Select District first'),
                            isSelected: selectedLocalBody != null,
                            onTap: () async {
                              if (selectedDistrict == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please select District first'),
                                    duration: Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              final localBodies =
                                  _bookingRepo.getLocalBodies(selectedDistrict!);
                              final picked = await _showSelectionPicker(
                                context: context,
                                title: 'Select Local Body',
                                items: localBodies,
                                selectedItem: selectedLocalBody,
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  selectedLocalBody = picked;
                                  selectedWard = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),

                          // 6. Select Local Body first / Ward
                          _buildDropdownField(
                            label: selectedWard ??
                                (selectedLocalBody != null
                                    ? 'Ward'
                                    : 'Select Local Body first'),
                            isSelected: selectedWard != null,
                            onTap: () async {
                              if (selectedLocalBody == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please select Local Body first'),
                                    duration: Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              final picked = await _showWardPicker(
                                context: context,
                                localBody: selectedLocalBody!,
                                selectedWard: selectedWard,
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  selectedWard = picked;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),

                          // 7. Zip Code
                          _buildModernFieldContainer(
                            child: TextField(
                              controller: zipController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E242F),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Zip Code',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF94A3B8),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Set as Default Address Row
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Set as Default Address',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E242F),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setSheetState(() => isDefault = !isDefault);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 48,
                                    height: 28,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: isDefault
                                          ? const Color(0xFF1E242F)
                                          : const Color(0xFFE2DCE7),
                                    ),
                                    alignment: isDefault
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDefault
                                            ? Colors.white
                                            : const Color(0xFF717582),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // SAVE ADDRESS Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (streetController.text.trim().isEmpty ||
                                    cityController.text.trim().isEmpty ||
                                    zipController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Please fill out all required fields.'),
                                      backgroundColor: Color(0xFFDE202B),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }

                                _viewModel.addAddress(
                                  addressLine: streetController.text.trim(),
                                  city: cityController.text.trim(),
                                  pincode: zipController.text.trim(),
                                  state: selectedState,
                                  district: selectedDistrict,
                                  localBody: selectedLocalBody,
                                  ward: selectedWard,
                                  area: [
                                    if (selectedWard != null) selectedWard,
                                    if (selectedLocalBody != null)
                                      selectedLocalBody,
                                  ].join(', '),
                                  isDefault: isDefault,
                                );

                                Navigator.pop(sheetContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Address saved successfully!'),
                                    backgroundColor: Color(0xFF059669),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E2837),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'SAVE ADDRESS',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernFieldContainer({required Widget child}) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.0,
        ),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: _buildModernFieldContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    color: isSelected
                        ? const Color(0xFF1E242F)
                        : const Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF6B7280),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Dark Navy curved Header
            _buildHeader(context),

            // Content: Empty State or Address List
            Expanded(
              child: Consumer<AddressViewModel>(
                builder: (context, vm, child) {
                  if (!vm.hasAddresses) {
                    return _buildEmptyState();
                  }
                  return _buildAddressList(vm);
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 12, right: 4),
          child: FloatingActionButton.extended(
            onPressed: () => _showAddAddressBottomSheet(context),
            backgroundColor: const Color(0xFF1E242F),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 20,
            ),
            label: const Text(
              'Add Address',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Dark curved top header matching design
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1B2332),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
                    'Addresses',
                    style: TextStyle(
                      fontSize: 19,
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
      ),
    );
  }

  // Exact empty state matching the provided screenshot
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pin icon with slash
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.location_off_rounded,
                  size: 64,
                  color: Color(0xFFD1D5DB),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            const Text(
              'No saved addresses yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            const Text(
              "Tap '+' to add your first address",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFFA0AAB8),
              ),
            ),
            const SizedBox(height: 20),

            // Add Address Button
            ElevatedButton.icon(
              onPressed: () => _showAddAddressBottomSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E2837),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Add Address',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // List of addresses when created
  Widget _buildAddressList(AddressViewModel vm) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      itemCount: vm.addresses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final address = vm.addresses[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: address.isDefault
                  ? const Color(0xFF1E242F)
                  : const Color(0xFFE2E8F0),
              width: address.isDefault ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      address.type,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E242F),
                      ),
                    ),
                  ),
                  if (address.isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFDC2626),
                      size: 20,
                    ),
                    onPressed: () => vm.deleteAddress(address.id),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                address.addressLine,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E242F),
                ),
              ),
              if (address.area.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  address.area,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
              const SizedBox(height: 2),
              Text(
                '${address.city} - ${address.pincode}',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              if (!address.isDefault) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => vm.setDefaultAddress(address.id),
                  child: const Text(
                    'Set as Default',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Data class representing the location selected and confirmed by the user.
class SelectedLocationResult {
  final double latitude;
  final double longitude;
  final String fullAddress;
  final String street;
  final String city;
  final String state;
  final String district;
  final String? localBody;
  final String? ward;
  final String zipCode;
  final String shortCode;

  const SelectedLocationResult({
    required this.latitude,
    required this.longitude,
    required this.fullAddress,
    required this.street,
    required this.city,
    required this.state,
    required this.district,
    this.localBody,
    this.ward,
    required this.zipCode,
    required this.shortCode,
  });

  @override
  String toString() {
    return 'SelectedLocationResult(lat: $latitude, lng: $longitude, street: $street, city: $city, state: $state, zip: $zipCode)';
  }
}

class LocationPickerMapScreen extends StatefulWidget {
  static const String routeName = '/location_picker_map';

  final LatLng? initialLocation;
  final String? confirmButtonText;

  const LocationPickerMapScreen({
    super.key,
    this.initialLocation,
    this.confirmButtonText,
  });

  @override
  State<LocationPickerMapScreen> createState() =>
      _LocationPickerMapScreenState();
}

class _LocationPickerMapScreenState extends State<LocationPickerMapScreen> {
  // Default coordinates: Thiruvananthapuram, Kerala (matches app reference)
  static const LatLng _kDefaultLocation = LatLng(8.5241, 76.9366);

  GoogleMapController? _mapController;
  late LatLng _currentCenter;
  bool _isLoadingCurrentLocation = false;
  bool _isGeocoding = false;
  bool _hasLocationPermission = false;
  bool _isCameraMoving = false;

  final TextEditingController _searchController = TextEditingController();
  final Geocoding _geocoding = Geocoding();
  Timer? _debounceTimer;

  // Resolved Address Components
  String _shortCode = '';
  String _fullAddress = '';
  String _street = '';
  String _city = '';
  String _state = '';
  String _district = '';
  String _zipCode = '';
  String? _localBody;
  String? _ward;

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialLocation ?? _kDefaultLocation;
    _initLocation();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  /// Checks and requests location permission and retrieves current GPS position.
  Future<void> _initLocation() async {
    if (widget.initialLocation != null) {
      _reverseGeocode(_currentCenter);
      return;
    }

    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _reverseGeocode(_currentCenter);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _hasLocationPermission = true;
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );

        if (!mounted) return;
        final currentLatLng = LatLng(position.latitude, position.longitude);
        _currentCenter = currentLatLng;
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(currentLatLng, 16.5),
        );
        _reverseGeocode(currentLatLng);
      } else {
        // Fallback to default location
        _reverseGeocode(_currentCenter);
      }
    } catch (e) {
      debugPrint('⚠️ [LOCATION MAP] Location initialization exception: $e');
      _reverseGeocode(_currentCenter);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCurrentLocation = false;
        });
      }
    }
  }

  /// Triggers debounced reverse geocoding when camera stops moving.
  void _onCameraIdle() {
    if (_isCameraMoving) {
      setState(() {
        _isCameraMoving = false;
      });
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _reverseGeocode(_currentCenter);
    });
  }

  /// Reverse geocodes coordinates to a human-readable address.
  Future<void> _reverseGeocode(LatLng target) async {
    if (!mounted) return;
    setState(() {
      _isGeocoding = true;
    });

    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        target.latitude,
        target.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final streetPart = (place.street != null && place.street!.isNotEmpty)
            ? place.street!
            : (place.name ?? '');

        final subLocality = place.subLocality ?? '';
        final locality = place.locality ?? '';
        final subAdmin = place.subAdministrativeArea ?? '';
        final admin = place.administrativeArea ?? 'Kerala';
        final postal = place.postalCode ?? '';
        final name = place.name ?? '';

        // Formulate clean title / short code (matches Image 3: e.g. "GWFP+MM2" or area name)
        String title = '';
        if (name.contains('+') || name.length <= 10) {
          title = name;
        } else if (subLocality.isNotEmpty) {
          title = subLocality;
        } else if (locality.isNotEmpty) {
          title = locality;
        } else {
          title = '${target.latitude.toStringAsFixed(4)}, ${target.longitude.toStringAsFixed(4)}';
        }

        // Formulate full descriptive address
        final addressParts = <String>[];
        if (title.isNotEmpty && title != subLocality && title != locality) {
          addressParts.add(title);
        }
        if (streetPart.isNotEmpty && streetPart != title) {
          addressParts.add(streetPart);
        }
        if (subLocality.isNotEmpty && !addressParts.contains(subLocality)) {
          addressParts.add(subLocality);
        }
        if (locality.isNotEmpty && !addressParts.contains(locality)) {
          addressParts.add(locality);
        }
        if (subAdmin.isNotEmpty && !addressParts.contains(subAdmin)) {
          addressParts.add(subAdmin);
        }

        String full = addressParts.join(', ');
        if (admin.isNotEmpty) {
          full += full.isNotEmpty ? ', $admin' : admin;
        }
        if (postal.isNotEmpty) {
          full += ' - $postal';
        }

        setState(() {
          _shortCode = title;
          _fullAddress = full.isNotEmpty
              ? full
              : '${target.latitude.toStringAsFixed(5)}, ${target.longitude.toStringAsFixed(5)}';
          _street = streetPart.isNotEmpty ? streetPart : full;
          _city = locality.isNotEmpty ? locality : (subLocality.isNotEmpty ? subLocality : 'Thiruvananthapuram');
          _state = admin.isNotEmpty ? admin : 'Kerala';
          _district = subAdmin.isNotEmpty ? subAdmin : (locality.isNotEmpty ? locality : 'Thiruvananthapuram');
          _zipCode = postal.isNotEmpty ? postal : '695004';
          _localBody = subLocality.isNotEmpty ? subLocality : null;
          _ward = place.subThoroughfare;
        });
      } else {
        _setFallbackAddress(target);
      }
    } catch (e) {
      debugPrint('⚠️ [LOCATION MAP] Reverse geocoding error: $e');
      if (mounted) {
        _setFallbackAddress(target);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeocoding = false;
        });
      }
    }
  }

  void _setFallbackAddress(LatLng target) {
    setState(() {
      _shortCode = 'Selected Pin';
      _fullAddress =
          'Lat: ${target.latitude.toStringAsFixed(5)}, Lng: ${target.longitude.toStringAsFixed(5)}, Thiruvananthapuram, Kerala';
      _street = 'Location (${target.latitude.toStringAsFixed(4)}, ${target.longitude.toStringAsFixed(4)})';
      _city = 'Thiruvananthapuram';
      _state = 'Kerala';
      _district = 'Thiruvananthapuram';
      _zipCode = '695004';
    });
  }

  /// Performs forward geocoding search from search bar input.
  Future<void> _searchLocation(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isGeocoding = true;
    });

    try {
      final locations = await _geocoding.locationFromAddress(cleanQuery);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final target = LatLng(loc.latitude, loc.longitude);
        _currentCenter = target;
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(target, 16.5),
        );
        _reverseGeocode(target);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No location found. Please try a different query.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed: ${e.toString().replaceFirst("Exception: ", "")}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeocoding = false;
        });
      }
    }
  }

  /// Centers the map on the user's current GPS location.
  Future<void> _goToCurrentLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        final req = await Geolocator.requestPermission();
        if (req != LocationPermission.whileInUse &&
            req != LocationPermission.always) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission is needed to find your location.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final current = LatLng(position.latitude, position.longitude);
      _currentCenter = current;
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(current, 16.5),
      );
      _reverseGeocode(current);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not obtain current location. Move map manually.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCurrentLocation = false;
        });
      }
    }
  }

  /// Confirms the selected location and returns the result to caller.
  void _onConfirmLocation() {
    final result = SelectedLocationResult(
      latitude: _currentCenter.latitude,
      longitude: _currentCenter.longitude,
      fullAddress: _fullAddress.isNotEmpty
          ? _fullAddress
          : '${_currentCenter.latitude}, ${_currentCenter.longitude}',
      street: _street,
      city: _city.isNotEmpty ? _city : 'Thiruvananthapuram',
      state: _state.isNotEmpty ? _state : 'Kerala',
      district: _district.isNotEmpty ? _district : 'Thiruvananthapuram',
      localBody: _localBody,
      ward: _ward,
      zipCode: _zipCode.isNotEmpty ? _zipCode : '695004',
      shortCode: _shortCode,
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    const bottomCardHeight = 220.0;

    return Scaffold(
      backgroundColor: const Color(0xFF121826),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentCenter,
              zoom: 16.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              _onCameraIdle();
            },
            onCameraMoveStarted: () {
              if (!_isCameraMoving) {
                setState(() {
                  _isCameraMoving = true;
                });
              }
            },
            onCameraMove: (position) {
              _currentCenter = position.target;
            },
            onCameraIdle: _onCameraIdle,
            onTap: (target) {
              _currentCenter = target;
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(target),
              );
              _reverseGeocode(target);
            },
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            myLocationEnabled: _hasLocationPermission,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            padding: const EdgeInsets.only(bottom: bottomCardHeight, top: 75),
          ),

          // 2. Animated Center Pin with Ground Shadow & Lift/Drop Effect
          Positioned.fill(
            bottom: bottomCardHeight,
            top: 75,
            child: IgnorePointer(
              child: Center(
                child: SizedBox(
                  width: 60,
                  height: 70,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ground drop shadow (stays at ground level, scales down when pin lifts)
                      Positioned(
                        bottom: 4,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          width: _isCameraMoving ? 8 : 16,
                          height: _isCameraMoving ? 3 : 5,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(
                              alpha: _isCameraMoving ? 0.2 : 0.45,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      // Pin icon (lifts up smoothly while camera is moving)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        bottom: _isCameraMoving ? 22 : 8,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF161D2A),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: _isCameraMoving ? 0.25 : 0.4,
                                ),
                                blurRadius: _isCameraMoving ? 14 : 8,
                                offset: Offset(0, _isCameraMoving ? 12 : 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Top Floating Search Bar (Matches Image 3)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF161D2A),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: _searchLocation,
                      decoration: const InputDecoration(
                        hintText: 'Search for area, street name...',
                        hintStyle: TextStyle(
                          color: Color(0xFF8E9BAE),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_isGeocoding)
                    const Padding(
                      padding: EdgeInsets.only(right: 14),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF8E9BAE),
                        size: 22,
                      ),
                      onPressed: () => _searchLocation(_searchController.text),
                    ),
                ],
              ),
            ),
          ),

          // 4. Floating Action Controls on Right Side (Zoom In, Zoom Out, GPS Locate Me)
          Positioned(
            right: 16,
            bottom: bottomCardHeight + 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Zoom In Button
                _buildMapButton(
                  icon: Icons.add,
                  onTap: () {
                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                  },
                ),
                const SizedBox(height: 8),
                // Zoom Out Button
                _buildMapButton(
                  icon: Icons.remove,
                  onTap: () {
                    _mapController?.animateCamera(CameraUpdate.zoomOut());
                  },
                ),
                const SizedBox(height: 12),
                // Locate Me Button
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161D2A),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: _isLoadingCurrentLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.my_location_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                    onPressed: _goToCurrentLocation,
                  ),
                ),
              ],
            ),
          ),

          // 5. Bottom Location Confirmation Card (Matches Image 3)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: BoxDecoration(
                color: const Color(0xFF121826),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Location Pin + "Confirm Location"
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 19,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Confirm Location',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        if (_isGeocoding)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Primary Title (Short code / Area name)
                    Text(
                      _shortCode.isNotEmpty
                          ? _shortCode
                          : (_city.isNotEmpty ? _city : 'Pin Location'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),

                    // Secondary Subtitle (Full descriptive address)
                    Text(
                      _fullAddress.isNotEmpty
                          ? _fullAddress
                          : 'Move the pin to your precise address location',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF94A3B8),
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),

                    // Confirm & Save Address Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF222B3A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                        onPressed: _onConfirmLocation,
                        child: Text(
                          widget.confirmButtonText ?? 'Confirm & Save Address',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
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

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF161D2A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

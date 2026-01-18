import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MobileMapPicker extends StatefulWidget {
  final LatLng? initialPosition;

  const MobileMapPicker({super.key, this.initialPosition});

  @override
  State<MobileMapPicker> createState() => _MobileMapPickerState();
}

class _MobileMapPickerState extends State<MobileMapPicker> {
  late GoogleMapController _mapController;
  LatLng? _selectedPosition;
  String _selectedAddress = '';
  bool _isLoading = false;
  bool _isGettingCurrentLocation = false;
  Set<Marker> _markers = {};

  // Default position (Karachi, Pakistan)
  static const LatLng _defaultPosition = LatLng(24.8607, 67.0011);

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
    if (_selectedPosition != null) {
      _addMarker(_selectedPosition!);
      _decodeLocation(_selectedPosition!);
    }
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          draggable: true,
          onDragEnd: (newPosition) {
            _selectedPosition = newPosition;
            _decodeLocation(newPosition);
          },
          infoWindow: const InfoWindow(
            title: 'Selected Location',
            snippet: 'Drag to move marker',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      };
    });
  }

  Future<void> _decodeLocation(LatLng position) async {
    setState(() => _isLoading = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = _buildAddressString(place);
        setState(() {
          _selectedAddress = address;
        });
      } else {
        setState(() {
          _selectedAddress = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _buildAddressString(Placemark place) {
    List<String> addressParts = [];

    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
      addressParts.add(place.subAdministrativeArea!);
    }
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }
    if (place.postalCode != null && place.postalCode!.isNotEmpty) {
      addressParts.add(place.postalCode!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      addressParts.add(place.country!);
    }

    return addressParts.join(', ');
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    if (_selectedPosition == null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_defaultPosition, 12),
        );
      });
    } else {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedPosition!, 15),
      );
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _addMarker(position);
      _decodeLocation(position);
    });
  }

  Future<void> _goToCurrentLocation() async {
    try {
      setState(() => _isGettingCurrentLocation = true);

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable location services'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isGettingCurrentLocation = false);
        return;
      }

      // Check permissions
      PermissionStatus status = await Permission.location.status;
      if (status.isDenied) {
        status = await Permission.location.request();
        if (status.isDenied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isGettingCurrentLocation = false);
          return;
        }
      }

      if (status == PermissionStatus.permanentlyDenied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied. Please enable in settings.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isGettingCurrentLocation = false);
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng currentPosition = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedPosition = currentPosition;
        _addMarker(currentPosition);
      });

      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(currentPosition, 15),
      );

      await _decodeLocation(currentPosition);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Current location loaded successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGettingCurrentLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location on Map'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.orange,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _selectedPosition ?? _defaultPosition,
              zoom: _selectedPosition != null ? 15 : 12,
            ),
            onTap: _onMapTap,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
          ),

          // Current Location Button
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'current_location',
              onPressed: _goToCurrentLocation,
              backgroundColor: Colors.orange,
              child: _isGettingCurrentLocation
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.my_location, color: Colors.white),
            ),
          ),

          // Selected Location Info Card
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              color: Colors.grey[900]!.withOpacity(0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Location:',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading && _selectedAddress.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Getting address...',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                    else if (_selectedAddress.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedAddress,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          if (_selectedPosition != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Lat: ${_selectedPosition!.latitude.toStringAsFixed(6)}, '
                                    'Lng: ${_selectedPosition!.longitude.toStringAsFixed(6)}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      )
                    else
                      const Text(
                        'Tap on map to select location or use current location button',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[900],
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedPosition != null
                    ? () {
                  // Return both address and coordinates
                  final result = {
                    'address': _selectedAddress,
                    'latitude': _selectedPosition!.latitude,
                    'longitude': _selectedPosition!.longitude,
                  };
                  Navigator.pop(context, result);
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedPosition != null
                      ? Colors.orange
                      : Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Save Location',
                      style: TextStyle(color: Colors.white),
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
}
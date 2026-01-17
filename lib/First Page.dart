import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'ListOfPartiesScreen.dart';
import 'Map Picker Screen.dart';
import 'inventory app.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedPartyType = 'customer';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Contact picker function
  Future<void> _pickContact() async {
    try {
      // Request permission
      bool permissionGranted = await FlutterContacts.requestPermission();

      if (!permissionGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacts permission denied')),
        );
        return;
      }

      // Open contact picker
      final Contact? contact = await FlutterContacts.openExternalPick();

      if (contact == null) return;

      if (!mounted) return;
      setState(() {
        // Name
        _nameController.text = contact.displayName;

        // Phone (first number)
        if (contact.phones.isNotEmpty) {
          _phoneController.text = contact.phones.first.number;
        }

        // Address
        if (contact.addresses.isNotEmpty) {
          final address = contact.addresses.first;
          String fullAddress = '';

          // Use the address properties directly
          final street = address.street;
          final city = address.city;
          final postalCode = address.postalCode;
          final country = address.country;

          if (street.isNotEmpty) {
            fullAddress += street;
          }
          if (city.isNotEmpty) {
            fullAddress += fullAddress.isNotEmpty ? ', $city' : city;
          }

          if (postalCode.isNotEmpty) {
            fullAddress += fullAddress.isNotEmpty ? ', $postalCode' : postalCode;
          }
          if (country.isNotEmpty) {
            fullAddress += fullAddress.isNotEmpty ? ', $country' : country;
          }

          _addressController.text = fullAddress;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking contact: $e')),
      );
    }
  }

  // Platform-aware current location function
  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        // Web implementation
        await _getCurrentLocationWeb();
      } else {
        // Mobile implementation
        await _getCurrentLocationMobile();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  Future<Position> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }


  // Mobile location implementation
  Future<void> _getCurrentLocationMobile() async {
    // Check location permission
    PermissionStatus status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }

    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Get address from coordinates
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      String address = _buildAddressString(place);
      _addressController.text = address;
    }
  }

  // Web location implementation
  Future<void> _getCurrentLocationWeb() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          String address = _buildAddressString(place);
          _addressController.text = address;
        } else {
          _addressController.text =
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        }
      } catch (_) {
        _addressController.text =
        '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      }
    } catch (e) {
      rethrow;
    }
  }

  String _buildAddressString(Placemark place) {
    String address = '';

    if (place.street != null && place.street!.isNotEmpty) {
      address += place.street!;
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      address += address.isNotEmpty ? ', ${place.locality!}' : place.locality!;
    }
    if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
      address += address.isNotEmpty ? ', ${place.subAdministrativeArea!}' : place.subAdministrativeArea!;
    }
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      address += address.isNotEmpty ? ', ${place.administrativeArea!}' : place.administrativeArea!;
    }
    if (place.country != null && place.country!.isNotEmpty) {
      address += address.isNotEmpty ? ', ${place.country!}' : place.country!;
    }

    return address;
  }

  Future<void> _openMapPicker() async {
    if (kIsWeb) {
      // For web, show a dialog for manual address input or use Google Places API
      _showWebAddressInput();
      return;
    }

    // Mobile: Open map picker
    LatLng? currentPosition;

    PermissionStatus status = await Permission.location.status;
    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        currentPosition = LatLng(position.latitude, position.longitude);
      } catch (e) {
        // Use default position if can't get current location
      }
    }

    final address = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(initialPosition: currentPosition),
      ),
    );

    if (address != null && address is String) {
      if (!mounted) return;
      setState(() {
        _addressController.text = address;
      });
    }
  }

  void _showWebAddressInput() {
    showDialog(
      context: context,
      builder: (context) {
        String address = _addressController.text;
        return AlertDialog(
          title: const Text('Enter Address'),
          content: TextField(
            controller: TextEditingController(text: address),
            onChanged: (value) => address = value,
            decoration: const InputDecoration(
              hintText: 'Enter full address',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _addressController.text = address);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.my_location, color: Colors.orange),
              title: const Text('Use Current Location', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _getCurrentLocation();
              },
            ),
            if (!kIsWeb) // Only show map picker on mobile
              ListTile(
                leading: const Icon(Icons.map, color: Colors.orange),
                title: const Text('Pick on Map', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _openMapPicker();
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit_location, color: Colors.orange),
              title: const Text('Enter Address Manually', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showWebAddressInput();
              },
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[900]!, Colors.black],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: const NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTdcYJk-OSaTZz_auOIpwG7nLJVus3XoqnspA&s',
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text("Party Details",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 24),
                _buildInputCard(
                  title: "Party Information",
                  children: [
                    _buildPartyTypeSelector(),
                    const SizedBox(height: 12),
                    _buildTextField(_nameController, 'Name',
                        icon: Icons.person_outline),
                    const SizedBox(height: 12),
                    _buildTextField(_phoneController, 'Phone Number',
                      keyboardType: TextInputType.phone,
                      icon: Icons.contacts,
                      onIconPressed: _pickContact,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(_addressController, 'Address',
                      maxLines: 2,
                      icon: Icons.location_on,
                      onIconPressed: _showLocationOptions,
                      // Make it read-only so user clicks icon
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 4,
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
              style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildPartyTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Party Type",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            dropdownColor: Colors.grey[850],
            isExpanded: true,
            value: _selectedPartyType,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'customer', child: Text('Customer')),
              DropdownMenuItem(value: 'supplier', child: Text('Supplier')),
              DropdownMenuItem(value: 'fitter', child: Text('Fitter')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedPartyType = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hintText, {
        TextInputType? keyboardType,
        bool readOnly = false,
        int? maxLines = 1,
        IconData? icon,
        VoidCallback? onIconPressed,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        readOnly: readOnly,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: icon != null
              ? IconButton(
            icon: Icon(icon, color: Colors.orange),
            onPressed: onIconPressed,
          )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _isLoading
            ? const CircularProgressIndicator(color: Colors.orange)
            : SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Save & Create Inventory",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _navigateToListScreen,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "View All Parties",
                style: TextStyle(fontSize: 16),
              ),
            )
        ),
      ],
    );
  }

  Future<void> _navigateToListScreen() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ListOfPartiesScreen()),
    );
  }

  // In FirstPage.dart, update the _saveData method:
  Future<void> _saveData() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final databaseRef = FirebaseDatabase.instance.ref("parties");
      final newPartyRef = databaseRef.push();

      // In FirstPage.dart, update the _saveData method:
      await newPartyRef.set({
        'name': name,
        'phone': phone,
        'address': address,
        'type': _selectedPartyType,
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'createdAt': ServerValue.timestamp,
        'totalAmount': 0.0, // Initialize totals
        'totalAdvance': 0.0,
        'totalRemaining': 0.0,
      });

      final key = newPartyRef.key;
      if (key == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to generate party ID")),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InventoryApp(
            partyId: key,
            partyName: name,
            phone: phone,
            address: address,
            partyType: _selectedPartyType!,
            isEditMode: false,
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          ),
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Future<void> _saveData() async {
  //   final name = _nameController.text.trim();
  //   final phone = _phoneController.text.trim();
  //   final address = _addressController.text.trim();
  //
  //   if (name.isEmpty || phone.isEmpty || address.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please fill all the fields")),
  //     );
  //     return;
  //   }
  //
  //   setState(() => _isLoading = true);
  //
  //   try {
  //     final databaseRef = FirebaseDatabase.instance.ref("parties");
  //     final newPartyRef = databaseRef.push();
  //
  //     await newPartyRef.set({
  //       'name': name,
  //       'phone': phone,
  //       'address': address,
  //       'type': _selectedPartyType,
  //       'createdAt': ServerValue.timestamp,
  //     });
  //
  //     final key = newPartyRef.key;
  //     if (key == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Failed to generate party ID")),
  //       );
  //       setState(() => _isLoading = false);
  //       return;
  //     }
  //
  //     if (!mounted) return;
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => InventoryApp(
  //           partyId: key,
  //           partyName: name,
  //           phone: phone,
  //           address: address,
  //           partyType: _selectedPartyType!,
  //           isEditMode: false,
  //           date: '',
  //         ),
  //       ),
  //     );
  //
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error saving data: ${e.toString()}")),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }
}


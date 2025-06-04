import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'inventory app.dart';
import 'ShowInventoryListScreen.dart'; // Make sure to import this

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setCurrentDateTime();
  }

  void _setCurrentDateTime() {
    final now = DateTime.now();
    final formatted = DateFormat('dd-MM-yyyy hh:mm a').format(now);
    _dateController.text = formatted;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _customerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: AssetImage("assets/images/11.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey[800],
                backgroundImage: const NetworkImage(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTdcYJk-OSaTZz_auOIpwG7nLJVus3XoqnspA&s',
                ),
                onBackgroundImageError: (exception, stackTrace) {},
              ),
            ),
            const SizedBox(height: 50),
            _buildTextField(_customerNameController, 'Customer Name'),
            const SizedBox(height: 10),
            _buildTextField(_phoneController, 'Phone', keyboardType: TextInputType.phone,),
            const SizedBox(height: 10),
            _buildTextField(_addressController, 'Address', maxLines: 2),
            const SizedBox(height: 10),
            _buildTextField(
              _dateController,
              'Date',
              readOnly: true,
              suffixIcon: const Icon(Icons.access_time, color: Colors.white70),
            ),
            const SizedBox(height: 30),

            // Save Button
            _isLoading
                ? const CircularProgressIndicator(color: Colors.orange)
                : ElevatedButton(
              onPressed: _saveData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Save",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // Show All Data Button
            ElevatedButton(
              onPressed: _navigateToAllDataScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Different color to distinguish
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Show All Data",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add this new method to navigate to the all data screen
  Future<void> _navigateToAllDataScreen() async {
    try {
      setState(() => _isLoading = true);

      final databaseRef = FirebaseDatabase.instance.ref("customers");
      final snapshot = await databaseRef.get();

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final List<Map<String, dynamic>> allInventories = [];

        data.forEach((customerKey, customerValue) {
          if (customerValue is Map && customerValue['inventory'] != null) {
            final inventories = customerValue['inventory'] as Map<dynamic, dynamic>;

            inventories.forEach((inventoryKey, inventoryValue) {
              if (inventoryValue is Map) {
                final inventory = Map<String, dynamic>.from(inventoryValue);
                inventory['customerId'] = customerKey;
                allInventories.add(inventory);
              }
            });
          }
        });

        if (allInventories.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Showinventorylistscreen(
                inventoryList: allInventories,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No inventory data found")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No customer data found")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: ${e.toString()}")),
      );
    }
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hintText, {
        TextInputType? keyboardType,
        bool readOnly = false,
        int? maxLines = 1,
        Widget? suffixIcon,
      }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Future<void> _saveData() async {
    final customerName = _customerNameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final date = _dateController.text.trim();

    if (customerName.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final databaseRef = FirebaseDatabase.instance.ref("customers");
      final newCustomerRef = databaseRef.push();

      await newCustomerRef.set({
        'customerName': customerName,
        'phone': phone,
        'address': address,
        'date': date,
        'createdAt': ServerValue.timestamp,
      });

      final key = newCustomerRef.key;
      if (key == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to generate customer ID")),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Inventryapp(
            customerId: key,
            customerName: customerName,
            phone: phone,
            address: address,
            date: date,
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
}
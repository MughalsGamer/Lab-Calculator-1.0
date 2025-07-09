import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'ListOfPartiesScreen.dart';
import 'inventory app.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedPartyType = 'customer';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setCurrentDateTime();
  }

  void _setCurrentDateTime() {
    final now = DateTime.now();
    final formatted = DateFormat('dd MMM yyyy, hh:mm a').format(now);
    _dateController.text = formatted;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
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
                        icon: Icons.phone_android_outlined),
                    const SizedBox(height: 12),
                    _buildTextField(_addressController, 'Address',
                        maxLines: 2,
                        icon: Icons.location_on_outlined),
                    _buildClearButton(),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInputCard(
                  title: "Appointment",
                  children: [
                    _buildTextField(
                      _dateController,
                      'Date & Time',
                      readOnly: true,
                      icon: Icons.calendar_today_outlined,
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
            icon: Icon(Icons.arrow_drop_down, color: Colors.orange),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'customer', child: Text('Customer')),
              DropdownMenuItem(value: 'supplier', child: Text('Supplier')),
              DropdownMenuItem(value: 'fitter', child: Text('Fitter')),
            ],
            onChanged: (value) => setState(() => _selectedPartyType = value),
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
          prefixIcon: icon != null ? Icon(icon, color: Colors.orange) : null,
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
              "Create New Project",
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

  Widget _buildClearButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          icon: const Icon(Icons.clear, color: Colors.orange),
          label: const Text(
            "Clear Text",
            style: TextStyle(color: Colors.orange, fontSize: 16),
          ),
          onPressed: _clearFields,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.orange.withOpacity(0.5)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToListScreen() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ListOfPartiesScreen()),
    );
  }

  Future<void> _saveData() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final date = _dateController.text.trim();

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

      await newPartyRef.set({
        'name': name,
        'phone': phone,
        'address': address,
        'date': date,
        'type': _selectedPartyType,
        'createdAt': ServerValue.timestamp,
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
            date: date,
            partyType: _selectedPartyType!,
            isEditMode: false,
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

  void _clearFields() {
    _nameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _setCurrentDateTime();
  }
}
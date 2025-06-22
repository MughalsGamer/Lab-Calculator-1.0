import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Model class.dart';
import 'ShowInventoryListScreen.dart';

class InventoryApp extends StatefulWidget {
  final String customerId;
  final String customerName;
  final String phone;
  final String address;
  final String date;
  final bool isEditMode;
  final String? inventoryId;
  final CustomerModel? initialData;

  const InventoryApp({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.date,
    this.isEditMode = false,
    this.inventoryId,
    this.initialData,
  });

  @override
  State<InventoryApp> createState() => _InventoryAppState();
}

class _InventoryAppState extends State<InventoryApp> {
  final List<String> rooms = [
    'Room 1', 'Room 2', 'Room 3', 'Room 4', 'Room 5',
    'Hall', 'Kitchen', 'Office', 'Shop', 'Wall', 'Roof',
  ];

  final List<String> walls = ['Front', 'Back', 'Right', 'Left', 'Roof'];

  final TextEditingController fileTypeController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController additionalChargesController = TextEditingController();
  final TextEditingController advanceController = TextEditingController();
  final List<TextEditingController> widthControllers = [TextEditingController()];
  final List<TextEditingController> heightControllers = [TextEditingController()];


  String? selectedRoom;
  final List<String?> selectedWalls = [null];
  bool _isLoading = false;
  double totalSqFt = 0.0;
  double totalAmount = 0.0;
  double advanceAmount = 0.0;
  double remainingBalance = 0.0;


  @override
  void initState() {
    super.initState();
    _calculateTotal();

    // If in edit mode, load initial data
    if (widget.isEditMode && widget.initialData != null) {
      _loadInitialData(widget.initialData!);
    }
  }

  void _loadInitialData(CustomerModel model) {
    setState(() {
      fileTypeController.text = model.fileType;
      rateController.text = model.rate.toString();
      additionalChargesController.text = model.additionalCharges.toString();
      advanceController.text = model.advance.toString();
      selectedRoom = model.room;

      // Clear existing dimension controllers
      for (var controller in widthControllers) { controller.dispose(); }
      for (var controller in heightControllers) { controller.dispose(); }
      selectedWalls.clear();

      widthControllers.clear();
      heightControllers.clear();

      // Load dimensions
      for (var dim in model.dimensions) {
        widthControllers.add(TextEditingController(text: dim['width'].toString()));
        heightControllers.add(TextEditingController(text: dim['height'].toString()));
        selectedWalls.add(dim['wall']);
      }

      _calculateTotal();
    });
  }

  @override
  void dispose() {
    fileTypeController.dispose();
    rateController.dispose();
    additionalChargesController.dispose();
    advanceController.dispose();
    for (var controller in widthControllers) { controller.dispose(); }
    for (var controller in heightControllers) { controller.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.customerName}'s Project"),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _navigateToListScreen,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey, Colors.black],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildCustomerInfoCard(),
              const SizedBox(height: 20),
              _buildProjectDetailsCard(),
              const SizedBox(height: 20),
              _buildDimensionsCard(),
              const SizedBox(height: 20),
              _buildFinancialCard(),
              const SizedBox(height: 20),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
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
            const Text("Customer Information",
              style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, widget.customerName),
            _buildInfoRow(Icons.phone, widget.phone),
            _buildInfoRow(Icons.location_on, widget.address),
            _buildInfoRow(Icons.calendar_today, widget.date),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDetailsCard() {
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
            const Text("Project Details",
              style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),
            const SizedBox(height: 16),
            _buildRoomSelector(),
            const SizedBox(height: 16),
            _buildTextField(fileTypeController, 'Material Type', icon: Icons.construction),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Room",
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
            value: selectedRoom,
            icon: Icon(Icons.arrow_drop_down, color: Colors.orange),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            underline: const SizedBox(),
            items: rooms.map((room) => DropdownMenuItem(
              value: room,
              child: Text(room),
            )).toList(),
            onChanged: (value) => setState(() => selectedRoom = value),
            hint: const Text('Select Room',
                style: TextStyle(color: Colors.white70)),
          ),
        ),
      ],
    );
  }

  Widget _buildDimensionsCard() {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Dimensions",
                  style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.orange),
                  onPressed: _addDimensionField,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(widthControllers.length, (index) =>
                _buildDimensionRow(index)),
          ],
        ),
      ),
    );
  }

  void _addDimensionField() {
    setState(() {
      widthControllers.add(TextEditingController());
      heightControllers.add(TextEditingController());
      selectedWalls.add(null);
    });
  }

  Widget _buildDimensionRow(int index) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildDimensionInput(widthControllers[index], 'Width (ft)'),
            ),
            const SizedBox(width: 10),
            const Text('×', style: TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _buildDimensionInput(heightControllers[index], 'Height (ft)'),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: _buildWallSelector(index),
            ),
            if (widthControllers.length > 1)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _removeDimensionField(index),
              ),
          ],
        ),
        if (widthControllers[index].text.isNotEmpty &&
            heightControllers[index].text.isNotEmpty &&
            selectedWalls[index] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${selectedWalls[index]}: ${_calculateSqFt(index).toStringAsFixed(2)} sq.ft',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
          ),
        const Divider(color: Colors.grey),
      ],
    );
  }

  void _removeDimensionField(int index) {
    if (widthControllers.length > 1) {
      setState(() {
        widthControllers.removeAt(index).dispose();
        heightControllers.removeAt(index).dispose();
        selectedWalls.removeAt(index);
      });
      _calculateTotal();
    }
  }

  Widget _buildDimensionInput(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.number,
      onChanged: (value) => _calculateTotal(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[800],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildWallSelector(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        dropdownColor: Colors.grey[850],
        isExpanded: true,
        value: selectedWalls[index],
        icon: Icon(Icons.arrow_drop_down, color: Colors.orange),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        underline: const SizedBox(),
        items: walls.map((wall) => DropdownMenuItem(
          value: wall,
          child: Text(wall),
        )).toList(),
        onChanged: (value) {
          setState(() => selectedWalls[index] = value);
          _calculateTotal();
        },
        hint: const Text('Select Wall',
            style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  Widget _buildFinancialCard() {
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
            const Text("Financial Details",
              style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(rateController, 'Rate per sq.ft',
                keyboardType: TextInputType.number,
                icon: Icons.attach_money),
            const SizedBox(height: 12),
            _buildTextField(additionalChargesController, 'Additional Charges',
                keyboardType: TextInputType.number,
                icon: Icons.receipt_long),
            const SizedBox(height: 12),
            _buildTextField(advanceController, 'Advance Payment',
                keyboardType: TextInputType.number,
                icon: Icons.payment),
            const SizedBox(height: 20),
            _buildFinancialSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hintText, {
        TextInputType? keyboardType,
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
        onChanged: (value) => _calculateTotal(),
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

  Widget _buildFinancialSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
          children: [
          _buildSummaryRow('Total Area:', '${totalSqFt.toStringAsFixed(2)} sq.ft'),
      const Divider(color: Colors.grey),
      _buildSummaryRow('Material Cost:', "Rs ${(totalSqFt * (double.tryParse(rateController.text) ?? 0)).toStringAsFixed(2)}"),
        const Divider(color: Colors.grey),
        _buildSummaryRow('Additional Charges:', 'Rs ${additionalChargesController.text.isNotEmpty ? additionalChargesController.text : "0.00"}'),
        const Divider(color: Colors.grey),
        _buildSummaryRow('Total Amount:', 'Rs ${totalAmount.toStringAsFixed(2)}', isHighlighted: true),
        const Divider(color: Colors.grey),
        _buildSummaryRow('Advance Paid:', 'Rs ${advanceAmount.toStringAsFixed(2)}'),
        const Divider(color: Colors.grey),
        _buildSummaryRow('Balance Due:', 'Rs ${remainingBalance.toStringAsFixed(2)}',
            isHighlighted: true, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlighted = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
            style: TextStyle(
                color: isHighlighted ? Colors.orange : Colors.white70,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal
            ),
          ),
          Text(value,
            style: TextStyle(
                color: isHighlighted ? Colors.orange : Colors.white,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16 : 14
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.orange))
        : ElevatedButton(
      onPressed: _saveData,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        "Save Project Details",
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  double _calculateSqFt(int index) {
    try {
      final width = double.tryParse(widthControllers[index].text) ?? 0;
      final height = double.tryParse(heightControllers[index].text) ?? 0;
      return width * height;
    } catch (e) {
      return 0.0;
    }
  }

  void _calculateTotal() {
    double sqFtSum = 0.0;
    for (int i = 0; i < widthControllers.length; i++) {
      sqFtSum += _calculateSqFt(i);
    }

    final rate = double.tryParse(rateController.text) ?? 0;
    final charges = double.tryParse(additionalChargesController.text) ?? 0;
    advanceAmount = double.tryParse(advanceController.text) ?? 0;

    setState(() {
      totalSqFt = sqFtSum;
      totalAmount = (sqFtSum * rate) + charges;
      remainingBalance = totalAmount - advanceAmount;
    });
  }

  Future<void> _saveData() async {
    _calculateTotal();

    if (selectedRoom == null || fileTypeController.text.isEmpty || rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill required fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final inventoryRef = FirebaseDatabase.instance
          .ref("customers/${widget.customerId}/inventory")
          .push();

      final dimensions = <Map<String, dynamic>>[];
      for (int i = 0; i < widthControllers.length; i++) {
        if (widthControllers[i].text.isNotEmpty &&
            heightControllers[i].text.isNotEmpty &&
            selectedWalls[i] != null) {
          dimensions.add({
            'width': widthControllers[i].text,
            'height': heightControllers[i].text,
            'wall': selectedWalls[i],
            'sqFt': _calculateSqFt(i).toStringAsFixed(2),
          });
        }
      }

      await inventoryRef.set({
        'customerName': widget.customerName,
        'phone': widget.phone,
        'address': widget.address,
        'date': widget.date,
        'room': selectedRoom,
        'fileType': fileTypeController.text,
        'rate': rateController.text,
        'additionalCharges': additionalChargesController.text,
        'advance': advanceController.text,
        'totalSqFt': totalSqFt.toStringAsFixed(2),
        'totalAmount': totalAmount.toStringAsFixed(2),
        'remainingBalance': remainingBalance.toStringAsFixed(2),
        'dimensions': dimensions,
        'createdAt': ServerValue.timestamp,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Project saved successfully")),
      );

      _clearForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    setState(() {
      fileTypeController.clear();
      rateController.clear();
      additionalChargesController.clear();
      advanceController.clear();
      for (var controller in widthControllers) { controller.clear(); }
      for (var controller in heightControllers) { controller.clear(); }
      for (int i = 0; i < selectedWalls.length; i++) { selectedWalls[i] = null; }
      selectedRoom = null;
      totalSqFt = 0.0;
      totalAmount = 0.0;
      advanceAmount = 0.0;
      remainingBalance = 0.0;
    });
  }

  void _navigateToListScreen() async {
    try {
      setState(() => _isLoading = true);

      final databaseRef = FirebaseDatabase.instance.ref("customers/${widget.customerId}/inventory");
      final snapshot = await databaseRef.get();

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final List<Map<String, dynamic>> inventoryList = [];

        data.forEach((key, value) {
          if (value is Map) {
            final Map<String, dynamic> item = Map<String, dynamic>.from(value);
            item['id'] = key.toString();
            inventoryList.add(item);
          }
        });

        inventoryList.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowInventoryListScreen(
              inventoryList: inventoryList,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No projects found")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }
}
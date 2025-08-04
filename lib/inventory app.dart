import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ListOfPartiesScreen.dart';
import 'Model class.dart';
import 'Party Model.dart';
import 'PartyProjectsScreen.dart';

class InventoryApp extends StatefulWidget {
  final String partyId;
  final String partyName;
  final String phone;
  final String address;
  final String date;
  final String partyType;
  final bool isEditMode;
  final String? inventoryId;
  final CustomerModel? initialData;

  const InventoryApp({
    super.key,
    required this.partyId,
    required this.partyName,
    required this.phone,
    required this.address,
    required this.date,
    required this.partyType,
    this.isEditMode = false,
    this.inventoryId,
    this.initialData,
  });

  @override
  State<InventoryApp> createState() => _InventoryAppState();
}

class _InventoryAppState extends State<InventoryApp> {
  final List<String> rooms = [
    'Printing Only','Room 1', 'Room 2', 'Room 3', 'Room 4', 'Room 5',
    'Hall', 'Kitchen', 'Office', 'Shop', 'Wall', 'Roof',
  ];

  final List<String> walls = ['Front', 'Back', 'Right', 'Left', 'Roof','Front+Back','Left+Right','Flex Only'];

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController fileTypeController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController additionalChargesController = TextEditingController();
  final TextEditingController advanceController = TextEditingController();
  final List<TextEditingController> widthControllers = [TextEditingController()];
  final List<TextEditingController> heightControllers = [TextEditingController()];
  final List<TextEditingController> quantityControllers = [TextEditingController()];

  String? selectedRoom;
  final List<String?> selectedWalls = ['Flex Only'];
  bool _isLoading = false;
  double totalSqFt = 0.0;
  double totalAmount = 0.0;
  double advanceAmount = 0.0;
  double remainingBalance = 0.0;

  void _setCurrentDateTime() {
    final now = DateTime.now();
    final formatted = DateFormat('dd MMM yyyy, hh:mm a').format(now);
    _dateController.text = formatted;
  }

  @override
  void initState() {
    super.initState();
    _calculateTotal();
    _setCurrentDateTime();

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
      _dateController.text = model.date;

      widthControllers.clear();
      heightControllers.clear();
      quantityControllers.clear();
      selectedWalls.clear();

      for (var dim in model.dimensions) {
        widthControllers.add(TextEditingController(text: dim['width'].toString()));
        heightControllers.add(TextEditingController(text: dim['height'].toString()));
        quantityControllers.add(TextEditingController(text: dim['quantity'].toString()));
        selectedWalls.add(dim['wall']);
      }

      _calculateTotal();
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    fileTypeController.dispose();
    rateController.dispose();
    additionalChargesController.dispose();
    advanceController.dispose();
    for (var controller in widthControllers) { controller.dispose(); }
    for (var controller in heightControllers) { controller.dispose(); }
    for (var controller in quantityControllers) { controller.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.partyName}'s Inventory"),
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
              _buildPartyInfoCard(),
              const SizedBox(height: 20),
              _buildInputCard(
                title: "Appointment",
                children: [
                  _buildTextField(
                    _dateController,
                    'Date & Time',
                    icon: Icons.calendar_today_outlined,
                    readOnly: true,
                  ),
                ],
              ),
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

  Widget _buildPartyInfoCard() {
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
            Text("${widget.partyType.toUpperCase()} Information",
              style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, widget.partyName),
            _buildInfoRow(Icons.phone, widget.phone),
            _buildInfoRow(Icons.location_on, widget.address),
          ],
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
            const Text("Details",
              style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),
            const SizedBox(height: 16),
            _buildRoomSelector(),
            const SizedBox(height: 16),
            _buildTextField(fileTypeController, 'Material Type', icon: Icons.construction, readOnly: false),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 40),
                        _buildHeaderCell("Width", 100),
                        SizedBox(width: 30,),
                        _buildHeaderCell("Height", 100),
                        _buildHeaderCell("Qty", 60),
                        _buildHeaderCell("Wall", 100),
                        _buildHeaderCell("Sq.ft", 80),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(widthControllers.length, (index) =>
                        _buildDimensionRow(index)
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

  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 14
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDimensionRow(int index) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              alignment: Alignment.center,
              child: widthControllers.length > 1
                  ? IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 24),
                onPressed: () => _removeDimensionField(index),
              )
                  : const SizedBox(),
            ),
            _buildDimensionCell(
              controller: widthControllers[index],
              hint: 'W',
              width: 100,
            ),
            const SizedBox(
              width: 30,
              child: Center(
                child: Text('×', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ),
            _buildDimensionCell(
              controller: heightControllers[index],
              hint: 'H',
              width: 100,
            ),
            _buildDimensionCell(
              controller: quantityControllers[index],
              hint: 'Qty',
              width: 60,
            ),
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildWallSelector(index),
            ),
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                _calculateSqFt(index).toStringAsFixed(2),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const Divider(color: Colors.grey),
      ],
    );
  }

  Widget _buildDimensionCell({
    required TextEditingController controller,
    required String hint,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onChanged: (value) => _calculateTotal(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          filled: true,
          fillColor: Colors.grey[800],
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  void _addDimensionField() {
    setState(() {
      widthControllers.add(TextEditingController());
      heightControllers.add(TextEditingController());
      quantityControllers.add(TextEditingController()..text = '1');
      selectedWalls.add('Flex Only');
    });
  }

  void _removeDimensionField(int index) {
    if (widthControllers.length > 1) {
      setState(() {
        widthControllers.removeAt(index).dispose();
        heightControllers.removeAt(index).dispose();
        quantityControllers.removeAt(index).dispose();
        selectedWalls.removeAt(index);
      });
      _calculateTotal();
    }
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
                icon: Icons.attach_money, readOnly: false),
            const SizedBox(height: 12),
            _buildTextField(additionalChargesController, 'Additional Charges',
                keyboardType: TextInputType.number,
                icon: Icons.receipt_long, readOnly: false),
            const SizedBox(height: 12),
            _buildTextField(advanceController, 'Advance Payment',
                keyboardType: TextInputType.number,
                icon: Icons.payment, readOnly: false),
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
        IconData? icon, required bool readOnly,
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
        readOnly: readOnly,
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
        "Save Inventory Details",
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  double _calculateSqFt(int index) {
    try {
      final width = double.tryParse(widthControllers[index].text) ?? 0;
      final height = double.tryParse(heightControllers[index].text) ?? 0;
      final quantity = double.tryParse(quantityControllers[index].text) ?? 1;
      return width * height * quantity;
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
      final databaseRef = FirebaseDatabase.instance.ref("parties/${widget.partyId}/inventory");
      DatabaseReference inventoryRef;
      if (widget.isEditMode && widget.inventoryId != null) {
        inventoryRef = databaseRef.child(widget.inventoryId!);
      } else {
        inventoryRef = databaseRef.push();
      }

      final dimensions = <Map<String, dynamic>>[];
      for (int i = 0; i < widthControllers.length; i++) {
        if (widthControllers[i].text.isNotEmpty &&
            heightControllers[i].text.isNotEmpty &&
            quantityControllers[i].text.isNotEmpty &&
            selectedWalls[i] != null) {
          dimensions.add({
            'width': widthControllers[i].text,
            'height': heightControllers[i].text,
            'quantity': quantityControllers[i].text,
            'wall': selectedWalls[i],
            'sqFt': _calculateSqFt(i).toStringAsFixed(2),
          });
        }
      }

      await inventoryRef.set({
        'customerName': widget.partyName,
        'phone': widget.phone,
        'address': widget.address,
        'date': _dateController.text, // Use the date from the controller
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
        const SnackBar(content: Text("Inventory details saved successfully")),
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
      for (var controller in quantityControllers) { controller.clear(); }
      for (int i = 0; i < selectedWalls.length; i++) { selectedWalls[i] = null; }
      selectedRoom = null;
      totalSqFt = 0.0;
      totalAmount = 0.0;
      advanceAmount = 0.0;
      remainingBalance = 0.0;
      _setCurrentDateTime(); // Reset to current date/time
    });
  }

  void _navigateToListScreen() async {
    try {
      setState(() => _isLoading = true);

      final databaseRef = FirebaseDatabase.instance.ref("parties/${widget.partyId}/inventory");
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
            builder: (context) => PartyProjectsScreen(
              party: PartyModel(
                id: widget.partyId,
                name: widget.partyName,
                phone: widget.phone,
                address: widget.address,
                date: widget.date,
                type: widget.partyType,
              ),
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
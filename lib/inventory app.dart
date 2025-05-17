import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'Show details.dart';
import 'ShowInventoryListScreen.dart';

class Inventryapp extends StatefulWidget {
  final String customerName;
  final String phone;
  final String address;
  final String date;
  final String customerId;

  const Inventryapp({
    super.key,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.date,
    required this.customerId,
  });

  @override
  State<Inventryapp> createState() => _InventryappState();
}

class _InventryappState extends State<Inventryapp> {


  final List<String> rooms = [
    'Room 1', 'Room 2', 'Room 3', 'Room 4', 'Room 5',
    'Hall', 'Kitchen', 'Office', 'Shop', 'Wall', 'Roof',
  ];

  final List<String> walls = ['Front', 'Back', 'Right', 'Left', 'Roof'];

  final TextEditingController fileTypeController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController additionalChargesController = TextEditingController();
  final TextEditingController advanceController = TextEditingController();
  final List<TextEditingController> widthControllers = List.generate(7, (index) => TextEditingController());
  final List<TextEditingController> heightControllers = List.generate(7, (index) => TextEditingController());

  String? selectedRoom;
  final List<String?> selectedWalls = List.generate(7, (index) => null);
  bool _isLoading = false;
  double totalSqFt = 0.0;
  double totalAmount = 0.0;
  double advanceAmount = 0.0;
  double remainingBalance = 0.0;

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

  Widget _buildTextField(TextEditingController controller, String hintText,
      {TextInputType? keyboardType, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        readOnly: readOnly,
        onChanged: (value) => _calculateTotal(),
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
        ),
      ),
    );
  }

  Widget _buildDimensionRow(int index) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildTextField(
                widthControllers[index],
                'Width (ft)',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 5),
            const Text('X', style: TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(width: 5),
            Expanded(
              child: _buildTextField(
                heightControllers[index],
                'Height (ft)',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  dropdownColor: Colors.black87,
                  isExpanded: true,
                  value: selectedWalls[index],
                  hint: const Text('Wall', style: TextStyle(color: Colors.white70)),
                  iconEnabledColor: Colors.orange,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  underline: const SizedBox(),
                  items: walls.map((wall) => DropdownMenuItem(
                    value: wall,
                    child: Text(wall),
                  )).toList(),
                  onChanged: (value) {
                    setState(() => selectedWalls[index] = value);
                    _calculateTotal();
                  },
                ),
              ),
            ),
          ],
        ),
        if (widthControllers[index].text.isNotEmpty &&
            heightControllers[index].text.isNotEmpty &&
            selectedWalls[index] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${selectedWalls[index]}: ${_calculateSqFt(index)} sq.ft',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
      ],
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
    for (int i = 0; i < 7; i++) {
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
      // Always use push() to generate a new unique key for each entry
      final inventoryRef = FirebaseDatabase.instance
          .ref("customers/${widget.customerId}/inventory")
          .push(); // This creates a new unique key

      final dimensions = <Map<String, dynamic>>[];
      for (int i = 0; i < 7; i++) {
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
        const SnackBar(content: Text("Data saved successfully")),
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

  void _navigateToShowScreen() {
    _calculateTotal();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowInventoryScreen(
          customerName: widget.customerName,
          phone: widget.phone,
          address: widget.address,
          date: widget.date,
          room: selectedRoom ?? '',
          fileType: fileTypeController.text,
          rate: rateController.text,
          additionalCharges: additionalChargesController.text,
          advance: advanceController.text,
          totalSqFt: totalSqFt.toStringAsFixed(2),
          totalAmount: totalAmount.toStringAsFixed(2),
          remainingBalance: remainingBalance.toStringAsFixed(2),
          dimensions:

           List<Map<String, String>>.from(
            List.generate(7, (index) {
          if (widthControllers[index].text.isNotEmpty &&
              heightControllers[index].text.isNotEmpty &&
              selectedWalls[index] != null) {
            return {
              'wall': selectedWalls[index]!,
              'width': widthControllers[index].text,
              'height': heightControllers[index].text,
              'sqFt': _calculateSqFt(index).toStringAsFixed(2),
            };
          }
          return null;
        }).where((element) => element != null).cast<Map<String, String>>().toList(),
      ),

    ),
      ),
    );
  }


  // Add this new method for viewing all inventories
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
            item['id'] = key.toString(); // Ensure we keep the unique key
            inventoryList.add(item);
          }
        });

        // Sort by date (newest first)
        inventoryList.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Showinventorylistscreen(
              inventoryList: inventoryList,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No inventories found")),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(TextEditingController(text: widget.customerName), 'Customer Name', readOnly: true),
                _buildTextField(TextEditingController(text: widget.phone), 'Phone', readOnly: true),
                _buildTextField(TextEditingController(text: widget.address), 'Address', readOnly: true),
                _buildTextField(TextEditingController(text: widget.date), 'Date', readOnly: true),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    dropdownColor: Colors.black87,
                    isExpanded: true,
                    value: selectedRoom,
                    hint: const Text('Select Room', style: TextStyle(color: Colors.white70)),
                    iconEnabledColor: Colors.orange,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    underline: const SizedBox(),
                    items: rooms.map((room) => DropdownMenuItem(
                      value: room,
                      child: Text(room),
                    )).toList(),
                    onChanged: (value) => setState(() => selectedRoom = value),
                  ),
                ),

                const SizedBox(height: 20),
                _buildTextField(fileTypeController, 'File Type'),

                const SizedBox(height: 20),
                for (int i = 0; i < 7; i++) _buildDimensionRow(i),

                const SizedBox(height: 20),
                _buildTextField(rateController, 'Rate per sq.ft', keyboardType: TextInputType.number),
                _buildTextField(additionalChargesController, 'Additional Charges', keyboardType: TextInputType.number),
                _buildTextField(advanceController, 'Advance Payment', keyboardType: TextInputType.number),

                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Sq.ft: ${totalSqFt.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                        SizedBox(height: 8),
                        Text('Total Amount: Rs${totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                        SizedBox(height: 8),
                        Text('Advance Paid: Rs${advanceAmount.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                        SizedBox(height: 8),
                        Text('Remaining Balance: Rs${remainingBalance.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.orangeAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveData,
                      icon: const Icon(Icons.save),
                      label: Text(_isLoading ? 'Saving...' : 'Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _navigateToListScreen,
                      icon: const Icon(Icons.list),
                      label: const Text('All Records'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                  ],
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}


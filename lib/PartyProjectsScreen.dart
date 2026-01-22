import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'First Page.dart';
import 'Model class.dart';
import 'Party Model.dart';
import 'PdfService.dart';
import 'Show details.dart';
import 'inventory app.dart';

class PartyProjectsScreen extends StatefulWidget {
  final PartyModel party;
  final Function(PartyModel)? onPartyUpdated;

  const PartyProjectsScreen({
    super.key,
    required this.party,
    this.onPartyUpdated,
  });

  @override
  State<PartyProjectsScreen> createState() => _PartyProjectsScreenState();
}

class _PartyProjectsScreenState extends State<PartyProjectsScreen> {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref().child('parties');
  List<CustomerModel> _projects = [];
  bool _isLoading = true;

  double _totalAllAmount = 0.0;
  double _totalAllAdvance = 0.0;
  double _totalAllRemaining = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _updatePartyTotals() async {
    try {
      double totalAmount = 0;
      double totalAdvance = 0;
      double totalRemaining = 0;

      for (var project in _projects) {
        totalAmount += project.totalAmount;
        totalAdvance += project.advance;
        totalRemaining += project.remainingBalance;
      }

      setState(() {
        _totalAllAmount = totalAmount;
        _totalAllAdvance = totalAdvance;
        _totalAllRemaining = totalRemaining;
      });

      final paymentStatus = totalRemaining <= 0 ? 'Paid' : 'Pending';

      await _ref.child(widget.party.id).update({
        'totalAmount': totalAmount,
        'totalAdvance': totalAdvance,
        'totalRemaining': totalRemaining,
        'paymentStatus': paymentStatus,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      final updatedParty = widget.party.copyWith(
        totalAmount: totalAmount,
        totalAdvance: totalAdvance,
        totalRemaining: totalRemaining,
      );

      if (widget.onPartyUpdated != null) {
        widget.onPartyUpdated!(updatedParty);
      }
    } catch (e) {
      print('Error updating party totals: $e');
    }
  }

  // Receive payment for entire party
  void _showReceivePaymentDialog() {
    if (_totalAllRemaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No remaining balance to receive'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final TextEditingController amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Receive Payment', style: TextStyle(color: Colors.white)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Remaining: Rs${_totalAllRemaining.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Amount to Receive',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixText: 'Rs ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter valid amount';
                  }
                  if (amount > _totalAllRemaining) {
                    return 'Amount cannot exceed remaining balance';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final amount = double.parse(amountController.text);
                Navigator.pop(context);
                await _receivePartyPayment(amount);
              }
            },
            child: const Text('Receive', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Receive payment for specific project
  void _showReceiveProjectPaymentDialog(CustomerModel project) {
    if (project.remainingBalance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This project is already fully paid'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final TextEditingController amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Receive Project Payment', style: TextStyle(color: Colors.white)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project: ${project.room}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Current Balance: Rs${project.remainingBalance.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Amount to Receive',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixText: 'Rs ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter valid amount';
                  }
                  if (amount > project.remainingBalance) {
                    return 'Amount cannot exceed project balance';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final amount = double.parse(amountController.text);
                Navigator.pop(context);
                await _receiveProjectPayment(project, amount);
              }
            },
            child: const Text('Receive', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _receivePartyPayment(double amount) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );

      final newRemaining = _totalAllRemaining - amount;
      final newAdvance = _totalAllAdvance + amount;

      // Get existing payment history
      final snapshot = await _ref.child(widget.party.id).get();
      List<Map<String, dynamic>> paymentHistory = [];

      if (snapshot.exists) {
        final data = snapshot.value as Map;
        if (data['paymentHistory'] != null) {
          if (data['paymentHistory'] is List) {
            paymentHistory = List<Map<String, dynamic>>.from(
                (data['paymentHistory'] as List).map((e) => Map<String, dynamic>.from(e))
            );
          } else if (data['paymentHistory'] is Map) {
            paymentHistory = (data['paymentHistory'] as Map).values
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
          }
        }
      }

      // Add new payment record
      paymentHistory.add({
        'amount': amount,
        'remainingAfter': newRemaining,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'date': DateFormat('dd MMM yyyy').format(DateTime.now()),
        'time': DateFormat('hh:mm a').format(DateTime.now()),
        'type': 'party_payment',
      });

      final paymentStatus = newRemaining <= 0 ? 'Paid' : 'Pending';

      await _ref.child(widget.party.id).update({
        'totalAdvance': newAdvance,
        'totalRemaining': newRemaining,
        'paymentStatus': paymentStatus,
        'paymentHistory': paymentHistory,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      setState(() {
        _totalAllAdvance = newAdvance;
        _totalAllRemaining = newRemaining;
      });

      Navigator.pop(context); // Close loading dialog

      _showPaymentReceipt(amount, newRemaining);

      Fluttertoast.showToast(
        msg: 'Payment received successfully',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _receiveProjectPayment(CustomerModel project, double amount) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );

      final newRemaining = project.remainingBalance - amount;
      final newAdvance = project.advance + amount;

      // Get existing payment history for project
      List<Map<String, dynamic>> paymentHistory = List.from(project.paymentHistory);

      // Add new payment record
      paymentHistory.add({
        'amount': amount,
        'remainingAfter': newRemaining,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'date': DateFormat('dd MMM yyyy').format(DateTime.now()),
        'time': DateFormat('hh:mm a').format(DateTime.now()),
        'type': 'project_payment',
      });

      // Update project in Firebase
      await _ref.child(widget.party.id).child('inventory').child(project.id).update({
        'advance': newAdvance,
        'remainingBalance': newRemaining,
        'paymentHistory': paymentHistory,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Update local project
      setState(() {
        project.advance = newAdvance;
        project.remainingBalance = newRemaining;
        project.paymentHistory = paymentHistory;
      });

      // Update party totals
      await _updatePartyTotals();

      Navigator.pop(context); // Close loading dialog

      Fluttertoast.showToast(
        msg: 'Project payment received successfully',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  void _showPaymentReceipt(double amount, double remainingBalance) {
    final dateTime = DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 30),
            const SizedBox(width: 10),
            const Text('Payment Receipt', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReceiptRow('Party:', widget.party.name),
              const Divider(color: Colors.grey),
              _buildReceiptRow('Date:', formattedDate),
              _buildReceiptRow('Time:', formattedTime),
              const Divider(color: Colors.grey),
              _buildReceiptRow('Amount Received:', 'Rs${amount.toStringAsFixed(2)}', isHighlight: true),
              _buildReceiptRow('Remaining Balance:', 'Rs${remainingBalance.toStringAsFixed(2)}'),
              if (remainingBalance <= 0)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Center(
                      child: Text(
                        '✓ FULLY PAID',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? Colors.orange : Colors.white,
              fontSize: 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _handlePdfActions() {
    if (_projects.isEmpty) {
      Fluttertoast.showToast(msg: "No projects to generate PDF");
      return;
    }

    PdfService.handlePdfActions(
      context: context,
      generatePdf: () async {
        // Fetch latest party data to include payment history
        final snapshot = await _ref.child(widget.party.id).get();
        PartyModel latestParty = widget.party;

        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          data['id'] = widget.party.id;
          latestParty = PartyModel.fromMap(data);
        }

        return await PdfService.generatePartyProjectsPdf(
          party: latestParty,
          projects: _projects,
        );
      },
      fileName: '${widget.party.name}_Projects_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
    );
  }

  Future<void> _fetchProjects() async {
    try {
      _ref.child(widget.party.id).child('inventory').onValue.listen((event) async {
        final data = event.snapshot.value;
        List<CustomerModel> fetchedProjects = [];

        if (data != null && data is Map) {
          data.forEach((projectKey, projectValue) {
            if (projectValue is Map) {
              final projectMap = Map<String, dynamic>.from(projectValue);
              projectMap['id'] = projectKey;
              projectMap['partyId'] = widget.party.id;
              fetchedProjects.add(CustomerModel.fromMap(projectMap));
            }
          });
        }

        setState(() {
          _projects = fetchedProjects;
          _isLoading = false;
        });

        await _updatePartyTotals();
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProject(CustomerModel model) async {
    try {
      await _ref
          .child(widget.party.id)
          .child('inventory')
          .child(model.id)
          .remove();

      setState(() {
        _projects.removeWhere((item) => item.id == model.id);
      });

      await _updatePartyTotals();

      Fluttertoast.showToast(
        msg: "Project deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to delete project: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _navigateToEditScreen(BuildContext context, CustomerModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryApp(
          partyId: widget.party.id,
          partyName: widget.party.name,
          phone: widget.party.phone,
          address: widget.party.address,
          date: widget.party.date,
          partyType: widget.party.type,
          isEditMode: true,
          inventoryId: model.id,
          initialData: model,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.party.name}'s Projects"),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            onPressed: _handlePdfActions,
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generate PDF',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FirstPage()),
              );
            },
            icon: const Icon(Icons.home),
            tooltip: 'Home',
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.orange),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InventoryApp(
                    partyId: widget.party.id,
                    partyName: widget.party.name,
                    phone: widget.party.phone,
                    address: widget.party.address,
                    date: widget.party.date,
                    partyType: widget.party.type,
                    isEditMode: false,
                  ),
                ),
              );
            },
            tooltip: 'Add Project',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : Column(
        children: [
          if (_projects.isNotEmpty) _buildTotalsContainer(),
          Expanded(
            child: _projects.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory, size: 60, color: Colors.orange),
                  const SizedBox(height: 20),
                  const Text(
                    "No projects found",
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InventoryApp(
                            partyId: widget.party.id,
                            partyName: widget.party.name,
                            phone: widget.party.phone,
                            address: widget.party.address,
                            date: widget.party.date,
                            partyType: widget.party.type,
                            isEditMode: false,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text("Add First Project", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                final model = _projects[index];
                return _buildProjectCard(model);
              },
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildProjectCard(CustomerModel model) {
    return Card(
      elevation: 4,
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(model.date, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                Row(
                  children: [
                    if (model.remainingBalance > 0)
                      IconButton(
                        icon: const Icon(Icons.payment, color: Colors.green),
                        onPressed: () => _showReceiveProjectPaymentDialog(model),
                        tooltip: 'Receive Payment',
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _navigateToEditScreen(context, model),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(model),
                    ),
                  ],
                ),
              ],
            ),
            Text('Room: ${model.room}', style: const TextStyle(color: Colors.white)),
            Text('Material: ${model.fileType}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),

            // ========== DIMENSIONS TABLE ==========
            if (model.dimensions.isNotEmpty) ...[
              const Text(
                'Dimensions:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowHeight: 40,
                    dataRowHeight: 36,
                    headingTextStyle: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    dataTextStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                    columns: const [
                      DataColumn(label: Text('Wall')),
                      DataColumn(label: Text('Width')),
                      DataColumn(label: Text('Height')),
                      DataColumn(label: Text('Qty')),
                      DataColumn(label: Text('Sq.ft')),
                    ],
                    rows: model.dimensions.map((dim) {
                      return DataRow(cells: [
                        DataCell(Text(
                          dim['wall']?.toString() ?? 'N/A',
                          style: const TextStyle(color: Colors.white),
                        )),
                        DataCell(Text(
                          dim['width']?.toString() ?? '0',
                          style: const TextStyle(color: Colors.white70),
                        )),
                        DataCell(Text(
                          dim['height']?.toString() ?? '0',
                          style: const TextStyle(color: Colors.white70),
                        )),
                        DataCell(Text(
                          dim['quantity']?.toString() ?? '1',
                          style: const TextStyle(color: Colors.white70),
                        )),
                        DataCell(Text(
                          dim['sqFt']?.toString() ?? '0',
                          style: const TextStyle(color: Colors.orange),
                          textAlign: TextAlign.end,
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.grey),
              const SizedBox(height: 10),
            ],

            _buildProjectTotalsRow(model),
            const SizedBox(height: 10),

            // Financial Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFinancialRow('Rate per sq.ft:', 'Rs${model.rate.toStringAsFixed(2)}'),
                _buildFinancialRow('Total Area:', '${model.totalSqFt.toStringAsFixed(2)} sq.ft'),
                _buildFinancialRow('Additional Charges:', 'Rs${model.additionalCharges.toStringAsFixed(2)}'),
                _buildFinancialRow('Total Amount:', 'Rs${model.totalAmount.toStringAsFixed(2)}', isHighlighted: true),
                _buildFinancialRow('Advance Paid:', 'Rs${model.advance.toStringAsFixed(2)}'),
                _buildFinancialRow(
                  'Remaining Balance:',
                  'Rs${model.remainingBalance.toStringAsFixed(2)}',
                  isHighlighted: true,
                  color: model.remainingBalance > 0 ? Colors.orange : Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Payment History Section
            if (model.paymentHistory.isNotEmpty) _buildPaymentHistorySection(model),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => _navigateToDetailScreen(context, model),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                minimumSize: const Size(double.infinity, 40),
              ),
              child: const Text('View Details', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value, {bool isHighlighted = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isHighlighted ? Colors.orange : Colors.white70,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? (isHighlighted ? Colors.orange : Colors.white),
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistorySection(CustomerModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment History:',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...model.paymentHistory.map((payment) {
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${payment['date']} ${payment['time']}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Received: Rs${(payment['amount'] as double).toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
                Text(
                  'Balance: Rs${(payment['remainingAfter'] as double).toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTotalsContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Party Summary',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildTotalCard(
                  title: 'Total Amount',
                  value: _totalAllAmount,
                  icon: Icons.account_balance_wallet,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTotalCard(
                  title: 'Total Advance',
                  value: _totalAllAdvance,
                  icon: Icons.payment,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTotalCard(
                  title: 'Remaining',
                  value: _totalAllRemaining,
                  icon: Icons.balance,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTotalsRow(CustomerModel model) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMiniTotalCard(
            title: 'Amount',
            value: model.totalAmount,
            color: Colors.blue[700]!,
          ),
          _buildMiniTotalCard(
            title: 'Advance',
            value: model.advance,
            color: Colors.green[700]!,
          ),
          _buildMiniTotalCard(
            title: 'Balance',
            value: model.remainingBalance,
            color: Colors.orange[700]!,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTotalCard({
    required String title,
    required double value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Rs${value.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard({
    required String title,
    required double value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rs${value.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.white70
          )),
          Text(value, style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.orange : Colors.white
          )),
        ],
      ),
    );
  }

  void _confirmDelete(CustomerModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this project?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () {
              _deleteProject(model);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToDetailScreen(BuildContext context, CustomerModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowDetailsScreen(
          customerName: model.customerName,
          phone: model.phone,
          address: model.address,
          date: model.date,
          room: model.room,
          fileType: model.fileType,
          rate: model.rate.toString(),
          additionalCharges: model.additionalCharges.toString(),
          advance: model.advance.toString(),
          totalSqFt: model.totalSqFt.toString(),
          totalAmount: model.totalAmount.toString(),
          remainingBalance: model.remainingBalance.toString(),
          dimensions: model.dimensions.map((d) => {
            'wall': d['wall']?.toString() ?? 'N/A',
            'width': d['width']?.toString() ?? '0',
            'height': d['height']?.toString() ?? '0',
            'quantity': d['quantity']?.toString() ?? '1',
            'sqFt': d['sqFt']?.toString() ?? '0',
          }).toList(),
          paymentHistory: model.paymentHistory,
        ),
      ),
    );
  }
}
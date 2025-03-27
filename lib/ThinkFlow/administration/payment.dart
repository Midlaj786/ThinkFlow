import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddBankAccountPage extends StatefulWidget {
  @override
  _AddBankAccountPageState createState() => _AddBankAccountPageState();
}

class _AddBankAccountPageState extends State<AddBankAccountPage> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _holderController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _hasBankDetails = false;

  @override
  void initState() {
    super.initState();
    _fetchBankDetails();
  }

  /// Fetch Existing Bank Details
  Future<void> _fetchBankDetails() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot mentorDoc = await FirebaseFirestore.instance
        .collection('mentors')
        .doc(userId)
        .get();

    if (mentorDoc.exists) {
      var data = mentorDoc.data() as Map<String, dynamic>;
      if (data.containsKey('accountNumber')) {
        setState(() {
          _hasBankDetails = true;
          _accountController.text = data['accountNumber'] ?? '';
          _ifscController.text = data['ifscCode'] ?? '';
          _holderController.text = data['accountHolder'] ?? '';
          _upiController.text = data['upiId'] ?? '';
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  /// Save or Update Bank Details
  void _saveBankDetails() async {
    if (_formKey.currentState!.validate()) {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('mentors').doc(userId).set({
        'accountNumber': _accountController.text.trim(),
        'ifscCode': _ifscController.text.trim(),
        'accountHolder': _holderController.text.trim(),
        'upiId': _upiController.text.trim(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bank details updated successfully!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Bank Account")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _hasBankDetails ? _buildExistingDetails() : _buildForm(),
            ),
    );
  }

  /// **UI for Editing Existing Details**
  Widget _buildExistingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your Current Bank Details",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _infoRow("Account Number", _accountController.text),
        _infoRow("IFSC Code", _ifscController.text),
        _infoRow("Account Holder Name", _holderController.text),
        _infoRow("UPI ID", _upiController.text),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _hasBankDetails = false;
            });
          },
          child: const Text("Edit Bank Details"),
        ),
      ],
    );
  }

  /// **UI for Adding/Editing Bank Details**
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(_accountController, "Account Number"),
          _buildTextField(_ifscController, "IFSC Code"),
          _buildTextField(_holderController, "Account Holder Name"),
          _buildTextField(_upiController, "UPI ID (Required)"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveBankDetails,
            child: const Text("Save Details"),
          ),
        ],
      ),
    );
  }

  /// **Reusable Text Field with Validation**
  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$label is required";
          }
          return null;
        },
      ),
    );
  }

  /// **Display Bank Info Row**
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

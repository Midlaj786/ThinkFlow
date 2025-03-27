import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SendMoneyPage extends StatefulWidget {
  final String courseId;
  final String mentorId;

  const SendMoneyPage(
      {super.key, required this.courseId, required this.mentorId});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  late Razorpay _razorpay;
  String? upiId;
  Map<String, dynamic>? bankDetails;
  double amount = 0.0;
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  String? currentUserName;
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _fetchMentorAndUserDetails();
  }

  Future<void> _fetchMentorAndUserDetails() async {
    try {
      // Fetch Mentor Details
      var mentorDoc = await FirebaseFirestore.instance
          .collection('mentors')
          .doc(widget.mentorId)
          .get();
      if (mentorDoc.exists) {
        setState(() {
          upiId = mentorDoc.data()?['upiId'];
          bankDetails = mentorDoc.data()?['bankDetails'];
        });
      }

      // Fetch Course Details
      var courseDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .get();
      if (courseDoc.exists) {
        setState(() {
          amount = double.tryParse(
                  courseDoc.data()?['offerPrice'].toString() ?? '0') ??
              0.0;
        });
      }

      // Fetch User Details
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      if (userDoc.exists) {
        setState(() {
          currentUserName = userDoc.data()?['name'] ?? "Unknown User";
          currentUserEmail = userDoc.data()?['email'] ?? "unknown@example.com";
        });
      }
    } catch (e) {
      print("Error fetching details: $e");
    }
  }

  void _initiatePayment() {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid amount")),
      );
      return;
    }

    var options = {
      'key': 'YOUR_RAZORPAY_KEY', // Replace with your Razorpay Key
      'amount': (amount * 100).toInt(), // Convert amount to paise
      'currency': 'INR',
      'name': 'ThinkFlow Course Payment',
      'description': 'Payment for the course',
      'prefill': {
        'contact': '9999999999', // Replace with user's phone number
        'email': currentUserEmail ?? 'test@example.com'
      },
      'theme': {'color': '#FF9800'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error opening Razorpay: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    String transactionId = response.paymentId ?? "";

    // Store payment details in Firestore
    await FirebaseFirestore.instance.collection("payments").add({
      "courseId": widget.courseId,
      "mentorId": widget.mentorId,
      "userId": currentUserId,
      "userName": currentUserName,
      "amount": amount,
      "transactionId": transactionId,
      "timestamp": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Payment Successful")));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Payment Failed")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Send Money")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Amount: ₹$amount",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (upiId != null)
              _paymentOptionTile("Pay via UPI", "UPI ID: $upiId", Icons.payment,
                  _initiatePayment),
            if (upiId == null && bankDetails != null)
              _paymentOptionTile(
                  "Pay via Bank",
                  "Acc No: ${bankDetails!['accountNo']} \nIFSC: ${bankDetails!['ifsc']}",
                  Icons.account_balance,
                  _initiatePayment),
            if (upiId == null && bankDetails == null)
              const Text("No payment details available for this mentor",
                  style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _paymentOptionTile(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(onPressed: onTap, child: const Text("Pay")),
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}

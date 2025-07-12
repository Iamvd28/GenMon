import 'package:flutter/material.dart';
import 'contest_waiting_room_screen.dart';
import 'contest_screen.dart';

class PaymentScreen extends StatefulWidget {
  final dynamic contest;
  const PaymentScreen({Key? key, required this.contest}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isPaying = false;
  String _selectedMethod = 'UPI';

  Future<bool> _pay() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  void _onPayNowPressed() async {
    setState(() => _isPaying = true);
    bool paymentSuccess = await _pay();
    if (paymentSuccess) {
      final contest = widget.contest;
      if (contest == null || contest['startTime'] == null || contest['title'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contest data missing!')),
        );
        setState(() => _isPaying = false);
        return;
      }
      final now = DateTime.now();
      final startTime = contest['startTime'];
      final contestTitle = contest['title'];
      if (now.isBefore(startTime)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ContestWaitingRoomScreen(
              contestTitle: contestTitle,
              startTime: startTime,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ContestScreen(),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed!')),
      );
    }
    setState(() => _isPaying = false);
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethods = const [
      'UPI',
      'Credit/Debit Card',
      'Net Banking',
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Payment'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text(
              'Amount: Rs ${widget.contest?['price'] ?? 0}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('Choose Payment Method:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                final method = paymentMethods[index];
                return RadioListTile<String>(
                  value: method,
                  groupValue: _selectedMethod,
                  onChanged: _isPaying ? null : (v) => setState(() => _selectedMethod = v!),
                  title: Text(method),
                );
              },
            ),
            const SizedBox(height: 32),
            Center(
              child: AnimatedOpacity(
                opacity: _isPaying ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: ElevatedButton(
                  onPressed: _isPaying ? null : _onPayNowPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF00),
                  ),
                  child: _isPaying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Pay Now'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../themes/admin_theme.dart';
import '../widgets/admin_card.dart';

class TicketPricingScreen extends StatefulWidget {
  const TicketPricingScreen({super.key});

  @override
  State<TicketPricingScreen> createState() => _TicketPricingScreenState();
}

class _TicketPricingScreenState extends State<TicketPricingScreen> {
  final TextEditingController twoHoursController = TextEditingController(
    text: '200',
  );
  final TextEditingController sevenDaysController = TextEditingController(
    text: '2000',
  );

  @override
  void initState() {
    super.initState();
    loadPrices();
  }

  Future<void> loadPrices() async {
    try {
      final data = await ApiService.getTicketPrices();
      if (!mounted) return;

      if (data['success'] == true) {
        for (final ticket in data['data']) {
          if (ticket['ticket_name'] == '2-Hours Ticket') {
            twoHoursController.text = ticket['price'].toString();
          }

          if (ticket['ticket_name'] == '7-Days Ticket') {
            sevenDaysController.text = ticket['price'].toString();
          }
        }
      }
    } catch (_) {}
  }

  Future<void> savePrices() async {
    try {
      final data = await ApiService.saveTicketPrices(
        twoHoursPrice: twoHoursController.text,
        sevenDaysPrice: sevenDaysController.text,
      );

      if (!mounted) return;

      showMessage(
        data['message'] ??
            (data['success'] == true
                ? 'Ticket prices updated'
                : 'Could not update prices'),
        data['success'] == true ? Colors.green : Colors.red,
      );
    } catch (_) {
      if (!mounted) return;
      showMessage('Could not connect to the server', Colors.red);
    }
  }

  void showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Widget priceRow(
    String title,
    String description,
    TextEditingController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 150,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              suffixText: 'SDG',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    twoHoursController.dispose();
    sevenDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: SizedBox(
          width: 700,
          child: AdminCard(
            title: 'Ticket Pricing',
            subtitle:
                'Set the base price for each ticket type in Sudanese Pounds.',
            child: Column(
              children: [
                priceRow(
                  '2-Hours Ticket',
                  'Valid for two hours after purchase.',
                  twoHoursController,
                ),
                const Divider(height: 32),
                priceRow(
                  '7-Days Ticket',
                  'Valid for seven days after purchase.',
                  sevenDaysController,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: savePrices,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Prices'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

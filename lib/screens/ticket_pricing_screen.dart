import 'package:flutter/material.dart';

import '../themes/admin_theme.dart';
import '../widgets/admin_card.dart';

class TicketPricingScreen extends StatelessWidget {
  const TicketPricingScreen({
    super.key,
    required this.twoHoursPriceController,
    required this.sevenDaysPriceController,
    required this.onSavePrices,
  });

  final TextEditingController twoHoursPriceController;
  final TextEditingController sevenDaysPriceController;
  final VoidCallback onSavePrices;

  Widget pricingRow({
    required String title,
    required String description,
    required String currentPrice,
    required TextEditingController controller,
  }) {
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
          child: TextFormField(
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
                pricingRow(
                  title: '2-Hours Ticket',
                  description: 'Valid for two hours after purchase.',
                  currentPrice: '200',
                  controller: twoHoursPriceController,
                ),
                const Divider(height: 32),
                pricingRow(
                  title: '7-Days Ticket',
                  description: 'Valid for seven days after purchase.',
                  currentPrice: '2000',
                  controller: sevenDaysPriceController,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: onSavePrices,
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

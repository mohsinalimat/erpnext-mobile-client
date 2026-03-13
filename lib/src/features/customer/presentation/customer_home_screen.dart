import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/common_widgets.dart';
import 'widgets/customer_dock.dart';
import 'package:flutter/material.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Customer',
      subtitle: '',
      bottom: const CustomerDock(activeTab: CustomerDockTab.home),
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          _CustomerSummaryCard(),
          SizedBox(height: 16),
          SoftCard(
            child: Text('Customer oqimi keyingi bosqichda shu screen ustida quriladi.'),
          ),
        ],
      ),
    );
  }
}

class _CustomerSummaryCard extends StatelessWidget {
  const _CustomerSummaryCard();

  @override
  Widget build(BuildContext context) {
    return const SoftCard(
      padding: EdgeInsets.zero,
      borderWidth: 1.35,
      borderRadius: 20,
      child: Column(
        children: [
          _CustomerSummaryRow(label: 'Kutilmoqda', value: '0'),
          Divider(height: 1, thickness: 1),
          _CustomerSummaryRow(label: 'Tasdiqlangan', value: '0'),
          Divider(height: 1, thickness: 1),
          _CustomerSummaryRow(label: 'Rad etilgan', value: '0'),
        ],
      ),
    );
  }
}

class _CustomerSummaryRow extends StatelessWidget {
  const _CustomerSummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 34,
                ),
          ),
        ],
      ),
    );
  }
}

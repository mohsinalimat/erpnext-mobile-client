import '../../../core/api/mobile_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/motion_widgets.dart';
import '../../shared/models/app_models.dart';
import 'widgets/supplier_dock.dart';
import 'package:flutter/material.dart';

class SupplierHomeScreen extends StatefulWidget {
  const SupplierHomeScreen({super.key});

  @override
  State<SupplierHomeScreen> createState() => _SupplierHomeScreenState();
}

class _SupplierHomeScreenState extends State<SupplierHomeScreen> {
  late Future<List<DispatchRecord>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = MobileApi.instance.supplierHistory();
  }

  Future<void> _reload() async {
    final future = MobileApi.instance.supplierHistory();
    setState(() {
      _historyFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Supplier',
      subtitle: 'Jo‘natish va statuslarni shu yerdan boshqarasiz.',
      bottom: const SupplierDock(activeTab: SupplierDockTab.home),
      child: FutureBuilder<List<DispatchRecord>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: SoftCard(
                child: Text('Supplier history yuklanmadi: ${snapshot.error}'),
              ),
            );
          }

          final history = snapshot.data ?? <DispatchRecord>[];
          final pendingCount = history
              .where((item) => item.status == DispatchStatus.pending)
              .length;
          final acceptedCount = history
              .where((item) => item.status == DispatchStatus.accepted)
              .length;
          final itemCount = history
              .map((item) =>
                  item.itemCode.trim().isEmpty ? item.itemName : item.itemCode)
              .toSet()
              .length;
          final totalQty =
              history.fold<double>(0, (sum, item) => sum + item.sentQty);

          return RefreshIndicator.adaptive(
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                SmoothAppear(
                  child: _SummaryCard(
                    totalQty: totalQty,
                    pendingCount: pendingCount,
                    acceptedCount: acceptedCount,
                    itemCount: itemCount,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recent',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      '${history.length} ta',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (history.isEmpty)
                  const SoftCard(
                    child: Text('Hali jo‘natishlar yo‘q.'),
                  )
                else
                  SoftCard(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Column(
                      children: history.asMap().entries.map((entry) {
                        final index = entry.key;
                        final record = entry.value;
                        return SmoothAppear(
                          delay: Duration(milliseconds: 60 + (index * 35)),
                          offset: const Offset(0, 12),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            record.itemName.isEmpty
                                                ? record.itemCode
                                                : record.itemName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${record.sentQty.toStringAsFixed(0)} ${record.uom}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            record.createdLabel,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    StatusPill(status: record.status),
                                  ],
                                ),
                              ),
                              if (index != history.length - 1)
                                Divider(
                                  height: 1,
                                  color: AppTheme.dockDivider(context),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalQty,
    required this.pendingCount,
    required this.acceptedCount,
    required this.itemCount,
  });

  final double totalQty;
  final int pendingCount;
  final int acceptedCount;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Text(
            totalQty.toStringAsFixed(0),
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Jami jo‘natilgan birlik',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatChip(label: 'Pending', value: pendingCount.toString()),
              _StatChip(label: 'Accepted', value: acceptedCount.toString()),
              _StatChip(label: 'Items', value: itemCount.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.actionSurface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

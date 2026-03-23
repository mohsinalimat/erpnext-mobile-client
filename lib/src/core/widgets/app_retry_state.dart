import '../localization/app_localizations.dart';
import 'package:flutter/material.dart';

class AppRetryState extends StatelessWidget {
  const AppRetryState({
    super.key,
    required this.onRetry,
    this.padding = const EdgeInsets.fromLTRB(20, 120, 20, 24),
  });

  final Future<void> Function() onRetry;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.serverDisconnectedRetry,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onRetry,
                  child: Text(context.l10n.retry),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

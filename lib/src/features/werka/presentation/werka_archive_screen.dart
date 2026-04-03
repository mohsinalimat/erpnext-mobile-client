import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_shell.dart';
import 'widgets/werka_dock.dart';
import 'package:flutter/material.dart';

class WerkaArchiveScreen extends StatelessWidget {
  const WerkaArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppShell(
      title: context.l10n.archiveTitle,
      subtitle: '',
      bottom: const WerkaDock(activeTab: WerkaDockTab.archive),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 110),
        children: [
          Card.filled(
            margin: EdgeInsets.zero,
            color: scheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                context.l10n.archivePlaceholder,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

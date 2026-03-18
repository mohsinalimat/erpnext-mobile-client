import 'dart:ui';

import '../api/mobile_api.dart';
import '../localization/app_localizations.dart';
import '../security/security_controller.dart';
import 'package:flutter/material.dart';

Future<void> showLogoutPrompt(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (context) {
      final l10n = context.l10n;
      return Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                color: const Color(0x66000000),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Material(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 360),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.logoutTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.logoutPrompt),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                              ),
                              child: Text(l10n.no),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                              child: Text(l10n.yes),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
  if (confirmed != true || !context.mounted) {
    return;
  }

  await MobileApi.instance.logout();
  await SecurityController.instance.clearForLogout();
  if (!context.mounted) {
    return;
  }
  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
}

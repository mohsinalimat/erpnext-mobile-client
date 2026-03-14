import '../../../app/app_router.dart';
import '../../../core/api/mobile_api.dart';
import '../../../core/network/network_required_dialog.dart';
import '../../../core/notifications/push_messaging_service.dart';
import '../../../core/security/security_controller.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/motion_widgets.dart';
import '../../shared/models/app_models.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode codeFocusNode = FocusNode();
  String? errorText;
  bool loading = false;

  @override
  void dispose() {
    phoneController.dispose();
    codeController.dispose();
    phoneFocusNode.dispose();
    codeFocusNode.dispose();
    super.dispose();
  }

  void submitLogin(BuildContext context) {
    if (loading) {
      return;
    }
    final String phone = phoneController.text.trim();
    final String code = codeController.text.trim();

    if (phone.isEmpty || code.isEmpty) {
      setState(() => errorText = 'Telefon raqam va code ni kiriting');
      return;
    }
    setState(() {
      errorText = null;
      loading = true;
    });

    MobileApi.instance
        .login(phone: phone, code: code)
        .then((SessionProfile profile) {
      if (!context.mounted) {
        return;
      }
      PushMessagingService.instance.syncCurrentToken();
      SecurityController.instance.unlockAfterLogin();
      final String route = profile.role == UserRole.supplier
          ? AppRoutes.supplierHome
          : profile.role == UserRole.werka
              ? AppRoutes.werkaHome
              : profile.role == UserRole.customer
                  ? AppRoutes.customerHome
                  : AppRoutes.adminHome;
      Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
    }).catchError((error) {
      if (!context.mounted) {
        return;
      }
      setState(() {
        errorText = 'Login muvaffaqiyatsiz';
        loading = false;
      });
      final text = '$error';
      if (text.contains('SocketException') ||
          text.contains('ClientException') ||
          text.contains('Failed host lookup') ||
          text.contains('Connection refused') ||
          text.contains('timed out')) {
        showNetworkRequiredDialog(
          context,
          message: 'Iltimos internetga ulaning.',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final badgeBackground =
        isDark ? const Color(0xFF1C2434) : const Color(0xFFD9E3F8);
    final badgeForeground =
        isDark ? const Color(0xFFC7D7F7) : const Color(0xFF264A84);
    final panelBackground =
        isDark ? const Color(0xFF10141C) : const Color(0xFFF7F6F2);
    final panelBorder =
        isDark ? const Color(0xFF283244) : const Color(0xFFD8D4CB);
    final quietText =
        isDark ? const Color(0xFFB8C0CE) : const Color(0xFF5C6472);

    return AppShell(
      title: 'Accord',
      subtitle: 'Secure mobile access for warehouse operations',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SmoothAppear(
                          delay: const Duration(milliseconds: 20),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeBackground,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: panelBorder),
                                ),
                                child: Text(
                                  'Accord Mobile',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: badgeForeground,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                'Supplier, Werka, Customer, Admin',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: quietText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        SmoothAppear(
                          delay: const Duration(milliseconds: 40),
                          child: Text(
                            'One entry point for your daily ERP flow.',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontSize: 38,
                              height: 1.05,
                              letterSpacing: -1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SmoothAppear(
                          delay: const Duration(milliseconds: 70),
                          child: Text(
                            'Mavjud telefon raqam va code orqali tizimga kiring. Ilova ombor, jo‘natma va tasdiqlash jarayonlarini xavfsiz boshqaradi.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: quietText,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        SmoothAppear(
                          delay: const Duration(milliseconds: 90),
                          child: Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: panelBackground,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: panelBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? const Color(0x33000000)
                                      : const Color(0x12000000),
                                  blurRadius: 32,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Sign in',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontSize: 26),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ERPNext bilan bog‘langan ishchi profilingizni oching.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: quietText,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                AutofillGroup(
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: phoneController,
                                        focusNode: phoneFocusNode,
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.phone,
                                        autocorrect: false,
                                        enableSuggestions: true,
                                        autofillHints: const [
                                          AutofillHints.telephoneNumber
                                        ],
                                        decoration: const InputDecoration(
                                          labelText: 'Telefon raqam',
                                          hintText: 'Masalan: +998901234567',
                                          prefixIcon:
                                              Icon(Icons.phone_outlined),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      TextField(
                                        controller: codeController,
                                        focusNode: codeFocusNode,
                                        textInputAction: TextInputAction.done,
                                        autocorrect: false,
                                        enableSuggestions: true,
                                        autofillHints: const [
                                          AutofillHints.username
                                        ],
                                        onSubmitted: (_) {
                                          if (!loading) {
                                            submitLogin(context);
                                          }
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Code',
                                          hintText: 'Masalan: 10XXXXXXXXXX',
                                          prefixIcon:
                                              Icon(Icons.password_outlined),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (errorText != null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: scheme.errorContainer,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          color: scheme.onErrorContainer,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            errorText!,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: scheme.onErrorContainer,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                FilledButton.icon(
                                  onPressed: loading
                                      ? null
                                      : () => submitLogin(context),
                                  icon: loading
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: scheme.onPrimary,
                                          ),
                                        )
                                      : const Icon(Icons.arrow_forward_rounded),
                                  label: Text(
                                    loading ? 'Kuting...' : 'Login',
                                  ),
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(58),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

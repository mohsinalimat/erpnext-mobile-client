import '../../../app/app_router.dart';
import '../../../core/api/mobile_api.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/motion_widgets.dart';
import '../../shared/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String lastCodeKey = 'last_login_code';

  final TextEditingController codeController = TextEditingController();
  final TextEditingController secretController = TextEditingController();
  final FocusNode codeFocusNode = FocusNode();
  final FocusNode secretFocusNode = FocusNode();
  String? errorText;
  bool loading = false;
  String? rememberedCode;

  @override
  void initState() {
    super.initState();
    loadRememberedCode();
  }

  Future<void> loadRememberedCode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(lastCodeKey);
    if (!mounted) {
      return;
    }
    setState(() {
      rememberedCode = savedCode;
      if (codeController.text.trim().isEmpty &&
          savedCode != null &&
          savedCode.isNotEmpty) {
        codeController.text = savedCode;
      }
    });
  }

  Future<void> persistRememberedCode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      await prefs.remove(lastCodeKey);
      if (!mounted) {
        return;
      }
      setState(() {
        rememberedCode = null;
      });
      return;
    }

    await prefs.setString(lastCodeKey, trimmed);
    if (!mounted) {
      return;
    }
    setState(() {
      rememberedCode = trimmed;
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    secretController.dispose();
    codeFocusNode.dispose();
    secretFocusNode.dispose();
    super.dispose();
  }

  void submitLogin(BuildContext context) {
    if (loading) {
      return;
    }
    final String code = codeController.text.trim();
    final String secret = secretController.text.trim();

    if (code.isEmpty || secret.isEmpty) {
      setState(() => errorText = 'Code va secret ni kiriting');
      return;
    }
    setState(() {
      errorText = null;
      loading = true;
    });

    MobileApi.instance
        .login(code: code, secret: secret)
        .then((SessionProfile profile) {
      if (!context.mounted) {
        return;
      }
      final String route = profile.role == UserRole.supplier
          ? AppRoutes.supplierHome
          : AppRoutes.werkaHome;
      Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
    }).catchError((_) {
      if (!context.mounted) {
        return;
      }
      setState(() {
        errorText = 'Login muvaffaqiyatsiz';
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Login',
      subtitle: '',
      bottom: ElevatedButton(
        onPressed: loading ? null : () => submitLogin(context),
        child: Text(loading ? 'Kuting...' : 'Login'),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            AutofillGroup(
              child: Column(
                children: [
                  SmoothAppear(
                    delay: const Duration(milliseconds: 40),
                    child: TextField(
                      controller: codeController,
                      focusNode: codeFocusNode,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: true,
                      autofillHints: const [AutofillHints.username],
                      onChanged: persistRememberedCode,
                      onSubmitted: (_) => secretFocusNode.requestFocus(),
                      decoration: const InputDecoration(
                        labelText: 'Code',
                        hintText: 'Masalan: 10XXXXXXXXXX',
                      ),
                    ),
                  ),
                  if (rememberedCode != null && rememberedCode!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SmoothAppear(
                      delay: const Duration(milliseconds: 55),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ActionChip(
                          label: Text('Oxirgi code: $rememberedCode'),
                          onPressed: () {
                            codeController.text = rememberedCode!;
                            secretFocusNode.requestFocus();
                          },
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SmoothAppear(
                    delay: const Duration(milliseconds: 90),
                    child: TextField(
                      controller: secretController,
                      focusNode: secretFocusNode,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (!loading) {
                          submitLogin(context);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Secret',
                        hintText: 'Secret code',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (errorText != null) ...[
              const SizedBox(height: 14),
              SmoothAppear(
                delay: const Duration(milliseconds: 120),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0B0B),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Text(
                    errorText!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

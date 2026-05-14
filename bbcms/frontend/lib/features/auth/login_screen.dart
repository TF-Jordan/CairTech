import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/labeled_field.dart';
import '../../core/widgets/primary_button.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = ref.watch(authControllerProvider);
    return Scaffold(
      backgroundColor: BbcColors.ink,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // Dark hero
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 40, 28, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'B',
                            style: BbcTypo.serif(
                                size: 18, weight: FontWeight.w500, color: BbcColors.ink),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('BBCMS · CHF',
                            style: BbcTypo.mono(
                                size: 11,
                                letterSpacing: 2,
                                color: Colors.white.withOpacity(0.6))),
                      ],
                    ),
                    const Spacer(),
                    Text('CONNEXION',
                        style: BbcTypo.mono(
                            size: 10, color: Colors.white.withOpacity(0.5))),
                    const SizedBox(height: 8),
                    Text('Bienvenue\ndans la maison.',
                        style: BbcTypo.serif(
                            size: 44,
                            color: Colors.white,
                            letterSpacing: -0.9,
                            height: 1.05)),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: 280,
                      child: Text(
                        'Suivez votre fidélité, vos réunions et votre marche avec vos frères et sœurs.',
                        style: BbcTypo.sans(
                            size: 14,
                            color: Colors.white.withOpacity(0.65),
                            height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
            // Cream form
            Container(
              decoration: const BoxDecoration(
                color: BbcColors.bg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
              child: Column(
                children: <Widget>[
                  LabeledField(
                    label: 'Adresse e-mail',
                    controller: _email,
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  LabeledField(
                    label: 'Mot de passe',
                    controller: _password,
                    icon: Icons.lock_outline,
                    obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 18,
                          color: BbcColors.muted),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (auth.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(auth.error!,
                          style: BbcTypo.sans(size: 12, color: BbcColors.danger)),
                    ),
                  PrimaryButton(
                    label: auth.loading ? 'Connexion…' : 'Se connecter',
                    busy: auth.loading,
                    trailing: const Icon(Icons.arrow_forward),
                    onPressed: () async {
                      await ref
                          .read(authControllerProvider.notifier)
                          .login(_email.text.trim(), _password.text);
                    },
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => context.push('/onboarding'),
                    child: Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                              text: 'Pas encore membre ? ',
                              style: BbcTypo.sans(size: 13, color: BbcColors.muted)),
                          TextSpan(
                              text: 'Demander l\'adhésion',
                              style: BbcTypo.sans(
                                  size: 13,
                                  weight: FontWeight.w500,
                                  color: BbcColors.ink)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('V3.2 · SÉCURISÉ PAR JWT',
                      style: BbcTypo.mono(size: 9, color: BbcColors.muted2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

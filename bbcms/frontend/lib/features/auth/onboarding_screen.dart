import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/labeled_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/round_icon.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  String _userType = 'STUDENT';

  final TextEditingController _email = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  final TextEditingController _firstNames = TextEditingController();
  final TextEditingController _nextNames = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _profession = TextEditingController();

  List<Map<String, dynamic>> _bibleClubs = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _levels = <Map<String, dynamic>>[];
  Map<String, dynamic>? _selectedBbc;
  Map<String, dynamic>? _selectedLevel;
  bool _busy = false;
  String? _error;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _loadBibleClubs();
  }

  Future<void> _loadBibleClubs() async {
    try {
      final ApiClient api = ref.read(apiClientProvider);
      final List<Map<String, dynamic>> list = await api.publicBibleClubs();
      if (mounted) setState(() => _bibleClubs = list);
    } catch (_) {
      // silent — registration without a selection is still allowed for VISITOR
    }
  }

  Future<void> _onBbcChosen(Map<String, dynamic> bbc) async {
    setState(() {
      _selectedBbc = bbc;
      _selectedLevel = null;
      _levels = <Map<String, dynamic>>[];
    });
    try {
      final ApiClient api = ref.read(apiClientProvider);
      final List<Map<String, dynamic>> ls = await api.publicLevels(bbc['id'] as String);
      if (mounted) setState(() => _levels = ls);
    } catch (_) {}
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ApiClient api = ref.read(apiClientProvider);
      await api.registerUser(<String, dynamic>{
        'email': _email.text.trim(),
        'password': _pwd.text,
        'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        'firstNames': _firstNames.text.trim(),
        'nextNames': _nextNames.text.trim().isEmpty ? null : _nextNames.text.trim(),
        'requestedType': _userType,
        'bibleClubId': _selectedBbc?['id'],
        'levelId': _selectedLevel?['id'],
        'profession': _profession.text.trim().isEmpty ? null : _profession.text.trim(),
        'locale': 'fr',
      });
      if (mounted) setState(() => _success = true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Erreur réseau');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) return _SuccessView(onClose: () => context.go('/login'));
    return Scaffold(
      backgroundColor: BbcColors.bg,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: <Widget>[
                  RoundIcon(
                    icon: Icons.arrow_back,
                    onTap: () => _step > 0 ? setState(() => _step--) : context.pop(),
                  ),
                  const Spacer(),
                  Text('ÉTAPE 0${_step + 1} / 04',
                      style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
                  const Spacer(),
                  RoundIcon(icon: Icons.close, onTap: () => context.pop()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 14),
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < 4; i++) ...<Widget>[
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: i <= _step ? BbcColors.ink : BbcColors.hair,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (i < 3) const SizedBox(width: 4),
                  ],
                ],
              ),
            ),
            Expanded(child: SingleChildScrollView(child: _stepBody())),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
              child: PrimaryButton(
                label: _step == 3 ? 'Soumettre' : 'Continuer',
                busy: _busy,
                trailing: const Icon(Icons.arrow_forward),
                onPressed: _busy
                    ? null
                    : () {
                        if (_step == 3) {
                          _submit();
                        } else {
                          setState(() => _step++);
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepBody() {
    switch (_step) {
      case 0:
        return _ProfileStep(
          userType: _userType,
          onTypeChanged: (String v) => setState(() => _userType = v),
        );
      case 1:
        return _BbcStep(
          bibleClubs: _bibleClubs,
          selected: _selectedBbc,
          onSelected: _onBbcChosen,
          levels: _levels,
          selectedLevel: _selectedLevel,
          onLevelChanged: (Map<String, dynamic>? l) => setState(() => _selectedLevel = l),
        );
      case 2:
        return _IdentityStep(
          firstNames: _firstNames,
          nextNames: _nextNames,
          phone: _phone,
          profession: _profession,
          userType: _userType,
        );
      case 3:
        return _CredentialsStep(email: _email, password: _pwd, error: _error);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ProfileStep extends StatelessWidget {
  const _ProfileStep({required this.userType, required this.onTypeChanged});

  final String userType;
  final ValueChanged<String> onTypeChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('ADHÉSION · PROFIL',
                style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
            const SizedBox(height: 8),
            Text('Quel est votre lien\nau Bible Club ?',
                style: BbcTypo.serif(size: 32, height: 1.1)),
            const SizedBox(height: 6),
            Text('Le responsable national valide chaque demande sous 48 h.',
                style: BbcTypo.meta()),
            const SizedBox(height: 24),
            _typeOption('STUDENT', 'Étudiant',
                'Membre régulier d\'un club universitaire', Icons.menu_book_outlined),
            const SizedBox(height: 10),
            _typeOption('PROFESSIONAL', 'Professionnel',
                'Anciens & responsables, marché du travail', Icons.layers_outlined),
            const SizedBox(height: 10),
            _typeOption('VISITOR', 'Visiteur',
                'Accompagnement temporaire, en discernement', Icons.favorite_outline),
          ],
        ),
      );

  Widget _typeOption(String value, String label, String sub, IconData icon) {
    final bool sel = value == userType;
    return InkWell(
      onTap: () => onTypeChanged(value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: sel ? BbcColors.ink : BbcColors.surface,
          border: Border.all(color: sel ? BbcColors.ink : BbcColors.hair),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(
                    color: sel ? Colors.white.withOpacity(0.15) : BbcColors.hair),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: sel ? Colors.white : BbcColors.ink),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label,
                      style: BbcTypo.sans(
                          size: 15,
                          weight: FontWeight.w500,
                          color: sel ? Colors.white : BbcColors.ink)),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: BbcTypo.sans(
                          size: 12,
                          color: sel
                              ? Colors.white.withOpacity(0.7)
                              : BbcColors.muted)),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: sel ? Colors.white : Colors.transparent,
                border: Border.all(color: sel ? Colors.white : BbcColors.hair),
                shape: BoxShape.circle,
              ),
              child: sel
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: BbcColors.ink, shape: BoxShape.circle),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _BbcStep extends StatelessWidget {
  const _BbcStep({
    required this.bibleClubs,
    required this.selected,
    required this.onSelected,
    required this.levels,
    required this.selectedLevel,
    required this.onLevelChanged,
  });

  final List<Map<String, dynamic>> bibleClubs;
  final Map<String, dynamic>? selected;
  final ValueChanged<Map<String, dynamic>> onSelected;
  final List<Map<String, dynamic>> levels;
  final Map<String, dynamic>? selectedLevel;
  final ValueChanged<Map<String, dynamic>?> onLevelChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('BIBLE CLUB SOUHAITÉ',
                style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
            const SizedBox(height: 8),
            Text('Choisissez votre BBC',
                style: BbcTypo.serif(size: 28, height: 1.1)),
            const SizedBox(height: 16),
            if (bibleClubs.isEmpty)
              Text('Chargement…', style: BbcTypo.meta())
            else
              for (final Map<String, dynamic> bbc in bibleClubs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => onSelected(bbc),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected?['id'] == bbc['id'] ? BbcColors.ink : BbcColors.surface,
                        border: Border.all(
                            color: selected?['id'] == bbc['id']
                                ? BbcColors.ink
                                : BbcColors.hair),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.school_outlined,
                              size: 18,
                              color: selected?['id'] == bbc['id']
                                  ? Colors.white
                                  : BbcColors.ink),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(bbc['name'] as String,
                                    style: BbcTypo.sans(
                                      size: 14,
                                      weight: FontWeight.w500,
                                      color: selected?['id'] == bbc['id']
                                          ? Colors.white
                                          : BbcColors.ink,
                                    )),
                                if (bbc['schoolName'] != null)
                                  Text(bbc['schoolName'] as String,
                                      style: BbcTypo.sans(
                                          size: 12,
                                          color: selected?['id'] == bbc['id']
                                              ? Colors.white.withOpacity(0.7)
                                              : BbcColors.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            if (selected != null && levels.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text('NIVEAU', style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final Map<String, dynamic> l in levels)
                    InkWell(
                      onTap: () => onLevelChanged(l),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selectedLevel?['id'] == l['id']
                              ? BbcColors.ink
                              : BbcColors.surface,
                          border: Border.all(
                              color: selectedLevel?['id'] == l['id']
                                  ? BbcColors.ink
                                  : BbcColors.hair),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(l['name'] as String,
                            style: BbcTypo.sans(
                              size: 12,
                              weight: FontWeight.w500,
                              color: selectedLevel?['id'] == l['id']
                                  ? Colors.white
                                  : BbcColors.ink,
                            )),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      );
}

class _IdentityStep extends StatelessWidget {
  const _IdentityStep({
    required this.firstNames,
    required this.nextNames,
    required this.phone,
    required this.profession,
    required this.userType,
  });

  final TextEditingController firstNames;
  final TextEditingController nextNames;
  final TextEditingController phone;
  final TextEditingController profession;
  final String userType;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('IDENTITÉ', style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
            const SizedBox(height: 8),
            Text('Comment t\'appelles-tu ?',
                style: BbcTypo.serif(size: 28, height: 1.1)),
            const SizedBox(height: 16),
            LabeledField(label: 'Prénoms', controller: firstNames),
            const SizedBox(height: 12),
            LabeledField(label: 'Noms', controller: nextNames),
            const SizedBox(height: 12),
            LabeledField(
                label: 'Téléphone',
                controller: phone,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            if (userType == 'PROFESSIONAL') ...<Widget>[
              const SizedBox(height: 12),
              LabeledField(label: 'Profession', controller: profession),
            ],
          ],
        ),
      );
}

class _CredentialsStep extends StatelessWidget {
  const _CredentialsStep(
      {required this.email, required this.password, required this.error});

  final TextEditingController email;
  final TextEditingController password;
  final String? error;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('IDENTIFIANTS',
                style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
            const SizedBox(height: 8),
            Text('Crée tes accès', style: BbcTypo.serif(size: 28, height: 1.1)),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Email',
              controller: email,
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            LabeledField(
              label: 'Mot de passe (8+ caractères)',
              controller: password,
              icon: Icons.lock_outline,
              obscure: true,
            ),
            if (error != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(error!, style: BbcTypo.sans(size: 12, color: BbcColors.danger)),
            ],
          ],
        ),
      );
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: BbcColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.mark_email_read_outlined,
                    size: 48, color: BbcColors.positive),
                const SizedBox(height: 16),
                Text('Demande envoyée',
                    style: BbcTypo.serif(size: 28, height: 1.1)),
                const SizedBox(height: 8),
                Text(
                    'Vous recevrez un email d\'activation. Le responsable national valide chaque demande sous 48h.',
                    textAlign: TextAlign.center,
                    style: BbcTypo.meta()),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Aller à la connexion', onPressed: onClose),
              ],
            ),
          ),
        ),
      );
}

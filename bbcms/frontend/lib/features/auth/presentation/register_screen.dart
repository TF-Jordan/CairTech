import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/error/failures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../application/auth_controller.dart';
import '../domain/auth_models.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _step = 0;
  final _formKeys = List.generate(3, (_) => GlobalKey<FormState>());

  // Step 1 — Personal info
  final _firstNames = TextEditingController();
  final _nextNames = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  Gender? _gender;
  DateTime? _dob;

  // Step 2 — Spiritual journey
  DateTime? _dateBornAgain;
  final _howBornAgain = TextEditingController();
  DateTime? _dateEntered;

  // Step 3 — Membership
  UserType _type = UserType.student;
  final _profession = TextEditingController();
  final _bibleClubId = TextEditingController();
  final _levelId = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    for (final c in [
      _firstNames,
      _nextNames,
      _email,
      _phone,
      _password,
      _howBornAgain,
      _profession,
      _bibleClubId,
      _levelId,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKeys[_step].currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final req = RegisterRequest(
        email: _email.text.trim(),
        password: _password.text,
        firstNames: _firstNames.text.trim(),
        nextNames: _nextNames.text.trim().isEmpty ? null : _nextNames.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        dateOfBirth: _dob,
        gender: _gender,
        requestedType: _type,
        profession: _type == UserType.student ? null : _profession.text.trim(),
        bibleClubId: _type == UserType.student && _bibleClubId.text.isNotEmpty
            ? _bibleClubId.text.trim()
            : null,
        levelId: _type == UserType.student && _levelId.text.isNotEmpty
            ? _levelId.text.trim()
            : null,
        dateBornAgain: _dateBornAgain,
        howBornAgain: _howBornAgain.text.trim().isEmpty
            ? null
            : _howBornAgain.text.trim(),
        dateEntered: _dateEntered,
      );
      await ref.read(authControllerProvider.notifier).register(req);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Compte créé. Vérifiez votre email pour activer le compte.',
          ),
        ),
      );
      context.go(AppRoutes.login);
    } on AppFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Progress(step: _step, total: 3),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: IndexedStack(
                    index: _step,
                    children: [
                      _StepPersonal(
                        formKey: _formKeys[0],
                        firstNames: _firstNames,
                        nextNames: _nextNames,
                        email: _email,
                        phone: _phone,
                        password: _password,
                        gender: _gender,
                        dob: _dob,
                        onGender: (g) => setState(() => _gender = g),
                        onDob: (d) => setState(() => _dob = d),
                      ),
                      _StepSpiritual(
                        formKey: _formKeys[1],
                        howBornAgain: _howBornAgain,
                        dateBornAgain: _dateBornAgain,
                        dateEntered: _dateEntered,
                        onDateBornAgain: (d) =>
                            setState(() => _dateBornAgain = d),
                        onDateEntered: (d) =>
                            setState(() => _dateEntered = d),
                      ),
                      _StepMembership(
                        formKey: _formKeys[2],
                        type: _type,
                        profession: _profession,
                        bibleClubId: _bibleClubId,
                        levelId: _levelId,
                        onType: (t) => setState(() => _type = t),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _step -= 1),
                        child: const Text('Retour'),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: _step < 2 ? 'Continuer' : 'Créer le compte',
                      icon: _step < 2
                          ? Icons.arrow_forward
                          : Icons.check_rounded,
                      loading: _loading,
                      onPressed: () {
                        if (_step < 2) {
                          if (_formKeys[_step].currentState!.validate()) {
                            setState(() => _step += 1);
                          }
                        } else {
                          _submit();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.step, required this.total});
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: List.generate(total, (i) {
          final active = i <= step;
          return Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StepPersonal extends StatelessWidget {
  const _StepPersonal({
    required this.formKey,
    required this.firstNames,
    required this.nextNames,
    required this.email,
    required this.phone,
    required this.password,
    required this.gender,
    required this.dob,
    required this.onGender,
    required this.onDob,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNames;
  final TextEditingController nextNames;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController password;
  final Gender? gender;
  final DateTime? dob;
  final ValueChanged<Gender> onGender;
  final ValueChanged<DateTime> onDob;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          Text('Informations personnelles',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Renseignez vos coordonnées pour rejoindre le Bible Club.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          TextFormField(
            controller: firstNames,
            decoration: const InputDecoration(labelText: 'Prénoms *'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Requis' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: nextNames,
            decoration: const InputDecoration(labelText: 'Noms'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<Gender>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Homme'),
                  value: Gender.male,
                  groupValue: gender,
                  onChanged: (g) => onGender(g!),
                ),
              ),
              Expanded(
                child: RadioListTile<Gender>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Femme'),
                  value: Gender.female,
                  groupValue: gender,
                  onChanged: (g) => onGender(g!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DateField(
            label: 'Date de naissance',
            value: dob,
            onChanged: onDob,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email *'),
            validator: (v) => (v == null || !v.contains('@'))
                ? 'Email invalide'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Téléphone'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: password,
            obscureText: true,
            decoration:
                const InputDecoration(labelText: 'Mot de passe (min 8) *'),
            validator: (v) =>
                (v == null || v.length < 8) ? 'Min 8 caractères' : null,
          ),
        ],
      ),
    );
  }
}

class _StepSpiritual extends StatelessWidget {
  const _StepSpiritual({
    required this.formKey,
    required this.howBornAgain,
    required this.dateBornAgain,
    required this.dateEntered,
    required this.onDateBornAgain,
    required this.onDateEntered,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController howBornAgain;
  final DateTime? dateBornAgain;
  final DateTime? dateEntered;
  final ValueChanged<DateTime> onDateBornAgain;
  final ValueChanged<DateTime> onDateEntered;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          Text('Parcours spirituel',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Optionnel — partagez votre cheminement.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          _DateField(
            label: 'Date de nouvelle naissance',
            value: dateBornAgain,
            onChanged: onDateBornAgain,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: howBornAgain,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Comment êtes-vous né(e) de nouveau ?',
            ),
          ),
          const SizedBox(height: 12),
          _DateField(
            label: 'Date d\'entrée au Bible Club',
            value: dateEntered,
            onChanged: onDateEntered,
          ),
        ],
      ),
    );
  }
}

class _StepMembership extends StatelessWidget {
  const _StepMembership({
    required this.formKey,
    required this.type,
    required this.profession,
    required this.bibleClubId,
    required this.levelId,
    required this.onType,
  });

  final GlobalKey<FormState> formKey;
  final UserType type;
  final TextEditingController profession;
  final TextEditingController bibleClubId;
  final TextEditingController levelId;
  final ValueChanged<UserType> onType;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          Text('Type d\'adhésion',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          SegmentedButton<UserType>(
            segments: const [
              ButtonSegment(
                value: UserType.student,
                label: Text('Étudiant'),
                icon: Icon(Icons.school_outlined),
              ),
              ButtonSegment(
                value: UserType.professional,
                label: Text('Professionnel'),
                icon: Icon(Icons.work_outline),
              ),
            ],
            selected: {type},
            onSelectionChanged: (s) => onType(s.first),
          ),
          const SizedBox(height: 20),
          if (type == UserType.student) ...[
            TextFormField(
              controller: bibleClubId,
              decoration: const InputDecoration(
                labelText: 'Bible Club (UUID)',
                helperText:
                    'Saisissez l\'ID du Bible Club. Sera un sélecteur en V2.',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: levelId,
              decoration: const InputDecoration(
                labelText: 'Classe (UUID)',
                helperText: 'ID de la classe / niveau.',
              ),
            ),
          ] else
            TextFormField(
              controller: profession,
              decoration: const InputDecoration(
                labelText: 'Profession',
                hintText: 'Ex: Software Engineer',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requis' : null,
            ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final txt = value == null
        ? ''
        : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-'
            '${value!.day.toString().padLeft(2, '0')}';
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final now = DateTime.now();
        final d = await showDatePicker(
          context: context,
          firstDate: DateTime(1900),
          lastDate: now,
          initialDate: value ?? DateTime(now.year - 18),
        );
        if (d != null) onChanged(d);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(txt.isEmpty ? 'mm/jj/aaaa' : txt),
      ),
    );
  }
}

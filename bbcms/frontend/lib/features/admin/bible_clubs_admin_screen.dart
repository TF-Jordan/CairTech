import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/labeled_field.dart';
import '../../core/widgets/pill_tag.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/round_icon.dart';
import '../../core/widgets/screen_header.dart';

const String _kBbcLogoUrlPrefix = 'bbcms.bbc.logoUrl.';

class BibleClubsAdminScreen extends ConsumerStatefulWidget {
  const BibleClubsAdminScreen({super.key});

  @override
  ConsumerState<BibleClubsAdminScreen> createState() =>
      _BibleClubsAdminScreenState();
}

class _BibleClubsAdminScreenState
    extends ConsumerState<BibleClubsAdminScreen> {
  List<Map<String, dynamic>>? _bbcs;
  Map<String, String> _logos = <String, String>{};
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _bbcs = await ref.read(apiClientProvider).listBibleClubs();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _logos = <String, String>{
        for (final Map<String, dynamic> b in _bbcs!)
          if (prefs.getString('$_kBbcLogoUrlPrefix${b['id']}') != null)
            b['id'] as String:
                prefs.getString('$_kBbcLogoUrlPrefix${b['id']}')!,
      };
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createDialog() async {
    final TextEditingController name = TextEditingController();
    final TextEditingController school = TextEditingController();
    final TextEditingController goal = TextEditingController(text: '150');
    final bool? ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BbcColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext c) => Padding(
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          top: 24,
          bottom: MediaQuery.of(c).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Nouveau Bible Club',
                style: BbcTypo.serif(size: 24, height: 1.1)),
            const SizedBox(height: 16),
            LabeledField(label: 'Nom', controller: name),
            const SizedBox(height: 12),
            LabeledField(label: 'École / Université', controller: school),
            const SizedBox(height: 12),
            LabeledField(
                label: 'Objectif annuel (fidèles)',
                controller: goal,
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Créer',
              trailing: const Icon(Icons.check),
              onPressed: () => Navigator.of(c).pop(true),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(apiClientProvider).createBibleClub(<String, dynamic>{
        'name': name.text.trim(),
        'schoolName': school.text.trim(),
        'goalNbFaithful': int.tryParse(goal.text) ?? 0,
        'dateCreated': DateTime.now().toIso8601String().split('T').first,
      });
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _uploadLogo(Map<String, dynamic> bbc) async {
    final XFile? pick = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    if (pick == null) return;
    try {
      final Map<String, dynamic> up = await ref
          .read(apiClientProvider)
          .uploadLocalFile(File(pick.path), contentType: 'image/jpeg');
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          '$_kBbcLogoUrlPrefix${bbc['id']}', up['url'] as String);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _reset(Map<String, dynamic> bbc) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        backgroundColor: BbcColors.surface,
        title: Text('Reset annuel',
            style: BbcTypo.serif(size: 20)),
        content: Text(
          'Lancer le reset annuel de "${bbc['name']}" ?\n\nL\'écriture est gelée pendant l\'opération.',
          style: BbcTypo.sans(size: 13, color: BbcColors.ink),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text('Lancer')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(apiClientProvider).resetBibleClub(bbc['id'] as String);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reset déclenché')));
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BbcColors.bg,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ScreenHeader(
              eyebrow: 'Admin · Organization',
              title: 'Bible Clubs',
              actions: <Widget>[
                RoundIcon(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.maybePop(context),
                ),
                RoundIcon(icon: Icons.refresh, onTap: _load),
                RoundIcon(icon: Icons.add, onTap: _createDialog),
              ],
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: BbcColors.ink))
                  : _error != null
                      ? EmptyState(title: 'Indisponible', message: _error)
                      : _bbcs == null || _bbcs!.isEmpty
                          ? const EmptyState(title: 'Aucun BBC')
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: _bbcs!.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (BuildContext c, int i) {
                                final Map<String, dynamic> bbc = _bbcs![i];
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: BbcColors.surface,
                                    border: Border.all(color: BbcColors.hair),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () => _uploadLogo(bbc),
                                            child: Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: BbcColors.surface2,
                                                border: Border.all(
                                                    color: BbcColors.hair),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: _logos[bbc['id']] != null
                                                  ? Image.network(
                                                      _logos[bbc['id']]!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) =>
                                                          const Icon(
                                                              Icons.school_outlined,
                                                              color: BbcColors.muted),
                                                    )
                                                  : const Icon(
                                                      Icons.add_a_photo_outlined,
                                                      color: BbcColors.muted,
                                                      size: 18),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                    (bbc['name'] as String?) ??
                                                        'BBC',
                                                    style: BbcTypo.sans(
                                                        size: 14,
                                                        weight: FontWeight.w500)),
                                                if (bbc['schoolName'] != null)
                                                  Text(
                                                      bbc['schoolName']
                                                          as String,
                                                      style: BbcTypo.meta()),
                                              ],
                                            ),
                                          ),
                                          PillTag(
                                            (bbc['status'] as String?) ?? '?',
                                            kind: bbc['status'] == 'ACTIVE'
                                                ? PillKind.success
                                                : PillKind.warn,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: PrimaryButton(
                                              label: 'Niveaux',
                                              style: BbcButtonStyle.ghost,
                                              onPressed: () => context.push(
                                                  '/admin/bible-clubs/${bbc['id']}/levels'),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: PrimaryButton(
                                              label: 'Reset',
                                              style: BbcButtonStyle.danger,
                                              onPressed: () => _reset(bbc),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

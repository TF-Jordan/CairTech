import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/jwt_session.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/round_icon.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/section_header.dart';
import '../auth/auth_controller.dart';

const String _kProfilePhotoUrlPrefix = 'bbcms.profile.photoUrl.';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? _photoUrl;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restore());
  }

  Future<void> _restore() async {
    final JwtSession? s = ref.read(sessionProvider);
    if (s == null) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? url = prefs.getString('$_kProfilePhotoUrlPrefix${s.userId}');
    if (url != null && mounted) setState(() => _photoUrl = url);
  }

  Future<void> _pickPhoto() async {
    final XFile? pick = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    if (pick == null) return;
    setState(() => _uploading = true);
    try {
      final File f = File(pick.path);
      final Map<String, dynamic> up = await ref
          .read(apiClientProvider)
          .uploadLocalFile(f, contentType: 'image/jpeg');
      final String url = up['url'] as String;
      final JwtSession? s = ref.read(sessionProvider);
      if (s != null) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('$_kProfilePhotoUrlPrefix${s.userId}', url);
      }
      if (mounted) {
        setState(() => _photoUrl = url);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo de profil mise à jour')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final JwtSession? s = ref.watch(sessionProvider);
    final String email = s?.email ?? 'membre@chf.org';
    final String name = email.split('@').first;
    return Scaffold(
      backgroundColor: BbcColors.bg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const ScreenHeader(
              eyebrow: 'Mon compte',
              title: 'Profil',
              actions: <Widget>[RoundIcon(icon: Icons.edit_outlined)]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: BbcColors.surface,
                border: Border.all(color: BbcColors.hair),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Avatar(
                          name: name,
                          size: AvatarSize.lg,
                          imageUrl: _photoUrl),
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: InkWell(
                          onTap: _uploading ? null : _pickPhoto,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: BbcColors.ink,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2),
                            ),
                            child: _uploading
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 1.6,
                                        color: Colors.white))
                                : const Icon(Icons.photo_camera,
                                    size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            s?.isSuperAdmin == true
                                ? 'SUPER ADMIN · CHF'
                                : (s?.userType ?? 'MEMBRE'),
                            style: BbcTypo.mono(
                                size: 9.5, color: BbcColors.muted)),
                        const SizedBox(height: 3),
                        Text(name, style: BbcTypo.sans(size: 18, weight: FontWeight.w500)),
                        Text(email, style: BbcTypo.meta()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // QR membership card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: BbcColors.ink,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('CARTE DE MEMBRE',
                        style: BbcTypo.mono(
                            size: 9.5, color: Colors.white.withOpacity(0.5))),
                    const Spacer(),
                    Text('2025/26',
                        style: BbcTypo.mono(
                            size: 9.5, color: Colors.white.withOpacity(0.5))),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: QrImageView(
                        data:
                            'BBCMS:${s?.userId ?? ''}:${s?.bibleClubId ?? ''}:2025-26',
                        size: 72,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: BbcColors.ink,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: BbcColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(name,
                              style: BbcTypo.serif(
                                  size: 18,
                                  color: Colors.white,
                                  letterSpacing: -0.2)),
                          const SizedBox(height: 4),
                          Text(
                              'BBCMS-${(s?.userId ?? '').substring(0, 8).toUpperCase()}',
                              style: BbcTypo.mono(
                                  size: 10,
                                  color: Colors.white.withOpacity(0.6))),
                          const SizedBox(height: 2),
                          Text('VALIDE JUSQU\'AU 30/09/26',
                              style: BbcTypo.mono(
                                  size: 9,
                                  color: Colors.white.withOpacity(0.45))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Super-admin shortcut
          if (s?.isSuperAdmin == true) ...<Widget>[
            const SectionHeader('Administration', more: 'GOD-MODE'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: BbcColors.surface,
                border: Border.all(color: BbcColors.hair),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: <Widget>[
                  _AdminRow(
                    icon: Icons.dashboard_outlined,
                    label: 'Panneau d\'administration',
                    sub: 'Accès à toutes les ressources CHF',
                    onTap: () => context.push('/admin'),
                  ),
                  _AdminRow(
                    icon: Icons.public,
                    label: 'Vue nationale',
                    sub: 'Pilotage CHF',
                    onTap: () => context.push('/dashboard/national'),
                  ),
                ],
              ),
            ),
          ],
          // BBC leader shortcut
          if (s != null && s.canSeeBbcDashboard && !s.isSuperAdmin) ...<Widget>[
            const SectionHeader('Pilotage BBC'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: BbcColors.surface,
                border: Border.all(color: BbcColors.hair),
                borderRadius: BorderRadius.circular(14),
              ),
              child: _AdminRow(
                icon: Icons.bar_chart,
                label: 'Tableau de bord leader',
                sub: 'KPIs et inactifs',
                onTap: () => context.push('/dashboard/leader'),
              ),
            ),
          ],
          const SectionHeader('Paramètres'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: BbcColors.surface,
              border: Border.all(color: BbcColors.hair),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: const <Widget>[
                _AdminRow(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    sub: 'Push, e-mail, SMS'),
                _AdminRow(
                    icon: Icons.shield_outlined,
                    label: 'Confidentialité',
                    sub: 'Données & permissions'),
                _AdminRow(
                    icon: Icons.sync_outlined,
                    label: 'Synchronisation',
                    sub: 'Hors-ligne'),
                _AdminRow(
                    icon: Icons.menu_book_outlined,
                    label: 'Langue',
                    sub: 'Français',
                    last: true),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
            child: PrimaryButton(
              label: 'Se déconnecter',
              style: BbcButtonStyle.danger,
              trailing: const Icon(Icons.logout, color: BbcColors.danger),
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Center(
              child: Text('BBCMS · V3.2 · CHF · KINSHASA',
                  style: BbcTypo.mono(size: 9, color: BbcColors.muted2)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminRow extends StatelessWidget {
  const _AdminRow({
    required this.icon,
    required this.label,
    required this.sub,
    this.onTap,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback? onTap;
  final bool last;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: last ? Colors.transparent : BbcColors.hair2),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: BbcColors.surface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 14, color: BbcColors.muted),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(label,
                        style: BbcTypo.sans(
                            size: 13.5, weight: FontWeight.w500)),
                    Text(sub, style: BbcTypo.meta()),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 14, color: BbcColors.muted2),
            ],
          ),
        ),
      );
}

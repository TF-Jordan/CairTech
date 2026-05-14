import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/chip_selector.dart';
import '../../core/widgets/pill_tag.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/round_icon.dart';

enum _Status { present, late, excused, pending }

class _Row {
  _Row(this.name, this.level, this.status, [this.timestamp]);

  final String name;
  final String level;
  _Status status;
  String? timestamp;
}

class MeetingAttendanceScreen extends ConsumerStatefulWidget {
  const MeetingAttendanceScreen({super.key, required this.meetingId});

  final String meetingId;

  @override
  ConsumerState<MeetingAttendanceScreen> createState() =>
      _MeetingAttendanceScreenState();
}

class _MeetingAttendanceScreenState extends ConsumerState<MeetingAttendanceScreen> {
  final List<_Row> _rows = <_Row>[
    _Row('Marie Lukombo', 'L3', _Status.present, '16:02'),
    _Row('Patrice Diur', 'L2', _Status.present, '16:00'),
    _Row('Anne Mwenze', 'L1', _Status.present, '15:58'),
    _Row('Joseph Tshiala', 'L4', _Status.late, '16:18'),
    _Row('Esther Lumbu', 'L1', _Status.pending),
    _Row('Daniel Kayemba', 'L3', _Status.excused, 'Voyage'),
  ];
  String _filter = 'Tous';
  final List<File> _pictures = <File>[];
  bool _busy = false;

  Future<void> _addPicture() async {
    final XFile? pick =
        await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
    if (pick == null) return;
    setState(() => _pictures.add(File(pick.path)));
  }

  Future<void> _close() async {
    setState(() => _busy = true);
    try {
      // Upload pictures first → collect fileIds → call /meetings/{id}/record
      final List<String> ids = <String>[];
      for (final File f in _pictures) {
        final Map<String, dynamic> r =
            await ref.read(apiClientProvider).uploadLocalFile(f, contentType: 'image/jpeg');
        ids.add(r['id'] as String);
      }
      // We don't have a real meeting record API tied to this demo data set;
      // a real implementation would call:
      // await ref.read(apiClientProvider).recordMeeting(widget.meetingId, {...});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pointage clôturé (${ids.length} photos)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int present = _rows.where((_Row r) => r.status == _Status.present).length;
    final int excused = _rows.where((_Row r) => r.status == _Status.excused).length;
    return Scaffold(
      backgroundColor: BbcColors.bg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _Hero(present: present, excused: excused, total: _rows.length),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pointer un membre…',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 12, right: 8),
                  child: Icon(Icons.search, size: 16, color: BbcColors.muted),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 36, minHeight: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: BbcColors.hair),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: BbcColors.hair),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ChipSelector(
            options: <String>['Tous', 'Présents · $present', 'À pointer · ${_rows.where((_Row r) => r.status == _Status.pending).length}'],
            selected: _filter,
            onChanged: (String v) => setState(() => _filter = v),
          ),
          const SizedBox(height: 12),
          Container(
            color: BbcColors.surface,
            child: Column(
              children: <Widget>[
                for (final _Row r in _rows) _AttendanceRow(row: r, onTap: () {
                  setState(() {
                    r.status = r.status == _Status.present
                        ? _Status.pending
                        : _Status.present;
                    if (r.status == _Status.present) {
                      r.timestamp = TimeOfDay.now().format(context);
                    }
                  });
                }),
              ],
            ),
          ),
          // Pictures
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('PHOTOS DE LA RÉUNION',
                    style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
                const Spacer(),
                RoundIcon(icon: Icons.camera_alt_outlined, onTap: _addPicture),
              ],
            ),
          ),
          SizedBox(
            height: 80,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                for (final File f in _pictures)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(f, width: 64, height: 64, fit: BoxFit.cover),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 22),
            child: PrimaryButton(
              label: 'Clôturer le pointage',
              busy: _busy,
              trailing: const Icon(Icons.check),
              onPressed: _close,
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.present, required this.excused, required this.total});

  final int present;
  final int excused;
  final int total;

  @override
  Widget build(BuildContext context) => Container(
        color: BbcColors.ink,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  RoundIcon(
                    icon: Icons.arrow_back,
                    dark: true,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  const RoundIcon(icon: Icons.edit_outlined, dark: true),
                  const SizedBox(width: 6),
                  const RoundIcon(icon: Icons.more_horiz, dark: true),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Text('SAMEDI 10 MAI · 16:00',
                      style: BbcTypo.mono(
                          size: 10, color: Colors.white.withOpacity(0.55))),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('ÉTUDE',
                      style: BbcTypo.mono(size: 10, color: BbcColors.gold)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Romains 8 — La vie\npar l\'Esprit',
                  style: BbcTypo.serif(
                      size: 28, color: Colors.white, height: 1.1)),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Icon(Icons.place_outlined,
                      size: 12, color: Colors.white.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text('Salle B · Amphi',
                      style: BbcTypo.sans(
                          size: 12, color: Colors.white.withOpacity(0.7))),
                  const SizedBox(width: 10),
                  Icon(Icons.mic_outlined,
                      size: 12, color: Colors.white.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text('P. Mukendi',
                      style: BbcTypo.sans(
                          size: 12, color: Colors.white.withOpacity(0.7))),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                  height: 1, color: Colors.white.withOpacity(0.12)),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(child: _stat('PRÉSENTS', '$present', 'sur $total')),
                  Expanded(child: _stat('EXCUSÉS', '${excused.toString().padLeft(2, '0')}', '')),
                  Expanded(child: _stat('VISITEURS', '03', '')),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _stat(String l, String v, String s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l,
              style: BbcTypo.mono(
                  size: 9, color: Colors.white.withOpacity(0.5))),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(v,
                  style: BbcTypo.serif(
                      size: 22, color: Colors.white, height: 1, letterSpacing: -0.6)),
              if (s.isNotEmpty) ...<Widget>[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(s,
                      style: BbcTypo.sans(
                          size: 10, color: Colors.white.withOpacity(0.5))),
                ),
              ],
            ],
          ),
        ],
      );
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.row, required this.onTap});

  final _Row row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: BbcColors.hair)),
        ),
        child: Row(
          children: <Widget>[
            Avatar(name: row.name, size: AvatarSize.sm),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(row.name,
                      style: BbcTypo.sans(size: 13, weight: FontWeight.w500)),
                  Text(
                    'Niveau ${row.level}${row.timestamp != null ? ' · ${row.timestamp}' : ''}',
                    style: BbcTypo.meta(),
                  ),
                ],
              ),
            ),
            switch (row.status) {
              _Status.present => Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: BbcColors.ink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
              _Status.late => const PillTag('Retard', kind: PillKind.warn),
              _Status.excused => const PillTag('Excusé'),
              _Status.pending => Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    border: Border.all(color: BbcColors.hair, width: 1.5, style: BorderStyle.solid),
                    shape: BoxShape.circle,
                  ),
                ),
            },
          ],
        ),
      ),
    );
  }
}

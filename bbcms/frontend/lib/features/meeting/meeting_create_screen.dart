import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/jwt_session.dart';
import '../../core/widgets/labeled_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/round_icon.dart';
import '../auth/auth_controller.dart';

class MeetingCreateScreen extends ConsumerStatefulWidget {
  const MeetingCreateScreen({super.key});

  @override
  ConsumerState<MeetingCreateScreen> createState() => _MeetingCreateScreenState();
}

class _MeetingCreateScreenState extends ConsumerState<MeetingCreateScreen> {
  String _type = 'STUDY';
  final TextEditingController _title = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _start = const TimeOfDay(hour: 16, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 18, minute: 0);
  final TextEditingController _location = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final JwtSession? s = ref.read(sessionProvider);
      final Map<String, dynamic> body = <String, dynamic>{
        'title': _title.text.trim(),
        'type': _type,
        'bibleClubId': s?.bibleClubId,
        'plannedDate': _date.toIso8601String().split('T').first,
        'plannedStartTime': _fmt(_start),
        'plannedEndTime': _fmt(_end),
        'maxPictures': 10,
      };
      await ref.read(apiClientProvider).planMeeting(body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Réunion programmée')));
        context.pop();
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Erreur: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BbcColors.bg,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: <Widget>[
                  RoundIcon(icon: Icons.close, onTap: () => context.pop()),
                  const Spacer(),
                  Text('NOUVELLE RÉUNION',
                      style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
                  const Spacer(),
                  const RoundIcon(icon: Icons.more_horiz),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('BROUILLON',
                      style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
                  const SizedBox(height: 4),
                  Text('Programmer une\nréunion',
                      style: BbcTypo.serif(size: 28, height: 1.1)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                children: <Widget>[
                  Text('TYPE',
                      style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      for (final ({String code, String label}) t
                          in const <({String code, String label})>[
                        (code: 'STUDY', label: 'Étude'),
                        (code: 'PRAYER', label: 'Prière'),
                        (code: 'WORSHIP', label: 'Culte'),
                        (code: 'EVANGELISM', label: 'Évang.'),
                      ]) ...<Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _type = t.code),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _type == t.code
                                    ? BbcColors.ink
                                    : BbcColors.surface,
                                border: Border.all(
                                    color: _type == t.code
                                        ? BbcColors.ink
                                        : BbcColors.hair),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(t.label,
                                    style: BbcTypo.sans(
                                      size: 12,
                                      weight: FontWeight.w500,
                                      color: _type == t.code
                                          ? Colors.white
                                          : BbcColors.ink,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  LabeledField(label: 'Titre', controller: _title),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _DateTile(
                          label: 'Date',
                          value: _date.toString().split(' ').first,
                          onTap: () async {
                            final DateTime? d = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)),
                              initialDate: _date,
                            );
                            if (d != null) setState(() => _date = d);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DateTile(
                          label: 'Horaire',
                          value: '${_fmtT(_start)} → ${_fmtT(_end)}',
                          onTap: () async {
                            final TimeOfDay? s = await showTimePicker(
                              context: context, initialTime: _start);
                            if (s != null) {
                              final TimeOfDay? e = await showTimePicker(
                                context: context, initialTime: _end);
                              setState(() {
                                _start = s;
                                if (e != null) _end = e;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                      label: 'Lieu',
                      controller: _location,
                      icon: Icons.place_outlined),
                  if (_error != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: BbcTypo.sans(size: 12, color: BbcColors.danger)),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: PrimaryButton(
                      label: 'Brouillon',
                      style: BbcButtonStyle.ghost,
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: 'Publier',
                      busy: _busy,
                      trailing: const Icon(Icons.send),
                      onPressed: _busy ? null : _submit,
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

  String _fmtT(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}h${t.minute.toString().padLeft(2, '0')}';
}

class _DateTile extends StatelessWidget {
  const _DateTile(
      {required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label.toUpperCase(),
                style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: BbcColors.surface,
                border: Border.all(color: BbcColors.hair),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(value,
                  style: BbcTypo.sans(size: 15, color: BbcColors.ink)),
            ),
          ],
        ),
      );
}

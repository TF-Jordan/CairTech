/// Entity types supported by the backend `/sync/changes` endpoint.
enum SyncEntityKind {
  meeting,
  member,
  bibleClub,
  level,
  event,
  visitor,
  evangelism,
  discipleship,
  intercession,
  financialContrib,
  publication,
  attendanceScore,
}

extension SyncEntityKindX on SyncEntityKind {
  String get apiValue => switch (this) {
        SyncEntityKind.meeting => 'MEETING',
        SyncEntityKind.member => 'MEMBER',
        SyncEntityKind.bibleClub => 'BIBLE_CLUB',
        SyncEntityKind.level => 'LEVEL',
        SyncEntityKind.event => 'EVENT',
        SyncEntityKind.visitor => 'VISITOR',
        SyncEntityKind.evangelism => 'EVANGELISM',
        SyncEntityKind.discipleship => 'DISCIPLESHIP',
        SyncEntityKind.intercession => 'INTERCESSION',
        SyncEntityKind.financialContrib => 'FINANCIAL_CONTRIB',
        SyncEntityKind.publication => 'PUBLICATION',
        SyncEntityKind.attendanceScore => 'ATTENDANCE_SCORE',
      };
}

class SyncChange {
  const SyncChange({
    required this.id,
    required this.updatedAt,
    required this.version,
    required this.payload,
  });

  factory SyncChange.fromJson(Map<String, dynamic> j) => SyncChange(
        id: j['id'] as String,
        updatedAt: DateTime.parse(j['updatedAt'] as String),
        version: (j['version'] as num).toInt(),
        payload: (j['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
      );

  final String id;
  final DateTime updatedAt;
  final int version;
  final Map<String, dynamic> payload;
}

class SyncBatch {
  const SyncBatch({
    required this.kind,
    required this.cursorAdvancedTo,
    required this.count,
    required this.changes,
    this.since,
  });

  factory SyncBatch.fromJson(Map<String, dynamic> j) => SyncBatch(
        kind: j['kind'] as String,
        since: j['since'] != null
            ? DateTime.parse(j['since'] as String)
            : null,
        cursorAdvancedTo: DateTime.parse(j['cursorAdvancedTo'] as String),
        count: (j['count'] as num).toInt(),
        changes: ((j['changes'] as List?) ?? const [])
            .map((e) => SyncChange.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String kind;
  final DateTime? since;
  final DateTime cursorAdvancedTo;
  final int count;
  final List<SyncChange> changes;
}

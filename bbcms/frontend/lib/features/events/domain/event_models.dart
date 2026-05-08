enum EventType { conference, retreat, outreach, celebration }

extension EventTypeX on EventType {
  String get apiValue => switch (this) {
        EventType.conference => 'CONFERENCE',
        EventType.retreat => 'RETREAT',
        EventType.outreach => 'OUTREACH',
        EventType.celebration => 'CELEBRATION',
      };

  String get label => switch (this) {
        EventType.conference => 'Conférence',
        EventType.retreat => 'Retraite',
        EventType.outreach => 'Mission',
        EventType.celebration => 'Célébration',
      };

  static EventType fromApi(String v) => EventType.values.firstWhere(
        (e) => e.apiValue == v,
        orElse: () => EventType.conference,
      );
}

enum EventStatus { planned, registrationOpen, started, ended, cancelled }

extension EventStatusX on EventStatus {
  String get apiValue => switch (this) {
        EventStatus.planned => 'PLANNED',
        EventStatus.registrationOpen => 'REGISTRATION_OPEN',
        EventStatus.started => 'STARTED',
        EventStatus.ended => 'ENDED',
        EventStatus.cancelled => 'CANCELLED',
      };

  String get label => switch (this) {
        EventStatus.planned => 'Planifié',
        EventStatus.registrationOpen => 'Inscriptions ouvertes',
        EventStatus.started => 'En cours',
        EventStatus.ended => 'Terminé',
        EventStatus.cancelled => 'Annulé',
      };

  static EventStatus fromApi(String v) => EventStatus.values.firstWhere(
        (e) => e.apiValue == v,
        orElse: () => EventStatus.planned,
      );
}

class EventModel {
  const EventModel({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.plannedStart,
    this.plannedEnd,
    this.startedAt,
    this.endedAt,
    this.durationMinutes,
    this.location,
    this.maxPictures,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'] as String,
        title: json['title'] as String,
        type: EventTypeX.fromApi(json['type'] as String),
        status: EventStatusX.fromApi(json['status'] as String),
        plannedStart: json['plannedStart'] != null
            ? DateTime.parse(json['plannedStart'] as String)
            : null,
        plannedEnd: json['plannedEnd'] != null
            ? DateTime.parse(json['plannedEnd'] as String)
            : null,
        startedAt: json['startedAt'] != null
            ? DateTime.parse(json['startedAt'] as String)
            : null,
        endedAt: json['endedAt'] != null
            ? DateTime.parse(json['endedAt'] as String)
            : null,
        durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
        location: json['location'] as String?,
        maxPictures: (json['maxPictures'] as num?)?.toInt(),
      );

  final String id;
  final String title;
  final EventType type;
  final EventStatus status;
  final DateTime? plannedStart;
  final DateTime? plannedEnd;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int? durationMinutes;
  final String? location;
  final int? maxPictures;
}

class PlanEventRequest {
  const PlanEventRequest({
    required this.title,
    required this.type,
    required this.plannedStart,
    this.plannedEnd,
    this.location,
    this.maxPictures,
  });

  final String title;
  final EventType type;
  final DateTime plannedStart;
  final DateTime? plannedEnd;
  final String? location;
  final int? maxPictures;

  Map<String, dynamic> toJson() => {
        'title': title,
        'type': type.apiValue,
        'plannedStart': plannedStart.toUtc().toIso8601String(),
        if (plannedEnd != null)
          'plannedEnd': plannedEnd!.toUtc().toIso8601String(),
        if (location != null) 'location': location,
        if (maxPictures != null) 'maxPictures': maxPictures,
      };
}

class EventParticipation {
  const EventParticipation({
    required this.id,
    required this.eventId,
    required this.present,
    this.memberId,
    this.visitorId,
    this.registeredAt,
    this.presentAt,
  });

  factory EventParticipation.fromJson(Map<String, dynamic> json) =>
      EventParticipation(
        id: json['id'] as String,
        eventId: json['eventId'] as String,
        memberId: json['memberId'] as String?,
        visitorId: json['visitorId'] as String?,
        registeredAt: json['registeredAt'] != null
            ? DateTime.parse(json['registeredAt'] as String)
            : null,
        present: json['present'] as bool? ?? false,
        presentAt: json['presentAt'] != null
            ? DateTime.parse(json['presentAt'] as String)
            : null,
      );

  final String id;
  final String eventId;
  final String? memberId;
  final String? visitorId;
  final DateTime? registeredAt;
  final bool present;
  final DateTime? presentAt;
}

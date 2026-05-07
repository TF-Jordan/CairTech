# BBCMS Frontend (Flutter)

Client Flutter pour BBCMS (Bible Club Management Software).

## Cibles

- Mobile (Android, iOS)
- Web

## Thème

Light only. Couleurs inspirées du PDF des plans (bleu vif #2563EB).

## Stack

- Flutter 3.24+ / Dart 3.5+
- Riverpod, go_router, dio + retrofit
- freezed, drift, flutter_secure_storage
- google_fonts (Space Grotesk + Inter), fl_chart

## Configuration

Tous les endpoints du backend sont centralisés dans :

```
lib/core/network/api_endpoints.dart
```

Base URL configurable via `--dart-define=BBCMS_API_BASE_URL=https://...`.

## Démarrage

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome \
  --dart-define=BBCMS_API_BASE_URL=http://localhost:8080/api/v1/bbcms
```

## Structure

Architecture feature-first, Clean inspirée :

```
lib/
  app/        router, theme, app shell
  core/       network, storage, rbac, sync, error, theme, widgets
  features/   <feature>/{data,domain,presentation}
  l10n/       i18n
```

## Phases

Implémentation progressive en 11 phases (voir conversation).

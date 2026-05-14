# BBCMS — Frontend Mobile

App Flutter (Android-first) du **Bible Club Management System** (CHF), pilotée par le
backend Spring Boot dans `../backend/`.

## Stack

- Flutter 3.24+ / Dart 3.4+
- Riverpod 2 (state)
- go_router 14 (navigation)
- Dio 5 (HTTP) + JWT refresh interceptor
- Freezed + json_serializable (modèles immutables)
- flutter_secure_storage (tokens)
- google_fonts (Geist, Instrument Serif, Geist Mono)

## Démarrage

```bash
# Pré-requis : Flutter 3.24, Android SDK, backend démarré (cf ../backend/README.md)

flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Lancement Android (émulateur ou device USB)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

> `10.0.2.2` = hôte local depuis l'émulateur Android.
> Sur device physique, utiliser l'IP LAN de votre poste : `http://192.168.x.y:8080`.

## Architecture

```
lib/
├── main.dart                  Bootstrap + ProviderScope
├── app.dart                   MaterialApp.router + theme
├── core/
│   ├── theme/                 Tokens (couleurs, typo, radii, spacing)
│   ├── widgets/               Atoms du design system
│   ├── network/               Dio + interceptors + ApiClient
│   ├── storage/               SecureStorage, LocalCache
│   ├── router/                go_router, guards (auth, role)
│   └── utils/                 Helpers (jwt, date, format)
├── data/models/               Modèles freezed alignés sur les DTOs Java
├── features/                  1 dossier = 1 module backend
│   ├── auth/                  login, onboarding, activation
│   ├── dashboard/             member/leader/national/superadmin
│   ├── meeting/               list/create/attendance + pictures
│   ├── event/                 plan, enroll, presence
│   ├── publication/           verse + announcements
│   ├── intercession/          chains, slots, subjects
│   ├── finance/               contributions, payments
│   ├── people/                members directory + detail
│   ├── evangelism/            programs, records
│   ├── discipleship/          links, records
│   ├── profile/               settings + QR card
│   ├── admin/                 super-admin god-mode pages
│   └── storage/               file upload/download
└── shell/                     bottom-tab shell (role-aware)
```

## Super-admin god-mode

Le compte super-admin (`SYSTEM_ADMIN`) bootstrappé au démarrage du backend a
**toutes les permissions** (cf `17-seed-roles.xml`). À sa connexion, l'app
affiche un onglet "Admin" supplémentaire donnant accès à :

- Liste exhaustive des Bible Clubs (CRUD)
- Liste des demandes d'adhésion (PENDING/APPROVED/REJECTED)
- Vue globale national
- Gestion des niveaux et triumvirats
- Gestion des publications, programmes, chaînes de prière
- Trigger du reset annuel

## Routes backend consommées

Voir `lib/core/network/api_routes.dart` — toutes les routes du backend y sont
centralisées avec leur permission requise.

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

### Première fois — scaffolder les dossiers de plateforme

Le repo versionne uniquement `lib/`, `test/`, `pubspec.yaml` et les configs
spécifiques (`android/app/src/main/res/xml/network_security_config.xml`,
patches `*.md`). Les dossiers `android/`, `ios/`, `linux/`, etc. sont générés
par Flutter :

```bash
cd bbcms/frontend
flutter create . --platforms=android,ios,linux,macos,windows --org com.chf
flutter pub get
```

Puis **appliquez les patches** (lire pour copier-coller) :
- `android/MANIFEST_PATCH.md` — permission INTERNET + cleartext HTTP dev
- `ios/INFO_PLIST_PATCH.md` — ATS dev + permissions caméra/galerie

### Lancement

L'URL backend est résolue automatiquement selon la plateforme :

| Cible                              | URL par défaut         |
|-----------------------------------|------------------------|
| Émulateur Android                  | `http://10.0.2.2:8080` |
| Simulateur iOS / desktop / Chrome  | `http://localhost:8080`|
| Device physique (Android/iOS)      | **à surcharger**       |

```bash
# Émulateur Android (défaut OK)
flutter run -d emulator-5554

# Simulateur iOS (défaut OK)
flutter run -d "iPhone 15"

# Linux desktop / macOS desktop / Chrome
flutter run -d linux       # ou -d macos / -d chrome

# Device physique Android ou iOS — passer l'IP LAN du poste qui héberge le backend
flutter run --dart-define=API_BASE_URL=http://192.168.1.42:8080

# Production
flutter build apk --release --dart-define=API_BASE_URL=https://api.bbcms.chf.org
flutter build ios --release --dart-define=API_BASE_URL=https://api.bbcms.chf.org
```

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

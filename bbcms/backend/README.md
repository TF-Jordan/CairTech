# BBCMS — Backend

Backend Java 21 / Spring Boot 3 / WebFlux pour le **Bible Club Management System** (CHF).
Architecture **hexagonale** stricte (ports & adapters), monolithe modulaire packagé en un seul JAR.

## Stack

| Couche | Choix |
|---|---|
| Langage | Java 21 LTS |
| Build | Gradle 8.14 (Kotlin DSL) |
| Framework | Spring Boot 3.3 (WebFlux réactif) |
| Persistance | R2DBC (PostgreSQL) + Liquibase |
| Auth | JWT HS256 (jjwt) + BCrypt + RBAC interne scopé par BBC |
| Scheduler | `@Scheduled` + ShedLock (lock distribué via DB) |
| Bus events | Outbox transactionnelle (`bbcms_domain_event`) + `ApplicationEventPublisher` |
| Médias | MinIO (S3-compatible) |
| Notifications | SMTP (V1), FCM/APNS/SMS (V2) |
| Observabilité | Micrometer / Prometheus / Actuator |
| Tests | JUnit 5, Reactor Test, ArchUnit, Testcontainers |

## Structure (package-by-feature, hexagonale)

```
com.chf.bbcms/
├── shared/         # BaseEntity, DomainEvent, Outbox, ApiErrorResponse
├── config/         # SecurityConfiguration, ShedLockConfig, MinioConfig
├── authentication/ # JWT, login, refresh, password reset, activation
├── authorization/  # Role, Permission, RBAC (scopé bibleClubId)
├── identity/       # UserAccount + MembershipRequest (PII = source de vérité ici)
└── (V2) organization, people, meeting, event, attendance, evangelism,
      discipleship, intercession, finance, publication, reset
```

Chaque module suit la structure hexagonale:
```
<module>/
├── domain/         # Agrégats, VOs, enums (zéro dépendance Spring)
├── application/
│   ├── port/in/    # Use cases interfaces
│   ├── port/out/   # Repositories interfaces, ports techniques
│   └── service/    # Implémentations
└── adapter/
    ├── in/web/         # REST controllers
    ├── in/security/    # JWT filter
    └── out/persistence/ # R2DBC repositories
```

## Démarrage

### Pré-requis
- Java 21
- Docker & docker-compose

### Lancement infra locale
```bash
docker-compose up -d
```

### Lancement application
```bash
./gradlew bootRun
```

L'application démarre sur `http://localhost:8080`. OpenAPI: `http://localhost:8080/swagger-ui.html`.

### Tests
```bash
./gradlew test                              # tout
./gradlew test --tests "*ArchitectureTest"  # ArchUnit seulement
./gradlew test --tests "*IntegrationTest"   # Testcontainers
```

## Décisions techniques validées

- **PII**: source unique de vérité dans `bbcms_user_account` (pas de duplication dans `bbcms_member`)
- **Devise V1**: XAF unique
- **Évangélisation + events** comptent dans le score de fidélité
- **Sync offline**: V2 (pas dans cette V1)
- **RGPD**: anonymisation différée 24 mois après `REMOVED` (configurable via `bbcms_setting`)

## Migrations Liquibase

Master: `src/main/resources/db/changelog/db.changelog-master.xml`

Phase 1 livrée:
- `00-extensions` — pgcrypto
- `01-rbac-audit-settings` — Role, Permission, UserRoleAssignment, Setting
- `02-identity` — UserAccount, MembershipRequest, ActivationToken, PasswordResetToken, RefreshToken
- `14-domain-event-outbox` — table outbox transactionnelle
- `15-shedlock` — verrou distribué scheduler
- `16-seed-permissions` — catalogue (~70 permissions)
- `17-seed-roles` — 13 rôles standards + mappings
- `18-seed-settings` — seuils par défaut

## Endpoints livrés (Phase 1)

| Méthode | Path | Permission |
|---|---|---|
| POST | `/api/v1/bbcms/auth/login` | (publique) |
| POST | `/api/v1/bbcms/auth/refresh` | (publique) |
| POST | `/api/v1/bbcms/auth/logout` | (publique) |
| POST | `/api/v1/bbcms/users` | (publique — VISITOR) |
| POST | `/api/v1/bbcms/users/activate?token=...` | (publique) |
| GET | `/api/v1/bbcms/users/{id}` | authentifié |

## Prochaines phases

- **Phase 2** (organization, people): BibleClub, Level, Member polymorphe, Visitor
- **Phase 3** (activités): Meeting, Event, Attendance + FaithfulnessEngine, schedulers
- **Phase 4**: Evangelism, Discipleship, Intercession, Finance, Publications, Notifications push/SMS
- **Phase 5**: Reset BBC, Dashboards, hardening
- **Phase 6** (V2): Sync offline mobile/desktop

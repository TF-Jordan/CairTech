package com.chf.bbcms.bootstrap;

import com.chf.bbcms.authentication.application.port.out.PasswordHasher;
import com.chf.bbcms.identity.application.port.out.UserAccountRepository;
import com.chf.bbcms.identity.domain.Gender;
import com.chf.bbcms.identity.domain.UserAccount;
import com.chf.bbcms.identity.domain.UserProfile;
import com.chf.bbcms.identity.domain.UserType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.event.EventListener;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

/**
 * Crée automatiquement un compte SUPER ADMIN au démarrage si aucun n'existe
 * avec l'email configuré (bbcms.bootstrap.super-admin.email).
 *
 * - Idempotent: re-démarrer ne duplique pas, ne réécrase pas le mot de passe.
 * - Le compte est créé ACTIVE (pas besoin d'activation par e-mail).
 * - user_type = NATIONAL_LEADER, role assigné = SYSTEM_ADMIN (toutes permissions).
 *
 * Le rôle SYSTEM_ADMIN (UUID 11111111-0000-0000-0000-000000000001) est seedé par
 * la migration 17-seed-roles avec toutes les permissions du catalogue.
 */
@Component
@EnableConfigurationProperties(SuperAdminProperties.class)
public class SuperAdminBootstrap {

    private static final Logger log = LoggerFactory.getLogger(SuperAdminBootstrap.class);

    private static final UUID SYSTEM_USER = UUID.fromString("00000000-0000-0000-0000-000000000000");
    private static final UUID SYSTEM_ADMIN_ROLE = UUID.fromString("11111111-0000-0000-0000-000000000001");

    private final SuperAdminProperties props;
    private final UserAccountRepository userRepository;
    private final PasswordHasher passwordHasher;
    private final DatabaseClient client;

    public SuperAdminBootstrap(SuperAdminProperties props,
                               UserAccountRepository userRepository,
                               PasswordHasher passwordHasher,
                               DatabaseClient client) {
        this.props = props;
        this.userRepository = userRepository;
        this.passwordHasher = passwordHasher;
        this.client = client;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void onApplicationReady() {
        if (!props.isEnabled()) {
            log.info("Super-admin bootstrap disabled (bbcms.bootstrap.super-admin.enabled=false)");
            return;
        }
        if (props.getEmail() == null || props.getEmail().isBlank()
                || props.getPassword() == null || props.getPassword().isBlank()) {
            log.warn("Super-admin bootstrap skipped: email/password missing in .env or env vars "
                    + "(BBCMS_SUPER_ADMIN_EMAIL / BBCMS_SUPER_ADMIN_PASSWORD)");
            return;
        }

        bootstrap()
                .doOnError(ex -> log.error("Super-admin bootstrap failed: {}", ex.getMessage(), ex))
                .subscribe();
    }

    private Mono<Void> bootstrap() {
        String email = props.getEmail().trim().toLowerCase();
        return userRepository.findByEmail(email)
                .flatMap(existing -> {
                    log.info("Super-admin '{}' already exists (status={}); ensuring role + user_type",
                            email, existing.getStatus());
                    // Normalise les valeurs en DB (corrige user_type orphelin ex 'SYSTEM_ADMIN')
                    // et garantit que le compte est ACTIVE.
                    return normalizeRow(existing.getId())
                            .then(ensureRoleAssignment(existing.getId()));
                })
                .switchIfEmpty(Mono.defer(() -> createSuperAdmin(email)))
                .then();
    }

    private Mono<Void> normalizeRow(UUID userId) {
        return client.sql("""
                UPDATE bbcms_user_account
                   SET status = 'ACTIVE',
                       user_type = CASE
                           WHEN user_type IN ('VISITOR','STUDENT','PROFESSIONAL','NATIONAL_LEADER') THEN user_type
                           ELSE 'NATIONAL_LEADER'
                       END
                 WHERE id = :id
                """)
                .bind("id", userId)
                .then();
    }

    private Mono<Void> createSuperAdmin(String email) {
        return passwordHasher.hash(props.getPassword())
                .flatMap(hash -> {
                    UserProfile profile = new UserProfile(
                            props.getFirstNames(), props.getNextNames(),
                            null, Gender.MALE, null, null, null, null);
                    UserAccount account = UserAccount.register(email, hash, null, profile, "fr");
                    return userRepository.save(account);
                })
                .flatMap(saved -> {
                    // forcer ACTIVE + NATIONAL_LEADER (register() laisse PENDING/VISITOR par défaut)
                    return client.sql("""
                            UPDATE bbcms_user_account
                               SET status = 'ACTIVE',
                                   user_type = 'NATIONAL_LEADER'
                             WHERE id = :id
                            """)
                            .bind("id", saved.getId())
                            .then()
                            .then(ensureRoleAssignment(saved.getId()))
                            .doOnSuccess(v -> log.info("✅ Super-admin created: {} (id={})", email, saved.getId()));
                });
    }

    private Mono<Void> ensureRoleAssignment(UUID userId) {
        return client.sql("""
                SELECT count(*) AS n
                  FROM bbcms_user_role_assignment
                 WHERE user_account_id = :uid AND role_id = :rid AND active = true
                """)
                .bind("uid", userId)
                .bind("rid", SYSTEM_ADMIN_ROLE)
                .map((row, m) -> row.get("n", Long.class))
                .one()
                .flatMap(count -> {
                    if (count != null && count > 0) return Mono.empty();
                    return client.sql("""
                            INSERT INTO bbcms_user_role_assignment
                                (user_account_id, role_id, scope_bible_club_id, active,
                                 created_by, created_at, updated_by, updated_at, version)
                            VALUES (:uid, :rid, NULL, true, :sys, :now, :sys, :now, 0)
                            """)
                            .bind("uid", userId)
                            .bind("rid", SYSTEM_ADMIN_ROLE)
                            .bind("sys", SYSTEM_USER)
                            .bind("now", Instant.now())
                            .then();
                });
    }
}

package com.chf.bbcms.identity.application.service;

import com.chf.bbcms.authentication.application.port.out.ActivationTokenRepository;
import com.chf.bbcms.authentication.application.port.out.PasswordHasher;
import com.chf.bbcms.authentication.domain.ActivationToken;
import com.chf.bbcms.identity.application.port.in.ManageUserAccountUseCase;
import com.chf.bbcms.identity.application.port.in.RegisterUserCommand;
import com.chf.bbcms.identity.application.port.out.UserAccountRepository;
import com.chf.bbcms.identity.domain.UserAccount;
import com.chf.bbcms.identity.domain.UserProfile;
import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import com.chf.bbcms.shared.domain.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.reactive.TransactionalOperator;
import reactor.core.publisher.Mono;

import java.time.Duration;
import java.util.UUID;

@Service
public class UserAccountService implements ManageUserAccountUseCase {

    private static final Duration ACTIVATION_TTL = Duration.ofDays(7);

    private final UserAccountRepository userRepository;
    private final ActivationTokenRepository activationTokenRepository;
    private final PasswordHasher passwordHasher;
    private final TransactionalOperator txOperator;

    public UserAccountService(UserAccountRepository userRepository,
                              ActivationTokenRepository activationTokenRepository,
                              PasswordHasher passwordHasher,
                              TransactionalOperator txOperator) {
        this.userRepository = userRepository;
        this.activationTokenRepository = activationTokenRepository;
        this.passwordHasher = passwordHasher;
        this.txOperator = txOperator;
    }

    @Override
    public Mono<UserAccount> register(RegisterUserCommand cmd) {
        return userRepository.existsByEmail(cmd.email())
                .flatMap(exists -> {
                    if (Boolean.TRUE.equals(exists)) {
                        return Mono.error(new BusinessRuleViolation(
                                "BBCMS_EMAIL_TAKEN", "Email already registered: " + cmd.email()));
                    }
                    return passwordHasher.hash(cmd.plainPassword())
                            .flatMap(hash -> {
                                UserProfile profile = new UserProfile(
                                        cmd.firstNames(), cmd.nextNames(), cmd.dateOfBirth(),
                                        cmd.gender(), null, null, null, null);
                                UserAccount account = UserAccount.register(
                                        cmd.email(), hash, cmd.phone(), profile, cmd.locale());
                                return userRepository.save(account)
                                        .flatMap(saved -> activationTokenRepository
                                                .save(ActivationToken.issue(saved.getId(), ACTIVATION_TTL))
                                                .thenReturn(saved));
                            });
                })
                .as(txOperator::transactional);
    }

    @Override
    public Mono<UserAccount> activateByToken(String activationToken) {
        return activationTokenRepository.findByToken(activationToken)
                .switchIfEmpty(Mono.error(new NotFoundException("ActivationToken", activationToken)))
                .flatMap(token -> {
                    token.consume();
                    return activationTokenRepository.save(token)
                            .then(userRepository.findById(token.getUserAccountId()))
                            .switchIfEmpty(Mono.error(new NotFoundException("UserAccount", token.getUserAccountId())))
                            .flatMap(account -> {
                                account.activate();
                                return userRepository.save(account);
                            });
                })
                .as(txOperator::transactional);
    }

    @Override
    public Mono<UserAccount> findById(UUID id) {
        return userRepository.findById(id)
                .switchIfEmpty(Mono.error(new NotFoundException("UserAccount", id)));
    }
}

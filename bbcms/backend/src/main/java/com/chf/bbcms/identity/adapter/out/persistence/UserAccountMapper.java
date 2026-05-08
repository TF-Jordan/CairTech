package com.chf.bbcms.identity.adapter.out.persistence;

import com.chf.bbcms.identity.domain.Gender;
import com.chf.bbcms.identity.domain.UserAccount;
import com.chf.bbcms.identity.domain.UserProfile;
import com.chf.bbcms.identity.domain.UserStatus;
import com.chf.bbcms.identity.domain.UserType;

import java.time.Instant;
import java.util.UUID;

final class UserAccountMapper {

    private static final UUID SYSTEM = UUID.fromString("00000000-0000-0000-0000-000000000000");

    private UserAccountMapper() {}

    static UserAccount toDomain(UserAccountRow row) {
        UserProfile profile = new UserProfile(
                row.getFirstNames(), row.getNextNames(), row.getDateOfBirth(),
                row.getGender() == null ? null : Gender.valueOf(row.getGender()),
                row.getDateBornAgain(), row.getHowBornAgain(), row.getDateEntered(),
                row.getPictureFileId());
        return UserAccount.rehydrate(row.getId(), row.getEmail(), row.getPasswordHash(), row.getPhone(),
                parseStatus(row.getStatus()), parseUserType(row.getUserType()),
                row.getLastLoginAt(), row.getLocale(), profile, row.getAnonymizedAt(),
                row.getCreatedAt(), row.getUpdatedAt(), row.getVersion());
    }

    private static UserStatus parseStatus(String raw) {
        try {
            return UserStatus.valueOf(raw);
        } catch (IllegalArgumentException ex) {
            return UserStatus.PENDING;
        }
    }

    private static UserType parseUserType(String raw) {
        try {
            return UserType.valueOf(raw);
        } catch (IllegalArgumentException ex) {
            // Tolérant: si la DB contient une valeur orpheline (ex: 'SYSTEM_ADMIN' qui est
            // un rôle, pas un user type), on retombe sur NATIONAL_LEADER pour ne pas casser
            // la lecture. Le bootstrap normalise ensuite.
            return UserType.NATIONAL_LEADER;
        }
    }

    static UserAccountRow toRow(UserAccount account, UUID actorId) {
        UserAccountRow row = new UserAccountRow();
        row.setId(account.getId());
        row.setEmail(account.getEmail());
        row.setPasswordHash(account.getPasswordHash());
        row.setPhone(account.getPhone());
        row.setStatus(account.getStatus().name());
        row.setUserType(account.getUserType().name());
        row.setLastLoginAt(account.getLastLoginAt());
        row.setLocale(account.getLocale());

        UserProfile p = account.getProfile();
        row.setFirstNames(p.firstNames());
        row.setNextNames(p.nextNames());
        row.setDateOfBirth(p.dateOfBirth());
        row.setGender(p.gender() == null ? null : p.gender().name());
        row.setDateBornAgain(p.dateBornAgain());
        row.setHowBornAgain(p.howBornAgain());
        row.setDateEntered(p.dateEntered());
        row.setPictureFileId(p.pictureFileId());

        row.setAnonymizedAt(account.getAnonymizedAt());

        UUID who = actorId == null ? SYSTEM : actorId;
        if (account.getId() == null) {
            row.setCreatedBy(who);
            row.setCreatedAt(Instant.now());
        } else {
            row.setCreatedBy(account.getCreatedBy() == null ? who : account.getCreatedBy());
            row.setCreatedAt(account.getCreatedAt() == null ? Instant.now() : account.getCreatedAt());
        }
        row.setUpdatedBy(who);
        row.setUpdatedAt(Instant.now());
        row.setVersion(account.getVersion());
        return row;
    }
}

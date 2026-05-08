package com.chf.bbcms.organization.adapter.in.web;

import com.chf.bbcms.organization.application.port.in.ManageBibleClubUseCase;
import com.chf.bbcms.organization.application.port.in.ManageLevelUseCase;
import com.chf.bbcms.organization.domain.BibleClub;
import com.chf.bbcms.organization.domain.Level;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

import java.util.UUID;

/**
 * Endpoints publics (sans auth) consommés par le formulaire d'inscription:
 * lister les Bible Clubs et leurs classes pour peupler les selects.
 *
 * Les payloads sont volontairement restreints (id + name + schoolName/type).
 */
@RestController
@RequestMapping("/api/v1/bbcms/public")
public class PublicRegistryController {

    private final ManageBibleClubUseCase bibleClubs;
    private final ManageLevelUseCase levels;

    public PublicRegistryController(ManageBibleClubUseCase bibleClubs,
                                    ManageLevelUseCase levels) {
        this.bibleClubs = bibleClubs;
        this.levels = levels;
    }

    @GetMapping("/bible-clubs")
    public Flux<PublicBibleClubDto> listBibleClubs() {
        return bibleClubs.listAll()
                .filter(b -> b.getStatus().name().equals("ACTIVE"))
                .map(PublicBibleClubDto::from);
    }

    @GetMapping("/bible-clubs/{bibleClubId}/levels")
    public Flux<PublicLevelDto> listLevels(@PathVariable UUID bibleClubId) {
        return levels.listByBibleClub(bibleClubId).map(PublicLevelDto::from);
    }

    public record PublicBibleClubDto(UUID id, String name, String schoolName) {
        static PublicBibleClubDto from(BibleClub b) {
            return new PublicBibleClubDto(b.getId(), b.getName(), b.getSchoolName());
        }
    }

    public record PublicLevelDto(UUID id, String name, String type) {
        static PublicLevelDto from(Level l) {
            return new PublicLevelDto(l.getId(), l.getName(), l.getType().name());
        }
    }
}

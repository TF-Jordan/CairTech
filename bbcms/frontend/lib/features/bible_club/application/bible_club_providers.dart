import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bible_club_repository.dart';
import '../domain/bible_club_models.dart';

final bibleClubsProvider = FutureProvider.autoDispose<List<BibleClub>>((ref) {
  return ref.watch(bibleClubRepositoryProvider).list();
});

final bibleClubProvider =
    FutureProvider.autoDispose.family<BibleClub, String>((ref, id) {
  return ref.watch(bibleClubRepositoryProvider).getById(id);
});

final levelsProvider =
    FutureProvider.autoDispose.family<List<Level>, String>((ref, bibleClubId) {
  return ref.watch(bibleClubRepositoryProvider).listLevels(bibleClubId);
});

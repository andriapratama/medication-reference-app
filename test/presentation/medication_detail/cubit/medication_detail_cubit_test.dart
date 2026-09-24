import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medication_reference_app/core/error/failure.dart';
import 'package:medication_reference_app/core/utils/result.dart';
import 'package:medication_reference_app/domain/entities/medication_detail.dart';
import 'package:medication_reference_app/domain/usecases/add_favorite.dart';
import 'package:medication_reference_app/domain/usecases/get_medication_detail.dart';
import 'package:medication_reference_app/domain/usecases/remove_favorite.dart';
import 'package:medication_reference_app/presentation/medication_detail/cubit/medication_detail_cubit.dart';
import 'package:medication_reference_app/presentation/medication_detail/cubit/medication_detail_state.dart';

// Fake use cases so the cubit is tested without repository, network, or Hive.
class MockGetMedicationDetail extends Mock implements GetMedicationDetail {}

class MockAddFavorite extends Mock implements AddFavorite {}

class MockRemoveFavorite extends Mock implements RemoveFavorite {}

void main() {
  late MockGetMedicationDetail getDetail;
  late MockAddFavorite addFavorite;
  late MockRemoveFavorite removeFavorite;

  const detail = MedicationDetail(
    id: 'abc-123',
    brandName: 'Tylenol',
    type: MedicationType.otc,
  );
  final favoriteDetail = detail.copyWith(isFavorite: true);
  const network = NetworkFailure('offline');
  const storage = UnknownFailure('hive error');

  setUp(() {
    getDetail = MockGetMedicationDetail();
    addFavorite = MockAddFavorite();
    removeFavorite = MockRemoveFavorite();
  });

  MedicationDetailCubit buildCubit() => MedicationDetailCubit(
    getMedicationDetail: getDetail,
    addFavorite: addFavorite,
    removeFavorite: removeFavorite,
  );

  test('initial state is MedicationDetailInitial', () {
    expect(buildCubit().state, MedicationDetailInitial());
  });

  group('fetchDetail', () {
    blocTest<MedicationDetailCubit, MedicationDetailState>(
      'emits [Loading, Loaded] on success',
      setUp: () => when(() => getDetail('abc-123')).thenAnswer((_) async => const Ok(detail)),
      build: buildCubit,
      act: (cubit) => cubit.fetchDetail('abc-123'),
      expect: () => [MedicationDetailLoading(), const MedicationDetailLoaded(detail)],
    );

    blocTest<MedicationDetailCubit, MedicationDetailState>(
      'emits [Loading, Error] on failure',
      setUp: () => when(() => getDetail('abc-123')).thenAnswer((_) async => const Err(network)),
      build: buildCubit,
      act: (cubit) => cubit.fetchDetail('abc-123'),
      expect: () => [MedicationDetailLoading(), const MedicationDetailError(network)],
    );

    test('does not throw when the response arrives after the cubit is closed', () async {
      // Keep the request open, leave the screen, then let the response arrive.
      final pending = Completer<Result<MedicationDetail>>();
      when(() => getDetail('abc-123')).thenAnswer((_) => pending.future);
      final cubit = buildCubit();

      final fetch = cubit.fetchDetail('abc-123');
      await cubit.close();
      pending.complete(const Ok(detail));

      await expectLater(fetch, completes);
    });
  });

  group('toggleFavorite', () {
    blocTest<MedicationDetailCubit, MedicationDetailState>(
      'adds to favorites and fills the star immediately',
      setUp: () => when(() => addFavorite(favoriteDetail)).thenAnswer((_) async => const Ok(null)),
      build: buildCubit,
      seed: () => const MedicationDetailLoaded(detail),
      act: (cubit) => cubit.toggleFavorite(),
      expect: () => [MedicationDetailLoaded(favoriteDetail)],
      verify: (_) => verify(() => addFavorite(favoriteDetail)).called(1),
    );

    blocTest<MedicationDetailCubit, MedicationDetailState>(
      'removes from favorites when already a favorite',
      setUp: () => when(() => removeFavorite('abc-123')).thenAnswer((_) async => const Ok(null)),
      build: buildCubit,
      seed: () => MedicationDetailLoaded(favoriteDetail),
      act: (cubit) => cubit.toggleFavorite(),
      expect: () => [const MedicationDetailLoaded(detail)],
      verify: (_) => verify(() => removeFavorite('abc-123')).called(1),
    );

    blocTest<MedicationDetailCubit, MedicationDetailState>(
      'reverts the star when saving fails',
      setUp: () => when(() => addFavorite(favoriteDetail)).thenAnswer((_) async => const Err(storage)),
      build: buildCubit,
      seed: () => const MedicationDetailLoaded(detail),
      act: (cubit) => cubit.toggleFavorite(),
      // Optimistic update first, then back to the original.
      expect: () => [MedicationDetailLoaded(favoriteDetail), const MedicationDetailLoaded(detail)],
    );

    blocTest<MedicationDetailCubit, MedicationDetailState>(
      'ignores extra taps while a save is still running',
      build: buildCubit,
      seed: () => const MedicationDetailLoaded(detail),
      act: (cubit) async {
        final pending = Completer<Result<void>>();
        when(() => addFavorite(favoriteDetail)).thenAnswer((_) => pending.future);

        final first = cubit.toggleFavorite();
        unawaited(cubit.toggleFavorite());
        unawaited(cubit.toggleFavorite());
        pending.complete(const Ok(null));
        await first;
      },
      expect: () => [MedicationDetailLoaded(favoriteDetail)],
      verify: (_) {
        verify(() => addFavorite(favoriteDetail)).called(1);
        verifyNever(() => removeFavorite(any()));
      },
    );

    blocTest<MedicationDetailCubit, MedicationDetailState>(
      'does nothing before the detail is loaded',
      build: buildCubit,
      act: (cubit) => cubit.toggleFavorite(),
      expect: () => <MedicationDetailState>[],
      verify: (_) => verifyZeroInteractions(addFavorite),
    );
  });
}

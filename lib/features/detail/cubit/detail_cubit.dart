import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../data/repositories/medication_repository.dart';
import 'detail_state.dart';

/// Loads one label by `set_id`. Used both to open a detail screen and to
/// refresh a saved Favorites snapshot when back online.
class DetailCubit extends Cubit<DetailState> {
  DetailCubit(this._repository, {required this.setId})
    : super(const DetailState()) {
    load();
  }

  final MedicationRepository _repository;
  final String setId;

  Future<void> load() async {
    emit(DetailState(isLoading: true, detail: state.detail));
    try {
      final detail = await _repository.fetchDetail(setId);
      emit(
        DetailState(
          isLoading: false,
          detail: detail,
          failure:
              detail == null ? const Failure(FailureKind.invalidData) : null,
        ),
      );
    } on Failure catch (failure) {
      emit(
        DetailState(isLoading: false, detail: state.detail, failure: failure),
      );
    }
  }
}

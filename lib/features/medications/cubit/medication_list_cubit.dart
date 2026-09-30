import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/medication_summary.dart';
import '../../../data/repositories/medication_repository.dart';
import 'medication_list_state.dart';

/// Debounced (400ms), min-2-char search over openFDA labels with
/// limit=20/skip pagination. A stale request (superseded by a newer search,
/// a clear, or a refresh) never overwrites the state a later request
/// already wrote — the "restartable" behaviour the design calls for.
class MedicationListCubit extends Cubit<MedicationListState> {
  MedicationListCubit(this._repository) : super(const MedicationListState());

  final MedicationRepository _repository;
  Timer? _debounce;
  int _requestId = 0;

  List<MedicationSummary>? _cachedUnfilteredItems;
  bool _cachedUnfilteredHasMore = true;

  static const _debounceDuration = Duration(milliseconds: 400);
  static const minQueryLength = 2;

  void onSearchChanged(String raw) {
    final trimmed = raw.trim();
    _debounce?.cancel();

    if (trimmed.isEmpty) {
      if (_cachedUnfilteredItems != null) {
        _requestId++; // supersede any in-flight request
        emit(
          state.copyWith(
            query: '',
            items: _cachedUnfilteredItems,
            hasMore: _cachedUnfilteredHasMore,
            isLoading: false,
            isLoadingMore: false,
            firstLoadFailure: null,
            loadMoreFailure: null,
          ),
        );
        return;
      }
      _debounce = Timer(
        _debounceDuration,
        () => _load(reset: true, query: '', showFullLoading: true),
      );
      return;
    }

    if (trimmed.length < minQueryLength) {
      _requestId++; // below min length: show the hint, don't call the API
      emit(
        state.copyWith(
          query: trimmed,
          isLoading: false,
          firstLoadFailure: null,
        ),
      );
      return;
    }

    emit(state.copyWith(query: trimmed));
    _debounce = Timer(
      _debounceDuration,
      () => _load(reset: true, query: trimmed, showFullLoading: true),
    );
  }

  /// Pull-to-refresh: keeps the current list visible while it runs.
  Future<void> refresh() =>
      _load(reset: true, query: state.query, showFullLoading: false);

  Future<void> loadMore() {
    if (state.isLoadingMore || state.isLoading || !state.hasMore) {
      return Future.value();
    }
    return _load(reset: false, query: state.query, showFullLoading: false);
  }

  Future<void> retryFirstLoad() =>
      _load(reset: true, query: state.query, showFullLoading: true);

  Future<void> retryLoadMore() =>
      _load(reset: false, query: state.query, showFullLoading: false);

  Future<void> _load({
    required bool reset,
    required String query,
    required bool showFullLoading,
  }) async {
    final requestId = ++_requestId;

    emit(
      reset
          ? state.copyWith(
            query: query,
            items: showFullLoading ? const [] : null,
            isLoading: showFullLoading,
            firstLoadFailure: null,
          )
          : state.copyWith(isLoadingMore: true, loadMoreFailure: null),
    );

    try {
      final skip = reset ? 0 : state.items.length;
      final page = await _repository.fetchSummaries(
        query: query.isEmpty ? null : query,
        skip: skip,
      );
      if (requestId != _requestId) return;

      final items = reset ? page.items : [...state.items, ...page.items];
      emit(
        state.copyWith(
          items: items,
          hasMore: page.hasMore,
          isLoading: false,
          isLoadingMore: false,
        ),
      );

      if (query.isEmpty) {
        _cachedUnfilteredItems = items;
        _cachedUnfilteredHasMore = page.hasMore;
      }
    } on Failure catch (failure) {
      if (requestId != _requestId) return;
      if (reset) {
        // A refresh failure with content already on screen surfaces as an
        // inline banner instead of replacing the visible list.
        emit(
          state.items.isEmpty
              ? state.copyWith(isLoading: false, firstLoadFailure: failure)
              : state.copyWith(isLoading: false, loadMoreFailure: failure),
        );
      } else {
        emit(state.copyWith(isLoadingMore: false, loadMoreFailure: failure));
      }
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

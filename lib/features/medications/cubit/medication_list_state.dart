import 'package:equatable/equatable.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/medication_summary.dart';

class MedicationListState extends Equatable {
  const MedicationListState({
    this.query = '',
    this.items = const [],
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.firstLoadFailure,
    this.loadMoreFailure,
  });

  final String query;
  final List<MedicationSummary> items;
  final bool hasMore;

  /// True during the first load of a query and during pull-to-refresh.
  final bool isLoading;
  final bool isLoadingMore;

  /// Full-screen state view failure (first load / refresh).
  final Failure? firstLoadFailure;

  /// Inline banner failure — pagination errors don't replace content
  /// already loaded.
  final Failure? loadMoreFailure;

  bool get belowMinQueryLength => query.isNotEmpty && query.length < 2;

  bool get isEmptyResult =>
      !isLoading &&
      firstLoadFailure == null &&
      items.isEmpty &&
      !belowMinQueryLength;

  static const _unset = Object();

  MedicationListState copyWith({
    String? query,
    List<MedicationSummary>? items,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Object? firstLoadFailure = _unset,
    Object? loadMoreFailure = _unset,
  }) {
    return MedicationListState(
      query: query ?? this.query,
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      firstLoadFailure:
          identical(firstLoadFailure, _unset)
              ? this.firstLoadFailure
              : firstLoadFailure as Failure?,
      loadMoreFailure:
          identical(loadMoreFailure, _unset)
              ? this.loadMoreFailure
              : loadMoreFailure as Failure?,
    );
  }

  @override
  List<Object?> get props => [
    query,
    items,
    hasMore,
    isLoading,
    isLoadingMore,
    firstLoadFailure,
    loadMoreFailure,
  ];
}

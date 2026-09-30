import 'package:equatable/equatable.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/medication_detail.dart';

class DetailState extends Equatable {
  const DetailState({this.detail, this.isLoading = true, this.failure});

  final MedicationDetail? detail;
  final bool isLoading;
  final Failure? failure;

  @override
  List<Object?> get props => [detail, isLoading, failure];
}

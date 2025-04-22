import 'package:equatable/equatable.dart';

import '../../../domain/entities/dining_info.dart';

abstract class DiningState extends Equatable {
  const DiningState();

  @override
  List<Object?> get props => [];
}

class DiningInitial extends DiningState {}

class DiningLoading extends DiningState {}

class DiningOptionsLoaded extends DiningState {
  final List<DiningInfo> options;

  const DiningOptionsLoaded(this.options);

  @override
  List<Object?> get props => [options];
}

class DiningOptionDetailsLoaded extends DiningState {
  final DiningInfo option;

  const DiningOptionDetailsLoaded(this.option);

  @override
  List<Object?> get props => [option];
}

class MealPlanOptionsLoaded extends DiningState {
  final List<DiningInfo> options;

  const MealPlanOptionsLoaded(this.options);

  @override
  List<Object?> get props => [options];
}

class DiningSearchResults extends DiningState {
  final String query;
  final Map<String, List<MenuItem>> results;

  const DiningSearchResults({
    required this.query,
    required this.results,
  });

  @override
  List<Object?> get props => [query, results];
}

class DiningSearchEmpty extends DiningState {
  final String query;

  const DiningSearchEmpty(this.query);

  @override
  List<Object?> get props => [query];
}

class OpenDiningOptionsLoaded extends DiningState {
  final List<DiningInfo> options;

  const OpenDiningOptionsLoaded(this.options);

  @override
  List<Object?> get props => [options];
}

class NoDiningOptionsOpen extends DiningState {}

class DiningEmpty extends DiningState {}

class DiningError extends DiningState {
  final String message;

  const DiningError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';

abstract class DiningEvent extends Equatable {
  const DiningEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllDiningOptions extends DiningEvent {}

class LoadDiningOptionDetails extends DiningEvent {
  final String id;

  const LoadDiningOptionDetails(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadMealPlanOptions extends DiningEvent {}

class SearchDiningMenuItems extends DiningEvent {
  final String query;

  const SearchDiningMenuItems(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadOpenDiningOptions extends DiningEvent {}

class RefreshDiningOptions extends DiningEvent {}

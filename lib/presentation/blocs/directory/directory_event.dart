import 'package:equatable/equatable.dart';

abstract class DirectoryEvent extends Equatable {
  const DirectoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllDirectoryEntries extends DirectoryEvent {}

class SearchDirectoryEntries extends DirectoryEvent {
  final String query;

  const SearchDirectoryEntries(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadDirectoryEntriesByDepartment extends DirectoryEvent {
  final String department;

  const LoadDirectoryEntriesByDepartment(this.department);

  @override
  List<Object?> get props => [department];
}

class LoadDirectoryEntryDetails extends DirectoryEvent {
  final String id;

  const LoadDirectoryEntryDetails(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadAllDepartments extends DirectoryEvent {}

class RefreshDirectoryEntries extends DirectoryEvent {}

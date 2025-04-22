import 'package:equatable/equatable.dart';

import '../../../domain/entities/directory_entry.dart';

abstract class DirectoryState extends Equatable {
  const DirectoryState();

  @override
  List<Object?> get props => [];
}

class DirectoryInitial extends DirectoryState {}

class DirectoryLoading extends DirectoryState {}

class DirectoryEntriesLoaded extends DirectoryState {
  final List<DirectoryEntry> entries;

  const DirectoryEntriesLoaded(this.entries);

  @override
  List<Object?> get props => [entries];
}

class DirectorySearchResults extends DirectoryState {
  final String query;
  final List<DirectoryEntry> results;

  const DirectorySearchResults({
    required this.query,
    required this.results,
  });

  @override
  List<Object?> get props => [query, results];
}

class DirectorySearchEmpty extends DirectoryState {
  final String query;

  const DirectorySearchEmpty(this.query);

  @override
  List<Object?> get props => [query];
}

class DirectoryEntriesByDepartmentLoaded extends DirectoryState {
  final String department;
  final List<DirectoryEntry> entries;

  const DirectoryEntriesByDepartmentLoaded({
    required this.department,
    required this.entries,
  });

  @override
  List<Object?> get props => [department, entries];
}

class DirectoryEntryDetailsLoaded extends DirectoryState {
  final DirectoryEntry entry;

  const DirectoryEntryDetailsLoaded(this.entry);

  @override
  List<Object?> get props => [entry];
}

class DirectoryEntryNotFound extends DirectoryState {
  final String id;

  const DirectoryEntryNotFound(this.id);

  @override
  List<Object?> get props => [id];
}

class DepartmentsLoaded extends DirectoryState {
  final List<String> departments;

  const DepartmentsLoaded(this.departments);

  @override
  List<Object?> get props => [departments];
}

class DirectoryEmpty extends DirectoryState {}

class DirectoryError extends DirectoryState {
  final String message;

  const DirectoryError(this.message);

  @override
  List<Object?> get props => [message];
}

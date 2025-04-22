import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/directory_usecase.dart';
import 'directory_event.dart';
import 'directory_state.dart';

class DirectoryBloc extends Bloc<DirectoryEvent, DirectoryState> {
  final DirectoryUseCase _directoryUseCase;

  DirectoryBloc(this._directoryUseCase) : super(DirectoryInitial()) {
    on<LoadAllDirectoryEntries>(_onLoadAllDirectoryEntries);
    on<SearchDirectoryEntries>(_onSearchDirectoryEntries);
    on<LoadDirectoryEntriesByDepartment>(_onLoadDirectoryEntriesByDepartment);
    on<LoadDirectoryEntryDetails>(_onLoadDirectoryEntryDetails);
    on<LoadAllDepartments>(_onLoadAllDepartments);
    on<RefreshDirectoryEntries>(_onRefreshDirectoryEntries);
  }

  Future<void> _onLoadAllDirectoryEntries(
    LoadAllDirectoryEntries event, 
    Emitter<DirectoryState> emit
  ) async {
    emit(DirectoryLoading());
    try {
      final entries = await _directoryUseCase.getAllDirectoryEntries();
      
      if (entries.isEmpty) {
        emit(DirectoryEmpty());
      } else {
        emit(DirectoryEntriesLoaded(entries));
      }
    } catch (e) {
      emit(DirectoryError(e.toString()));
    }
  }

  Future<void> _onSearchDirectoryEntries(
    SearchDirectoryEntries event, 
    Emitter<DirectoryState> emit
  ) async {
    emit(DirectoryLoading());
    try {
      final entries = await _directoryUseCase.searchDirectory(event.query);
      
      if (entries.isEmpty) {
        emit(DirectorySearchEmpty(event.query));
      } else {
        emit(DirectorySearchResults(
          query: event.query,
          results: entries,
        ));
      }
    } catch (e) {
      emit(DirectoryError(e.toString()));
    }
  }

  Future<void> _onLoadDirectoryEntriesByDepartment(
    LoadDirectoryEntriesByDepartment event, 
    Emitter<DirectoryState> emit
  ) async {
    emit(DirectoryLoading());
    try {
      final entries = await _directoryUseCase.getEntriesByDepartment(event.department);
      
      if (entries.isEmpty) {
        emit(DirectoryEmpty());
      } else {
        emit(DirectoryEntriesByDepartmentLoaded(
          department: event.department,
          entries: entries,
        ));
      }
    } catch (e) {
      emit(DirectoryError(e.toString()));
    }
  }

  Future<void> _onLoadDirectoryEntryDetails(
    LoadDirectoryEntryDetails event, 
    Emitter<DirectoryState> emit
  ) async {
    emit(DirectoryLoading());
    try {
      final entry = await _directoryUseCase.getEntryById(event.id);
      
      if (entry == null) {
        emit(DirectoryEntryNotFound(event.id));
      } else {
        emit(DirectoryEntryDetailsLoaded(entry));
      }
    } catch (e) {
      emit(DirectoryError(e.toString()));
    }
  }

  Future<void> _onLoadAllDepartments(
    LoadAllDepartments event, 
    Emitter<DirectoryState> emit
  ) async {
    emit(DirectoryLoading());
    try {
      final departments = await _directoryUseCase.getAllDepartments();
      
      if (departments.isEmpty) {
        emit(DirectoryEmpty());
      } else {
        emit(DepartmentsLoaded(departments));
      }
    } catch (e) {
      emit(DirectoryError(e.toString()));
    }
  }

  Future<void> _onRefreshDirectoryEntries(
    RefreshDirectoryEntries event, 
    Emitter<DirectoryState> emit
  ) async {
    emit(DirectoryLoading());
    try {
      await _directoryUseCase.refreshDirectory();
      final entries = await _directoryUseCase.getAllDirectoryEntries();
      
      if (entries.isEmpty) {
        emit(DirectoryEmpty());
      } else {
        emit(DirectoryEntriesLoaded(entries));
      }
    } catch (e) {
      emit(DirectoryError(e.toString()));
    }
  }
}

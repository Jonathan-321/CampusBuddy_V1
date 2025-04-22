import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/dining_usecase.dart';
import 'dining_event.dart';
import 'dining_state.dart';

class DiningBloc extends Bloc<DiningEvent, DiningState> {
  final DiningUseCase _diningUseCase;

  DiningBloc(this._diningUseCase) : super(DiningInitial()) {
    on<LoadAllDiningOptions>(_onLoadAllDiningOptions);
    on<LoadDiningOptionDetails>(_onLoadDiningOptionDetails);
    on<LoadMealPlanOptions>(_onLoadMealPlanOptions);
    on<SearchDiningMenuItems>(_onSearchDiningMenuItems);
    on<LoadOpenDiningOptions>(_onLoadOpenDiningOptions);
    on<RefreshDiningOptions>(_onRefreshDiningOptions);
  }

  Future<void> _onLoadAllDiningOptions(
    LoadAllDiningOptions event, 
    Emitter<DiningState> emit
  ) async {
    emit(DiningLoading());
    try {
      final options = await _diningUseCase.getAllDiningOptions();
      
      if (options.isEmpty) {
        emit(DiningEmpty());
      } else {
        emit(DiningOptionsLoaded(options));
      }
    } catch (e) {
      emit(DiningError(e.toString()));
    }
  }

  Future<void> _onLoadDiningOptionDetails(
    LoadDiningOptionDetails event, 
    Emitter<DiningState> emit
  ) async {
    emit(DiningLoading());
    try {
      final option = await _diningUseCase.getDiningOptionById(event.id);
      emit(DiningOptionDetailsLoaded(option));
    } catch (e) {
      emit(DiningError(e.toString()));
    }
  }

  Future<void> _onLoadMealPlanOptions(
    LoadMealPlanOptions event, 
    Emitter<DiningState> emit
  ) async {
    emit(DiningLoading());
    try {
      final options = await _diningUseCase.getMealPlanOptions();
      
      if (options.isEmpty) {
        emit(DiningEmpty());
      } else {
        emit(MealPlanOptionsLoaded(options));
      }
    } catch (e) {
      emit(DiningError(e.toString()));
    }
  }

  Future<void> _onSearchDiningMenuItems(
    SearchDiningMenuItems event, 
    Emitter<DiningState> emit
  ) async {
    emit(DiningLoading());
    try {
      final results = await _diningUseCase.searchMenuItems(event.query);
      
      if (results.isEmpty) {
        emit(DiningSearchEmpty(event.query));
      } else {
        emit(DiningSearchResults(
          query: event.query,
          results: results,
        ));
      }
    } catch (e) {
      emit(DiningError(e.toString()));
    }
  }

  Future<void> _onLoadOpenDiningOptions(
    LoadOpenDiningOptions event, 
    Emitter<DiningState> emit
  ) async {
    emit(DiningLoading());
    try {
      final options = await _diningUseCase.getCurrentlyOpenDiningOptions();
      
      if (options.isEmpty) {
        emit(NoDiningOptionsOpen());
      } else {
        emit(OpenDiningOptionsLoaded(options));
      }
    } catch (e) {
      emit(DiningError(e.toString()));
    }
  }

  Future<void> _onRefreshDiningOptions(
    RefreshDiningOptions event, 
    Emitter<DiningState> emit
  ) async {
    emit(DiningLoading());
    try {
      await _diningUseCase.refreshDiningOptions();
      final options = await _diningUseCase.getAllDiningOptions();
      
      if (options.isEmpty) {
        emit(DiningEmpty());
      } else {
        emit(DiningOptionsLoaded(options));
      }
    } catch (e) {
      emit(DiningError(e.toString()));
    }
  }
}

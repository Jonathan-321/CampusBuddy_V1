import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/emergency_usecase.dart';
import 'emergency_event.dart';
import 'emergency_state.dart';

class EmergencyBloc extends Bloc<EmergencyEvent, EmergencyState> {
  final EmergencyUseCase _emergencyUseCase;

  EmergencyBloc(this._emergencyUseCase) : super(EmergencyInitial()) {
    on<LoadEmergencyContacts>(_onLoadEmergencyContacts);
    on<LoadEmergencyContactsByCategory>(_onLoadEmergencyContactsByCategory);
    on<LoadEmergencyOnlyContacts>(_onLoadEmergencyOnlyContacts);
    on<RefreshEmergencyContacts>(_onRefreshEmergencyContacts);
  }

  Future<void> _onLoadEmergencyContacts(
    LoadEmergencyContacts event, 
    Emitter<EmergencyState> emit
  ) async {
    emit(EmergencyLoading());
    try {
      final contacts = await _emergencyUseCase.getAllEmergencyContacts();
      
      if (contacts.isEmpty) {
        emit(EmergencyEmpty());
      } else {
        final categorizedContacts = await _emergencyUseCase.getContactsByCategory();
        emit(EmergencyLoaded(
          allContacts: contacts,
          categorizedContacts: categorizedContacts,
        ));
      }
    } catch (e) {
      emit(EmergencyError(e.toString()));
    }
  }

  Future<void> _onLoadEmergencyContactsByCategory(
    LoadEmergencyContactsByCategory event, 
    Emitter<EmergencyState> emit
  ) async {
    emit(EmergencyLoading());
    try {
      final contacts = await _emergencyUseCase.getEmergencyContactsByCategory(event.category);
      
      if (contacts.isEmpty) {
        emit(EmergencyEmpty());
      } else {
        emit(EmergencyContactsForCategoryLoaded(
          category: event.category,
          contacts: contacts,
        ));
      }
    } catch (e) {
      emit(EmergencyError(e.toString()));
    }
  }

  Future<void> _onLoadEmergencyOnlyContacts(
    LoadEmergencyOnlyContacts event, 
    Emitter<EmergencyState> emit
  ) async {
    emit(EmergencyLoading());
    try {
      final contacts = await _emergencyUseCase.getEmergencyOnlyContacts();
      
      if (contacts.isEmpty) {
        emit(EmergencyEmpty());
      } else {
        emit(EmergencyOnlyContactsLoaded(contacts));
      }
    } catch (e) {
      emit(EmergencyError(e.toString()));
    }
  }

  Future<void> _onRefreshEmergencyContacts(
    RefreshEmergencyContacts event, 
    Emitter<EmergencyState> emit
  ) async {
    emit(EmergencyLoading());
    try {
      await _emergencyUseCase.refreshContacts();
      final contacts = await _emergencyUseCase.getAllEmergencyContacts();
      
      if (contacts.isEmpty) {
        emit(EmergencyEmpty());
      } else {
        final categorizedContacts = await _emergencyUseCase.getContactsByCategory();
        emit(EmergencyLoaded(
          allContacts: contacts,
          categorizedContacts: categorizedContacts,
        ));
      }
    } catch (e) {
      emit(EmergencyError(e.toString()));
    }
  }
}

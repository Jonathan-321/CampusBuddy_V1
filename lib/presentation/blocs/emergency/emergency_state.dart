import 'package:equatable/equatable.dart';

import '../../../domain/entities/emergency_contact.dart';

abstract class EmergencyState extends Equatable {
  const EmergencyState();

  @override
  List<Object?> get props => [];
}

class EmergencyInitial extends EmergencyState {}

class EmergencyLoading extends EmergencyState {}

class EmergencyLoaded extends EmergencyState {
  final List<EmergencyContact> allContacts;
  final Map<String, List<EmergencyContact>> categorizedContacts;

  const EmergencyLoaded({
    required this.allContacts,
    required this.categorizedContacts,
  });

  @override
  List<Object?> get props => [allContacts, categorizedContacts];
}

class EmergencyContactsForCategoryLoaded extends EmergencyState {
  final String category;
  final List<EmergencyContact> contacts;

  const EmergencyContactsForCategoryLoaded({
    required this.category,
    required this.contacts,
  });

  @override
  List<Object?> get props => [category, contacts];
}

class EmergencyOnlyContactsLoaded extends EmergencyState {
  final List<EmergencyContact> contacts;

  const EmergencyOnlyContactsLoaded(this.contacts);

  @override
  List<Object?> get props => [contacts];
}

class EmergencyEmpty extends EmergencyState {}

class EmergencyError extends EmergencyState {
  final String message;

  const EmergencyError(this.message);

  @override
  List<Object?> get props => [message];
}

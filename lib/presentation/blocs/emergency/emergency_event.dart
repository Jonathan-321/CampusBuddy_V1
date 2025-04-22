import 'package:equatable/equatable.dart';

abstract class EmergencyEvent extends Equatable {
  const EmergencyEvent();

  @override
  List<Object?> get props => [];
}

class LoadEmergencyContacts extends EmergencyEvent {}

class LoadEmergencyContactsByCategory extends EmergencyEvent {
  final String category;

  const LoadEmergencyContactsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class LoadEmergencyOnlyContacts extends EmergencyEvent {}

class RefreshEmergencyContacts extends EmergencyEvent {}

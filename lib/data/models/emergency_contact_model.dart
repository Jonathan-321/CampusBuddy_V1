import '../../domain/entities/emergency_contact.dart';

class EmergencyContactModel extends EmergencyContact {
  EmergencyContactModel({
    required super.id,
    required super.name,
    required super.phoneNumber,
    required super.description,
    required super.category,
    super.isEmergency,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      isEmergency: json['isEmergency'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'description': description,
      'category': category,
      'isEmergency': isEmergency,
    };
  }

  factory EmergencyContactModel.fromEntity(EmergencyContact contact) {
    return EmergencyContactModel(
      id: contact.id,
      name: contact.name,
      phoneNumber: contact.phoneNumber,
      description: contact.description,
      category: contact.category,
      isEmergency: contact.isEmergency,
    );
  }
}

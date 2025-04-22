import '../../domain/entities/directory_entry.dart';

class DirectoryModel extends DirectoryEntry {
  DirectoryModel({
    required super.id,
    required super.name,
    required super.title,
    required super.department,
    required super.email,
    required super.phoneNumber,
    super.officeLocation,
    super.photoUrl,
    super.researchInterests,
  });

  factory DirectoryModel.fromJson(Map<String, dynamic> json) {
    return DirectoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      department: json['department'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      officeLocation: json['officeLocation'],
      photoUrl: json['photoUrl'],
      researchInterests: json['researchInterests'] != null
          ? List<String>.from(json['researchInterests'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'department': department,
      'email': email,
      'phoneNumber': phoneNumber,
      'officeLocation': officeLocation,
      'photoUrl': photoUrl,
      'researchInterests': researchInterests,
    };
  }

  factory DirectoryModel.fromEntity(DirectoryEntry entry) {
    return DirectoryModel(
      id: entry.id,
      name: entry.name,
      title: entry.title,
      department: entry.department,
      email: entry.email,
      phoneNumber: entry.phoneNumber,
      officeLocation: entry.officeLocation,
      photoUrl: entry.photoUrl,
      researchInterests: entry.researchInterests,
    );
  }
}

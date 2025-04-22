import '../../domain/entities/event.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String imageUrl;
  final String category;
  final String organizer;
  final List<String> categories;
  final bool isVirtual;
  final String? virtualLink;
  final List<String> tags;
  final bool isRegistrationRequired;
  final int? maxAttendees;
  final int? currentAttendees;
  final bool isUserRegistered;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.imageUrl,
    required this.category,
    required this.organizer,
    required this.categories,
    required this.isVirtual,
    this.virtualLink,
    required this.tags,
    this.isRegistrationRequired = false,
    this.maxAttendees,
    this.currentAttendees,
    this.isUserRegistered = false,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : DateTime.now().add(const Duration(hours: 1)),
      location: json['location'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      organizer: json['organizer'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      isVirtual: json['isVirtual'] ?? false,
      virtualLink: json['virtualLink'],
      tags: List<String>.from(json['tags'] ?? []),
      isRegistrationRequired: json['isRegistrationRequired'] ?? false,
      maxAttendees: json['maxAttendees'],
      currentAttendees: json['currentAttendees'],
      isUserRegistered: json['isUserRegistered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'category': category,
      'organizer': organizer,
      'categories': categories,
      'isVirtual': isVirtual,
      'virtualLink': virtualLink,
      'tags': tags,
      'isRegistrationRequired': isRegistrationRequired,
      'maxAttendees': maxAttendees,
      'currentAttendees': currentAttendees,
      'isUserRegistered': isUserRegistered,
    };
  }

  Event toEntity() {
    return Event(
      id: id,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      location: location,
      category: category,
      organizer: organizer,
      imageUrl: imageUrl,
      categories: categories,
      isVirtual: isVirtual,
      virtualLink: virtualLink,
      tags: tags,
      isRegistrationRequired: isRegistrationRequired,
      maxAttendees: maxAttendees,
      currentAttendees: currentAttendees,
      isUserRegistered: isUserRegistered,
    );
  }

  // Convert from Event entity to EventModel
  factory EventModel.fromEntity(Event event) {
    return EventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      startTime: event.startTime,
      endTime: event.endTime,
      location: event.location,
      imageUrl: event.imageUrl ?? '',
      category: event.category,
      organizer: event.organizer,
      categories: event.categories,
      isVirtual: event.isVirtual,
      virtualLink: event.virtualLink,
      tags: event.tags,
      isRegistrationRequired: event.isRegistrationRequired,
      maxAttendees: event.maxAttendees,
      currentAttendees: event.currentAttendees,
      isUserRegistered: event.isUserRegistered,
    );
  }
}

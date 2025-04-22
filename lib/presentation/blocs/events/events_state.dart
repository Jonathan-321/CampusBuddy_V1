import 'package:equatable/equatable.dart';

import '../../../domain/entities/event.dart';

abstract class EventsState extends Equatable {
  const EventsState();

  @override
  List<Object?> get props => [];
}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<Event> allEvents;
  final List<Event> filteredEvents;
  final List<Event> featuredEvents;
  final List<String> registeredEventIds;
  final String currentFilter;

  const EventsLoaded({
    required this.allEvents,
    required this.filteredEvents,
    required this.featuredEvents,
    this.registeredEventIds = const [],
    this.currentFilter = 'All',
  });

  EventsLoaded copyWith({
    List<Event>? allEvents,
    List<Event>? filteredEvents,
    List<Event>? featuredEvents,
    List<String>? registeredEventIds,
    String? currentFilter,
  }) {
    return EventsLoaded(
      allEvents: allEvents ?? this.allEvents,
      filteredEvents: filteredEvents ?? this.filteredEvents,
      featuredEvents: featuredEvents ?? this.featuredEvents,
      registeredEventIds: registeredEventIds ?? this.registeredEventIds,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }

  bool isRegistered(String eventId) {
    return registeredEventIds.contains(eventId);
  }

  List<Event> get upcomingEvents => allEvents.where((event) => event.isUpcoming).toList();
  List<Event> get todayEvents => allEvents.where((event) {
    final now = DateTime.now();
    return event.startTime.year == now.year &&
           event.startTime.month == now.month &&
           event.startTime.day == now.day;
  }).toList();
  List<Event> get pastEvents => allEvents.where((event) => event.isPast).toList();

  @override
  List<Object?> get props => [
    allEvents, 
    filteredEvents, 
    featuredEvents, 
    registeredEventIds, 
    currentFilter
  ];
}

class EventDetailsLoaded extends EventsState {
  final Event event;

  const EventDetailsLoaded(this.event);

  @override
  List<Object?> get props => [event];
}

class UpcomingEventsLoaded extends EventsState {
  final List<Event> events;

  const UpcomingEventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class EventsByCategoryLoaded extends EventsState {
  final String category;
  final List<Event> events;

  const EventsByCategoryLoaded({
    required this.category,
    required this.events,
  });

  @override
  List<Object?> get props => [category, events];
}

class EventsByDateRangeLoaded extends EventsState {
  final DateTime startDate;
  final DateTime endDate;
  final List<Event> events;

  const EventsByDateRangeLoaded({
    required this.startDate,
    required this.endDate,
    required this.events,
  });

  @override
  List<Object?> get props => [startDate, endDate, events];
}

class EventsForDayLoaded extends EventsState {
  final DateTime day;
  final List<Event> events;

  const EventsForDayLoaded({
    required this.day,
    required this.events,
  });

  @override
  List<Object?> get props => [day, events];
}

class NoEventsForDay extends EventsState {
  final DateTime day;

  const NoEventsForDay(this.day);

  @override
  List<Object?> get props => [day];
}

class EventCategoriesLoaded extends EventsState {
  final List<String> categories;

  const EventCategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class EventAddedToCalendar extends EventsState {
  final String eventId;

  const EventAddedToCalendar(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class EventsEmpty extends EventsState {}

class EventsError extends EventsState {
  final String message;

  const EventsError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';

abstract class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object?> get props => [];
}

class LoadEvents extends EventsEvent {}

class LoadAllEvents extends EventsEvent {}

class LoadEventDetails extends EventsEvent {
  final String id;

  const LoadEventDetails(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadUpcomingEvents extends EventsEvent {}

class LoadEventsByCategory extends EventsEvent {
  final String category;

  const LoadEventsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class LoadEventsByDateRange extends EventsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadEventsByDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadEventsForDay extends EventsEvent {
  final DateTime day;

  const LoadEventsForDay(this.day);

  @override
  List<Object?> get props => [day];
}

class LoadEventCategories extends EventsEvent {}

class AddEventToCalendar extends EventsEvent {
  final String eventId;

  const AddEventToCalendar(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class RefreshEvents extends EventsEvent {}

class SearchEvents extends EventsEvent {
  final String query;

  const SearchEvents(this.query);

  @override
  List<Object?> get props => [query];
}

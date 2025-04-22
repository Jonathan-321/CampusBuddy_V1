/// Events Feature - State Management
///
/// This file implements the BLoC (Business Logic Component) pattern for managing
/// events-related state in the Campus Buddy application.
///
/// Responsibilities:
/// 1. Manage events state (loading, loaded, error)
/// 2. Handle events-related operations
/// 3. Coordinate with EventsUseCase for data operations
/// 4. Emit appropriate states for UI updates
///
/// Events Handled:
/// - LoadEvents: Initial load of all events
/// - LoadAllEvents: Load complete events list
/// - LoadEventDetails: Load specific event details
/// - LoadUpcomingEvents: Load upcoming events
/// - LoadEventsByCategory: Filter events by category
/// - LoadEventsByDateRange: Filter events by date range
/// - LoadEventsForDay: Get events for specific day
/// - LoadEventCategories: Get all event categories
/// - AddEventToCalendar: Add event to personal calendar
/// - RefreshEvents: Refresh events data
/// - SearchEvents: Search events by query
///
/// States Emitted:
/// - EventsInitial: Initial state
/// - EventsLoading: Loading state
/// - EventsLoaded: Success state with events data
/// - EventsEmpty: No events available
/// - EventsError: Error state
/// - EventDetailsLoaded: Event details loaded
/// - UpcomingEventsLoaded: Upcoming events loaded
/// - EventsByCategoryLoaded: Category-filtered events
/// - EventsByDateRangeLoaded: Date-range filtered events
/// - EventsForDayLoaded: Day-specific events
/// - EventCategoriesLoaded: Categories list
/// - EventAddedToCalendar: Calendar operation success
///
/// Dependencies:
/// - EventsUseCase: For business logic operations
///
/// Usage:
/// To use this BLoC:
/// 1. Add to MultiBlocProvider in main.dart
/// 2. Access via BlocProvider.of<EventsBloc>(context)
/// 3. Add events using bloc.add(Event())
/// 4. Listen to states using BlocBuilder
///
/// Note: This BLoC follows the single responsibility principle
/// and should only handle events-related state management.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/events_usecase.dart';
import 'events_event.dart';
import 'events_state.dart';

/// EventsBloc manages the state and operations for events feature
class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final EventsUseCase _eventsUseCase;

  /// Initialize EventsBloc with required EventsUseCase
  EventsBloc(this._eventsUseCase) : super(EventsInitial()) {
    // Register event handlers
    on<LoadEvents>(_onLoadEvents);
    on<LoadAllEvents>(_onLoadAllEvents);
    on<LoadEventDetails>(_onLoadEventDetails);
    on<LoadUpcomingEvents>(_onLoadUpcomingEvents);
    on<LoadEventsByCategory>(_onLoadEventsByCategory);
    on<LoadEventsByDateRange>(_onLoadEventsByDateRange);
    on<LoadEventsForDay>(_onLoadEventsForDay);
    on<LoadEventCategories>(_onLoadEventCategories);
    on<AddEventToCalendar>(_onAddEventToCalendar);
    on<RefreshEvents>(_onRefreshEvents);
    on<SearchEvents>(_onSearchEvents);
  }

  /// Handle initial events load
  ///
  /// Loads:
  /// 1. All events
  /// 2. Upcoming events
  /// 3. Featured events (top 5 upcoming)
  Future<void> _onLoadEvents(
      LoadEvents event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      // First, load all events
      final allEvents = await _eventsUseCase.getAllEvents();

      // Then get upcoming events
      final upcomingEvents = await _eventsUseCase.getUpcomingEvents();

      if (allEvents.isEmpty) {
        emit(EventsEmpty());
      } else {
        emit(EventsLoaded(
          allEvents: allEvents,
          filteredEvents: allEvents, // Initially, all events are shown
          featuredEvents: upcomingEvents
              .take(5)
              .toList(), // Show top 5 upcoming events as featured
        ));
      }
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  /// Handle loading all events
  Future<void> _onLoadAllEvents(
      LoadAllEvents event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      final events = await _eventsUseCase.getAllEvents();

      if (events.isEmpty) {
        emit(EventsEmpty());
      } else {
        emit(EventsLoaded(
          allEvents: events,
          filteredEvents: events,
          featuredEvents: events.where((e) => e.isUpcoming).take(5).toList(),
        ));
      }
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  /// Handle loading specific event details
  Future<void> _onLoadEventDetails(
      LoadEventDetails event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      final eventDetails = await _eventsUseCase.getEventById(event.id);
      emit(EventDetailsLoaded(eventDetails));
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  /// Handle loading upcoming events
  Future<void> _onLoadUpcomingEvents(
      LoadUpcomingEvents event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      final events = await _eventsUseCase.getUpcomingEvents();

      if (events.isEmpty) {
        emit(EventsEmpty());
      } else {
        emit(UpcomingEventsLoaded(events));
      }
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  /// Handle loading events by category
  Future<void> _onLoadEventsByCategory(
      LoadEventsByCategory event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      final events = await _eventsUseCase.getEventsByCategory(event.category);

      if (events.isEmpty) {
        emit(EventsEmpty());
      } else {
        emit(EventsByCategoryLoaded(
          category: event.category,
          events: events,
        ));
      }
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  /// Handle loading events by date range
  Future<void> _onLoadEventsByDateRange(
      LoadEventsByDateRange event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      final events = await _eventsUseCase.getEventsByDateRange(
        event.startDate,
        event.endDate,
      );

      if (events.isEmpty) {
        emit(EventsEmpty());
      } else {
        emit(EventsByDateRangeLoaded(
          startDate: event.startDate,
          endDate: event.endDate,
          events: events,
        ));
      }
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  /// Handle loading events for specific day
  Future<void> _onLoadEventsForDay(
      LoadEventsForDay event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      final events = await _eventsUseCase.getEventsForDay(event.day);

      if (events.isEmpty) {
        emit(NoEventsForDay(event.day));
      } else {
        emit(EventsForDayLoaded(
          day: event.day,
          events: events,
        ));
      }
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  /// Handle loading event categories
  Future<void> _onLoadEventCategories(
      LoadEventCategories event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      final categories = await _eventsUseCase.getAllEventCategories();

      if (categories.isEmpty) {
        emit(EventsEmpty());
      } else {
        emit(EventCategoriesLoaded(categories));
      }
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  /// Handle adding event to personal calendar
  Future<void> _onAddEventToCalendar(
      AddEventToCalendar event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      final success = await _eventsUseCase.addToPersonalCalendar(event.eventId);

      if (success) {
        emit(EventAddedToCalendar(event.eventId));
      } else {
        emit(const EventsError('Failed to add event to calendar'));
      }
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  /// Handle refreshing events data
  Future<void> _onRefreshEvents(
      RefreshEvents event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      await _eventsUseCase.refreshEvents();
      final events = await _eventsUseCase.getAllEvents();

      if (events.isEmpty) {
        emit(EventsEmpty());
      } else {
        emit(EventsLoaded(
          allEvents: events,
          filteredEvents: events,
          featuredEvents: events.where((e) => e.isUpcoming).take(5).toList(),
        ));
      }
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  /// Handle searching events
  Future<void> _onSearchEvents(
      SearchEvents event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      final allEvents = await _eventsUseCase.getAllEvents();

      // Filter events based on search query
      final queryLower = event.query.toLowerCase();
      final filteredEvents = allEvents
          .where((e) =>
              e.title.toLowerCase().contains(queryLower) ||
              e.description.toLowerCase().contains(queryLower) ||
              e.category.toLowerCase().contains(queryLower) ||
              e.location.toLowerCase().contains(queryLower) ||
              e.organizer.toLowerCase().contains(queryLower) ||
              e.categories
                  .any((cat) => cat.toLowerCase().contains(queryLower)) ||
              e.tags.any((tag) => tag.toLowerCase().contains(queryLower)))
          .toList();

      if (filteredEvents.isEmpty) {
        emit(EventsEmpty());
      } else {
        emit(EventsLoaded(
          allEvents: allEvents,
          filteredEvents: filteredEvents,
          featuredEvents:
              filteredEvents.where((e) => e.isUpcoming).take(5).toList(),
        ));
      }
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }
}

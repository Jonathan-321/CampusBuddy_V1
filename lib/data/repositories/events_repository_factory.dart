/// Events Repository Factory
///
/// This file provides factory methods to create instances of EventsRepository
/// that implement the EventsRepositoryInterface.
///
/// This factory approach allows the domain layer to remain decoupled from
/// specific implementations while still being able to create instances.
library;

import '../../domain/repositories/events_repository_interface.dart';
import 'events_repository.dart';

/// Creates a mock EventsRepository for testing or development purposes
///
/// Returns an implementation of EventsRepositoryInterface
EventsRepositoryInterface createMockEventsRepository() {
  return EventsRepository.mock();
}

/// Creates a real EventsRepository with specified dependencies
///
/// Parameters:
/// - apiService: The API service to use for remote data
/// - preferences: The preferences service for local storage
///
/// Returns an implementation of EventsRepositoryInterface
EventsRepositoryInterface createEventsRepository(
    dynamic apiService, dynamic preferences) {
  return EventsRepository(apiService, preferences);
}

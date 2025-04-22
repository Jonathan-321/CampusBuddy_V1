import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../config/theme.dart';
import '../blocs/events/events_bloc.dart';
import '../blocs/events/events_event.dart';
import '../blocs/events/events_state.dart';
import '../widgets/event_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart' as error_widget;
import '../../domain/entities/event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String? _selectedCategory;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load upcoming events and categories
    context.read<EventsBloc>().add(LoadUpcomingEvents());
    context.read<EventsBloc>().add(LoadEventCategories());

    // Load events for today
    context.read<EventsBloc>().add(LoadEventsForDay(_selectedDay));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Events'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Calendar'),
            Tab(text: 'Categories'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EventsBloc>().add(RefreshEvents());
              context.read<EventsBloc>().add(LoadEventCategories());
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upcoming Events Tab
          _buildUpcomingEventsTab(),

          // Calendar Tab
          _buildCalendarTab(),

          // Categories Tab
          _buildCategoriesTab(),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsTab() {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        if (state is EventsLoading) {
          return const Center(child: LoadingIndicator());
        } else if (state is UpcomingEventsLoaded) {
          return _buildEventsList(state.events);
        } else if (state is EventsLoaded) {
          return _buildEventsList(state.filteredEvents);
        } else if (state is EventsError) {
          return error_widget.ErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<EventsBloc>().add(LoadUpcomingEvents());
            },
          );
        } else if (state is EventsEmpty) {
          return const Center(
            child: Text('No upcoming events available.'),
          );
        }
        return const Center(child: LoadingIndicator());
      },
    );
  }

  Widget _buildCalendarTab() {
    return Column(
      children: [
        // Calendar Widget
        TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 30)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            // Load events for selected day
            context.read<EventsBloc>().add(LoadEventsForDay(selectedDay));
          },
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            markersMaxCount: 3,
            todayDecoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
          ),
        ),

        const Divider(),

        // Events for Selected Day
        Expanded(
          child: BlocBuilder<EventsBloc, EventsState>(
            builder: (context, state) {
              if (state is EventsLoading) {
                return const Center(child: LoadingIndicator());
              } else if (state is EventsForDayLoaded) {
                return _buildEventsForDay(state.day, state.events);
              } else if (state is NoEventsForDay) {
                return Center(
                  child: Text(
                      'No events for ${DateFormat.yMMMd().format(state.day)}'),
                );
              } else if (state is EventsError) {
                return error_widget.ErrorWidget(
                  message: state.message,
                  onRetry: () {
                    context
                        .read<EventsBloc>()
                        .add(LoadEventsForDay(_selectedDay));
                  },
                );
              }
              return const Center(
                child: Text('Select a day to view events'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesTab() {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        if (state is EventCategoriesLoaded) {
          _categories = state.categories;

          return Column(
            children: [
              // Category Dropdown
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _selectedCategory,
                  items: state.categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    if (value != null) {
                      context
                          .read<EventsBloc>()
                          .add(LoadEventsByCategory(value));
                    }
                  },
                ),
              ),

              // Events by Category
              Expanded(
                child: BlocBuilder<EventsBloc, EventsState>(
                  builder: (context, state) {
                    if (state is EventsByCategoryLoaded) {
                      return _buildEventsList(state.events);
                    } else if (_selectedCategory == null) {
                      return const Center(
                        child: Text('Please select a category'),
                      );
                    } else if (state is EventsLoading) {
                      return const Center(child: LoadingIndicator());
                    } else if (state is EventsError) {
                      return error_widget.ErrorWidget(
                        message: state.message,
                        onRetry: () {
                          if (_selectedCategory != null) {
                            context.read<EventsBloc>().add(
                                  LoadEventsByCategory(_selectedCategory!),
                                );
                          }
                        },
                      );
                    } else if (state is EventsEmpty) {
                      return const Center(
                        child: Text('No events found for this category.'),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          );
        } else if (state is EventsLoading) {
          return const Center(child: LoadingIndicator());
        } else if (state is EventsError) {
          return error_widget.ErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<EventsBloc>().add(LoadEventCategories());
            },
          );
        }
        return const Center(child: LoadingIndicator());
      },
    );
  }

  Widget _buildEventsList(List<Event> events) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<EventsBloc>().add(RefreshEvents());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: EventCard(
              event: events[index],
              onTap: () {
                _showEventDetailsScreen(events[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventsForDay(DateTime day, List<Event> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Events for ${DateFormat.yMMMd().format(day)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: events.isEmpty
              ? const Center(
                  child: Text('No events for this day'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: EventCard(
                        event: events[index],
                        onTap: () {
                          _showEventDetailsScreen(events[index]);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showEventDetailsScreen(Event event) {
    // Load the details for this event
    context.read<EventsBloc>().add(LoadEventDetails(event.id));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(event: event),
      ),
    );
  }
}

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: BlocBuilder<EventsBloc, EventsState>(
        builder: (context, state) {
          if (state is EventsLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is EventDetailsLoaded) {
            // Use the loaded details from the state
            final details = state.event;
            return _buildEventDetails(context, details);
          } else {
            // Use the passed-in event if state doesn't have details yet
            return _buildEventDetails(context, event);
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<EventsBloc>().add(AddEventToCalendar(event.id));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event added to your calendar'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: const Icon(Icons.calendar_today),
        label: const Text('Add to Calendar'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildEventDetails(BuildContext context, Event details) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Header Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              image: details.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(details.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: details.imageUrl == null
                ? Center(
                    child: Icon(
                      Icons.event,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  )
                : null,
          ),

          const SizedBox(height: 16),

          // Event Title
          Text(
            details.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 8),

          // Event Date and Time
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 4),
              Text(details.formattedDate),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 4),
              Text(details.formattedTime),
            ],
          ),

          const SizedBox(height: 8),

          // Event Location
          Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  details.isVirtual
                      ? 'Virtual Event${details.virtualLink != null ? " - ${details.virtualLink}" : ""}'
                      : details.location,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Event Organizer
          Row(
            children: [
              const Icon(Icons.person, size: 16),
              const SizedBox(width: 4),
              Text('Organized by ${details.organizer}'),
            ],
          ),

          const SizedBox(height: 16),

          // Event Status
          _buildEventStatusChip(details),

          const SizedBox(height: 16),

          // Event Categories
          if (details.categories.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              children: details.categories.map((category) {
                return Chip(
                  label: Text(category),
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Event Description
          const Text(
            'About this event',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(details.description),

          const SizedBox(height: 24),

          // Tags
          if (details.tags.isNotEmpty) ...[
            const Text(
              'Tags',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: details.tags.map((tag) {
                return Chip(
                  label: Text('#$tag'),
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildEventStatusChip(Event event) {
    if (event.isOngoing) {
      return Chip(
        label: const Text('Happening Now'),
        backgroundColor: Colors.green.withOpacity(0.2),
        avatar: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 16,
        ),
      );
    } else if (event.isPast) {
      return Chip(
        label: const Text('Past Event'),
        backgroundColor: Colors.grey.withOpacity(0.2),
        avatar: const Icon(
          Icons.event_busy,
          color: Colors.grey,
          size: 16,
        ),
      );
    } else {
      return Chip(
        label: const Text('Upcoming'),
        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
        avatar: Icon(
          Icons.event_available,
          color: AppTheme.primaryColor,
          size: 16,
        ),
      );
    }
  }
}

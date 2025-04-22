import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/theme.dart';
import '../../../domain/entities/event.dart';
import '../../../services/notification_service.dart';
import '../../blocs/events/events_bloc.dart';
import '../../blocs/events/events_event.dart';
import '../../blocs/events/events_state.dart';
import '../../helpers/event_ui_helper.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart' as error_widget;
import 'event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Academic',
    'Social',
    'Sports',
    'Career',
    'Arts'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize notifications
    _notificationService.initialize();
    _notificationService.requestPermissions();

    // Load events
    context.read<EventsBloc>().add(LoadEvents());
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
            Tab(text: 'Today'),
            Tab(text: 'Past'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showNotificationSettingsDialog();
            },
          ),
        ],
      ),
      body: BlocConsumer<EventsBloc, EventsState>(
        listener: (context, state) {
          if (state is EventsLoaded) {
            // Schedule notifications for upcoming events
            _notificationService
                .scheduleNotificationsForEvents(state.upcomingEvents);
          }
        },
        builder: (context, state) {
          if (state is EventsLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is EventsLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                // Upcoming Events Tab
                _buildEventsList(
                  _filterEventsByCategory(
                      state.upcomingEvents, _selectedCategory),
                  emptyMessage: 'No upcoming events',
                ),

                // Today's Events Tab
                _buildEventsList(
                  _filterEventsByCategory(state.todayEvents, _selectedCategory),
                  emptyMessage: 'No events today',
                ),

                // Past Events Tab
                _buildEventsList(
                  _filterEventsByCategory(state.pastEvents, _selectedCategory),
                  emptyMessage: 'No past events',
                ),
              ],
            );
          } else if (state is EventsError) {
            return error_widget.ErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<EventsBloc>().add(LoadEvents());
              },
            );
          }
          return const Center(child: LoadingIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create event screen (for admins)
          // or show event suggestions dialog (for students)
          _showEventSuggestionDialog();
        },
        child: const Icon(Icons.add),
        tooltip: 'Suggest Event',
      ),
    );
  }

  List<Event> _filterEventsByCategory(List<Event> events, String category) {
    if (category == 'All') {
      return events;
    }
    return events.where((event) => event.category == category).toList();
  }

  Widget _buildEventsList(List<Event> events, {required String emptyMessage}) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(eventId: event.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image or category banner
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: EventUIHelper.getEventColor(event).withOpacity(0.2),
                image: event.imageUrl != null && event.imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: AssetImage(event.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  // Category chip
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: EventUIHelper.getEventColor(event),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            EventUIHelper.getEventIcon(event),
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Notification toggle
                  Positioned(
                    top: 12,
                    right: 12,
                    child: FutureBuilder<bool>(
                      future: _notificationService
                          .isEventNotificationEnabled(event.id),
                      builder: (context, snapshot) {
                        final isEnabled = snapshot.data ?? true;
                        return IconButton(
                          icon: Icon(
                            isEnabled
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            color: isEnabled
                                ? EventUIHelper.getEventColor(event)
                                : Colors.grey,
                          ),
                          onPressed: () async {
                            final newValue = !isEnabled;
                            await _notificationService.toggleEventNotification(
                                event, newValue);
                            setState(() {});
                          },
                          tooltip: isEnabled
                              ? 'Disable notifications'
                              : 'Enable notifications',
                        );
                      },
                    ),
                  ),

                  // Date chip for upcoming events
                  if (event.isUpcoming)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          event.dateString,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Event details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.timeRangeString} • ${event.dateString}',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.location,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Registration status
                      if (event.isRegistrationRequired)
                        Chip(
                          label: Text(
                            event.isUserRegistered
                                ? 'Registered'
                                : event.isFull
                                    ? 'Full'
                                    : 'Registration Required',
                          ),
                          backgroundColor: event.isUserRegistered
                              ? Colors.green.withOpacity(0.2)
                              : event.isFull
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: event.isUserRegistered
                                ? Colors.green
                                : event.isFull
                                    ? Colors.red
                                    : Colors.orange,
                            fontSize: 12,
                          ),
                        ),

                      // View details button
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailScreen(eventId: event.id),
                            ),
                          );
                        },
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Events'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: _categories.map((category) {
                return RadioListTile<String>(
                  title: Text(category),
                  value: category,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Notification Settings'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const ListTile(
                      title: Text(
                        'Event Notifications',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Receive notifications 30 minutes before events',
                      ),
                    ),
                    const Divider(),
                    ..._categories.where((c) => c != 'All').map((category) {
                      return FutureBuilder<bool>(
                        future: () async {
                          final prefs = await SharedPreferences.getInstance();
                          return prefs.getBool('notify_$category') ?? true;
                        }(),
                        builder: (context, snapshot) {
                          final isEnabled = snapshot.data ?? true;
                          return SwitchListTile(
                            title: Text(category),
                            value: isEnabled,
                            onChanged: (value) async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('notify_$category', value);
                              setState(() {});

                              // Reload events to update notifications
                              if (context.mounted) {
                                context.read<EventsBloc>().add(LoadEvents());
                              }
                            },
                          );
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEventSuggestionDialog() {
    // This would allow students to suggest events to administrators
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Suggest an Event'),
          content: const Text(
            'This feature allows you to suggest events to campus administrators. '
            'Coming soon!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../blocs/events/events_bloc.dart';
import '../../blocs/events/events_state.dart';
import '../../blocs/events/events_event.dart';
import '../../../domain/entities/event.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile
            },
          ),
        ],
      ),
      body: BlocBuilder<EventsBloc, EventsState>(
        builder: (context, state) {
          // Load events if they're not already loaded
          if (state is EventsInitial) {
            context.read<EventsBloc>().add(LoadEvents());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                _buildProfileHeader(),
                const SizedBox(height: 24),

                // Registered Events
                _buildSectionHeader('My Registered Events'),
                _buildRegisteredEvents(context, state),
                const SizedBox(height: 24),

                // Academic information
                _buildSectionHeader('Academic Information'),
                _buildInfoCard([
                  _buildInfoRow('Student ID', '12345678'),
                  _buildInfoRow('Major', 'Computer Science'),
                  _buildInfoRow('Year', 'Junior (3rd Year)'),
                  _buildInfoRow('GPA', '3.85'),
                  _buildInfoRow('Advisor', 'Dr. Jane Smith'),
                ]),
                const SizedBox(height: 24),

                // Contact information
                _buildSectionHeader('Contact Information'),
                _buildInfoCard([
                  _buildInfoRow('Email', 'student@university.edu'),
                  _buildInfoRow('Phone', '(555) 123-4567'),
                  _buildInfoRow(
                      'Address', '123 Campus Drive, University Housing'),
                ]),
                const SizedBox(height: 24),

                // Settings & preferences
                _buildSectionHeader('Settings & Preferences'),
                _buildSettingsSection(),
                const SizedBox(height: 24),

                // Sign out button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Sign out and navigate to login
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          // Profile picture
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue.shade100,
            child: const Icon(
              Icons.person,
              size: 50,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),

          // Name
          const Text(
            'John Doe',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Student info
          Text(
            'Computer Science • Junior',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Quick stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat('3.85', 'GPA'),
              _buildDivider(),
              _buildStat('18', 'Credits'),
              _buildDivider(),
              _buildStat('86', 'Completed'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredEvents(BuildContext context, EventsState state) {
    if (state is EventsLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is EventsError) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<EventsBloc>().add(LoadEvents());
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (state is EventsLoaded) {
      final registeredEvents = state.allEvents
          .where((event) => state.registeredEventIds.contains(event.id))
          .toList();

      if (registeredEvents.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(
                  Icons.event_busy,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No registered events yet',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Browse events and register to see them here',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to events screen
                    context.go('/events');
                  },
                  child: const Text('Browse Events'),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          for (final event in registeredEvents)
            _buildRegisteredEventCard(context, event),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildRegisteredEventCard(BuildContext context, Event event) {
    final dateFormat = DateFormat('E, MMM d');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Navigate to event details
          _showEventDetails(context, event);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date indicator
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(event.categories.first)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dateFormat.format(event.startTime),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(event.categories.first),
                      ),
                    ),
                    Text(
                      timeFormat.format(event.startTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getCategoryColor(event.categories.first),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Event details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(event.categories.first)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            event.categories.first,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getCategoryColor(event.categories.first),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (event.isPast)
                          const Chip(
                            label: Text('Past',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white)),
                            backgroundColor: Colors.grey,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                          )
                        else if (event.isOngoing)
                          const Chip(
                            label: Text('Now',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white)),
                            backgroundColor: Colors.green,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                          )
                        else
                          Chip(
                            label: const Text('Upcoming',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white)),
                            backgroundColor: Colors.blue.shade700,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action button
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () {
                  // Add to calendar
                  _addToCalendar(context, event);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetails(BuildContext context, Event event) {
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final timeFormat = DateFormat('h:mm a');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Event image or placeholder
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: _getCategoryColor(event.categories.first)
                          .withOpacity(0.2),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(event.categories.first),
                          size: 64,
                          color: _getCategoryColor(event.categories.first)
                              .withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),

                  // Event details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and category
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(event.categories.first)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                event.categories.first,
                                style: TextStyle(
                                  color:
                                      _getCategoryColor(event.categories.first),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Date and time
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              dateFormat.format(event.startTime),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.location,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.people, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              event.organizer,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),

                        const Divider(height: 32),

                        // Description
                        const Text(
                          'About',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.description,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),

                        const SizedBox(height: 24),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _addToCalendar(context, event);
                                },
                                icon: const Icon(Icons.calendar_today),
                                label: const Text('Add to Calendar'),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _addToCalendar(BuildContext context, Event event) {
    // Show a snackbar to simulate adding to calendar
    // In a real app, this would integrate with the device's calendar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${event.title} added to your calendar'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Would open calendar app
          },
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Academic':
        return Colors.blue;
      case 'Social':
        return Colors.purple;
      case 'Sports':
        return Colors.green;
      case 'Career':
        return Colors.orange;
      case 'Featured':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Academic':
        return Icons.school;
      case 'Social':
        return Icons.people;
      case 'Sports':
        return Icons.sports_basketball;
      case 'Career':
        return Icons.work;
      case 'Featured':
        return Icons.star;
      default:
        return Icons.event;
    }
  }

  Widget _buildSettingsSection() {
    final settingsItems = [
      {
        'icon': Icons.notifications,
        'title': 'Notifications',
        'subtitle': 'Configure notification preferences',
      },
      {
        'icon': Icons.language,
        'title': 'Language',
        'subtitle': 'English (US)',
      },
      {
        'icon': Icons.dark_mode,
        'title': 'Dark Mode',
        'subtitle': 'Off',
      },
      {
        'icon': Icons.privacy_tip,
        'title': 'Privacy Settings',
        'subtitle': 'Manage your data and privacy',
      },
      {
        'icon': Icons.help,
        'title': 'Help & Support',
        'subtitle': 'Get assistance and report issues',
      },
      {
        'icon': Icons.info,
        'title': 'About',
        'subtitle': 'App version and information',
      },
    ];

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: settingsItems.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = settingsItems[index];
          return ListTile(
            leading: Icon(
              item['icon'] as IconData,
              color: Colors.blue,
            ),
            title: Text(item['title'] as String),
            subtitle: Text(item['subtitle'] as String),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to specific setting
            },
          );
        },
      ),
    );
  }
}

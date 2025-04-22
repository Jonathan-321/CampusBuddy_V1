import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/app_theme.dart';
import '../../../domain/entities/event.dart';
import '../../blocs/events/events_bloc.dart';
import '../../blocs/events/events_state.dart';
import '../../blocs/events/events_event.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Event? _event;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  void _loadEventDetails() {
    try {
      final eventsState = context.read<EventsBloc>().state;
      if (eventsState is EventsLoaded) {
        // Look for the event in all events first
        Event? foundEvent;

        // Check both filtered and all events to ensure we find the right event
        foundEvent = eventsState.filteredEvents.cast<Event>().firstWhere(
              (event) => event.id == widget.eventId,
              orElse: () => Event(
                id: '',
                title: '',
                description: '',
                startTime: DateTime.now(),
                endTime: DateTime.now(),
                location: '',
                organizer: '',
                category: 'Unknown',
              ),
            );

        // If not found in filtered events (empty ID), check all events
        if (foundEvent?.id.isEmpty ??
            true && eventsState.allEvents.isNotEmpty) {
          foundEvent = eventsState.allEvents.cast<Event>().firstWhere(
                (event) => event.id == widget.eventId,
                orElse: () => Event(
                  id: 'not-found',
                  title: 'Event Not Found',
                  description: 'The requested event could not be found.',
                  startTime: DateTime.now(),
                  endTime: DateTime.now().add(const Duration(hours: 1)),
                  location: 'N/A',
                  organizer: 'N/A',
                  imageUrl: null,
                  isVirtual: false,
                  category: 'N/A',
                  categories: [],
                  tags: [],
                ),
              );
        }

        setState(() {
          _event = foundEvent;
        });
      }
    } catch (error) {
      print('Error loading event details: $error');
      setState(() {
        _event = Event(
          id: 'error',
          title: 'Error Loading Event',
          description: 'There was an error loading this event.',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          location: 'N/A',
          organizer: 'N/A',
          imageUrl: null,
          isVirtual: false,
          category: 'Error',
          categories: [],
          tags: [],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _event == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: _buildEventDetails(),
                ),
              ],
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _event?.title ?? 'Event Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Event image or placeholder
            if (_event?.imageUrl != null && _event!.imageUrl!.isNotEmpty)
              Image.asset(
                _event!.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImagePlaceholder(),
              )
            else
              _buildImagePlaceholder(),
            // Gradient overlay for better text visibility
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            context.go('/home');
          }
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Share event functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share functionality coming soon')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_border),
          onPressed: () {
            // Save event functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event saved')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.primaryColor.withOpacity(0.7),
      child: Center(
        child: Icon(
          Icons.event,
          size: 80,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEventDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and time
          _buildInfoRow(
            Icons.calendar_today,
            '${DateFormat('E, MMM d, yyyy').format(_event?.startTime ?? DateTime.now())} · ${DateFormat('h:mm a').format(_event?.startTime ?? DateTime.now())} - ${DateFormat('h:mm a').format(_event?.endTime ?? DateTime.now())}',
          ),
          const SizedBox(height: 12),

          // Location
          _buildInfoRow(
            Icons.location_on,
            _event?.location ?? 'Location not specified',
          ),
          const SizedBox(height: 16),

          // Category/Tag
          if (_event?.categories != null && _event!.categories.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _event!.categories
                  .map(
                    (category) => Chip(
                      label: Text(category),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 24),

          // Description
          const Text(
            'About',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Wrap text in a Container to handle overflow
          Container(
            constraints: const BoxConstraints(minHeight: 100),
            child: Text(
              _event?.description ?? 'No description available',
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Organizer
          const Text(
            'Organizer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.group,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _event?.organizer ?? 'University Club',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Event Organizer',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.mail_outline),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Contact feature coming soon!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Registration button
          if (_event != null && !(_event!.isPast ?? false)) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Show registration dialog or handle virtual link
                  if ((_event!.isVirtual ?? false) &&
                      _event!.virtualLink != null) {
                    // Handle virtual link
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Opening virtual event at ${_event!.virtualLink}'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } else {
                    _showRegistrationDialog();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  (_event!.isVirtual ?? false)
                      ? 'Join Virtual Event'
                      : 'Register Now',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Add to Calendar button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Add to calendar functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to calendar')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add to Calendar',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Removed _formatDate and _formatTime methods as we're using DateFormat directly

  // _buildOrganizerCard method removed and inlined above

  void _showRegistrationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(
          _event?.isVirtual == true
              ? 'Join Virtual Event'
              : 'Register for Event',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to ${_event?.isVirtual == true ? 'join' : 'register for'}: ${_event?.title}',
            ),
            const SizedBox(height: 16),
            if (_event?.isVirtual != true) ...[
              const Text(
                'Please confirm your attendance:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _event?.isVirtual == true
                        ? 'Joining virtual event...'
                        : 'Registration successful!',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text(
              _event?.isVirtual == true ? 'Join Now' : 'Register',
            ),
          ),
        ],
      ),
    );
  }
}

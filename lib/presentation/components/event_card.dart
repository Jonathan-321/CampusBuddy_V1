import 'package:flutter/material.dart';
import '../../domain/entities/event.dart';
import '../../config/theme/app_theme.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final int index;
  final VoidCallback onTap;
  final VoidCallback? onRegister;
  final bool showFullDetails;

  const EventCard({
    Key? key,
    required this.event,
    this.index = 0,
    required this.onTap,
    this.onRegister,
    this.showFullDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure we have a fixed size container to prevent 'render box with no size' errors
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeInOut,
      width: showFullDetails ? double.infinity : 280,
      // Set a minimum height but don't constrain max height to prevent overflow
      constraints: BoxConstraints(minHeight: 200),
      margin: EdgeInsets.only(
        right: showFullDetails ? 0 : 16,
        bottom: showFullDetails ? 16 : 0,
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Event header with image/gradient
              Stack(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    // Ensure the container has a minimum width
                    constraints: BoxConstraints(minWidth: 200),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getEventGradient(event.categories.isNotEmpty
                            ? event.categories.first
                            : ''),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getEventIcon(event.categories.isNotEmpty
                            ? event.categories.first
                            : ''),
                        size: 48,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        event.categories.isNotEmpty
                            ? event.categories.first
                            : 'Event',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (event.isVirtual == false)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Open',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Event details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 2,
                          child: Text(
                            event.formattedDate,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 2,
                          child: Text(
                            event.formattedTime,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (showFullDetails) ...[
                      const SizedBox(height: 12),
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (onRegister != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Register'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get event icon based on category
  IconData _getEventIcon(String category) {
    switch (category.toLowerCase()) {
      case 'social':
        return Icons.people;
      case 'career':
        return Icons.work;
      case 'academic':
        return Icons.school;
      case 'sports':
        return Icons.sports_basketball;
      case 'clubs':
        return Icons.group;
      case 'technology':
        return Icons.computer;
      case 'research':
        return Icons.science;
      case 'volunteer':
        return Icons.volunteer_activism;
      default:
        return Icons.event;
    }
  }

  // Helper method to get gradient colors based on event category
  List<Color> _getEventGradient(String category) {
    switch (category.toLowerCase()) {
      case 'social':
        return [Colors.purple.shade300, Colors.purple.shade700];
      case 'career':
        return [Colors.blue.shade300, Colors.blue.shade700];
      case 'academic':
        return [Colors.green.shade300, Colors.green.shade700];
      case 'sports':
        return [Colors.orange.shade300, Colors.orange.shade700];
      case 'clubs':
        return [Colors.teal.shade300, Colors.teal.shade700];
      case 'technology':
        return [Colors.indigo.shade300, Colors.indigo.shade700];
      case 'research':
        return [Colors.cyan.shade300, Colors.cyan.shade700];
      case 'volunteer':
        return [Colors.pink.shade300, Colors.pink.shade700];
      default:
        return [Colors.blue.shade300, Colors.blue.shade700];
    }
  }
}

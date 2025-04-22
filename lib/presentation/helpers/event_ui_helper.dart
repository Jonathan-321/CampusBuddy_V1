/// Event UI Helper
///
/// Provides UI-specific helper methods and properties for the Event entity.
/// This keeps UI concerns separate from the domain entity.

import 'package:flutter/material.dart';
import '../../domain/entities/event.dart';

class EventUIHelper {
  /// Get appropriate color for an event category
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'academic':
        return Colors.blue;
      case 'social':
        return Colors.purple;
      case 'sports':
        return Colors.green;
      case 'career':
        return Colors.orange;
      case 'arts':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  /// Get appropriate icon for an event category
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'academic':
        return Icons.school;
      case 'social':
        return Icons.people;
      case 'sports':
        return Icons.sports;
      case 'career':
        return Icons.work;
      case 'arts':
        return Icons.palette;
      default:
        return Icons.event;
    }
  }

  /// Get color for an event
  static Color getEventColor(Event event) {
    return getCategoryColor(event.category);
  }

  /// Get icon for an event
  static IconData getEventIcon(Event event) {
    return getCategoryIcon(event.category);
  }

  /// Get background color for an event card based on status
  static Color getEventCardColor(Event event, {bool isDarkMode = false}) {
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.white;

    if (event.isOngoing) {
      return isDarkMode
          ? Colors.green.withOpacity(0.2)
          : Colors.green.withOpacity(0.05);
    } else if (event.isPast) {
      return isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;
    }

    return baseColor;
  }

  /// Get text style for event title
  static TextStyle getEventTitleStyle(Event event, {bool isDarkMode = false}) {
    if (event.isPast) {
      return TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
      );
    }

    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? Colors.white : Colors.black87,
    );
  }

  /// Get indicator widget for event status
  static Widget getStatusIndicator(Event event) {
    if (event.isOngoing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Now',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (event.isUpcoming) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Upcoming',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Past',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }
}

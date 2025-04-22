import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';
import '../../../domain/entities/course.dart';
import '../animations/animated_list_item.dart';

class ClassCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;
  final int index;
  final bool isNext;

  const ClassCard({
    Key? key,
    required this.course,
    this.onTap,
    this.index = 0,
    this.isNext = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Extract course code from the name (assuming format like "CS 101: Intro to Programming")
    final courseCode = _extractCourseCode(course.name);

    return AnimatedListItem(
      index: index,
      child: AnimatedTapContainer(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: isNext
                ? Border.all(color: AppTheme.accentColor, width: 2)
                : null,
          ),
          child: Row(
            children: [
              // Color indicator and subject icon
              Container(
                width: 70,
                height: 100,
                decoration: BoxDecoration(
                  color: _getSubjectColor(courseCode),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getSubjectIcon(courseCode),
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      courseCode.length > 4
                          ? courseCode.substring(0, 4)
                          : courseCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Class details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Class name with status indicator
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              course.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isNext)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'NEXT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Time
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatSchedule(course.schedule),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              course.location,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Instructor
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              course.instructor,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Extract course code from name (e.g., "CS 101: Intro to Programming" -> "CS")
  String _extractCourseCode(String name) {
    // Try to extract course code from format like "CS 101: Intro to Programming"
    final parts = name.split(' ');
    if (parts.isNotEmpty) {
      // If contains digits (likely course number), return the first part
      if (parts.length > 1 && RegExp(r'\d').hasMatch(parts[1])) {
        return parts[0];
      }
    }
    // Default to first 3 chars or full name if shorter
    return name.length > 3 ? name.substring(0, 3) : name;
  }

  // Format schedule to extract time information
  String _formatSchedule(String schedule) {
    // If schedule contains time range (e.g., "MWF 10:00 AM - 11:30 AM")
    if (schedule.contains('-')) {
      final timeParts = schedule.split(' ');
      if (timeParts.length >= 4) {
        // Try to extract just the time portion
        return '${timeParts[1]} ${timeParts[2]} ${timeParts[3]}';
      }
    }
    return schedule; // Return as is if can't parse
  }

  Color _getSubjectColor(String subject) {
    final normalizedSubject = subject.toLowerCase();

    if (normalizedSubject.contains('math') ||
        normalizedSubject.contains('calculus') ||
        normalizedSubject.contains('statistics')) {
      return Colors.blue;
    } else if (normalizedSubject.contains('cs') ||
        normalizedSubject.contains('comp') ||
        normalizedSubject.contains('computer') ||
        normalizedSubject.contains('programming') ||
        normalizedSubject.contains('informatics')) {
      return Colors.indigo;
    } else if (normalizedSubject.contains('bio') ||
        normalizedSubject.contains('biology') ||
        normalizedSubject.contains('ecology')) {
      return Colors.green;
    } else if (normalizedSubject.contains('chem') ||
        normalizedSubject.contains('chemistry')) {
      return Colors.purple;
    } else if (normalizedSubject.contains('phys') ||
        normalizedSubject.contains('physics')) {
      return Colors.orange;
    } else if (normalizedSubject.contains('hist') ||
        normalizedSubject.contains('history') ||
        normalizedSubject.contains('political')) {
      return Colors.brown;
    } else if (normalizedSubject.contains('eng') ||
        normalizedSubject.contains('english') ||
        normalizedSubject.contains('literature') ||
        normalizedSubject.contains('writing')) {
      return Colors.teal;
    } else if (normalizedSubject.contains('art') ||
        normalizedSubject.contains('music') ||
        normalizedSubject.contains('design')) {
      return Colors.pink;
    } else if (normalizedSubject.contains('psych') ||
        normalizedSubject.contains('psychology') ||
        normalizedSubject.contains('sociology')) {
      return Colors.deepPurple;
    } else if (normalizedSubject.contains('bus') ||
        normalizedSubject.contains('business') ||
        normalizedSubject.contains('economics') ||
        normalizedSubject.contains('finance')) {
      return Colors.amber.shade800;
    } else {
      return AppTheme.primaryColor;
    }
  }

  IconData _getSubjectIcon(String subject) {
    final normalizedSubject = subject.toLowerCase();

    if (normalizedSubject.contains('math') ||
        normalizedSubject.contains('calculus') ||
        normalizedSubject.contains('statistics')) {
      return Icons.functions;
    } else if (normalizedSubject.contains('cs') ||
        normalizedSubject.contains('comp') ||
        normalizedSubject.contains('computer') ||
        normalizedSubject.contains('programming') ||
        normalizedSubject.contains('informatics')) {
      return Icons.computer;
    } else if (normalizedSubject.contains('bio') ||
        normalizedSubject.contains('biology') ||
        normalizedSubject.contains('ecology')) {
      return Icons.biotech;
    } else if (normalizedSubject.contains('chem') ||
        normalizedSubject.contains('chemistry')) {
      return Icons.science;
    } else if (normalizedSubject.contains('phys') ||
        normalizedSubject.contains('physics')) {
      return Icons.bolt;
    } else if (normalizedSubject.contains('hist') ||
        normalizedSubject.contains('history') ||
        normalizedSubject.contains('political')) {
      return Icons.history_edu;
    } else if (normalizedSubject.contains('eng') ||
        normalizedSubject.contains('english') ||
        normalizedSubject.contains('literature') ||
        normalizedSubject.contains('writing')) {
      return Icons.menu_book;
    } else if (normalizedSubject.contains('art') ||
        normalizedSubject.contains('music') ||
        normalizedSubject.contains('design')) {
      return Icons.palette;
    } else if (normalizedSubject.contains('psych') ||
        normalizedSubject.contains('psychology') ||
        normalizedSubject.contains('sociology')) {
      return Icons.psychology;
    } else if (normalizedSubject.contains('bus') ||
        normalizedSubject.contains('business') ||
        normalizedSubject.contains('economics') ||
        normalizedSubject.contains('finance')) {
      return Icons.business;
    } else {
      return Icons.school;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_theme.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/event.dart';
import '../../blocs/events/events_bloc.dart';
import '../../blocs/events/events_state.dart';
import '../../blocs/events/events_event.dart';
import '../../../logic/blocs/courses/courses_bloc.dart';
import '../../widgets/event_card.dart';
import '../../widgets/empty_state.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load courses and events
    context.read<CoursesBloc>().add(LoadCourses());
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
        title: const Text('Schedule'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Day'),
            Tab(text: 'Week'),
            Tab(text: 'Month'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDayView(),
          _buildWeekView(),
          _buildMonthView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDayView() {
    return Column(
      children: [
        _buildDateSelector(),
        Expanded(
          child: _buildScheduleForDay(_selectedDay),
        ),
      ],
    );
  }

  Widget _buildWeekView() {
    return Column(
      children: [
        _buildCalendar(),
        Expanded(
          child: _buildScheduleForDay(_selectedDay),
        ),
      ],
    );
  }

  Widget _buildMonthView() {
    return Column(
      children: [
        _buildCalendar(initialCalendarFormat: CalendarFormat.month),
        Expanded(
          child: _buildScheduleForDay(_selectedDay),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDay = _selectedDay.subtract(const Duration(days: 1));
                _focusedDay = _selectedDay;
              });
            },
          ),
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDay,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() {
                  _selectedDay = picked;
                  _focusedDay = picked;
                });
              }
            },
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE').format(_selectedDay),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMMM d, y').format(_selectedDay),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDay = _selectedDay.add(const Duration(days: 1));
                _focusedDay = _selectedDay;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(
      {CalendarFormat initialCalendarFormat = CalendarFormat.week}) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: initialCalendarFormat == CalendarFormat.month
          ? CalendarFormat.month
          : _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      eventLoader: (day) {
        // Return events for this day
        return _getEventsForDay(day);
      },
      calendarStyle: CalendarStyle(
        markersMaxCount: 3,
        markerDecoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    // Get courses for this day
    final coursesState = context.read<CoursesBloc>().state;
    final eventsState = context.read<EventsBloc>().state;

    List<dynamic> events = [];

    if (coursesState is CoursesLoaded) {
      // Add courses that occur on this day of the week
      final dayOfWeek = DateFormat('EEEE').format(day).toLowerCase();
      final coursesForDay = coursesState.allCourses.where((course) {
        return course.schedule.toLowerCase().contains(dayOfWeek);
      }).toList();

      events.addAll(coursesForDay);
    }

    if (eventsState is EventsLoaded) {
      // Add events that occur on this day
      final eventsForDay = eventsState.allEvents.where((event) {
        return isSameDay(event.startTime, day);
      }).toList();

      events.addAll(eventsForDay);
    }

    return events;
  }

  Widget _buildScheduleForDay(DateTime day) {
    final events = _getEventsForDay(day);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No events scheduled for ${DateFormat('MMMM d').format(day)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _showAddEventDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Event'),
            ),
          ],
        ),
      );
    }

    // Sort events by time
    events.sort((a, b) {
      if (a is Course && b is Course) {
        return a.schedule.compareTo(b.schedule);
      } else if (a is Event && b is Event) {
        return a.startTime.compareTo(b.startTime);
      } else if (a is Course && b is Event) {
        return -1; // Courses come before events
      } else {
        return 1; // Events come after courses
      }
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];

        if (event is Course) {
          return _buildCourseItem(event);
        } else if (event is Event) {
          return _buildEventItem(event);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCourseItem(Course course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          _showCourseDetails(course);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _extractTimeFromSchedule(course.schedule),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Course details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.class_, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Course',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Instructor: ${course.instructor}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Location: ${course.location}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventItem(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          _showEventDetails(event);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  DateFormat('h:mm a').format(event.startTime),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Event details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Event',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Location: ${event.location}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Duration: ${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractTimeFromSchedule(String schedule) {
    // Extract time from schedule string (e.g., "Monday, Wednesday 2:00 PM - 3:30 PM")
    final timeRegex = RegExp(r'(\d+:\d+ [AP]M) - (\d+:\d+ [AP]M)');
    final match = timeRegex.firstMatch(schedule);

    if (match != null) {
      return match.group(1) ?? ''; // Return start time
    }

    return 'TBD';
  }

  void _showCourseDetails(Course course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Course title
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Course details
                    _buildDetailRow(Icons.access_time, 'Time', course.schedule),
                    _buildDetailRow(
                        Icons.location_on, 'Location', course.location),
                    _buildDetailRow(
                        Icons.person, 'Instructor', course.instructor),
                    _buildDetailRow(
                        Icons.school, 'Credits', course.credits.toString()),
                    if (course.grade != null)
                      _buildDetailRow(Icons.grade, 'Grade', course.grade!),
                    _buildDetailRow(Icons.trending_up, 'Progress',
                        '${(course.progress * 100).toInt()}%'),

                    const Divider(height: 32),

                    // Course description
                    const Text(
                      'Course Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.description,
                      style: const TextStyle(height: 1.5),
                    ),

                    if (course.assignments.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Assignments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...course.assignments.map((assignment) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.assignment),
                            title: Text(assignment.title),
                            subtitle: Text('Due: ${assignment.dueDate}'),
                            trailing: Text(
                              assignment.status,
                              style: TextStyle(
                                color: assignment.status == 'Completed'
                                    ? Colors.green
                                    : assignment.status == 'Pending'
                                        ? Colors.orange
                                        : Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
                    ],

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.menu_book),
                            label: const Text('View Course'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Assignment submission coming soon!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.assignment),
                            label: const Text('Assignments'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEventDetails(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Event image
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.event,
                          size: 64,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Event title
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Event details
                    _buildDetailRow(
                        Icons.calendar_today, 'Date', event.formattedDate),
                    _buildDetailRow(
                        Icons.access_time, 'Time', event.formattedTime),
                    _buildDetailRow(
                        Icons.location_on, 'Location', event.location),
                    _buildDetailRow(Icons.person, 'Organizer', event.organizer),

                    const Divider(height: 32),

                    // Event description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: const TextStyle(height: 1.5),
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Adding to calendar...'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Add to Calendar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('RSVP feature coming soon!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_circle),
                            label: const Text('RSVP'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.class_),
              title: const Text('Add Course'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Course registration coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Add Event'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Event creation coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Add Assignment'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Assignment creation coming soon!'),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

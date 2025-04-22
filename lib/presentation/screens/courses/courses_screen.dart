import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Import necessary BLoCs and models
import '../../../logic/blocs/courses/courses_bloc.dart';
import '../../../domain/entities/course.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Current', 'Upcoming', 'Completed'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Trigger initial courses load
    context.read<CoursesBloc>().add(LoadCourses());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      final status = _tabs[_tabController.index];
      context.read<CoursesBloc>().add(FilterCoursesByStatus(status));
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    context.read<CoursesBloc>().add(SearchCourses(query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<CoursesBloc, CoursesState>(
        builder: (context, state) {
          if (state is CoursesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CoursesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load courses'),
                  ElevatedButton(
                    onPressed: () => context.read<CoursesBloc>().add(LoadCourses()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CoursesLoaded) {
            // Use the correct properties from the state
            final allCourses = state.allCourses;

            return TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) {
                final filteredCourses = allCourses
                    .where((course) => 
                      course.status == tab && 
                      course.name.toLowerCase().contains(_searchQuery.toLowerCase())
                    )
                    .toList();

                return filteredCourses.isEmpty
                    ? _buildEmptyState(tab)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredCourses.length,
                        itemBuilder: (context, index) {
                          return _buildCourseCard(filteredCourses[index]);
                        },
                      );
              }).toList(),
            );
          }

          return const Center(child: Text('No courses found'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCourseRegistrationDialog,
        icon: const Icon(Icons.add),
        label: const Text('Register Courses'),
      ),
    );
  }

  Widget _buildEmptyState(String tab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            tab == 'Current' 
              ? Icons.book 
              : tab == 'Upcoming' 
                ? Icons.calendar_today 
                : Icons.check_circle,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No $tab Courses',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tab == 'Current' 
              ? 'You are not enrolled in any courses this semester.' 
              : tab == 'Upcoming' 
                ? 'No upcoming courses at the moment.' 
                : 'You have not completed any courses yet.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    final Color statusColor = _getStatusColor(course.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          try {
            // Navigate to course detail screen using GoRouter
            context.go('/courses/${course.id}');
          } catch (e) {
            print('Navigation error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not navigate to course details')),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                border: Border(
                  left: BorderSide(
                    color: statusColor,
                    width: 4,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Course code
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      course.id,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Course name
                  Expanded(
                    child: Text(
                      course.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  
                  // Credits
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${course.credits} cr',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Course details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instructor
                  _buildDetailRow(
                    icon: Icons.person,
                    label: 'Instructor',
                    value: course.instructor,
                  ),
                  
                  // Schedule
                  _buildDetailRow(
                    icon: Icons.access_time,
                    label: 'Schedule',
                    value: course.schedule,
                  ),
                  
                  // Location
                  _buildDetailRow(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: course.location,
                  ),
                  
                  // Progress or Grade
                  if (course.status == 'Current') 
                    _buildProgressIndicator(course),
                  
                  if (course.status == 'Completed') 
                    _buildCompletedCourseGrade(course),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon, 
    required String label, 
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Course Progress',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(course.progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getStatusColor(course.status),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: course.progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(course.status)),
        ),
      ],
    );
  }

  Widget _buildCompletedCourseGrade(Course course) {
    final grade = course.grade ?? 'N/A';
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Icon(Icons.grade, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          const Text(
            'Final Grade: ',
            style: TextStyle(fontSize: 14),
          ),
          Text(
            grade,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getGradeColor(grade),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Current':
        return Colors.blue;
      case 'Upcoming':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
      case 'A-':
        return Colors.green;
      case 'B+':
      case 'B':
      case 'B-':
        return Colors.blue;
      case 'C+':
      case 'C':
      case 'C-':
        return Colors.orange;
      case 'D+':
      case 'D':
      case 'D-':
        return Colors.deepOrange;
      case 'F':
        return Colors.red;
      case 'In Progress':
        return Colors.blue;
      case 'N/A':
      default:
        return Colors.grey;
    }
  }

  void _showCourseDetailsBottomSheet(Course course) {
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course title
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Course code and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          course.id,
                          style: TextStyle(
                            color: _getStatusColor(course.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          course.status,
                          style: TextStyle(
                            color: _getStatusColor(course.status),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    
                    // Detailed course information
                    _buildDetailRow(
                      icon: Icons.person,
                      label: 'Instructor',
                      value: course.instructor,
                    ),
                    _buildDetailRow(
                      icon: Icons.access_time,
                      label: 'Schedule',
                      value: course.schedule,
                    ),
                    _buildDetailRow(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: course.location,
                    ),
                    _buildDetailRow(
                      icon: Icons.school,
                      label: 'Credits',
                      value: '${course.credits}',
                    ),
                    
                    const SizedBox(height: 16),
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
                    
                    const SizedBox(height: 24),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showAssignmentsBottomSheet(course),
                            icon: const Icon(Icons.assignment),
                            label: const Text('Assignments'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showCourseResourcesBottomSheet(course),
                            icon: const Icon(Icons.book),
                            label: const Text('Resources'),
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

  void _showAssignmentsBottomSheet(Course course) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Assignments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: course.assignments.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final assignment = course.assignments[index];
                  return ListTile(
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
                      ),
                    ),
                    onTap: () {
                      // TODO: Implement assignment submission or details
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCourseResourcesBottomSheet(Course course) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Course Resources',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.file_present),
                    title: const Text('Lecture Slides'),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        // TODO: Implement file download
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.video_library),
                    title: const Text('Recorded Lectures'),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        // TODO: Implement video playback
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.book),
                    title: const Text('Recommended Reading'),
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () {
                        // TODO: Implement external link opening
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Courses'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by course name or code',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _handleSearch,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _searchController.clear();
              context.read<CoursesBloc>().add(LoadCourses());
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Courses'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('By Department'),
              trailing: DropdownButton<String>(
                hint: const Text('Select'),
                items: [
                  'Computer Science',
                  'Mathematics',
                  'Physics',
                  'Biology',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {
                  // TODO: Implement department filtering
                },
              ),
            ),
            ListTile(
              title: const Text('By Credits'),
              trailing: DropdownButton<String>(
                hint: const Text('Select'),
                items: [
                  '1-3 Credits',
                  '4-6 Credits',
                  '7+ Credits',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {
                  // TODO: Implement credits filtering
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Apply filters
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showCourseRegistrationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register for Courses'),
        content: const Text(
          'Course registration is currently not available. '
          'Please visit the university portal or contact the registrar\'s office.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

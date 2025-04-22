import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/assignment.dart';
import '../../../domain/entities/course.dart';
import '../../../logic/blocs/courses/courses_bloc.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({Key? key}) : super(key: key);

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Upcoming', 'Completed', 'Late'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load courses
    context.read<CoursesBloc>().add(LoadCourses());
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
        title: const Text('Assignments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'By Course'),
            Tab(text: 'Calendar'),
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
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllAssignmentsTab(),
          _buildByCourseTab(),
          _buildCalendarTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAssignmentDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildAllAssignmentsTab() {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        if (state is CoursesInitial) {
          context.read<CoursesBloc>().add(LoadCourses());
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is CoursesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is CoursesError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<CoursesBloc>().add(LoadCourses());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state is CoursesLoaded) {
          // Get all assignments from all courses
          final allAssignments = <Assignment>[];
          for (final course in state.allCourses) {
            allAssignments.addAll(course.assignments);
          }
          
          // Filter assignments based on selected filter
          final filteredAssignments = _filterAssignments(allAssignments, _selectedFilter);
          
          if (filteredAssignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No $_selectedFilter assignments found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddAssignmentDialog();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Assignment'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredAssignments.length,
            itemBuilder: (context, index) {
              final assignment = filteredAssignments[index];
              final course = _getCourseForAssignment(state.allCourses, assignment);
              
              return _buildAssignmentCard(assignment, course);
            },
          );
        }
        
        return const Center(child: Text('No assignments found'));
      },
    );
  }
  
  Widget _buildByCourseTab() {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        if (state is CoursesInitial || state is CoursesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is CoursesError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<CoursesBloc>().add(LoadCourses());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state is CoursesLoaded) {
          // Filter courses to only include those with assignments
          final coursesWithAssignments = state.allCourses
              .where((course) => course.assignments.isNotEmpty)
              .toList();
          
          if (coursesWithAssignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.class_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No courses with assignments found',
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
            itemCount: coursesWithAssignments.length,
            itemBuilder: (context, index) {
              final course = coursesWithAssignments[index];
              
              // Filter assignments for this course based on selected filter
              final filteredAssignments = _filterAssignments(course.assignments, _selectedFilter);
              
              if (filteredAssignments.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.class_, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              course.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '${filteredAssignments.length} assignments',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Assignments for this course
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredAssignments.length,
                      itemBuilder: (context, assignmentIndex) {
                        final assignment = filteredAssignments[assignmentIndex];
                        
                        return ListTile(
                          leading: _getAssignmentStatusIcon(assignment.status),
                          title: Text(assignment.title),
                          subtitle: Text('Due: ${assignment.dueDate}'),
                          trailing: Text(
                            assignment.status,
                            style: TextStyle(
                              color: _getStatusColor(assignment.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            _showAssignmentDetails(assignment, course);
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }
        
        return const Center(child: Text('No assignments found'));
      },
    );
  }
  
  Widget _buildCalendarTab() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Calendar view coming soon!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Calendar view will be available in the next update!'),
                ),
              );
            },
            child: const Text('Check for Updates'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAssignmentCard(Assignment assignment, Course? course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          _showAssignmentDetails(assignment, course);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Assignment header
              Row(
                children: [
                  _getAssignmentStatusIcon(assignment.status),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      assignment.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(assignment.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      assignment.status,
                      style: TextStyle(
                        color: _getStatusColor(assignment.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Due date
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Due: ${assignment.dueDate}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Course
              if (course != null) ...[
                Row(
                  children: [
                    const Icon(Icons.class_, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Course: ${course.name}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Description preview
              Text(
                assignment.description,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Grade if available
              if (assignment.grade != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.grade, size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Grade: ${(assignment.grade! * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _getAssignmentStatusIcon(String status) {
    switch (status) {
      case 'Completed':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'Pending':
        return const Icon(Icons.pending, color: Colors.orange);
      case 'Late':
        return const Icon(Icons.warning, color: Colors.red);
      case 'Upcoming':
        return const Icon(Icons.schedule, color: Colors.blue);
      default:
        return const Icon(Icons.assignment, color: Colors.grey);
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Late':
        return Colors.red;
      case 'Upcoming':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  List<Assignment> _filterAssignments(List<Assignment> assignments, String filter) {
    switch (filter) {
      case 'Upcoming':
        return assignments.where((a) => a.status == 'Upcoming').toList();
      case 'Completed':
        return assignments.where((a) => a.status == 'Completed').toList();
      case 'Late':
        return assignments.where((a) => a.status == 'Late').toList();
      case 'All':
      default:
        return assignments;
    }
  }
  
  Course? _getCourseForAssignment(List<Course> courses, Assignment assignment) {
    for (final course in courses) {
      for (final a in course.assignments) {
        if (a.id == assignment.id) {
          return course;
        }
      }
    }
    return null;
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Assignments'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filters.map((filter) => RadioListTile<String>(
            title: Text(filter),
            value: filter,
            groupValue: _selectedFilter,
            onChanged: (value) {
              setState(() {
                _selectedFilter = value!;
              });
              Navigator.pop(context);
            },
          )).toList(),
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
  
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Assignments'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter assignment title',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            // Implement search functionality
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement search
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
  
  void _showAddAssignmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Assignment'),
        content: const Text('Assignment creation coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showAssignmentDetails(Assignment assignment, Course? course) {
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
                    
                    // Assignment status
                    Row(
                      children: [
                        _getAssignmentStatusIcon(assignment.status),
                        const SizedBox(width: 8),
                        Text(
                          assignment.status,
                          style: TextStyle(
                            fontSize: 16,
                            color: _getStatusColor(assignment.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Assignment title
                    Text(
                      assignment.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Assignment details
                    _buildDetailRow(Icons.calendar_today, 'Due Date', assignment.dueDate),
                    if (course != null)
                      _buildDetailRow(Icons.class_, 'Course', course.name),
                    if (assignment.grade != null)
                      _buildDetailRow(Icons.grade, 'Grade', '${(assignment.grade! * 100).toInt()}%'),
                    
                    const Divider(height: 32),
                    
                    // Assignment description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      assignment.description,
                      style: const TextStyle(height: 1.5),
                    ),
                    
                    if (assignment.feedback != null) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Feedback',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          assignment.feedback!,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                    
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
                                  content: Text('Download feature coming soon!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Download'),
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
                                  content: Text('Submission feature coming soon!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Submit'),
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
}

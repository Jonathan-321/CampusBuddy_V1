import '../../domain/entities/course.dart';
import '../../domain/entities/assignment.dart';
import 'assignment_model.dart';

class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.name,
    required super.instructor,
    required super.schedule,
    required super.location,
    required super.credits,
    required super.status,
    required super.progress,
    super.grade,
    required super.description,
    required super.assignments,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      instructor: json['instructor'] ?? '',
      schedule: json['schedule'] ?? '',
      location: json['location'] ?? '',
      credits: json['credits'] ?? 0,
      status: json['status'] ?? 'Upcoming',
      progress: json['progress'] ?? 0.0,
      grade: json['grade'],
      description: json['description'] ?? '',
      assignments: (json['assignments'] as List<dynamic>? ?? [])
          .map((assignment) => AssignmentModel.fromJson(assignment))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'instructor': instructor,
      'schedule': schedule,
      'location': location,
      'credits': credits,
      'status': status,
      'progress': progress,
      'grade': grade,
      'description': description,
      'assignments': assignments,
    };
  }

  factory CourseModel.fromEntity(Course course) {
    return CourseModel(
      id: course.id,
      name: course.name,
      instructor: course.instructor,
      schedule: course.schedule,
      location: course.location,
      credits: course.credits,
      status: course.status,
      progress: course.progress,
      grade: course.grade,
      description: course.description,
      assignments: course.assignments,
    );
  }

  static List<CourseModel> mockCourses() {
    return [
      CourseModel(
        id: 'CS101',
        name: 'Introduction to Computer Science',
        instructor: 'Dr. Alan Smith',
        schedule: 'MWF 10:00 AM - 11:30 AM',
        location: 'Building A, Room 101',
        credits: 3,
        status: 'Current',
        progress: 0.65,
        grade: 'In Progress',
        description: 'An introduction to the basic principles of computer science including algorithms, data structures, and programming fundamentals.',
        assignments: [
          AssignmentModel(
            id: '1',
            title: 'Programming Assignment 1',
            description: 'Implement a simple algorithm in Python',
            dueDate: 'April 10, 2025',
            status: 'Completed',
            grade: 95.0,
            feedback: 'Great work!',
          ),
          AssignmentModel(
            id: '2',
            title: 'Programming Assignment 2',
            description: 'Create a data structure implementation',
            dueDate: 'April 20, 2025',
            status: 'Pending',
          ),
          AssignmentModel(
            id: '3',
            title: 'Midterm Exam',
            description: 'Covers all topics from weeks 1-7',
            dueDate: 'April 15, 2025',
            status: 'Upcoming',
          ),
        ],
      ),
      CourseModel(
        id: 'MATH202',
        name: 'Calculus II',
        instructor: 'Prof. Sarah Johnson',
        schedule: 'TR 1:00 PM - 2:30 PM',
        location: 'Building B, Room 205',
        credits: 4,
        status: 'Current',
        progress: 0.7,
        grade: 'In Progress',
        description: 'A continuation of Calculus I, covering integration techniques, applications of integration, and infinite series.',
        assignments: [
          AssignmentModel(
            id: '4',
            title: 'Problem Set 3',
            description: 'Integration techniques and applications',
            dueDate: 'April 12, 2025',
            status: 'Pending',
          ),
          AssignmentModel(
            id: '5',
            title: 'Quiz 2',
            description: 'Short quiz on integration by parts',
            dueDate: 'April 8, 2025',
            status: 'Completed',
            grade: 88.0,
            feedback: 'Good work, but review integration by parts',
          ),
        ],
      ),
      CourseModel(
        id: 'ENG205',
        name: 'Creative Writing',
        instructor: 'Prof. Emily Davis',
        schedule: 'TR 3:00 PM - 4:30 PM',
        location: 'Humanities Building, Room 105',
        credits: 3,
        status: 'Upcoming',
        progress: 0.0,
        grade: 'Not Started',
        description: 'A workshop-based course focusing on the craft of creative writing across multiple genres.',
        assignments: const [],
      ),
      CourseModel(
        id: 'HIST101',
        name: 'World History',
        instructor: 'Dr. Lisa Thompson',
        schedule: 'TR 11:00 AM - 12:30 PM',
        location: 'Humanities Building, Room 203',
        credits: 3,
        status: 'Completed',
        progress: 1.0,
        grade: 'A',
        description: 'A survey of world history from ancient civilizations to the modern era.',
        assignments: [
          AssignmentModel(
            id: '6',
            title: 'Research Paper',
            description: 'Research on a historical event of your choice',
            dueDate: 'December 10, 2024',
            status: 'Completed',
            grade: 95.0,
            feedback: 'Excellent research and analysis',
          ),
          AssignmentModel(
            id: '7',
            title: 'Final Exam',
            description: 'Comprehensive exam covering all course material',
            dueDate: 'December 15, 2024',
            status: 'Completed',
            grade: 92.0,
            feedback: 'Strong understanding of course concepts',
          ),
        ],
      ),
    ];
  }
}

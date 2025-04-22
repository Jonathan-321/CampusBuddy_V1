import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/course.dart';
import '../../../data/models/course_model.dart';

// Events
abstract class CoursesEvent extends Equatable {
  const CoursesEvent();

  @override
  List<Object?> get props => [];
}

class LoadCourses extends CoursesEvent {}

class FilterCoursesByStatus extends CoursesEvent {
  final String status;

  const FilterCoursesByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class SearchCourses extends CoursesEvent {
  final String query;

  const SearchCourses(this.query);

  @override
  List<Object?> get props => [query];
}

class RegisterForCourse extends CoursesEvent {
  final Course course;

  const RegisterForCourse(this.course);

  @override
  List<Object?> get props => [course];
}

// States
abstract class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

class CoursesInitial extends CoursesState {}

class CoursesLoading extends CoursesState {}

class CoursesLoaded extends CoursesState {
  final List<Course> allCourses;
  final List<Course> filteredCourses;
  final String currentFilter;

  const CoursesLoaded({
    required this.allCourses,
    required this.filteredCourses,
    this.currentFilter = 'All',
  });

  @override
  List<Object?> get props => [allCourses, filteredCourses, currentFilter];

  CoursesLoaded copyWith({
    List<Course>? allCourses,
    List<Course>? filteredCourses,
    String? currentFilter,
  }) {
    return CoursesLoaded(
      allCourses: allCourses ?? this.allCourses,
      filteredCourses: filteredCourses ?? this.filteredCourses,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class CoursesError extends CoursesState {
  final String message;

  const CoursesError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  CoursesBloc() : super(CoursesInitial()) {
    on<LoadCourses>(_onLoadCourses);
    on<FilterCoursesByStatus>(_onFilterCoursesByStatus);
    on<SearchCourses>(_onSearchCourses);
    on<RegisterForCourse>(_onRegisterForCourse);
  }

  void _onLoadCourses(LoadCourses event, Emitter<CoursesState> emit) async {
    emit(CoursesLoading());

    try {
      // In a real app, we would fetch courses from a repository
      // For now, we'll use mock data
      await Future.delayed(const Duration(milliseconds: 800));

      final courses = CourseModel.mockCourses();

      emit(CoursesLoaded(
        allCourses: courses,
        filteredCourses: courses,
      ));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  void _onFilterCoursesByStatus(
      FilterCoursesByStatus event, Emitter<CoursesState> emit) {
    if (state is CoursesLoaded) {
      final currentState = state as CoursesLoaded;

      final filteredCourses = event.status == 'All'
          ? currentState.allCourses
          : currentState.allCourses
              .where((course) => course.status == event.status)
              .toList();

      emit(currentState.copyWith(
        filteredCourses: filteredCourses,
        currentFilter: event.status,
      ));
    }
  }

  void _onSearchCourses(SearchCourses event, Emitter<CoursesState> emit) {
    if (state is CoursesLoaded) {
      final currentState = state as CoursesLoaded;
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        // If query is empty, just apply the current filter
        add(FilterCoursesByStatus(currentState.currentFilter));
        return;
      }

      // Filter courses based on the query and current filter
      final filteredCourses = currentState.allCourses.where((course) {
        final matchesQuery = course.name.toLowerCase().contains(query) ||
            course.id.toLowerCase().contains(query) ||
            course.instructor.toLowerCase().contains(query);

        final matchesFilter = currentState.currentFilter == 'All' ||
            course.status == currentState.currentFilter;

        return matchesQuery && matchesFilter;
      }).toList();

      emit(currentState.copyWith(
        filteredCourses: filteredCourses,
      ));
    }
  }

  void _onRegisterForCourse(
      RegisterForCourse event, Emitter<CoursesState> emit) async {
    if (state is CoursesLoaded) {
      emit(CoursesLoading());

      try {
        // In a real app, we would call a repository to register for the course
        // For now, we'll just simulate a successful registration
        await Future.delayed(const Duration(seconds: 1));

        final currentState = state as CoursesLoaded;
        final updatedCourse = CourseModel.fromEntity(event.course);

        // Update the course status to 'Current'
        final updatedCourseWithStatus = CourseModel(
          id: updatedCourse.id,
          name: updatedCourse.name,
          instructor: updatedCourse.instructor,
          schedule: updatedCourse.schedule,
          location: updatedCourse.location,
          credits: updatedCourse.credits,
          status: 'Current',
          progress: 0.0,
          grade: 'In Progress',
          description: updatedCourse.description,
          assignments: updatedCourse.assignments,
        );

        // Update the courses list
        final updatedCourses = currentState.allCourses.map((course) {
          return course.id == updatedCourseWithStatus.id
              ? updatedCourseWithStatus
              : course;
        }).toList();

        // Apply the current filter to the updated courses
        final filteredCourses = currentState.currentFilter == 'All'
            ? updatedCourses
            : updatedCourses
                .where((course) => course.status == currentState.currentFilter)
                .toList();

        emit(CoursesLoaded(
          allCourses: updatedCourses,
          filteredCourses: filteredCourses,
          currentFilter: currentState.currentFilter,
        ));
      } catch (e) {
        emit(CoursesError(e.toString()));
      }
    }
  }
}

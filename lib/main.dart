/// Campus Buddy - Main Application Entry Point
///
/// This file serves as the entry point for the Campus Buddy application.
/// It initializes the app with necessary configurations, services, and state management.
///
/// Key Responsibilities:
/// 1. Initialize Flutter bindings and services
/// 2. Set up theme configurations
/// 3. Configure state management (BLoC providers)
/// 4. Initialize navigation (GoRouter)
/// 5. Set up app-wide configurations
///
/// Dependencies:
/// - flutter_bloc: For state management
/// - go_router: For navigation
/// - flutter_local_notifications: For notifications
///
/// Architecture:
/// The app follows Clean Architecture with the following layers:
/// - Presentation (UI)
/// - Domain (Business Logic)
/// - Data (Data Sources)
/// - Services (External Services)
///
/// State Management:
/// The app uses BLoC pattern with the following BLoCs:
/// - AuthBloc: Handles authentication state
/// - CoursesBloc: Manages course-related state
/// - EventsBloc: Manages event-related state
/// - CampusAIBloc: Manages campus AI-related state
///
/// Navigation:
/// Uses GoRouter for declarative routing with:
/// - Root navigation for auth flows
/// - Shell navigation for main app sections
/// - Nested navigation for feature-specific screens
///
/// Theme:
/// Supports both light and dark themes with:
/// - Material 3 design system
/// - Custom color schemes
/// - Consistent component styling
///
/// Usage:
/// To add new features:
/// 1. Create necessary BLoC
/// 2. Add routes in AppRouter
/// 3. Create corresponding screens
/// 4. Update theme if needed
///
/// Note: This file should remain focused on app initialization and configuration.
/// Business logic should be implemented in respective feature modules.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/router/app_router.dart';
import 'domain/usecases/events_usecase.dart';
import 'domain/usecases/campus_ai_usecases.dart';
import 'domain/repositories/campus_ai_repository.dart';
import 'data/repositories/campus_ai_repository_impl.dart';
import 'data/services/claude_api_service.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/campus_ai/campus_ai_bloc.dart';
import 'logic/blocs/courses/courses_bloc.dart';
import 'presentation/blocs/events/events_bloc.dart';
import 'presentation/blocs/events/events_event.dart';
import 'services/notification_service.dart';

/// Application entry point
///
/// Initializes:
/// 1. Flutter bindings
/// 2. Notification service
/// 3. Screen orientation
/// 4. Required use cases
/// 5. Main app widget
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize notifications service
  await NotificationService().initialize();

  // Set preferred screen orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Create EventsUseCase instance for event management
  final eventsUseCase = EventsUseCase();

  // Initialize shared preferences for local storage
  final sharedPreferences = await SharedPreferences.getInstance();

  // Create ClaudeApiService for AI chat - using API key from environment variables
  final claudeApiService = ClaudeApiService(
    apiKey: dotenv.env['CLAUDE_API_KEY'] ?? '',
    model: dotenv.env['CLAUDE_MODEL'] ?? 'claude-3-haiku-20240307',
  );

  // Create repository implementation
  final campusAIRepository = CampusAIRepositoryImpl(
    claudeApiService,
    sharedPreferences,
  );

  // Create AI use cases
  final sendMessageUseCase = SendMessageUseCase(campusAIRepository);
  final getConversationHistoryUseCase =
      GetConversationHistoryUseCase(campusAIRepository);
  final clearConversationUseCase = ClearConversationUseCase(campusAIRepository);

  // Run the application with required dependencies
  runApp(MyApp(
    eventsUseCase: eventsUseCase,
    sendMessageUseCase: sendMessageUseCase,
    getConversationHistoryUseCase: getConversationHistoryUseCase,
    clearConversationUseCase: clearConversationUseCase,
  ));
}

/// Root application widget
///
/// Configures:
/// 1. Theme (light/dark)
/// 2. State management (BLoCs)
/// 3. Navigation (GoRouter)
/// 4. App-wide configurations
class MyApp extends StatelessWidget {
  final EventsUseCase eventsUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final GetConversationHistoryUseCase getConversationHistoryUseCase;
  final ClearConversationUseCase clearConversationUseCase;

  const MyApp({
    super.key,
    required this.eventsUseCase,
    required this.sendMessageUseCase,
    required this.getConversationHistoryUseCase,
    required this.clearConversationUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Authentication state management
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc.noAuth()..add(AuthCheckRequested()),
        ),
        // Courses state management
        BlocProvider<CoursesBloc>(
          create: (context) => CoursesBloc(),
        ),
        // Events state management
        BlocProvider<EventsBloc>(
          create: (context) => EventsBloc(eventsUseCase)..add(LoadEvents()),
        ),
        // Campus Oracle AI chat state management
        BlocProvider<CampusAIBloc>(
          create: (context) => CampusAIBloc(
            sendMessage: sendMessageUseCase,
            getConversationHistory: getConversationHistoryUseCase,
            clearConversation: clearConversationUseCase,
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Campus Buddy',
        // Light theme configuration
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        // Dark theme configuration
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[900],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[850],
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            color: Colors.grey[850],
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[800],
          ),
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

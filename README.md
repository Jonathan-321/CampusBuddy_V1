# Campus Buddy V1

A comprehensive campus mobile application designed to assist university students with various aspects of campus life.

## Overview

Campus Buddy aims to be the go-to mobile companion for students at Oklahoma Christian University (OC). It provides easy access to essential information, academic resources, event schedules, and an intelligent AI assistant powered by Anthropic's Claude API to answer campus-related questions.

## Features

*   **Campus AI Assistant ("Campus Oracle"):**
    *   Answers questions about OC using university-specific data.
    *   Powered by Anthropic's Claude 3 Haiku model (configurable via `.env`).
    *   Provides information on courses, schedules, departments, locations, contacts, housing, meal plans, events, services, and academic dates.
    *   Conversation history is stored locally.
*   **Event Management:** View upcoming campus events.
*   **Course Information:** (Basic structure in place) Access course details.
*   **Local Data Persistence:** Uses `shared_preferences` for caching university data and chat history.
*   **Environment Configuration:** Uses `.env` file for sensitive API keys.
*   **Theming:** Supports both Light and Dark modes based on system settings.

## Architecture & Tech Stack

*   **Architecture:** Follows Clean Architecture principles (Presentation, Domain, Data layers).
*   **State Management:** `flutter_bloc` for predictable state management.
*   **Navigation:** `go_router` for declarative routing.
*   **Core:** Flutter, Dart
*   **AI:** Anthropic Claude API via `http` package.
*   **Local Storage:** `shared_preferences`
*   **UI:** Material 3, `google_fonts`, `lottie` (for animations)
*   **Utilities:** `flutter_dotenv`, `intl`, `equatable`

## Setup Instructions

### Prerequisites

*   Flutter SDK (version >= 2.19.0)
*   Dart SDK (comes with Flutter)
*   Git
*   An IDE like VS Code or Android Studio
*   An Android Emulator/Device or other target platform (iOS, Web, Desktop)

### Steps

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Jonathan-321/CampusBuddy_V1.git
    cd CampusBuddy_V1
    ```

2.  **Create `.env` file:**
    *   Create a file named `.env` in the root directory of the project.
    *   Add your Anthropic Claude API key and desired model:
        ```dotenv
        CLAUDE_API_KEY=YOUR_ANTHROPIC_API_KEY
        CLAUDE_MODEL=claude-3-haiku-20240307 # Or another Claude model
        ```
    *   *Note:* The `.env` file is included in `.gitignore` to prevent accidental commits of your API key.

3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Run the app:**
    *   Make sure you have a device connected or an emulator running.
    *   Run the application:
        ```bash
        flutter run
        ```
    *   To run on a specific device (find the ID with `flutter devices`):
        ```bash
        flutter run -d <your_device_id>
        ```

## Folder Structure

```
├── android/          # Android specific files
├── assets/           # Static assets (images, fonts, data files, animations)
│   ├── animations/   # Lottie animations (e.g., placeholder.json)
│   ├── data/         # Data files (e.g., university_data.json)
│   ├── icons/        # Icon files
│   └── images/       # Image files
├── ios/              # iOS specific files
├── lib/              # Main application code
│   ├── config/       # Configuration files (e.g., router, themes)
│   ├── data/         # Data layer (repositories, models, services)
│   ├── domain/       # Domain layer (entities, use cases, repositories interfaces)
│   ├── logic/        # Business logic components (BLoCs - can be merged/renamed with presentation/blocs)
│   ├── presentation/ # Presentation layer (UI screens, widgets, BLoCs)
│   ├── services/     # App-level services (e.g., notifications)
│   └── main.dart     # Application entry point
├── test/             # Unit and widget tests
├── .env              # Environment variables (API Keys, etc. - **DO NOT COMMIT**)
├── .gitignore        # Specifies intentionally untracked files that Git should ignore
├── pubspec.yaml      # Flutter project dependencies and configuration
└── README.md         # This file
```

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues to improve Campus Buddy.

## License

(Specify License if applicable - e.g., MIT License)

---

*This README was generated with assistance from an AI pair programmer.*

# News App Frontend

This is a Flutter application built following **Clean Architecture** principles and using **BLoc/Cubit** for state management.

For the original Flutter project README, see [doc.md](./doc.md).

## Architecture Layers

The app is divided into three main layers to ensure separation of concerns and testability:

1.  **Domain (Business Logic)**:
    *   **Entities**: Pure Dart classes representing business objects.
    *   **Use Cases**: Single business operations (e.g., `GetArticles`, `CreateArticle`).
    *   **Repositories (Interfaces)**: Abstract definitions of data operations.
2.  **Data (Implementation)**:
    *   **Models**: Extensions of entities with JSON/Firestore parsing logic.
    *   **Data Sources**: Direct communication with external APIs or Firebase.
    *   **Repositories (Implementations)**: Concrete implementation of domain repository interfaces.
3.  **Presentation (UI/Logic)**:
    *   **Blocs/Cubits**: Manage UI state and interact with Use Cases.
    *   **Pages/Widgets**: The UI components built using Flutter.

## Getting Started

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install)
*   [Firebase CLI](https://firebase.google.com/docs/cli) (for local testing)

### Setup

1.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

2.  **Run the app**:
    ```bash
    flutter run
    ```

##  Key Technologies

*   **State Management**: `flutter_bloc`
*   **Dependency Injection**: `get_it`
*   **Networking**: `dio` & `retrofit`
*   **Local Database**: `floor`
*   **Backend Integration**: `firebase_core`, `cloud_firestore`, `firebase_storage`

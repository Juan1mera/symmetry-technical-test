# Development Report - Applicant Showcase App

## 1. Introduction
The primary objective for this project was to demonstrate technical proficiency in implementing CRUD functionality with Flutter and Firebase, while maintaining a commitment to technical excellence and clean architecture. Following the principle that "Truth is King," the focus was on building a transparent, robust, and scalable solution.

## 2. Learning Journey
The project involved an in-depth exploration of the Flutter BLoc ecosystem and the Clean Architecture structure.
- **BLoc/Cubit:** State management was refined to ensure a responsive UI free of business logic.
- **Firebase Firestore Rules:** Schema validation was integrated directly into the backend to maintain data integrity.
- **Dependency Injection:** `get_it` was utilized to decouple application layers, facilitating future testability.

## 3. Challenges Overcome
- **Firebase Decoupling:** A significant challenge involved removing direct dependencies on Firebase Auth/Firestore from the presentation layer (Cubit). This was resolved by creating `GetCurrentUserUseCase` and abstracting logic into the domain layer.
- **Image Handling:** A robust workflow was implemented where local images are uploaded to Storage and converted into public URLs before saving an article to Firestore.

## 4. Reflection and Future Directions
Technical proficiency in implementing decoupled data and domain layers was strengthened. The importance of documentation and architectural rigor over mere functionality was emphasized.
**Future Ideas:**
- Implement local caching (SQLite/Floor) for remote articles.
- Add commentary and "like" functionality to increase interactivity.

## 5. Enhancements
The implementation exceeds basic "Upload an Article" requirements:
1. **Full Editing:** An editing flow allows modifications to titles, content, and images of existing articles.
2. **Remote Deletion:** Functionality to delete articles from Firestore was added to the UI.
3. **Rules Validation:** `firestore.rules` were configured to ensure only the author of an article can edit or delete it.
4. **Dependency Updates:** Project dependencies (`dio`, `retrofit`, `firebase`, `floor`, etc.) were updated to the latest stable versions, ensuring security and compatibility with recent Flutter versions.

## 6. Operational Documentation
The application follows a reactive data flow based on Clean Architecture:

### User Flow:
1.  **Authentication**: Users register or sign in via Firebase Auth. Data is synchronized with a `users` collection in Firestore.
2.  **External News**: Articles from an external API are consumed using `Retrofit`.
3.  **Article Management**: 
    - Articles can be created by selecting a local image (`image_picker`).
    - Images are uploaded to `Firebase Storage`.
    - Image URLs and metadata are stored in `Firestore`.
4.  **Synchronization:** Firestore changes are immediately reflected in the UI through `Streams` or controlled reloads by `RemoteArticlesBloc`.

### Key Components:
- **Core**: Contains `DataState` for generic success/error state handling.
- **Features**: Each functionality (Daily News, Auth) is encapsulated with specific business logic and UI.



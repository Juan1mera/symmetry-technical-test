# Applicant Showcase App
Welcome to the Applicant Showcase App repository.

---

#  Quick Start

If Flutter and Firebase CLI are already installed, the project can be run locally using these steps:

### 1. Backend Setup (Firebase Emulator)
The project is configured to work with the Firebase Local Emulator Suite.
```bash
cd backend
npm install
firebase login
firebase emulators:start
```
> [!IMPORTANT]
> **Verify Emulator Status**: Once the emulators are running, open [http://localhost:4000](http://localhost:4000) in a browser. Firestore and Storage emulators should be active.

### 2. Frontend Setup
In a new terminal:
```bash
cd frontend
flutter pub get
flutter run
```

---

#  Project Documentation

For the original project assignment, learning resources, and step-by-step instructions, please refer to:
 **[Original Instructions (doc.md)](./doc.md)**

---

# Project Index

This index contains all the links to the project's documentation.

**Frontend Documentation**
*   [Current Setup & Architecture](./frontend/README.md)
*   [Original Frontend README](./frontend/doc.md)

**Backend Documentation**
*   [Current Setup & Schema](./backend/README.md)
*   [Original Backend README](./backend/doc.md)

**Guidelines & Reports**
*   [App Architecture](./docs/APP_ARCHITECTURE.md)
*   [Contribution Guidelines](./docs/CONTRIBUTION_GUIDELINES.md)
*   [Coding Guidelines](./docs/CODING_GUIDELINES.md)
*   [Architecture Violations](./docs/ARCHITECTURE_VIOLATIONS.md)
*   [Development Report](./docs/REPORT.md)

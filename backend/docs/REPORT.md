# Backend Development Report - Applicant Showcase App

## 1. Introduction
The backend of this project was designed to provide a secure and robust foundation for article management. The primary focus was on data integrity and the implementation of business rules directly within the persistence layer using Firebase Firestore Rules.

## 2. Configuration and Emulators
To adhere to professional development principles and ensure easy reproducibility, the **Firebase Local Emulator Suite** was used exclusively.
- **Benefits:** An isolated development environment, rapid testing of security rules, and zero infrastructure costs during development.
- **Emulated Services:** Firestore, Cloud Storage, and Auth.

## 3. Data Architecture (Firestore)
A NoSQL schema optimized for news retrieval was designed:
- **`articles` Collection:** Stores metadata for articles. 
    - Includes referential integrity with `Firebase Storage` via the `thumbnailURL` field.
    - Strict author mapping using `authorId` for access control.
- **`users` Collection:** Stores profiles of journalists synchronized with Firebase Auth.

## 4. Security and Integrity (Rules)w
Robust security rules were implemented in `firestore.rules`:
- **Schema Validation:** The `isValidArticle()` function ensures that every document contains the required fields and correct data types before acceptance.
- **Ownership:** Access controls guarantee that only authenticated users can create content, and that **only the original author** of an article can edit or delete it, thereby protecting intellectual integrity.

## 5. Storage
Storage configuration enables efficient management of thumbnails:
- Folder organization: `media/articles/{filename}`.
- Access rules allow public reading while restricting uploads to authenticated users.

## 6. Backend Reflection
The combination of backend schema validation (Security Rules) and strict typing in the frontend ensures the application is resilient against errors or malicious data manipulation attempts.
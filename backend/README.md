# Firebase Firestore Backend

This folder contains the backend configuration, including **Firestore Security Rules**, **Cloud Storage configuration**, and **Local Emulator settings**.

For the original backend setup instructions, see [doc.md](./doc.md).

## DB Schema

The data structure for articles is defined in [DB_SCHEMA.md](./docs/DB_SCHEMA.md). 
Key fields include:
*   `title`, `content`, `authorId`, `createdAt`.
*   `thumbnailURL`: Reference to an image in Firebase Cloud Storage.

## Security Rules

The `firestore.rules` file ensures that:
1.  **Read Access**: Anyone can read articles.
2.  **Schema Validation**: The `isValidArticle()` function verifies data types.
3.  **Ownership**: Only authors can update or delete their articles.

## Getting Started

### Setup and Local Execution

1.  **Install dependencies**:
    ```bash
    npm install -g firebase-tools
    ```
2.  **Login**:
    ```bash
    firebase login
    ```

3.  **Start the Emulators**:
    ```bash
    firebase emulators:start
    ```

### 🔍 Verifying the Emulator

Once the emulator is running, check:
*   **Emulator UI**: [http://localhost:4000](http://localhost:4000)
*   **Firestore Viewer**: Verify the `articles` collection.
*   **Storage Viewer**: Verify the `media/articles` path.


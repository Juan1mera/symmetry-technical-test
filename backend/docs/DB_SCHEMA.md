# DB Schema: Articles

This document defines the data structure for the `articles` collection.

## Collection: `articles`

| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `id` | string | Yes | Auto-generated Document ID. |
| `title` | string | Yes | The article's headline. |
| `content` | string | Yes | The full content of the article. |
| `category` | string | Yes | Category (e.g., Tech, Science). |
| `thumbnailURL` | string | Yes | **CRITICAL:** Reference to Firebase Storage. Must start with `gs://` or be a public URL pointing to `media/articles`. |
| `authorId` | string | Yes | UID of the journalist (authenticated user). |
| `createdAt` | timestamp | Yes | Publication date. |

### JSON Example
```json
{
  "title": "Flutter Advancements 2024",
  "content": "Lorem ipsum...",
  "category": "Technology",
  "thumbnailURL": "https://firebasestorage.../media/articles/photo.jpg",
  "authorId": "user_123456",
  "createdAt": "2024-02-02T12:00:00Z",
}
```
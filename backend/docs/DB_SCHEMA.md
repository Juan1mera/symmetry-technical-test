# DB Schema: Articles

Este documento define la estructura de datos para la colección `articles`.

## Collection: `articles`

| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `id` | string | Yes | Auto-generated Document ID. |
| `title` | string | Yes | El titular del artículo. |
| `content` | string | Yes | El contenido completo del artículo. |
| `category` | string | Yes | Categoría (ej. Tech, Science). |
| `thumbnailURL` | string | Yes | **CRITICAL:** Referencia a Firebase Storage. Debe empezar con `gs://` o ser una URL pública apuntando a `media/articles`. |
| `authorId` | string | Yes | UID del periodista (usuario autenticado). |
| `createdAt` | timestamp | Yes | Fecha de publicación. |
| `tags` | array | No | Lista de strings para búsquedas. |

### Ejemplo JSON
```json
{
  "title": "Avances en Flutter 2024",
  "content": "Lorem ipsum...",
  "category": "Technology",
  "thumbnailURL": "https://firebasestorage.../media/articles/foto.jpg",
  "authorId": "user_123456",
  "createdAt": "2024-02-02T12:00:00Z",
  "tags": ["code", "mobile"]
}
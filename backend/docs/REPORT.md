# Reporte de Desarrollo Backend - Applicant Showcase App

## 1. Introducción
El backend de este proyecto fue diseñado para servir como una base sólida y segura para la gestión de artículos. El enfoque principal fue la integridad de los datos y la implementación de reglas de negocio directamente en la capa de persistencia mediante Firebase Firestore Rules.

## 2. Configuración y Emuladores
Para cumplir con los principios de desarrollo profesional y asegurar que el proyecto sea fácilmente reproducible por otros desarrolladores, se optó por el uso exclusivo de **Firebase Local Emulator Suite**.
- **Beneficios:** Entorno de desarrollo aislado, pruebas rápidas de reglas de seguridad y cero costos de infraestructura durante el desarrollo.
- **Servicios Emulados:** Firestore, Cloud Storage y Auth.

## 3. Arquitectura de Datos (Firestore)
Se diseñó un esquema NoSQL optimizado para la lectura de noticias:
- **Colección `articles`:** Almacena los metadatos de las noticias. 
    - Incluye integridad referencial hacia `Firebase Storage` mediante el campo `thumbnailURL`.
    - Mapeo estricto del autor mediante `authorId` para control de acceso.
- **Colección `users`:** Almacena perfiles de periodistas sincronizados con Firebase Auth.

## 4. Seguridad e Integridad (Rules)
Se implementaron reglas de seguridad robustas en `firestore.rules`:
- **Validación de Esquema:** Mediante la función `isValidArticle()`, se asegura que cada documento contenga los campos obligatorios y los tipos de datos correctos antes de ser aceptado.
- **Autoría:** Se garantiza que solo usuarios autenticados puedan crear contenido y que **solo el dueño original** de un artículo pueda editarlo o borrarlo, protegiendo así la integridad intelectual de los periodistas.

## 5. Almacenamiento (Storage)
La configuración de Storage permite una gestión eficiente de los thumbnails:
- Organización por carpetas: `media/articles/{filename}`.
- Reglas de acceso que permiten la lectura pública pero restringen la carga a usuarios autenticados.

## 6. Reflexión Backend
La combinación de validación de esquema en backend (Security Rules) y tipado estricto en frontend asegura que la aplicación sea resiliente a errores o intentos de manipulación malintencionada de datos.
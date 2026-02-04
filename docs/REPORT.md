# Reporte de Desarrollo - Applicant Showcase App

## 1. Introducción
Al iniciar este proyecto, mi objetivo principal fue demostrar no solo mi capacidad técnica para implementar funcionalidades de CRUD con Flutter y Firebase, sino también mi compromiso con la **excelencia técnica y la arquitectura limpia**. Entiendo que en Symmetry la "Verdad es el Rey", por lo que mi enfoque ha sido construir una solución honesta, robusta y escalable.

## 2. Viaje de Aprendizaje
Durante este proyecto, profundicé en el ecosistema de **Flutter BLoc** y la estructura de **Arquitectura Limpia (Clean Architecture)** adaptada por Symmetry. 
- **BLoc/Cubit:** Refiné el manejo de estados para asegurar una UI responsiva y libre de lógica de negocio.
- **Firebase Firestore Rules:** Aprendí a integrar la validación del esquema directamente en el backend para asegurar la integridad de los datos.
- **Inyección de Dependencias:** Utilicé `get_it` para desacoplar las capas de la aplicación, facilitando la futura testabilidad.

## 3. Desafíos Superados
- **Desacoplamiento de Firebase:** Uno de los mayores retos fue eliminar las dependencias directas de Firebase Auth/Firestore de la capa de presentación (Cubit). Lo resolví creando `GetCurrentUserUseCase` y abstrayendo la lógica en la capa de dominio.
- **Manejo de Imágenes:** Implementar un flujo robusto donde las imágenes locales se cargan a Storage y se convierten en URLs públicas antes de guardar el artículo en Firestore.

## 4. Reflexión y Direcciones Futuras
Técnicamente, me siento mucho más sólido en la implementación de capas de datos y dominio desacopladas. Profesionalmente, me ha recordado la importancia de la documentación y el rigor arquitectónico por encima de la simple funcionalidad "que funciona".
**Ideas futuras:**
- Implementar cacheo local (SQLite/Floor) para los artículos remotos.
- Añadir funcionalidad de comentarios y "likes" para aumentar la interactividad.

## 5. Plus
He ido más allá de los requisitos básicos de "Subir un Artículo":
1. **Edición Completa:** Implementé el flujo de edición que permite cambiar títulos, contenido e imágenes de artículos existentes.
2. **Eliminación Remota:** Añadí la capacidad de borrar artículos de Firestore desde la UI.
3. **Validación de Reglas:** Configuré `firestore.rules` para validar que solo el autor de un artículo pueda editarlo o borrarlo.
4. **Actualización de Dependencias:** Se actualizaron todas las dependencias del proyecto (`dio`, `retrofit`, `firebase`, `floor`, etc.) a sus versiones más recientes y estables, garantizando seguridad y compatibilidad con las últimas versiones de Flutter.


## 6. Documentación de Funcionamiento
La aplicación sigue un flujo de datos reactivo basado en Clean Architecture:

### Flujo de Usuario:
1.  **Autenticación**: El usuario se registra o inicia sesión (Firebase Auth). Los datos se sincronizan con una colección `users` en Firestore.
2.  **Noticias Externas**: Se consumen artículos de una API externa mediante `Retrofit`.
3.  **Gestión de Artículos Propios**: 
    - El usuario puede crear artículos seleccionando una imagen local (`image_picker`).
    - La imagen se sube a `Firebase Storage`.
    - La URL de la imagen y los metadatos se guardan en `Firestore`.
4.  **Sincronización:** Los cambios en Firestore se reflejan inmediatamente en la UI mediante el uso de `Streams` o recargas controladas por `RemoteArticlesBloc`.

### Componentes Clave:
- **Core**: Contiene el `DataState` para manejar estados de éxito/error de forma genérica.
- **Features**: Cada funcionalidad (Daily News, Auth) está encapsulada con su propia lógica de negocio y UI.



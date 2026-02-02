# Reporte de Desarrollo - Applicant Showcase App

## Backend
### Configuración del Entorno
- Se configuró el entorno local con Firebase Emulators.

### Diseño de Base de Datos
- Se diseñó el esquema `ArticleSchema` asegurando la inclusión de `thumbnailURL` apuntando a Storage, tal como se requería.
- Se implementaron reglas de seguridad estrictas en Firestore (`firestore.rules`) para validar tipos de datos y autoría.
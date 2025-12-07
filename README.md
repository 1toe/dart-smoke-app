# SmokeTracker

Una aplicación de seguimiento de cesación de tabaquismo para ayudar a los usuarios a dejar de fumar.

## Versión 1.1.0+2

### Características principales

- **Seguimiento de progreso**: Visualiza tu viaje hacia una vida sin humo
- **Manejo de antojos**: Técnicas efectivas cuando necesites apoyo
- **Logros y recompensas**: Celebra cada hito en tu camino
- **Ahorro de dinero**: Observa cuánto estás ahorrando
- **Modo oscuro**: Tema claro y oscuro completamente funcional
- **Tutorial de inicio**: Onboarding interactivo para nuevos usuarios

## Novedades en v1.1.0

### Mejoras implementadas

1. ✅ **Código limpio**: Se eliminaron archivos innecesarios y se mejoró el `.gitignore`
   - Eliminados scripts de compilación PowerShell (.ps1)
   - Eliminado archivo .metadata generado por Flutter
   - Añadidas exclusiones para archivos específicos de Windows

2. ✅ **Sin datos de demostración**: La aplicación comienza limpia para todos los nuevos usuarios
   - Eliminados todos los datos mockup de perfiles predeterminados
   - Eliminados datos de ejemplo de historial de fumar y antojos
   - La app ahora empieza con un estado limpio

3. ✅ **Onboarding para nuevos usuarios**: Tutorial interactivo al primer uso
   - Pantalla de bienvenida con características principales
   - Formulario de configuración inicial
   - Recopilación de datos esenciales (nombre, fecha de abandono, cigarrillos por día, costo)

4. ✅ **Modo oscuro funcional**: Toggle completamente operativo
   - Implementado con Provider para gestión de estado
   - Persistencia de preferencia en SharedPreferences
   - Cambio instantáneo de tema desde configuración

5. ✅ **Dependencias actualizadas**: Todas las librerías al día
   - Actualizado sizer a 3.0.1
   - Actualizado flutter_svg a 2.0.14
   - Actualizado google_fonts a 6.2.1
   - Actualizado shared_preferences a 2.3.4
   - Y muchas más actualizaciones de dependencias

## Requisitos del sistema

- Flutter SDK ^3.6.0
- Dart SDK ^3.6.0

## Estructura del proyecto

```
lib/
├── core/               # Exportaciones y utilidades centrales
├── presentation/       # Pantallas de la aplicación
│   ├── onboarding/    # Tutorial de inicio
│   ├── dashboard_home/ # Pantalla principal
│   ├── settings_profile/ # Configuración
│   └── ...
├── providers/         # Gestores de estado
│   └── theme_provider.dart # Gestor de tema
├── services/          # Servicios de datos
│   └── local_data_service.dart # Almacenamiento local
├── theme/             # Temas de la aplicación
├── widgets/           # Widgets reutilizables
└── main.dart          # Punto de entrada

```

## Instalación

1. Clona el repositorio
2. Ejecuta `flutter pub get` para instalar dependencias
3. Ejecuta `flutter run` para iniciar la aplicación

## Uso

### Primera vez
Al abrir la aplicación por primera vez, verás:
1. Pantalla de bienvenida con características
2. Tutorial interactivo
3. Formulario de configuración inicial

### Usuarios existentes
Los usuarios que ya hayan completado el onboarding irán directamente al dashboard.

### Cambiar tema
Ve a Configuración > Privacidad > Modo oscuro para alternar entre tema claro y oscuro.

## Almacenamiento de datos

Todos los datos se almacenan localmente en el dispositivo usando SharedPreferences. No se envían datos a servidores externos.

## Licencia

Este es un proyecto privado.

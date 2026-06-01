# Detección de rostros (asistencia)

Aplicación Flutter para registrar asistencia de estudiantes mediante reconocimiento facial. La app captura una imagen con la cámara, detecta el rostro, lo recorta y lo clasifica con un modelo TFLite; luego registra el resultado (incluida la confianza) en SQLite y permite consultar el historial.

## Tecnologías

- Flutter (Dart)
- Cámara: `camera`
- Detección de rostro: `google_mlkit_face_detection`
- Clasificación: `tflite_flutter` + `image`
- Persistencia local: `sqflite` + `path`

## Funcionalidades

- Login y navegación a menú principal.
- Reconocimiento: cámara frontal + detección + clasificación.
- Registro de asistencia en SQLite (fecha/hora/confianza).
- Historial de asistencias (consulta y limpieza).
- Panel de control de estudiantes (CRUD básico).

## Estructura (carpetas clave)

- `lib/`
  - `lib/pantallas/` pantallas UI
  - `lib/ia/` carga del modelo y predicción
  - `lib/datos/` SQLite y entidades
- `assets/modelos/`
  - `assets/modelos/modelo_clasificador.tflite`
  - `assets/modelos/clases.json`
- `assets/perfiles/` (imágenes/recursos por estudiante, según tu implementación)
- `assets/logo/` logo + splash

## Ejecución

### Requisitos

- Flutter SDK instalado y en `PATH`
- Android Studio + Android SDK (para Android)
- Xcode (para iOS/macOS)

Comprobar instalación:

```bash
flutter doctor
```

### Instalar dependencias

```bash
flutter pub get
```

### Ejecutar (debug)

```bash
flutter devices
flutter run
```

### Ejecutar (release)

```bash
flutter run --release
```

## Builds

### Android APK

```bash
flutter build apk
```

APK generado (ruta típica): `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Play Store)

```bash
flutter build appbundle
```

### iOS

En macOS (con Xcode instalado):

```bash
flutter build ios
```

## Splash e iconos (opcional)

```bash
flutter pub run flutter_native_splash:create
flutter pub run flutter_launcher_icons
```

## Modelo (TFLite) y pipeline de reconocimiento

### Archivos del modelo

- Modelo: `assets/modelos/modelo_clasificador.tflite`
- Clases/IDs: `assets/modelos/clases.json`

`clases.json` es una lista (JSON) de etiquetas/IDs. En tiempo de ejecución, la predicción devuelve el índice con mayor probabilidad y se mapea a ese ID.

### Entrada del modelo (según el código actual)

- Tamaño: `160x160`
- Forma: `[1, 160, 160, 3]`
- Canales: RGB
- Valores: actualmente se envían como `double` en rango aproximado `0..255` (no hay normalización en el código).

### Flujo de reconocimiento (resumen)

1) Captura foto con la cámara frontal.
2) Detección de rostro con ML Kit (`google_mlkit_face_detection`).
3) La imagen se espeja horizontalmente (por ser cámara frontal).
4) Se recorta el rostro usando `boundingBox` (con margen 0.25) y se redimensiona a `160x160`.
5) Se ejecuta el modelo TFLite y se toma la clase con mayor score.
6) Umbral actual: si `confianza < 0.65` se considera “no reconocido”.
7) Si supera el umbral, se busca el estudiante en SQLite por ID; si existe, se registra asistencia.

### Nota importante

El panel de control permite registrar/editar estudiantes, pero el modelo **no reconocerá** nuevos alumnos si no se reentrena y se actualizan `modelo_clasificador.tflite` y `clases.json`.

## Base de datos (SQLite)

La base se crea como `estudiantes.db` y contiene al menos:

- `estudiantes(id TEXT PRIMARY KEY, nombre TEXT, semestre TEXT, carrera TEXT)`
- `asistencias(id INTEGER PK AUTOINCREMENT, estudianteId TEXT, nombre TEXT, fecha TEXT, hora TEXT, confianza REAL)`

En el primer arranque se insertan estudiantes de ejemplo (ver `lib/datos/base_datos.dart`).

## Permisos

- Android: `android.permission.CAMERA` en `android/app/src/main/AndroidManifest.xml`.
- iOS: `NSCameraUsageDescription` en `ios/Runner/Info.plist`.

## Solución de problemas

- Verifica `NSCameraUsageDescription` en `ios/Runner/Info.plist`.

### Assets no encontrados

Si aparece “Unable to load asset”, verifica:

- `pubspec.yaml` incluye `assets/modelos/`, `assets/perfiles/`, `assets/logo/`
- Existen:
  - `assets/modelos/modelo_clasificador.tflite`
  - `assets/modelos/clases.json`
  - `assets/logo/logo.png`

Luego ejecuta:

```bash
flutter pub get
```

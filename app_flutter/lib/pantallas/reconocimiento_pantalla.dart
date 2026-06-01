import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../datos/base_datos.dart';
import '../datos/estudiante.dart';
import '../ia/modelos_rostro.dart';

class ReconocimientoPantalla extends StatefulWidget {
  const ReconocimientoPantalla({super.key});

  @override
  State<ReconocimientoPantalla> createState() => _ReconocimientoPantallaState();
}

class _ReconocimientoPantallaState extends State<ReconocimientoPantalla> {
  final ModelosRostro _modelo = ModelosRostro();

  CameraController? _cameraController;
  FaceDetector? _faceDetector;

  Estudiante? _estudiante;
  String _estado = 'Inicializando...';
  double? _confianza;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    try {
      setState(() {
        _estado = 'Cargando modelo...';
      });

      await _modelo.inicializar();

      setState(() {
        _estado = 'Inicializando cámara...';
      });

      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.fast,
          enableContours: false,
          enableLandmarks: false,
        ),
      );

      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _estado = 'No se encontró cámara disponible.';
        });
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _cameraController = controller;
        _estado = 'Listo para reconocer.';
      });
    } catch (e) {
      setState(() {
        _estado = 'Error al inicializar: $e';
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    _modelo.liberar();
    super.dispose();
  }

  bool get _puedeReconocer {
    final camaraLista = _cameraController?.value.isInitialized ?? false;
    return camaraLista && _modelo.listo && !_procesando;
  }

  Future<void> _reconocer() async {
    if (!_puedeReconocer) return;

    setState(() {
      _procesando = true;
      _estado = 'Reconociendo rostro...';
      _estudiante = null;
      _confianza = null;
    });
    try {
      final controller = _cameraController!;
      final detector = _faceDetector!;

      final foto = await controller.takePicture();

      final inputImage = InputImage.fromFilePath(foto.path);
      final rostros = await detector.processImage(inputImage);

      if (rostros.isEmpty) {
        setState(() {
          _estado = 'No se detectó ningún rostro.';
        });
        return;
      }

      final bytes = await File(foto.path).readAsBytes();
      final imagenOriginal = img.decodeImage(bytes);

      if (imagenOriginal == null) {
        setState(() {
          _estado = 'No se pudo leer la imagen.';
        });
        return;
      }

      img.Image imagenProcesada = imagenOriginal;

      // Cámara frontal = imagen espejada
      imagenProcesada = img.flipHorizontal(imagenProcesada);

      final rostro = _recortarRostro(
        imagenProcesada,
        rostros.first.boundingBox,
      );
      final rostro160 = img.copyResize(rostro, width: 160, height: 160);

      final entrada = _convertirAEntrada(rostro160);

      final prediccion = _modelo.predecirImagen(entrada);
      debugPrint('PREDICCIÓN: $prediccion');
      final id = prediccion['id'] as String;
      final confianza = prediccion['confianza'] as double;

      if (confianza < 0.65) {
        setState(() {
          _estudiante = null;
          _estado = 'Estudiante no reconocido';
        });
        return;
      }

      final estudiante = await BaseDatos.instancia.obtenerEstudiantePorId(id);
      debugPrint('ID PREDICHO: $id');
      debugPrint('ESTUDIANTE EN SQLITE: ${estudiante?.nombre}');

      String nuevoEstado;

      if (estudiante == null) {
        nuevoEstado = 'ID reconocido: $id, pero no existe en SQLite.';
      } else {
        await BaseDatos.instancia.registrarAsistencia(
          estudiante: estudiante,
          confianza: confianza,
        );

        nuevoEstado =
            'Asistencia registrada (${(confianza * 100).toStringAsFixed(1)}%)';
      }

      setState(() {
        _estudiante = estudiante;
        _confianza = confianza;
        _estado = nuevoEstado;
      });
    } catch (e) {
      setState(() {
        _estado = 'Error durante reconocimiento: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _procesando = false;
        });
      }
    }
  }

  img.Image _recortarRostro(img.Image imagen, Rect caja) {
    const margen = 0.25;

    final dx = (caja.width * margen).round();
    final dy = (caja.height * margen).round();

    final x1 = _clamp(caja.left.round() - dx, 0, imagen.width - 1);
    final y1 = _clamp(caja.top.round() - dy, 0, imagen.height - 1);
    final x2 = _clamp(caja.right.round() + dx, x1 + 1, imagen.width);
    final y2 = _clamp(caja.bottom.round() + dy, y1 + 1, imagen.height);

    return img.copyCrop(imagen, x: x1, y: y1, width: x2 - x1, height: y2 - y1);
  }

  int _clamp(int valor, int min, int max) {
    if (valor < min) return min;
    if (valor > max) return max;
    return valor;
  }

  List<List<List<List<double>>>> _convertirAEntrada(img.Image imagen) {
    return List.generate(
      1,
      (_) => List.generate(
        160,
        (y) => List.generate(160, (x) {
          final pixel = imagen.getPixel(x, y);

          return [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;
    final camaraLista = controller?.value.isInitialized ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconocimiento de Estudiantes'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 320,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26),
              ),
              clipBehavior: Clip.antiAlias,
              child: camaraLista
                  ? CameraPreview(controller!)
                  : const Center(child: Text('Cargando cámara...')),
            ),
            const SizedBox(height: 16),
            Text(
              _estado,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _estado.startsWith('Error')
                    ? Colors.red
                    : Colors.blueGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _TarjetaEstudiante(estudiante: _estudiante, confianza: _confianza),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _puedeReconocer ? _reconocer : null,
                icon: _procesando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.face),
                label: Text(
                  _procesando ? 'Procesando...' : 'Reconocer estudiante',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaEstudiante extends StatelessWidget {
  const _TarjetaEstudiante({required this.estudiante, required this.confianza});

  final Estudiante? estudiante;
  final double? confianza;

  @override
  Widget build(BuildContext context) {
    final e = estudiante;
    final porcentaje = confianza == null
        ? '--'
        : '${(confianza! * 100).toStringAsFixed(1)}%';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: e == null
                  ? null
                  : AssetImage('assets/perfiles/${e.id}.jpeg'),
              child: e == null
                  ? Icon(
                      Icons.person,
                      size: 42,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              e?.nombre ?? 'Sin estudiante reconocido',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _DatoFila(titulo: 'ID', valor: e?.id ?? '--'),
            _DatoFila(titulo: 'Semestre', valor: e?.semestre ?? '--'),
            _DatoFila(titulo: 'Carrera', valor: e?.carrera ?? '--'),
            _DatoFila(titulo: 'Confianza', valor: porcentaje),
          ],
        ),
      ),
    );
  }
}

class _DatoFila extends StatelessWidget {
  const _DatoFila({required this.titulo, required this.valor});

  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$titulo:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}

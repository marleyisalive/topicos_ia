import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelosRostro {
  Interpreter? _modelo;
  List<String> _clases = [];

  List<String> get clases => List.unmodifiable(_clases);

  bool get listo => _modelo != null && _clases.isNotEmpty;

  Future<void> inicializar() async {
    _modelo = await Interpreter.fromAsset(
      'assets/modelos/modelo_clasificador.tflite',
    );

    final contenido = await rootBundle.loadString('assets/modelos/clases.json');

    final lista = jsonDecode(contenido) as List<dynamic>;
    _clases = lista.map((e) => e.toString()).toList();
  }

  Map<String, Object> predecirImagen(List<List<List<List<double>>>> entrada) {
    if (_modelo == null) {
      throw StateError('El modelo no está inicializado.');
    }

    final salida = [List<double>.filled(_clases.length, 0.0)];

    _modelo!.run(entrada, salida);

    final probabilidades = salida[0];

    var mejorIndice = 0;
    var mejorScore = probabilidades[0];

    for (var i = 1; i < probabilidades.length; i++) {
      if (probabilidades[i] > mejorScore) {
        mejorScore = probabilidades[i];
        mejorIndice = i;
      }
    }
    debugPrint('PROBABILIDADES: $probabilidades');
    debugPrint('MEJOR INDICE: $mejorIndice');
    debugPrint('MEJOR SCORE: $mejorScore');
    debugPrint('ID: ${_clases[mejorIndice]}');

    return {
      'id': _clases[mejorIndice],
      'confianza': mejorScore,
      'indice': mejorIndice,
    };
  }

  void liberar() {
    _modelo?.close();
    _modelo = null;
  }
}

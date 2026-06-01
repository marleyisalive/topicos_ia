import 'package:flutter/material.dart';

import '../datos/asistencia.dart';
import '../datos/base_datos.dart';
import '../tema/app_colores.dart';

class HistorialAsistenciasPantalla extends StatefulWidget {
  const HistorialAsistenciasPantalla({super.key});

  @override
  State<HistorialAsistenciasPantalla> createState() =>
      _HistorialAsistenciasPantallaState();
}

class _HistorialAsistenciasPantallaState
    extends State<HistorialAsistenciasPantalla> {
  List<Asistencia> _asistencias = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final datos = await BaseDatos.instancia.obtenerAsistencias();

    setState(() {
      _asistencias = datos;
    });
  }

  Future<void> _limpiarHistorial() async {
    await BaseDatos.instancia.eliminarAsistencias();
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de asistencias'),
        actions: [
          IconButton(
            onPressed: _asistencias.isEmpty ? null : _limpiarHistorial,
            icon: const Icon(Icons.delete_sweep),
          ),
        ],
      ),
      body: _asistencias.isEmpty
          ? const Center(child: Text('No hay asistencias registradas.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _asistencias.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final a = _asistencias[index];

                return Card(
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColores.azulMarino,
                      child: Text(
                        a.nombre.isNotEmpty ? a.nombre[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      a.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'ID: ${a.estudianteId}\n'
                      'Fecha: ${a.fecha}  Hora: ${a.hora}\n'
                      'Confianza: ${(a.confianza * 100).toStringAsFixed(1)}%',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}

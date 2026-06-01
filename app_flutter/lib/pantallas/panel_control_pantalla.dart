import 'package:flutter/material.dart';

import '../datos/base_datos.dart';
import '../datos/estudiante.dart';
import '../tema/app_colores.dart';

class PanelControlPantalla extends StatefulWidget {
  const PanelControlPantalla({super.key});

  @override
  State<PanelControlPantalla> createState() => _PanelControlPantallaState();
}

class _PanelControlPantallaState extends State<PanelControlPantalla> {
  List<Estudiante> _estudiantes = [];

  @override
  void initState() {
    super.initState();
    _cargarEstudiantes();
  }

  Future<void> _cargarEstudiantes() async {
    final estudiantes = await BaseDatos.instancia.obtenerTodos();
    setState(() {
      _estudiantes = estudiantes;
    });
  }

  Future<void> _eliminar(String id) async {
    await BaseDatos.instancia.eliminarEstudiante(id);
    await _cargarEstudiantes();
  }

  void _editar(Estudiante estudiante) {
    final nombreController = TextEditingController(text: estudiante.nombre);
    final semestreController = TextEditingController(text: estudiante.semestre);
    final carreraController = TextEditingController(text: estudiante.carrera);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Actualizar estudiante'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text('ID: ${estudiante.id}'),
                const SizedBox(height: 12),
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: semestreController,
                  decoration: const InputDecoration(labelText: 'Semestre'),
                ),
                TextField(
                  controller: carreraController,
                  decoration: const InputDecoration(labelText: 'Carrera'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final actualizado = Estudiante(
                  id: estudiante.id,
                  nombre: nombreController.text.trim(),
                  semestre: semestreController.text.trim(),
                  carrera: carreraController.text.trim(),
                );

                await BaseDatos.instancia.actualizarEstudiante(actualizado);

                if (!mounted) return;

                Navigator.pop(context);
                await _cargarEstudiantes();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _registrar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Puedes registrar datos, pero el modelo no reconocerá alumnos nuevos si no fue reentrenado.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de control')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _registrar,
        backgroundColor: AppColores.azulMarino,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Registrar'),
      ),
      body: _estudiantes.isEmpty
          ? const Center(child: Text('No hay estudiantes registrados.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _estudiantes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final e = _estudiantes[index];

                return Card(
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColores.azulMarino,
                      backgroundImage: AssetImage(
                        'assets/perfiles/${e.id}.jpeg',
                      ),
                    ),
                    title: Text(
                      e.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'ID: ${e.id}\nSemestre: ${e.semestre}\n${e.carrera}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'editar') {
                          _editar(e);
                        } else if (value == 'eliminar') {
                          _eliminar(e.id);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'editar', child: Text('Editar')),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Text('Eliminar'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'historial_asistencias_pantalla.dart';
import '../tema/app_colores.dart';
import 'panel_control_pantalla.dart';
import 'reconocimiento_pantalla.dart';

class MenuPrincipalPantalla extends StatelessWidget {
  const MenuPrincipalPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Principal')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bienvenido a Reconoce-Tec',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColores.azulMarino,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona una opción para continuar.',
              style: TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 32),
            _OpcionPrincipal(
              icono: Icons.dashboard_customize,
              titulo: 'Panel de control',
              descripcion: 'Consultar, actualizar o eliminar estudiantes.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PanelControlPantalla(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _OpcionPrincipal(
              icono: Icons.face_retouching_natural,
              titulo: 'Reconocedor de rostros',
              descripcion: 'Iniciar cámara y registrar reconocimiento.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReconocimientoPantalla(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _OpcionPrincipal(
              icono: Icons.history,
              titulo: 'Historial de asistencias',
              descripcion: 'Consultar el historial de asistencias registradas.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistorialAsistenciasPantalla(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcionPrincipal extends StatelessWidget {
  const _OpcionPrincipal({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColores.azulMarino,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white.withValues(alpha: 38),
                child: Icon(icono, color: Colors.white, size: 34),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      descripcion,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'pantallas/splash_pantalla.dart';
import 'tema/app_colores.dart';

void main() {
  runApp(const AppReconocimiento());
}

class AppReconocimiento extends StatelessWidget {
  const AppReconocimiento({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Asistencia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColores.azulMarino,
          primary: AppColores.azulMarino,
          secondary: AppColores.azulSecundario,
        ),
        scaffoldBackgroundColor: AppColores.fondo,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColores.azulMarino,
          foregroundColor: AppColores.blanco,
          centerTitle: true,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColores.azulMarino,
            foregroundColor: AppColores.blanco,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const SplashPantalla(),
    );
  }
}

class Asistencia {
  final int? id;
  final String estudianteId;
  final String nombre;
  final String fecha;
  final String hora;
  final double confianza;

  Asistencia({
    this.id,
    required this.estudianteId,
    required this.nombre,
    required this.fecha,
    required this.hora,
    required this.confianza,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'estudianteId': estudianteId,
      'nombre': nombre,
      'fecha': fecha,
      'hora': hora,
      'confianza': confianza,
    };
  }

  factory Asistencia.fromMap(Map<String, dynamic> map) {
    return Asistencia(
      id: map['id'] as int?,
      estudianteId: map['estudianteId'] as String,
      nombre: map['nombre'] as String,
      fecha: map['fecha'] as String,
      hora: map['hora'] as String,
      confianza: map['confianza'] as double,
    );
  }
}

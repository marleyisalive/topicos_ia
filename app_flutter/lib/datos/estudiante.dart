class Estudiante {
  final String id;
  final String nombre;
  final String semestre;
  final String carrera;

  Estudiante({
    required this.id,
    required this.nombre,
    required this.semestre,
    required this.carrera,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'semestre': semestre,
      'carrera': carrera,
    };
  }

  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      semestre: map['semestre'] as String,
      carrera: map['carrera'] as String,
    );
  }
}

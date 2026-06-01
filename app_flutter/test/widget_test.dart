import 'package:flutter_test/flutter_test.dart';

import 'package:deteccion_rostros_final/main.dart';

void main() {
  testWidgets('La app inicia en Splash', (WidgetTester tester) async {
    await tester.pumpWidget(const AppReconocimiento());
    await tester.pump();

    expect(find.text('Reconoce-Tec'), findsOneWidget);
  });
}

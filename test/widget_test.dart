import 'package:flutter_test/flutter_test.dart';

import 'package:pet_medical_app/main.dart';

void main() {
  testWidgets('App should render without error', (WidgetTester tester) async {
    await tester.pumpWidget(const PetMedicalApp());
    expect(find.byType(PetMedicalApp), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:jordan_landmarks/main.dart';

void main() {
  testWidgets('app loads test', (WidgetTester tester) async {
    await tester.pumpWidget(JordanLandmarksApp());
  });
}

import 'package:cosarc/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Cosarc app boots to the splash/start shell', (tester) async {
    await tester.pumpWidget(const CosarcApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(CosarcApp), findsOneWidget);
  });
}

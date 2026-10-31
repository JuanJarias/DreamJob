import 'package:dreamjob/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Arranque inicial redirige de splash a login', (tester) async {
    await tester.pumpWidget(const DreamJobApp());
    await tester.pumpAndSettle();
    expect(find.text('LoginScreen (Placeholder)'), findsOneWidget);
  });
}

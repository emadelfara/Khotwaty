import 'package:flutter_test/flutter_test.dart';
import 'package:khotwaty/app/khotwaty_app.dart';

void main() {
  testWidgets('Khotwaty opens the Arabic dashboard', (tester) async {
    await tester.pumpWidget(const KhotwatyApp());
    await tester.pumpAndSettle();
    expect(find.text('خُطوتي'), findsOneWidget);
    expect(find.text('خطواتك النهارده'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:lottogenerator_v3/main.dart';

void main() {
  testWidgets('App starts and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Lottogenerator'), findsOneWidget);
    expect(find.text('LOTTO 6aus49'), findsOneWidget);
    expect(find.text('EUROJACKPOT'), findsOneWidget);
    expect(find.text('SAYISAL LOTO'), findsOneWidget);
    expect(find.text('CUSTOM LOTTO'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:selfpass/main.dart'; // Assicurati che il path sia corretto

void main() {
  testWidgets('MyApp displays encryption results', (WidgetTester tester) async {
    // Fornisci dei valori di test ai parametri richiesti.
    const originalText = "TestoOriginale";
    const cipherText = "TestoCifrato";
    const decryptedText = "TestoDecifrato";

    // Istanziamo MyApp con tutti i parametri richiesti.
    await tester.pumpWidget(
      const MyApp(
        original: originalText,
        cipher: cipherText,
        decrypted: decryptedText,
      ),
    );

    // Verifica che ogni pezzo di testo sia presente nel widget
    expect(find.text(originalText), findsOneWidget);
    expect(find.text(cipherText), findsOneWidget);
    expect(find.text(decryptedText), findsOneWidget);
  });
}

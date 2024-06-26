import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:weather/layers/presentation/pages/my_home_page.dart'; // Импортируйте ваш виджет

void main() {
  testWidgets('Golden test for MyWidget', (WidgetTester tester) async {
    // Построение виджета
    final widget = MaterialApp(
      home: Scaffold(
        body: MyHomePage(), // Замените на ваш виджет
      ),
    );

    // Рендеринг виджета
    await tester.pumpWidget(widget);

    // Задержка для завершения всех анимаций
    await tester.pumpAndSettle();

    // Сравнение с эталонным изображением
    await expectLater(
      find.byType(MyHomePage), // Замените на ваш виджет
      matchesGoldenFile('goldens/my_widget.png'),
    );
  });
}

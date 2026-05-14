import 'package:bbcms/core/theme/colors.dart';
import 'package:bbcms/core/widgets/avatar.dart';
import 'package:bbcms/core/widgets/pill_tag.dart';
import 'package:bbcms/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PrimaryButton renders label', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PrimaryButton(label: 'Test', onPressed: () {}),
      ),
    ));
    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('PillTag renders uppercased label', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: PillTag('actif', kind: PillKind.success),
      ),
    ));
    expect(find.text('ACTIF'), findsOneWidget);
  });

  testWidgets('Avatar renders initials when no image', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Avatar(name: 'Jean Kabongo'),
      ),
    ));
    expect(find.text('JK'), findsOneWidget);
  });

  test('BbcColors are exposed', () {
    expect(BbcColors.ink, const Color(0xFF0B1E4A));
  });
}

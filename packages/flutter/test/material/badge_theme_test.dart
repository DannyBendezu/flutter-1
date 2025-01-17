// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../rendering/mock_canvas.dart';

void main() {
  test('BadgeThemeData copyWith, ==, hashCode basics', () {
    expect(const BadgeThemeData(), const BadgeThemeData().copyWith());
    expect(const BadgeThemeData().hashCode, const BadgeThemeData().copyWith().hashCode);
  });

  test('BadgeThemeData defaults', () {
    const BadgeThemeData themeData = BadgeThemeData();
    expect(themeData.backgroundColor, null);
    expect(themeData.foregroundColor, null);
    expect(themeData.smallSize, null);
    expect(themeData.largeSize, null);
    expect(themeData.textStyle, null);
    expect(themeData.padding, null);
    expect(themeData.alignment, null);
  });

  testWidgets('Default BadgeThemeData debugFillProperties', (WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    const BadgeThemeData().debugFillProperties(builder);

    final List<String> description = builder.properties
      .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
      .map((DiagnosticsNode node) => node.toString())
      .toList();

    expect(description, <String>[]);
  });

  testWidgets('BadgeThemeData implements debugFillProperties', (WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    const BadgeThemeData(
      backgroundColor: Color(0xfffffff0),
      foregroundColor: Color(0xfffffff1),
      smallSize: 1,
      largeSize: 2,
      textStyle: TextStyle(fontSize: 4),
      padding: EdgeInsets.all(5),
      alignment: AlignmentDirectional(6, 7),
    ).debugFillProperties(builder);

    final List<String> description = builder.properties
        .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode node) => node.toString())
        .toList();

    expect(description, <String>[
      'backgroundColor: Color(0xfffffff0)',
      'foregroundColor: Color(0xfffffff1)',
      'smallSize: 1.0',
      'largeSize: 2.0',
      'textStyle: TextStyle(inherit: true, size: 4.0)',
      'padding: EdgeInsets.all(5.0)',
      'alignment: AlignmentDirectional(6.0, 7.0)'
    ]);
  });

  testWidgets('Badge uses ThemeData badge theme', (WidgetTester tester) async {
    const Color green = Color(0xff00ff00);
    const Color black = Color(0xff000000);
    const BadgeThemeData badgeTheme = BadgeThemeData(
      backgroundColor: green,
      foregroundColor: black,
      smallSize: 5,
      largeSize: 20,
      textStyle: TextStyle(fontSize: 12),
      padding: EdgeInsets.symmetric(horizontal: 5),
      alignment: AlignmentDirectional(24, 0),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(useMaterial3: true).copyWith(
          badgeTheme: badgeTheme,
        ),
        home: const Scaffold(
          body: Badge(
            label: Text('1234'),
            child: Icon(Icons.add),
          ),
        ),
      ),
    );

    // text width = 48 = fontSize * 4, text height = fontSize
    expect(tester.getSize(find.text('1234')), const Size(48, 12));

    // x = 29 = alignment.start + padding.left, y = 4 = (largeSize - fontSize) / 2
    expect(tester.getTopLeft(find.text('1234')), const Offset(29, 4));


    expect(tester.getSize(find.byType(Badge)), const Size(24, 24)); // default Icon size
    expect(tester.getTopLeft(find.byType(Badge)), Offset.zero);

    final TextStyle textStyle = tester.renderObject<RenderParagraph>(find.text('1234')).text.style!;
    expect(textStyle.fontSize, 12);
    expect(textStyle.color, black);

    final RenderBox box = tester.renderObject(find.byType(Badge));
    // L = alignment.start, T = alignment.top, R = L + fontSize * 4 + padding.width, B = largeSize R = largeSize/2
    expect(box, paints..rrect(rrect: RRect.fromLTRBR(24, 0, 82, 20, const Radius.circular(10)), color: green));
  });


  // This test is essentially the same as 'Badge uses ThemeData badge theme'. In
  // this case the theme is introduced with the BadgeTheme widget instead of
  // ThemeData.badgeTheme.
  testWidgets('Badge uses BadgeTheme', (WidgetTester tester) async {
    const Color green = Color(0xff00ff00);
    const Color black = Color(0xff000000);
    const BadgeThemeData badgeTheme = BadgeThemeData(
      backgroundColor: green,
      foregroundColor: black,
      smallSize: 5,
      largeSize: 20,
      textStyle: TextStyle(fontSize: 12),
      padding: EdgeInsets.symmetric(horizontal: 5),
      alignment: AlignmentDirectional(24, 0),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: BadgeTheme(
          data: badgeTheme,
          child: Scaffold(
            body: Badge(
              label: Text('1234'),
              child: Icon(Icons.add),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.text('1234')), const Size(48, 12));
    expect(tester.getTopLeft(find.text('1234')), const Offset(29, 4));
    expect(tester.getSize(find.byType(Badge)), const Size(24, 24)); // default Icon size
    expect(tester.getTopLeft(find.byType(Badge)), Offset.zero);
    final TextStyle textStyle = tester.renderObject<RenderParagraph>(find.text('1234')).text.style!;
    expect(textStyle.fontSize, 12);
    expect(textStyle.color, black);
    final RenderBox box = tester.renderObject(find.byType(Badge));
    expect(box, paints..rrect(rrect: RRect.fromLTRBR(24, 0, 82, 20, const Radius.circular(10)), color: green));
  });
}

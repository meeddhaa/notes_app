import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notes_app/main.dart';

void main() {
  testWidgets('Notes app loads without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NotesApp());

    // Verify the Notes List screen's app bar title is shown.
    expect(find.text('My Notes'), findsOneWidget);
  });
}
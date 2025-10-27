import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

void main() {
  group('CredentialsWarningBanner', () {
    testWidgets('should show message for both prefix and password configured', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CredentialsWarningBanner(
              prefixConfigured: true,
              passwordConfigured: true,
            ),
          ),
        ),
      );

      expect(find.text('Both hotspot prefix and password were provided but will be overridden by the values you enter here.'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('should show message for only prefix configured', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CredentialsWarningBanner(
              prefixConfigured: true,
              passwordConfigured: false,
            ),
          ),
        ),
      );

      expect(find.text('Hotspot prefix was provided but will be overridden by the value you enter here.'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('should show message for only password configured', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CredentialsWarningBanner(
              prefixConfigured: false,
              passwordConfigured: true,
            ),
          ),
        ),
      );

      expect(find.text('Hotspot password was provided but will be overridden by the value you enter here.'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('should show fallback message when neither is configured', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CredentialsWarningBanner(
              prefixConfigured: false,
              passwordConfigured: false,
            ),
          ),
        ),
      );

      expect(find.text('Initial credentials were provided but will be overridden by the values you enter here.'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('should have proper styling and layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CredentialsWarningBanner(
              prefixConfigured: true,
              passwordConfigured: true,
            ),
          ),
        ),
      );

      // Check that the banner has proper styling
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, equals(const EdgeInsets.all(16.0)));
      expect(container.margin, equals(const EdgeInsets.only(bottom: 16.0)));

      // Check that the decoration has proper styling
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(BorderRadius.circular(8.0)));
      expect(decoration.border, isNotNull);

      // Check that the row contains icon and text
      expect(find.byType(Row), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget); // The spacing between icon and text
    });

    testWidgets('should be accessible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CredentialsWarningBanner(
              prefixConfigured: true,
              passwordConfigured: false,
            ),
          ),
        ),
      );

      // Check that the text is accessible
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.fontSize, equals(14.0));
      expect(textWidget.data, isNotNull);
      expect(textWidget.data!.isNotEmpty, isTrue);
    });

    testWidgets('should handle theme changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: CredentialsWarningBanner(
              prefixConfigured: true,
              passwordConfigured: true,
            ),
          ),
        ),
      );

      expect(find.byType(CredentialsWarningBanner), findsOneWidget);

      // Switch to dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: CredentialsWarningBanner(
              prefixConfigured: true,
              passwordConfigured: true,
            ),
          ),
        ),
      );

      expect(find.byType(CredentialsWarningBanner), findsOneWidget);
    });
  });
}

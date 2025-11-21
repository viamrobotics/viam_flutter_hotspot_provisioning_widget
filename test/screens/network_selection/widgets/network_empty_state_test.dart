import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

void main() {
  Widget networkEmptyStateWidget({
    required VoidCallback onManualEntry,
    required VoidCallback onRefresh,
    required bool isLoading,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: NetworkEmptyState(
          onManualEntry: onManualEntry,
          onRefresh: onRefresh,
          isLoading: isLoading,
        ),
      ),
    );
  }

  group('NetworkEmptyState', () {
    testWidgets('displays "No networks found" title', (WidgetTester tester) async {
      await tester.pumpWidget(
        networkEmptyStateWidget(
          onManualEntry: () {},
          onRefresh: () {},
          isLoading: false,
        ),
      );

      expect(find.text('No networks found'), findsOneWidget);
    });

    testWidgets('displays body text', (WidgetTester tester) async {
      await tester.pumpWidget(
        networkEmptyStateWidget(
          onManualEntry: () {},
          onRefresh: () {},
          isLoading: false,
        ),
      );

      expect(
        find.text('Is your device powered on and nearby? Try turning the device off and back on.'),
        findsOneWidget,
      );
    });

    testWidgets('displays error icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        networkEmptyStateWidget(
          onManualEntry: () {},
          onRefresh: () {},
          isLoading: false,
        ),
      );

      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('displays "My network isn\'t showing up" button', (WidgetTester tester) async {
      await tester.pumpWidget(
        networkEmptyStateWidget(
          onManualEntry: () {},
          onRefresh: () {},
          isLoading: false,
        ),
      );

      expect(find.text("My network isn't showing up"), findsOneWidget);
    });

    testWidgets('displays "Try again" button', (WidgetTester tester) async {
      await tester.pumpWidget(
        networkEmptyStateWidget(
          onManualEntry: () {},
          onRefresh: () {},
          isLoading: false,
        ),
      );

      expect(find.text('Try again'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('"Try again" button is disabled when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        networkEmptyStateWidget(
          onManualEntry: () {},
          onRefresh: () {},
          isLoading: true,
        ),
      );

      final buttonFinder = find.ancestor(
        of: find.text('Try again'),
        matching: find.byType(FilledButton),
      );
      final button = tester.widget<FilledButton>(buttonFinder);
      expect(button.onPressed, isNull);
    });

    testWidgets('"Try again" button is enabled when isLoading is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        networkEmptyStateWidget(
          onManualEntry: () {},
          onRefresh: () {},
          isLoading: false,
        ),
      );

      final buttonFinder = find.ancestor(
        of: find.text('Try again'),
        matching: find.byType(FilledButton),
      );
      final button = tester.widget<FilledButton>(buttonFinder);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('shows TroubleshootingDialog when "My network isn\'t showing up" button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        networkEmptyStateWidget(
          onManualEntry: () {},
          onRefresh: () {},
          isLoading: false,
        ),
      );

      expect(find.byType(TroubleshootingDialog), findsNothing);

      await tester.tap(find.text("My network isn't showing up"));
      await tester.pump();

      expect(find.byType(TroubleshootingDialog), findsOneWidget);
    });

    testWidgets('calls onRefresh when "Try again" button is tapped and not loading', (WidgetTester tester) async {
      bool onRefreshCalled = false;
      void testOnRefresh() {
        onRefreshCalled = true;
      }

      await tester.pumpWidget(
        networkEmptyStateWidget(
          onManualEntry: () {},
          onRefresh: testOnRefresh,
          isLoading: false,
        ),
      );

      await tester.tap(find.text('Try again'));
      await tester.pump();

      expect(onRefreshCalled, isTrue);
    });

    testWidgets('does not call onRefresh when "Try again" button is tapped while loading', (WidgetTester tester) async {
      bool onRefreshCalled = false;
      void testOnRefresh() {
        onRefreshCalled = true;
      }

      await tester.pumpWidget(
        networkEmptyStateWidget(
          onManualEntry: () {},
          onRefresh: testOnRefresh,
          isLoading: true,
        ),
      );

      await tester.tap(find.text('Try again'));
      await tester.pump();

      expect(onRefreshCalled, isFalse);
    });
  });
}

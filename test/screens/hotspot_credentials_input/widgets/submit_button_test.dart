import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

void main() {
  group('CredentialsSubmitButton', () {
    late HotspotCredentialsInputViewModel viewModel;
    late VoidCallback mockOnPressed;

    setUp(() {
      mockOnPressed = () {};
      viewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: null,
        configuredHotspotPassword: null,
        onCredentialsSubmitted: (prefix, password) {},
      );
    });

    Widget submitButtonWidget() {
      return MaterialApp(
        home: Scaffold(
          body: CredentialsSubmitButton(
            viewModel: viewModel,
            onPressed: mockOnPressed,
          ),
        ),
      );
    }

    testWidgets('displays "Continue" text when not submitting', (WidgetTester tester) async {
      await tester.pumpWidget(submitButtonWidget());

      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Connecting...'), findsNothing);
    });

    testWidgets('displays "Connecting..." text when submitting', (WidgetTester tester) async {
      await tester.pumpWidget(submitButtonWidget());
      expect(find.text('Continue'), findsOneWidget);

      viewModel.submitCredentials('test-prefix', 'test-password');
      await tester.pump();

      expect(find.text('Connecting...'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    });

    testWidgets('button is enabled when not submitting', (WidgetTester tester) async {
      await tester.pumpWidget(submitButtonWidget());

      final buttonFinder = find.byType(PrimaryButton);
      final button = tester.widget<PrimaryButton>(buttonFinder);
      expect(button.onPressed, isNotNull);
      expect(button.isLoading, isFalse);
    });

    testWidgets('button is disabled when submitting', (WidgetTester tester) async {
      await tester.pumpWidget(submitButtonWidget());

      viewModel.submitCredentials('test-prefix', 'test-password');
      await tester.pump();

      final buttonFinder = find.byType(PrimaryButton);
      final button = tester.widget<PrimaryButton>(buttonFinder);
      expect(button.onPressed, isNull);
    });

    testWidgets('calls onPressed when button is tapped and not submitting', (WidgetTester tester) async {
      bool onPressedCalled = false;
      void testOnPressed() {
        onPressedCalled = true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CredentialsSubmitButton(
              viewModel: viewModel,
              onPressed: testOnPressed,
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(PrimaryButton);
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(onPressedCalled, isTrue);
    });

    testWidgets('does not call onPressed when button is tapped while submitting', (WidgetTester tester) async {
      bool onPressedCalled = false;
      void testOnPressed() {
        onPressedCalled = true;
      }

      viewModel.submitCredentials('test-prefix', 'test-password');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CredentialsSubmitButton(
              viewModel: viewModel,
              onPressed: testOnPressed,
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(PrimaryButton);
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(onPressedCalled, isFalse);
    });
  });
}

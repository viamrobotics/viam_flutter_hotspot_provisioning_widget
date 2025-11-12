import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

void main() {
  group('CredentialsTextField', () {
    testWidgets('displays label correctly', (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CredentialsTextField(
              controller: controller,
              label: 'Test Label',
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('uses controller to display and update text', (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CredentialsTextField(
              controller: controller,
              label: 'Test Field',
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test input');
      await tester.pump();

      expect(controller.text, equals('test input'));
      expect(find.text('test input'), findsOneWidget);
    });

    testWidgets('shows validation error when validator returns error', (WidgetTester tester) async {
      // Controller starts empty, so the CredentialsTextField will be empty
      final controller = TextEditingController(); 
      // FormKey accesses the state of the form
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form( 
              key: formKey,
              child: CredentialsTextField(
                controller: controller,
                label: 'Test Field',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // CredentialsTextField is empty, so validation should fail
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('does not show error when validator returns null', (WidgetTester tester) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CredentialsTextField(
                controller: controller,
                label: 'Test Field',
                validator: (value) => null,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'valid input');
      await tester.pump();

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('This field is required'), findsNothing);
    });

    testWidgets('calls onFieldSubmitted when field is submitted with done action', (WidgetTester tester) async {
      final controller = TextEditingController();
      bool onFieldSubmittedCalled = false;
      String? submittedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CredentialsTextField(
              controller: controller,
              label: 'Test Field',
              onFieldSubmitted: (value) {
                onFieldSubmittedCalled = true;
                submittedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test value');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(onFieldSubmittedCalled, isTrue);
      expect(submittedValue, equals('test value'));
    });

    testWidgets('calls onFieldSubmitted with next action when textInputAction is next', (WidgetTester tester) async {
      final controller = TextEditingController();
      bool onFieldSubmittedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CredentialsTextField(
              controller: controller,
              label: 'Test Field',
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) {
                onFieldSubmittedCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test value');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      expect(onFieldSubmittedCalled, isTrue);
    });
  });
}

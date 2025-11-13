import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

import '../../../mocks/generate_mocks.mocks.dart';

void main() {
  late PasswordInputViewModel viewModel;
  late MockHotspotProvisioningRepository mockRepository;
  late RobotPart mockRobotPart;
  late Function(String? fragmentId) mockOnPasswordSubmitted;
  late VoidCallback mockOnSubmit;

  setUp(() {
    mockRepository = MockHotspotProvisioningRepository();
    mockRobotPart = RobotPart(
      id: 'test-part-id',
      name: 'test-robot-name',
      secret: 'test-secret',
      locationId: 'test-location-id',
    );
    mockOnPasswordSubmitted = (String? fragmentId) {};
    mockOnSubmit = () {};
    viewModel = PasswordInputViewModel(
      repository: mockRepository,
      mainPart: mockRobotPart,
      fragmentId: 'test-fragment-id',
      onPasswordSubmitted: mockOnPasswordSubmitted,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  Widget passwordFieldWidget() {
    return MaterialApp(
      home: Scaffold(
        body: PasswordFieldWidget(
          viewModel: viewModel,
          onSubmit: mockOnSubmit,
        ),
      ),
    );
  }

  group('PasswordFieldWidget', () {
    testWidgets('displays password label', (WidgetTester tester) async {
      await tester.pumpWidget(passwordFieldWidget());

      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('displays TextField for password input', (WidgetTester tester) async {
      await tester.pumpWidget(passwordFieldWidget());

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('TextField updates viewModel passwordController when text is entered', (WidgetTester tester) async {
      await tester.pumpWidget(passwordFieldWidget());

      await tester.enterText(find.byType(TextField), 'test-password');
      await tester.pump();

      expect(viewModel.passwordController.text, equals('test-password'));
    });

    testWidgets('has autocorrect disabled', (WidgetTester tester) async {
      await tester.pumpWidget(passwordFieldWidget());

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.autocorrect, isFalse);
    });

    group('Password visibility toggle', () {
      testWidgets('shows visibility icon when password is visible (initial state)', (WidgetTester tester) async {
        await tester.pumpWidget(passwordFieldWidget());

        expect(find.byIcon(Icons.visibility), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off), findsNothing);
      });

      testWidgets('shows visibility_off icon when password is hidden after toggle', (WidgetTester tester) async {
        await tester.pumpWidget(passwordFieldWidget());

        viewModel.toggleObscureText();
        // rebuild widget after viewModel change since it's a StatelessWidget
        await tester.pumpWidget(passwordFieldWidget());

        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsNothing);
      });

      testWidgets('toggles password visibility when visibility icon is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(passwordFieldWidget());

        expect(viewModel.obscureText, isFalse);

        // tap the visibility icon (initial state shows visibility icon)
        final iconButton = find.byIcon(Icons.visibility);
        await tester.tap(iconButton);
        await tester.pump();
        // rebuild widget after viewModel change
        await tester.pumpWidget(passwordFieldWidget());

        expect(viewModel.obscureText, isTrue);
      });

      testWidgets('TextField obscureText property stays in sync with viewModel obscureText value', (WidgetTester tester) async {
        await tester.pumpWidget(passwordFieldWidget());

        var textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.obscureText, equals(viewModel.obscureText));

        viewModel.toggleObscureText();
        // rebuild widget after viewModel change
        await tester.pumpWidget(passwordFieldWidget());

        textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.obscureText, equals(viewModel.obscureText));
      });
    });

    group('Password submission', () {
      testWidgets('calls onSubmit when field is submitted with valid credentials', (WidgetTester tester) async {
        bool onSubmitCalled = false;
        void testOnSubmit() {
          onSubmitCalled = true;
        }

        // set up valid credentials
        viewModel.network = NetworkInfo(
          ssid: 'Test Network',
          security: 'WPA2',
          signal: 80,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PasswordFieldWidget(
                viewModel: viewModel,
                onSubmit: testOnSubmit,
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'test-password');
        await tester.pump();

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(onSubmitCalled, isTrue);
      });

      testWidgets('does not call onSubmit when credentials are invalid', (WidgetTester tester) async {
        bool onSubmitCalled = false;
        void testOnSubmit() {
          onSubmitCalled = true;
        }

        // set up invalid credentials (no network, empty SSID)
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PasswordFieldWidget(
                viewModel: viewModel,
                onSubmit: testOnSubmit,
              ),
            ),
          ),
        );

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(onSubmitCalled, isFalse);
      });
    });
  });
}

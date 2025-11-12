import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

void main() {
  late HotspotCredentialsInputViewModel viewModel;
  late VoidCallback mockOnBack;
  late Function(String prefix, String password) mockOnCredentialsSubmitted;

  setUp(() {
    mockOnBack = () {};
    mockOnCredentialsSubmitted = (String prefix, String password) {};
    viewModel = HotspotCredentialsInputViewModel(
      configuredHotspotPrefix: null,
      configuredHotspotPassword: null,
      onCredentialsSubmitted: mockOnCredentialsSubmitted,
    );
  });

  Widget hotspotCredentialsInputScreenWidget({HotspotCredentialsInputViewModel? vm}) {
    return MaterialApp(
      home: HotspotCredentialsInputScreen(
        viewModel: vm ?? viewModel,
        onBack: mockOnBack,
      ),
    );
  }

  group('Initial UI State', () {
    testWidgets('displays correct title in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(hotspotCredentialsInputScreenWidget());
      expect(find.text('Enter Hotspot Credentials'), findsOneWidget);
    });

    testWidgets('displays back button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(hotspotCredentialsInputScreenWidget());
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('displays prefix and password text fields', (WidgetTester tester) async {
      await tester.pumpWidget(hotspotCredentialsInputScreenWidget());
      expect(find.text('Hotspot Prefix'), findsOneWidget);
      expect(find.text('Hotspot Password'), findsOneWidget);
    });

    testWidgets('displays submit button with correct initial text', (WidgetTester tester) async {
      await tester.pumpWidget(hotspotCredentialsInputScreenWidget());
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('does not show warning banner when no credentials are configured', (WidgetTester tester) async {
      await tester.pumpWidget(hotspotCredentialsInputScreenWidget());
      expect(find.byType(CredentialsWarningBanner), findsNothing);
    });

    testWidgets('shows warning banner when prefix is configured', (WidgetTester tester) async {
      final viewModelWithPrefix = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: 'configured-prefix',
        configuredHotspotPassword: null,
        onCredentialsSubmitted: mockOnCredentialsSubmitted,
      );
      await tester.pumpWidget(hotspotCredentialsInputScreenWidget(vm: viewModelWithPrefix));
      expect(find.byType(CredentialsWarningBanner), findsOneWidget);
    });

    testWidgets('shows warning banner when password is configured', (WidgetTester tester) async {
      final viewModelWithPassword = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: null,
        configuredHotspotPassword: 'configured-password',
        onCredentialsSubmitted: mockOnCredentialsSubmitted,
      );
      await tester.pumpWidget(hotspotCredentialsInputScreenWidget(vm: viewModelWithPassword));
      expect(find.byType(CredentialsWarningBanner), findsOneWidget);
    });

    testWidgets('shows warning banner when both prefix and password are configured', (WidgetTester tester) async {
      final viewModelWithBoth = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: 'configured-prefix',
        configuredHotspotPassword: 'configured-password',
        onCredentialsSubmitted: mockOnCredentialsSubmitted,
      );
      await tester.pumpWidget(hotspotCredentialsInputScreenWidget(vm: viewModelWithBoth));
      expect(find.byType(CredentialsWarningBanner), findsOneWidget);
    });
  });

  group('User Interactions', () {
    testWidgets('calls onBack when back button is pressed', (WidgetTester tester) async {
      bool onBackCalled = false;
      void testOnBack() {
        onBackCalled = true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: HotspotCredentialsInputScreen(
            viewModel: viewModel,
            onBack: testOnBack,
          ),
        ),
      );

      final backButtonFinder = find.byIcon(Icons.arrow_back);
      expect(backButtonFinder, findsOneWidget);

      await tester.tap(backButtonFinder);
      await tester.pump();

      expect(onBackCalled, isTrue);
    });

    testWidgets('calls submitCredentials when form is submitted with valid inputs', (WidgetTester tester) async {
      String? capturedPrefix;
      String? capturedPassword;
      final testViewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: null,
        configuredHotspotPassword: null,
        onCredentialsSubmitted: (prefix, password) {
          capturedPrefix = prefix;
          capturedPassword = password;
        },
      );

      await tester.pumpWidget(hotspotCredentialsInputScreenWidget(vm: testViewModel));

      final prefixFields = find.byType(CredentialsTextField);
      await tester.enterText(prefixFields.first, 'test-prefix');
      await tester.pump();

      await tester.enterText(prefixFields.at(1), 'test-password');
      await tester.pump();

      final buttonFinder = find.byType(CredentialsSubmitButton);
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(capturedPrefix, equals('test-prefix'));
      expect(capturedPassword, equals('test-password'));
    });

    testWidgets('trims whitespace from inputs before submitting', (WidgetTester tester) async {
      String? capturedPrefix;
      String? capturedPassword;
      final testViewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: null,
        configuredHotspotPassword: null,
        onCredentialsSubmitted: (prefix, password) {
          capturedPrefix = prefix;
          capturedPassword = password;
        },
      );

      await tester.pumpWidget(hotspotCredentialsInputScreenWidget(vm: testViewModel));

      final textFields = find.byType(CredentialsTextField);
      await tester.enterText(textFields.first, '  test-prefix  ');
      await tester.pump();

      await tester.enterText(textFields.at(1), '  test-password  ');
      await tester.pump();

      final buttonFinder = find.byType(CredentialsSubmitButton);
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(capturedPrefix, equals('test-prefix'));
      expect(capturedPassword, equals('test-password'));
    });

    testWidgets('submits form when password field is submitted via keyboard', (WidgetTester tester) async {
      String? capturedPrefix;
      String? capturedPassword;
      final testViewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: null,
        configuredHotspotPassword: null,
        onCredentialsSubmitted: (prefix, password) {
          capturedPrefix = prefix;
          capturedPassword = password;
        },
      );

      await tester.pumpWidget(hotspotCredentialsInputScreenWidget(vm: testViewModel));

      final textFields = find.byType(CredentialsTextField);
      await tester.enterText(textFields.first, 'test-prefix');
      await tester.pump();

      // enter valid password and submit via keyboard done action
      await tester.enterText(textFields.at(1), 'test-password');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(capturedPrefix, equals('test-prefix'));
      expect(capturedPassword, equals('test-password'));
    });
  });

  group('Prefix and password text field validation', () {
    testWidgets('shows error when prefix is empty', (WidgetTester tester) async {
      await tester.pumpWidget(hotspotCredentialsInputScreenWidget());
      // enter password but leave prefix empty
      final textFields = find.byType(CredentialsTextField);
      await tester.enterText(textFields.at(1), 'test-password');
      await tester.pump();

      final buttonFinder = find.byType(CredentialsSubmitButton);
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(find.text('Please enter a hotspot prefix'), findsOneWidget);
    });

    testWidgets('shows error when prefix is only whitespace', (WidgetTester tester) async {
      await tester.pumpWidget(hotspotCredentialsInputScreenWidget());
     
      final textFields = find.byType(CredentialsTextField);
      await tester.enterText(textFields.first, '   ');
      await tester.pump();

      await tester.enterText(textFields.at(1), 'test-password');
      await tester.pump();

      final buttonFinder = find.byType(CredentialsSubmitButton);
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(find.text('Please enter a hotspot prefix'), findsOneWidget);
    });

    testWidgets('shows error when prefix is too short', (WidgetTester tester) async {
      await tester.pumpWidget(hotspotCredentialsInputScreenWidget());
      // enter prefix that is too short
      final textFields = find.byType(CredentialsTextField);
      await tester.enterText(textFields.first, 'ab');
      await tester.pump();

      await tester.enterText(textFields.at(1), 'test-password');
      await tester.pump();

      final buttonFinder = find.byType(CredentialsSubmitButton);
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(find.text('Hotspot prefix must be at least 3 characters long'), findsOneWidget);
    });

    testWidgets('shows error when password is empty', (WidgetTester tester) async {
      await tester.pumpWidget(hotspotCredentialsInputScreenWidget());
      // enter prefix but leave password empty
      final textFields = find.byType(CredentialsTextField);
      await tester.enterText(textFields.first, 'test-prefix');
      await tester.pump();

      final buttonFinder = find.byType(CredentialsSubmitButton);
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(find.text('Please enter a hotspot password'), findsOneWidget);
    });

    testWidgets('does not call submitCredentials when validation fails', (WidgetTester tester) async {
      bool onCredentialsSubmittedCalled = false;
      final testViewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: null,
        configuredHotspotPassword: null,
        onCredentialsSubmitted: (prefix, password) {
          onCredentialsSubmittedCalled = true;
        },
      );

      await tester.pumpWidget(hotspotCredentialsInputScreenWidget(vm: testViewModel));

      final buttonFinder = find.byType(CredentialsSubmitButton);
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(onCredentialsSubmittedCalled, isFalse);
    });

    testWidgets('accepts valid prefix with exactly 3 characters', (WidgetTester tester) async {
      String? capturedPrefix;
      String? capturedPassword;
      final testViewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: null,
        configuredHotspotPassword: null,
        onCredentialsSubmitted: (prefix, password) {
          capturedPrefix = prefix;
          capturedPassword = password;
        },
      );

      await tester.pumpWidget(hotspotCredentialsInputScreenWidget(vm: testViewModel));

      final textFields = find.byType(CredentialsTextField);
      await tester.enterText(textFields.first, 'abc');
      await tester.pump();

      await tester.enterText(textFields.at(1), 'test-password');
      await tester.pump();

      final buttonFinder = find.byType(CredentialsSubmitButton);
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(capturedPrefix, equals('abc'));
      expect(capturedPassword, equals('test-password'));
      expect(find.text('Hotspot prefix must be at least 3 characters long'), findsNothing);
    });
  });
}

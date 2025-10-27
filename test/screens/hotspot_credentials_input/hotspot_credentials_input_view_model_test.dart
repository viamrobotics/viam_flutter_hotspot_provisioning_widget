import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

void main() {
  late HotspotCredentialsInputViewModel viewModel;
  late Function(String prefix, String password) mockOnCredentialsSubmitted;
  late String mockConfiguredHotspotPrefix;
  late String mockConfiguredHotspotPassword;

  setUp(() {
    mockOnCredentialsSubmitted = (String prefix, String password) {};
    mockConfiguredHotspotPrefix = 'configured-prefix';
    mockConfiguredHotspotPassword = 'configured-password';
    viewModel = HotspotCredentialsInputViewModel(
      configuredHotspotPrefix: mockConfiguredHotspotPrefix,
      configuredHotspotPassword: mockConfiguredHotspotPassword,
      onCredentialsSubmitted: mockOnCredentialsSubmitted,
    );
  });

  group('Constructor and Initialization', () {
    test('should initialize with provided credentials', () {
      // The viewModel is initialized with the mockConfiguredHotspotPrefix and mockConfiguredHotspotPassword in setUp()
      expect(viewModel.configuredHotspotPrefix, equals(mockConfiguredHotspotPrefix));
      expect(viewModel.configuredHotspotPassword, equals(mockConfiguredHotspotPassword));
      expect(viewModel.isSubmitting, isFalse);
    });

    test('should initialize with null credentials', () {
      final viewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: null,
        configuredHotspotPassword: null,
        onCredentialsSubmitted: mockOnCredentialsSubmitted,
      );

      expect(viewModel.configuredHotspotPrefix, isNull);
      expect(viewModel.configuredHotspotPassword, isNull);
      expect(viewModel.isSubmitting, isFalse);
    });
    test('should initialize with empty string credentials', () {
      final viewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: '',
        configuredHotspotPassword: '',
        onCredentialsSubmitted: mockOnCredentialsSubmitted,
      );

      expect(viewModel.configuredHotspotPrefix, equals(''));
      expect(viewModel.configuredHotspotPassword, equals(''));
      expect(viewModel.isSubmitting, isFalse);
    });
  });

  group('test hasConfiguredPrefix', () {
    test('should return false when prefix is null', () {
      final viewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: null,
        configuredHotspotPassword: mockConfiguredHotspotPassword,
        onCredentialsSubmitted: mockOnCredentialsSubmitted,
      );

      expect(viewModel.hasConfiguredPrefix, isFalse);
    });

    test('should return false when prefix is empty', () {
      final viewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: '',
        configuredHotspotPassword: null,
        onCredentialsSubmitted: mockOnCredentialsSubmitted,
      );

      expect(viewModel.hasConfiguredPrefix, isFalse);
    });

    test('should return false when prefix has only whitespace', () {
      final viewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: '   ',
        configuredHotspotPassword: mockConfiguredHotspotPassword,
        onCredentialsSubmitted: mockOnCredentialsSubmitted,
      );

      expect(viewModel.hasConfiguredPrefix, isFalse);
    });

    test('should return true when prefix is configured', () {
      final viewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: mockConfiguredHotspotPrefix,
        configuredHotspotPassword: null,
        onCredentialsSubmitted: mockOnCredentialsSubmitted,
      );

      expect(viewModel.hasConfiguredPrefix, isTrue);
    });

    test('should return true when prefix has content with whitespace', () {
      final viewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: '  $mockConfiguredHotspotPrefix  ',
        configuredHotspotPassword: null,
        onCredentialsSubmitted: mockOnCredentialsSubmitted,
      );

      expect(viewModel.hasConfiguredPrefix, isTrue);
    });
  });

  group('test hasConfiguredPassword', () {
    test('should return false when password is null', () {
      final viewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: mockConfiguredHotspotPrefix,
        configuredHotspotPassword: null,
        onCredentialsSubmitted: mockOnCredentialsSubmitted,
      );

      expect(viewModel.hasConfiguredPassword, isFalse);
    });

    test('should return false when password is empty', () {
      final viewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: mockConfiguredHotspotPrefix,
        configuredHotspotPassword: '',
        onCredentialsSubmitted: mockOnCredentialsSubmitted,
      );

      expect(viewModel.hasConfiguredPassword, isFalse);
    });

    test('should return false when password has only whitespace', () {
      final viewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: mockConfiguredHotspotPrefix,
        configuredHotspotPassword: '   ',
        onCredentialsSubmitted: mockOnCredentialsSubmitted,
      );

      expect(viewModel.hasConfiguredPassword, isFalse);
    });

    test('should return true when password is configured', () {
      final viewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: null,
        configuredHotspotPassword: mockConfiguredHotspotPassword,
        onCredentialsSubmitted: mockOnCredentialsSubmitted,
      );

      expect(viewModel.hasConfiguredPassword, isTrue);
    });

    test('should return true when password has content with whitespace', () {
      final viewModel = HotspotCredentialsInputViewModel(
        configuredHotspotPrefix: null,
        configuredHotspotPassword: '  $mockConfiguredHotspotPassword  ',
        onCredentialsSubmitted: mockOnCredentialsSubmitted,
      );

      expect(viewModel.hasConfiguredPassword, isTrue);
    });
  });

  group('isSubmitting', () {
    test('should be false initially', () {
      expect(viewModel.isSubmitting, isFalse);
    });

    test('should be true after calling submitCredentials', () {
      viewModel.submitCredentials(mockConfiguredHotspotPrefix, mockConfiguredHotspotPassword);
      expect(viewModel.isSubmitting, isTrue);
    });
  });

  group('submitCredentials', () {
    test('should set isSubmitting to true and call onCredentialsSubmitted', () {
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

      testViewModel.submitCredentials(mockConfiguredHotspotPrefix, mockConfiguredHotspotPassword);

      expect(testViewModel.isSubmitting, isTrue);
      expect(capturedPrefix, equals(mockConfiguredHotspotPrefix));
      expect(capturedPassword, equals(mockConfiguredHotspotPassword));
    });

    test('should handle empty strings', () {
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

      testViewModel.submitCredentials('', '');

      expect(testViewModel.isSubmitting, isTrue);
      expect(capturedPrefix, equals(''));
      expect(capturedPassword, equals(''));
    });

    test('should notify listeners when called', () {
      bool listenerCalled = false;
      viewModel.addListener(() {
        listenerCalled = true;
      });

      viewModel.submitCredentials('testPrefix', 'testPassword');

      expect(listenerCalled, isTrue);
    });
  });
}

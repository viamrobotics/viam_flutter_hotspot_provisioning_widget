import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

void main() {
  group('CredentialsWarningBanner', () {
    Widget warningBannerWidget({
      required bool prefixConfigured,
      required bool passwordConfigured,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CredentialsWarningBanner(
            prefixConfigured: prefixConfigured,
            passwordConfigured: passwordConfigured,
          ),
        ),
      );
    }

    testWidgets('displays warning icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        warningBannerWidget(
          prefixConfigured: true,
          passwordConfigured: true,
        ),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('shows message when both prefix and password are configured', (WidgetTester tester) async {
      await tester.pumpWidget(
        warningBannerWidget(
          prefixConfigured: true,
          passwordConfigured: true,
        ),
      );

      expect(
        find.text(
          'Initial hotspot prefix and password credentials were provided earlier but will be overwritten by the values you enter here.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows message when only prefix is configured', (WidgetTester tester) async {
      await tester.pumpWidget(
        warningBannerWidget(
          prefixConfigured: true,
          passwordConfigured: false,
        ),
      );

      expect(
        find.text(
          'Initial hotspot prefix credential was provided earlier but will be overwritten by the value you enter here.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows message when only password is configured', (WidgetTester tester) async {
      await tester.pumpWidget(
        warningBannerWidget(
          prefixConfigured: false,
          passwordConfigured: true,
        ),
      );

      expect(
        find.text(
          'Initial hotspot password credential was provided earlier but will be overwritten by the value you enter here.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows message when neither prefix nor password is configured', (WidgetTester tester) async {
      await tester.pumpWidget(
        warningBannerWidget(
          prefixConfigured: false,
          passwordConfigured: false,
        ),
      );

      expect(
        find.text(
          'Initial hotspot credentials were provided earlier but will be overwritten by the values you enter here.',
        ),
        findsOneWidget,
      );
    });
    testWidgets('has icon and text in a row layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        warningBannerWidget(
          prefixConfigured: true,
          passwordConfigured: true,
        ),
      );

      expect(find.byType(Row), findsWidgets);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });
  });
}

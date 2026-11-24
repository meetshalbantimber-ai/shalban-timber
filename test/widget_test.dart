import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shalban_smart/theme/app_theme.dart';
import 'package:shalban_smart/widgets/offline_view.dart';

void main() {
  testWidgets('OfflineView renders Retry button and triggers callback',
      (WidgetTester tester) async {
    bool retried = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: OfflineView(
            onRetry: () {
              retried = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('No Internet Connection'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });
}

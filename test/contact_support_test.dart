import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floret_app/features/profile/viewmodel/contact_support_view_model.dart';
import 'package:floret_app/features/profile/screen/contact_support_screen.dart';

void main() {
  group('ContactSupportViewModel Tests', () {
    test('validation fails when fields are empty', () async {
      final vm = ContactSupportViewModel();
      bool hasSucceeded = false;
      String? errorMessage;

      final result = await vm.submitMessage(
        onSuccess: () => hasSucceeded = true,
        onError: (err) => errorMessage = err,
      );

      expect(result, isFalse);
      expect(hasSucceeded, isFalse);
      expect(errorMessage, equals('Please fill in all required fields'));
      expect(vm.nameError, isNotNull);
      expect(vm.emailError, isNotNull);
      expect(vm.subjectError, isNotNull);
      expect(vm.messageError, isNotNull);
    });

    test('submitMessage succeeds when all fields are filled', () async {
      final vm = ContactSupportViewModel();
      vm.nameController.text = 'John Doe';
      vm.phoneController.text = '9876543210';
      vm.emailController.text = 'john@example.com';
      vm.subjectController.text = 'Need help with pickup';
      vm.messageController.text = 'My pickup was delayed, please help.';
      vm.setInquiryType('Schedule Pickup');

      bool hasSucceeded = false;
      String? errorMessage;

      final result = await vm.submitMessage(
        onSuccess: () => hasSucceeded = true,
        onError: (err) => errorMessage = err,
      );

      expect(result, isTrue);
      expect(hasSucceeded, isTrue);
      expect(errorMessage, isNull);

      // Verify form is cleared on success
      expect(vm.nameController.text, isEmpty);
      expect(vm.phoneController.text, isEmpty);
      expect(vm.emailController.text, isEmpty);
      expect(vm.subjectController.text, isEmpty);
      expect(vm.messageController.text, isEmpty);
    });
  });

  group('ContactSupportScreen Widget Tests', () {
    testWidgets('filling fields and tapping SEND MESSAGE triggers submitMessage', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ContactSupportScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter details
      await tester.enterText(find.widgetWithText(TextField, 'Your Name').first, 'Jane Doe');
      await tester.enterText(find.widgetWithText(TextField, 'Phone').first, '9123456789');
      await tester.enterText(find.widgetWithText(TextField, 'Email Address').first, 'jane@example.com');
      await tester.enterText(find.widgetWithText(TextField, 'Subject').first, 'General question');
      await tester.enterText(find.widgetWithText(TextField, 'Write your message here...').first, 'Hello support team');
      await tester.pumpAndSettle();

      // Tap SEND MESSAGE button
      final sendBtn = find.widgetWithText(ElevatedButton, 'SEND MESSAGE');
      expect(sendBtn, findsOneWidget);
      await tester.ensureVisible(sendBtn);
      await tester.tap(sendBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Verify success snackbar
      expect(find.text('Message sent successfully! We will get back to you soon.'), findsOneWidget);
    });
  });
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/models/district_model.dart';
import 'package:floret_app/features/auth/repos/auth_repository.dart';
import 'package:floret_app/features/auth/viewmodel/signup_view_model.dart';
import 'package:floret_app/features/booking/repos/booking_repository.dart';
import 'package:floret_app/features/booking/viewmodel/booking_view_model.dart';
import 'package:floret_app/features/booking/screen/book_pickup_screen.dart';
import 'package:floret_app/services/api_client.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('District Model and Dynamic Parsing Tests', () {
    test(
        'DistrictModel parses single and multiple dynamic API responses without hardcoding',
        () {
      final apiResponse = [
        {"id": 2, "name": "Thiruvananthapuram", "state": 1},
        {"id": 3, "name": "Kollam", "state": 1},
      ];

      final districts = DistrictModel.parseDistricts(apiResponse);
      expect(districts.length, equals(2));
      expect(districts[0], equals('Thiruvananthapuram'));
      expect(districts[1], equals('Kollam'));
    });

    test(
        'DistrictModel handles map wrapper responses with districts or results key',
        () {
      final wrappedResponse = {
        "districts": [
          {"id": 5, "name": "Ernakulam", "state": 1}
        ]
      };

      final districts = DistrictModel.parseDistricts(wrappedResponse);
      expect(districts.length, equals(1));
      expect(districts.first, equals('Ernakulam'));
    });
  });

  group('Sign Up Dynamic Districts Tests', () {
    test(
        'SignupViewModel fetches and exposes districts dynamically from repository',
        () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.uri.toString().contains('/api/districts/')) {
              expect(options.uri.queryParameters['state'], equals('kerala'));
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {"id": 2, "name": "Thiruvananthapuram", "state": 1}
                  ],
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      ApiClient(customDio: dio);

      final authRepo = AuthRepository();
      final vm = SignupViewModel(authRepository: authRepo);

      final fetched = await vm.fetchDistricts(state: 'kerala');
      expect(fetched, contains('Thiruvananthapuram'));
      expect(vm.availableDistricts, contains('Thiruvananthapuram'));
    });
  });

  group('Book Pickup Dynamic Districts Tests', () {
    test('BookingRepository fetches and exposes districts dynamically from API',
        () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.uri.toString().contains('/api/districts/')) {
              expect(options.uri.queryParameters['state'], equals('kerala'));
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {"id": 2, "name": "Thiruvananthapuram", "state": 1}
                  ],
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      ApiClient(customDio: dio);

      final repo = BookingRepository();
      final districts = await repo.fetchDistricts(state: 'kerala');

      expect(districts, contains('Thiruvananthapuram'));
      expect(
          repo.getDistrictsForState('Kerala'), contains('Thiruvananthapuram'));
    });

    testWidgets(
        'BookPickupScreen District selector displays dynamically fetched districts',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.uri.toString().contains('/api/districts/')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {"id": 2, "name": "Dynamic District A", "state": 1},
                    {"id": 3, "name": "Dynamic District B", "state": 1},
                  ],
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      ApiClient(customDio: dio);

      final vm = BookingViewModel();
      vm.fullNameController.text = 'Valid User';
      vm.contactNumberController.text = '+919876543210';
      vm.proceedToLocation();
      vm.setAddressTab(1); // Switch to New Address tab
      vm.setStateSelection('Kerala'); // Select Kerala state

      await tester.pumpWidget(
        MaterialApp(
          home: BookPickupScreen(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure we are on location step
      expect(find.text('Location Details'), findsOneWidget);

      // Tap on District dropdown (which has hint "Select District" since state is Kerala)
      final districtFinder = find.text('Select District');
      expect(districtFinder, findsOneWidget);
      await tester.tap(districtFinder);
      await tester.pumpAndSettle();

      // Verify dynamically fetched districts appear in selection sheet
      expect(find.text('Dynamic District A'), findsOneWidget);
      expect(find.text('Dynamic District B'), findsOneWidget);

      // Select one
      await tester.tap(find.text('Dynamic District A'));
      await tester.pumpAndSettle();

      expect(vm.selectedDistrict, equals('Dynamic District A'));
    });
  });
}

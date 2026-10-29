import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/features/wallet/model/wallet_model.dart';
import 'package:floret_app/features/wallet/repos/wallet_repository.dart';
import 'package:floret_app/features/wallet/viewmodel/wallet_view_model.dart';
import 'package:floret_app/features/wallet/screen/wallet_screen.dart';
import 'package:floret_app/services/api_service.dart';
import 'package:dio/dio.dart';

class MockRewardApiService extends ApiService {
  int getRewardPointsCallCount = 0;
  int getRewardPointsTxCallCount = 0;

  @override
  Future<Response> getRewardPoints({String? token}) async {
    getRewardPointsCallCount++;
    return Response(
      requestOptions: RequestOptions(path: '/api/reward-points/'),
      statusCode: 200,
      data: {
        'id': 71,
        'user': 447,
        'total_earned': 120,
        'total_redeemed': 20,
        'total_expired': 10,
        'available_points': 90,
        'monetary_value': 22.5,
        'created_at': '2026-10-28T06:52:41.241078Z',
        'updated_at': '2026-10-28T06:52:41.241113Z',
        'config': {
          'id': 1,
          'earnings_ratio': '100.00',
          'redemption_value': '0.25',
          'points_expiry_days': 30,
          'minimum_redemption_points': 1000,
          'is_active': true,
          'updated_at': '2026-09-03T04:57:52.978129Z',
        },
      },
    );
  }

  @override
  Future<Response> getRewardPointsTransactions({String? token}) async {
    getRewardPointsTxCallCount++;
    return Response(
      requestOptions: RequestOptions(path: '/api/reward-points/transactions/'),
      statusCode: 200,
      data: {
        'count': 0,
        'results': [],
      },
    );
  }

  @override
  Future<Response> getWalletBalance({String? token}) async {
    return Response(
      requestOptions: RequestOptions(path: '/api/wallet/balance/'),
      statusCode: 200,
      data: {'balance': 500.0},
    );
  }

  @override
  Future<Response> getWalletTopup({String? token}) async {
    return Response(
      requestOptions: RequestOptions(path: '/api/wallet/topup/'),
      statusCode: 200,
      data: {
        'presets': [100, 200, 500]
      },
    );
  }

  @override
  Future<Response> getWalletTransactions({String? token}) async {
    return Response(
      requestOptions: RequestOptions(path: '/api/wallet/transactions/'),
      statusCode: 200,
      data: {'results': []},
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Eco Rewards API & UI Flow Tests', () {
    test('RewardPointsDataModel parses backend json response properly', () {
      final json = {
        'id': 71,
        'user': 447,
        'total_earned': 0,
        'total_redeemed': 0,
        'total_expired': 0,
        'available_points': 0,
        'monetary_value': 0.0,
        'created_at': '2026-10-28T06:52:41.241078Z',
        'updated_at': '2026-10-28T06:52:41.241113Z',
        'config': {
          'id': 1,
          'earnings_ratio': '100.00',
          'redemption_value': '0.25',
          'points_expiry_days': 30,
          'minimum_redemption_points': 1000,
          'is_active': true,
          'updated_at': '2026-09-03T04:57:52.978129Z',
        },
      };

      final model = RewardPointsDataModel.fromJson(json);
      expect(model.id, equals(71));
      expect(model.user, equals(447));
      expect(model.availablePoints, equals(0));
      expect(model.monetaryValue, equals(0.0));
      expect(model.config?.earningsRatio, equals(100.0));
      expect(model.config?.redemptionValue, equals(0.25));
      expect(model.config?.minimumRedemptionPoints, equals(1000));
      expect(model.config?.pointsExpiryDays, equals(30));
    });

    test('WalletViewModel fetchRewardPoints updates bundle and state',
        () async {
      final mockApi = MockRewardApiService();
      final repo = WalletRepository(apiService: mockApi);
      final vm = WalletViewModel(repository: repo);

      final initialCount = mockApi.getRewardPointsCallCount;

      final points = await vm.fetchRewardPoints();
      expect(mockApi.getRewardPointsCallCount, equals(initialCount + 1));
      expect(points.availablePoints, equals(90));
      expect(vm.availableSafaiPoints, equals(90));
      expect(vm.totalEarned, equals(120));
      expect(vm.totalRedeemed, equals(20));
      expect(vm.totalExpired, equals(10));
      expect(vm.monetaryValue, equals(22.5));
    });

    testWidgets(
        'Tapping Eco Rewards in WalletScreen triggers GET /api/reward-points/',
        (tester) async {
      final mockApi = MockRewardApiService();
      final repo = WalletRepository(apiService: mockApi);
      final vm = WalletViewModel(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: WalletScreen(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      final countBeforeTap = mockApi.getRewardPointsCallCount;

      // Tap on 'Eco Rewards' tab
      final ecoRewardsTab = find.text('Eco Rewards');
      expect(ecoRewardsTab, findsOneWidget);

      await tester.tap(ecoRewardsTab);
      await tester.pumpAndSettle();

      expect(mockApi.getRewardPointsCallCount, equals(countBeforeTap + 1));
      expect(vm.selectedActivityTab, equals(1));
      expect(find.text('90 pts'), findsOneWidget);
      expect(find.text('Earned'), findsOneWidget);
      expect(find.text('120'), findsOneWidget);
    });
  });
}

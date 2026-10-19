import 'package:floret_app/features/auth/screen/login_screen.dart';
import 'package:floret_app/features/auth/screen/signup_screen.dart';
import 'package:floret_app/features/auth/screen/otp_screen.dart';
import 'package:floret_app/features/home/screen/bottom_navigation_screen.dart';
import 'package:floret_app/features/home/screen/home_screen.dart';
import 'package:floret_app/features/profile/screen/profile_screen.dart';
import 'package:floret_app/features/settings/screen/settings_screen.dart';
import 'package:floret_app/features/splashscreen/screen/splashscreen.dart';
import 'package:floret_app/utils/connection_failed_screen.dart';
import 'package:floret_app/views/login_view.dart';
import 'package:floret_app/views/profile_view.dart';
import 'package:floret_app/views/send_otp_view.dart';
import 'package:flutter/material.dart';

import 'package:floret_app/features/notifications/screen/notifications_screen.dart';
import 'package:floret_app/features/wallet/screen/wallet_screen.dart';
import 'package:floret_app/features/settings/screen/privacy_security_screen.dart';
import 'package:floret_app/features/settings/screen/notification_preferences_screen.dart';
import 'package:floret_app/features/settings/screen/help_support_screen.dart';
import 'package:floret_app/features/settings/screen/about_app_screen.dart';
import 'package:floret_app/features/profile/screen/order_history_screen.dart';
import 'package:floret_app/features/profile/screen/my_account_screen.dart';
import 'package:floret_app/features/profile/screen/saved_addresses_screen.dart';
import 'package:floret_app/features/profile/screen/contact_support_screen.dart';
import 'package:floret_app/features/profile/screen/official_invoice_screen.dart';
import 'package:floret_app/features/profile/screen/invoice_pdf_preview_screen.dart';
import 'package:floret_app/features/profile/model/order_model.dart';
import 'package:floret_app/features/profile/model/bill_model.dart';
import 'package:floret_app/features/booking/screen/disposal_console_screen.dart';
import 'package:floret_app/features/booking/screen/book_pickup_screen.dart';
import 'package:floret_app/features/wallet/screen/razorpay_checkout_screen.dart';
import 'package:floret_app/features/wallet/screen/payment_successful_screen.dart';

import 'package:floret_app/features/booking/screen/receipt_ticket_screen.dart';
import 'package:floret_app/features/map/screen/location_picker_map_screen.dart';

Map<String, Widget Function(BuildContext context)> appRoutes() => {
      LocationPickerMapScreen.routeName: (context) =>
          const LocationPickerMapScreen(),
      SplashScreen.routeName: (context) => const SplashScreen(),
      SendOtpView.routeName: (context) => const SendOtpView(),
      LoginView.routeName: (context) => const LoginView(),
      ProfileView.routeName: (context) => const ProfileView(),
      LoginScreen.routeName: (context) => const LoginScreen(),
      OtpScreen.routeName: (context) => const OtpScreen(),
      SignupScreen.routeName: (context) => const SignupScreen(),
      BottomNavigationScreen.routeName: (context) =>
          const BottomNavigationScreen(),
      HomeScreen.routeName: (context) => const HomeScreen(),
      SettingsScreen.routeName: (context) => const SettingsScreen(),
      ProfileScreen.routeName: (context) => const ProfileScreen(),
      NotificationsScreen.routeName: (context) => const NotificationsScreen(),
      WalletScreen.routeName: (context) => const WalletScreen(),
      PrivacySecurityScreen.routeName: (context) =>
          const PrivacySecurityScreen(),
      NotificationPreferencesScreen.routeName: (context) =>
          const NotificationPreferencesScreen(),
      HelpSupportScreen.routeName: (context) => const HelpSupportScreen(),
      AboutAppScreen.routeName: (context) => const AboutAppScreen(),
      OrderHistoryScreen.routeName: (context) => const OrderHistoryScreen(),
      MyAccountScreen.routeName: (context) => const MyAccountScreen(),
      SavedAddressesScreen.routeName: (context) => const SavedAddressesScreen(),
      ContactSupportScreen.routeName: (context) => const ContactSupportScreen(),
      DisposalConsoleScreen.routeName: (context) =>
          const DisposalConsoleScreen(),
      BookPickupScreen.routeName: (context) => const BookPickupScreen(),
      RazorpayCheckoutScreen.routeName: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Map<String, dynamic>) {
          return RazorpayCheckoutScreen(
            amount: (args['amount'] as num?)?.toDouble() ?? 500.00,
            orderId: args['orderId'] as String? ?? 'order_u6Fx1O',
            transactionId: args['transactionId'] as int?,
            onTopUpSuccess: args['onTopUpSuccess'] as VoidCallback?,
            isCommercialRegistration:
                args['isCommercialRegistration'] as bool? ?? false,
          );
        } else if (args is double) {
          return RazorpayCheckoutScreen(amount: args);
        }
        return const RazorpayCheckoutScreen();
      },
      PaymentSuccessfulScreen.routeName: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Map<String, dynamic>) {
          return PaymentSuccessfulScreen(
            amount: (args['amount'] as num?)?.toDouble() ?? 500.00,
          );
        } else if (args is double) {
          return PaymentSuccessfulScreen(amount: args);
        }
        return const PaymentSuccessfulScreen();
      },
      ReceiptTicketScreen.routeName: (context) =>
          const ReceiptTicketScreen(),
    };

Widget? _getScreen(RouteSettings settings) {
  switch (settings.name) {
    case ConnectionFailedScreen.routeName:
      ConnectionFailedScreenParams params =
          settings.arguments as ConnectionFailedScreenParams;
      return ConnectionFailedScreen(
        param: params,
      );
    case OfficialInvoiceScreen.routeName:
      final args = settings.arguments;
      if (args is OrderModel) {
        return OfficialInvoiceScreen(order: args);
      }
      return null;
    case InvoicePdfPreviewScreen.routeName:
      final args = settings.arguments;
      if (args is Map) {
        return InvoicePdfPreviewScreen(
          order: args['order'] as OrderModel,
          bill: args['bill'] as BillModel,
        );
      }
      return null;

    default:
      return null;
  }
}

RouteFactory onAppGenerateRoute() => (settings) {
      Widget? screen = _getScreen(settings);
      if (screen != null) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => screen,
          transitionsBuilder: (_, a, __, c) {
            return FadeTransition(opacity: a, child: c);
          },
        );
      }
      return null;
    };

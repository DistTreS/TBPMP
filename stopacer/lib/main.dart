import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/choose_business_screen.dart';
import 'screens/create_business_screen.dart';
import 'screens/add_stock_in_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/add_stock_out_screen.dart';
import 'screens/add_income_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/item_list_screen.dart';
import 'screens/report_screen.dart';
import 'screens/history_screen.dart';
import 'screens/account_screen.dart';
import 'screens/item_detail_screen.dart';
import 'screens/vendor_list_screen.dart';
import 'screens/add_vendor_screen.dart';
import 'screens/request_item_list_screen.dart';
import 'screens/add_request_item_screen.dart';

void main() {
  runApp(const StopacerApp());
}

class StopacerApp extends StatelessWidget {
  const StopacerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stopacer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF50C2C9),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF50C2C9),
          primary: const Color(0xFF50C2C9),
          secondary: Color.fromARGB(255, 2, 235, 248),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF50C2C9),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF1363DF)),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/choose-business': (context) => const ChooseBusinessScreen(),
        '/create-business': (context) => const CreateBusinessScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/add-stock-in': (context) => const AddStockInScreen(),
        '/add-item': (context) => const AddItemScreen(),
        '/add-stock-out': (context) => const AddStockOutScreen(),
        '/stock-list': (context) => const ItemListScreen(),
        '/add-income': (context) => const AddIncomeScreen(),
        '/add-expense': (context) => const AddExpenseScreen(),
        '/item-detail': (context) => ItemDetailScreen(
          item:
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>,
        ),
        '/report': (context) => const ReportScreen(),
        '/history': (context) => const HistoryScreen(),
        '/account': (context) => const AccountScreen(),
        '/vendors': (context) => const VendorListScreen(),
        '/add-vendor': (context) => const AddVendorScreen(),
        '/request-list': (context) => const RequestItemListScreen(),
        '/add-request': (context) => const AddRequestItemScreen(),
      },
    );
  }
}

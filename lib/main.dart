import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/product_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/product_detail_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Your Destination',
      theme: ThemeData(
        primaryColor: Color(0xFFF8E1E9), // Pastel pink
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
          bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.black),
          bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black87),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          color: Color(0xFFF8E1E9), // Pastel pink
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF8A4AF0), // Purple
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(fontFamily: 'Poppins', fontSize: 20, color: Colors.black),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: Color(0xFF2A1B3D), // Dark purple
        scaffoldBackgroundColor: Color(0xFF1F1F1F), // Dark gray
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
          bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.white),
          bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.white70),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          color: Color(0xFF2F2F2F), // Dark gray
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF8A4AF0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2A1B3D),
          elevation: 0,
          titleTextStyle: TextStyle(fontFamily: 'Poppins', fontSize: 20, color: Colors.white),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      themeMode: themeProvider.themeMode,
      home: AuthWrapper(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/products': (context) => ProductScreen(),
        '/cart': (context) => CartScreen(),
        '/checkout': (context) => CheckoutScreen(),
        '/history': (context) => OrderHistoryScreen(),
        '/product_detail': (context) => ProductDetailScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return FutureBuilder(
      future: Future.delayed(Duration.zero, () => authProvider.isAuthenticated),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return authProvider.isAuthenticated ? MainScreen() : LoginScreen();
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
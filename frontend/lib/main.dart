import 'package:flutter/material.dart';
import 'package:wedspace/screens/login_screen.dart';
import 'package:wedspace/screens/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(WedSpaceApp());
}

class WedSpaceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WedSpace',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple,
        ),
      ),
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (snapshot.data == true) {
            return DashboardScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
  
  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
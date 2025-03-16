import 'package:flutter/material.dart';
import 'package:musik/screens/main_screen.dart';
import 'package:musik/services/auth_service.dart';
import 'screens/auth/login/login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final storage = FlutterSecureStorage();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: FutureBuilder<String?>(
        future: _checkAuthToken(),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data != null) {
              _authService.getUserInfo(snapshot.data!, context);
              return MainScreen();
            } else {
              return LoginScreen();
            }
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ), // Loading indicator
            );
          }
        },
      ),
    );
  }

  Future<String?> _checkAuthToken() async {
    return await storage.read(key: 'authToken');
  }
}

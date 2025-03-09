import 'package:flutter/material.dart';
import 'package:musik/screens/main_screen.dart';
import 'screens/auth/login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: FutureBuilder<String?>(
        future: storage.read(key: 'authToken'),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              return MainScreen(); // If token exists, show home screen
            } else {
              return LoginScreen(); // Otherwise, show login screen
            }
          } else {
            return CircularProgressIndicator(); // Loading indicator
          }
        },
      ),
    );
  }
}

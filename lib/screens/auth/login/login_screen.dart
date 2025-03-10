import 'package:flutter/material.dart';
import 'package:musik/widgets/custom_text_field.dart';
import 'package:musik/services/auth_service.dart';
import 'package:musik/screens/main_screen.dart';
import 'package:musik/screens/auth/register/register_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.tealAccent.shade100, Colors.teal.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              margin: EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.shade900,
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Mật khẩu',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        bool isAuthenticated = await _authService.login(
                          _emailController.text,
                          _passwordController.text,
                        );

                        if (isAuthenticated) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => MainScreen(),
                            ),
                          );
                        } else {
                          print('Đăng nhập thất bại');
                          // Show an error message
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.teal,
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(
                        'Đăng nhập',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Chưa có tài khoản? Đăng ký',
                        style: TextStyle(color: Colors.teal.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:musik/widgets/custom_text_field.dart';
import 'package:musik/services/auth_service.dart';
import 'package:musik/widgets/success_popup.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/background.png',
            ), // Path to your background image
            fit: BoxFit.cover, // Cover the whole screen
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
                      'Tạo tài khoản',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _nameController,
                      label: 'Tên hiển thị',
                      icon: Icons.person,
                    ),
                    SizedBox(height: 15),
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
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.orange,
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(
                        'Đăng ký',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Đã có tài khoản? Đăng nhập',
                        style: TextStyle(color: Colors.orange.shade700),
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

  void _register() async {
    final isSuccess = await _authService.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );

    if (isSuccess) {
      Navigator.pop(context);
    } else {
      SuccessPopup(
        message: 'Đăng ký thất bại',
        outerContext: context,
      ).show(success: false);
    }
  }
}

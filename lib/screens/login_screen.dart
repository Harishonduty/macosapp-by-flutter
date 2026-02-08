import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/screens/landing_screen.dart';
import 'package:holy_cross_app/utils/preference_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty) {
      _showError('Enter Registered Username!');
      return;
    }
    if (password.isEmpty) {
      _showError('Enter Password!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiClient.login(username, password);
      final data = response.data;
      
      // The API seems to return the token direct on success (HTTP 200)
      // or a JSON with a 'status' field.
      if (response.statusCode == 200 && data != null && (data['token'] != null || data['status'] == true)) {
        await PreferenceService.setString('token', data['token']?.toString() ?? '');
        await PreferenceService.setString('role', data['rInfo']?.toString() ?? '');
        await PreferenceService.setString('sLogo', data['sLogo']?.toString() ?? '');
        await PreferenceService.setString('pLogo', data['pLogo']?.toString() ?? '');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SFSLandingScreen()),
          );
        }
      } else {
        String errorMsg = 'Login failed';
        if (data != null && data['message'] != null) {
          errorMsg = data['message'].toString();
        } else if (response.statusCode == 401) {
          errorMsg = 'Invalid Username or Password';
        }
        _showError(errorMsg);
      }
    } catch (e) {
      _showError('Connection Error: Please check your internet.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Logo
              Image.asset(
                'assets/logo.png',
                width: 130,
                height: 130,
              ),
              const SizedBox(height: 20),
              // App Name
              const Text(
                'JOSEPHITES',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              // Username Field
              _buildTextField(
                controller: _usernameController,
                hintText: 'Username',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              // Password Field
              _buildTextField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.lightGray,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 30),
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightGray, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.lightGray),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

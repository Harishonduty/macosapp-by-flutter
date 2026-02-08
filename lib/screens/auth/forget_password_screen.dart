import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _otpSent = false;
  bool _isLoading = false;

  void _sendOtp() {
    if (_mobileController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter a valid mobile number")));
      return;
    }
    setState(() => _isLoading = true);
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP sent successfully")));
      }
    });
  }

  void _resetPassword() {
    if (_otpController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }
    setState(() => _isLoading = true);
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password reset successfully. Please login.")));
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Icon(Icons.lock_reset, size: 80, color: AppColors.primary.withOpacity(0.8)),
            const SizedBox(height: 32),
            if (!_otpSent) ...[
              const Text(
                "Enter your registered mobile number to receive an OTP",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Mobile Number",
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("SEND OTP", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ] else ...[
              const Text(
                "Verify OTP and set your new password",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter OTP",
                  prefixIcon: const Icon(Icons.password),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "New Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("RESET PASSWORD", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _otpSent = false),
                child: const Text("Back to Mobile Number"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

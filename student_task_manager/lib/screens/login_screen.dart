// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../ widgets/animated_logo.dart';
import '../ widgets/custom_button.dart';
import '../ widgets/custom_text_field.dart';
import '../routes.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const AnimatedLogo(size: 96),
              const SizedBox(height: 20),
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text('Sign in to continue', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
              const SizedBox(height: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(hint: 'Email', keyboardType: TextInputType.emailAddress, controller: _email),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hint: 'Password',
                    obscure: _obscure,
                    controller: _password,
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Forgot password tapped (UI-only)'))),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  CustomButton(label: 'Login', onPressed: _onLogin),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Don\'t have an account?'),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.signup),
                        child: const Text('Sign up'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Center(child: Text('Or continue with', style: TextStyle(color: Colors.grey.shade600))),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: width,
                    child: OutlinedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Social login (UI-only)'))),
                      icon: const Icon(Icons.apple),
                      label: const Text('Continue with Apple (UI-only)'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

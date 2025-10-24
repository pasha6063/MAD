// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';

import '../ widgets/animated_logo.dart';
import '../ widgets/custom_button.dart';
import '../ widgets/custom_text_field.dart';
import '../routes.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _onSignup() {
    // UI-only: navigate to home
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const AnimatedLogo(size: 84),
              const SizedBox(height: 18),
              Text(
                'Create account',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 22),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(hint: 'Full name', controller: _name),
                  const SizedBox(height: 12),
                  CustomTextField(hint: 'Email', keyboardType: TextInputType.emailAddress, controller: _email),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hint: 'Password',
                    obscure: _obscure,
                    controller: _pass,
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(hint: 'Confirm password', obscure: _obscure, controller: _confirm),
                  const SizedBox(height: 18),
                  CustomButton(label: 'Sign up', onPressed: _onSignup),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                        child: const Text('Login'),
                      )
                    ],
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

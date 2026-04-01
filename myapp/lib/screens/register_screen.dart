import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    final error = await _authService.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (error == null && mounted) Navigator.pop(context);
    setState(() { _isLoading = false; _errorMessage = error; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: _register,
                  child: const Text('Daftar')),
          ],
        ),
      ),
    );
  }
}

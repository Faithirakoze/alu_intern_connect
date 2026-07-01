import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'student';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    // Basic validation
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your full name.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await ref.read(authServiceProvider).register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _role,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F0F1A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F0F1A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join the ALU Connect community',
                style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
              ),

              const SizedBox(height: 32),

              // Full name
              _label('Full Name'),
              const SizedBox(height: 8),
              _textField(
                controller: _nameController,
                hint: 'Amina Hassan',
              ),

              const SizedBox(height: 16),

              // Email
              _label('Email'),
              const SizedBox(height: 8),
              _textField(
                controller: _emailController,
                hint: 'your@alueducation.com',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              // Password
              _label('Password'),
              const SizedBox(height: 8),
              _textField(
                controller: _passwordController,
                hint: '••••••••',
                obscure: true,
              ),

              const SizedBox(height: 24),

              // Role selector
              _label('I am a...'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _roleCard(
                    emoji: '🎓',
                    title: 'Student',
                    subtitle: 'Find internships',
                    value: 'student',
                  ),
                  const SizedBox(width: 12),
                  _roleCard(
                    emoji: '🚀',
                    title: 'Startup',
                    subtitle: 'Post opportunities',
                    value: 'startup',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFEF4444), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMessage!,
                            style: const TextStyle(
                                color: Color(0xFFEF4444), fontSize: 13)),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Register button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C47FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ',
                      style: TextStyle(color: Color(0xFF6B7280))),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Color(0xFF6C47FF),
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF7F7FB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF6C47FF), width: 2),
          ),
        ),
      );

  Widget _roleCard({
    required String emoji,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _role == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = value),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFF0EEFF)
                : const Color(0xFFF7F7FB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6C47FF)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isSelected
                        ? const Color(0xFF6C47FF)
                        : const Color(0xFF0F0F1A),
                  )),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280))),
            ],
          ),
        ),
      ),
    );
  }
}
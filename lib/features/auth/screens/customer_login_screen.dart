import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../map_discovery/screens/home_screen.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLogin = true;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();
      final phone = _phoneController.text.trim();
      final pass = _passController.text.trim();
      
      String? error;
      if (_isLogin) {
        error = await auth.signIn(phone, pass);
      } else {
        error = await auth.signUp(phone, pass);
      }
      
      if (error == null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
        );
      } else {
        setState(() => _errorMessage = error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isWeb = width > 900;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Liquid Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                    : [const Color(0xFFE0F7FA), const Color(0xFFE3F2FD)],
              ),
            ),
          ),

          // 2. Ambient Blobs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [AppColors.primary.withOpacity(0.15), Colors.transparent]
                      : [Colors.blue.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [const Color(0xFFFF9800).withOpacity(0.1), Colors.transparent]
                      : [Colors.orange.withOpacity(0.15), Colors.transparent],
                ),
              ),
            ),
          ),

          // 3. Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: isWeb
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Web Left Side (Glass Branding)
                        Container(
                          width: 400,
                          height: 600,
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.shopping_bag_rounded, size: 80, color: Colors.white),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'Welcome to NEST',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.primary,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Discover local shops, amazing deals,\nand smart shopping insights.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        // Web Right Side (Glass Form)
                        _buildGlassForm(isDark, auth),
                      ],
                    )
                  : _buildGlassForm(isDark, auth),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassForm(bool isDark, AuthProvider auth) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (MediaQuery.of(context).size.width <= 900) ...[
                   Icon(Icons.shopping_bag_rounded, size: 60, color: AppColors.primary.withOpacity(0.9)),
                   const SizedBox(height: 24),
                ],
                Text(
                  _isLogin ? 'Welcome Back' : 'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? 'Login to continue shopping' : 'Start your smart shopping journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),

                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: isDark ? Colors.red[200] : Colors.red[700], fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: _glassInputDecoration('Phone Number', Icons.phone_android, isDark),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter phone number';
                    if (value.length < 10) return 'Please enter a valid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _passController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: _glassInputDecoration('Password', Icons.lock_outline, isDark).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter password';
                    if (!_isLogin) return auth.validatePassword(value);
                    return null;
                  },
                ),

                if (!_isLogin) ...[
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPassController,
                    obscureText: _obscureConfirmPassword,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: _glassInputDecoration('Confirm Password', Icons.lock_outline, isDark).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please confirm password';
                      if (value != _passController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 32),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _isLogin ? 'Login' : 'Sign Up',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _errorMessage = null;
                      _formKey.currentState?.reset();
                    });
                  },
                  child: RichText(
                    text: TextSpan(
                      text: _isLogin ? 'New to NEST? ' : 'Already have an account? ',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
                      children: [
                        TextSpan(
                          text: _isLogin ? 'Sign Up' : 'Login',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _glassInputDecoration(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
      prefixIcon: Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey[600]),
      filled: true,
      fillColor: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.5),
      ),
    );
  }
}

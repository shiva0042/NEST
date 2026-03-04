import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_colors.dart';
import '../../map_discovery/screens/home_screen.dart';
import 'customer_login_screen.dart';
import 'shop_login_screen.dart';
import '../../../screens/database_seed_screen.dart';
import '../../../core/widgets/theme_toggle_button.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && MediaQuery.of(context).size.width > 900) {
      return _WebRoleSelectionScreen();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: !kIsWeb ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DatabaseSeedScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.cloud_upload),
        label: const Text('Upload Data'),
      ) : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFE0F7FA), const Color(0xFFE3F2FD)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Animated Logo
                      const _FloatingLogo(),
                      const SizedBox(height: 32),
                      
                      // Welcome Text
                      Text(
                        'Welcome to',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Near Easy Shop Tracker',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1565C0),
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Choose your role to continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Customer Card
                      _ModernRoleCard(
                        title: "I'm a Customer",
                        description: 'Find shops, check stock, and discover amazing deals nearby.',
                        icon: Icons.shopping_bag_outlined,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CustomerLoginScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Shop Owner Card
                      _ModernRoleCard(
                        title: "I'm a Shop Owner",
                        description: 'Manage inventory, post offers, and grow your business effortlessly.',
                        icon: Icons.store_outlined,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ShopLoginScreen()),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Footer text
                      Text(
                        'By continuing, you agree to our Terms & Privacy Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 20, // Adjusted padding for better fit
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const ThemeToggleButton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebRoleSelectionScreen extends StatelessWidget {
  const _WebRoleSelectionScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            top: -150,
            left: -150,
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
          Row(
            children: [
              // Left Panel - Branding
              Expanded(
                flex: 5,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _FloatingLogo(),
                      const SizedBox(height: 48),
                      Text(
                        'NEST',
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: -2,
                          shadows: [
                            Shadow(
                              color: AppColors.primary.withOpacity(0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Near Easy Shop Tracker',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Features Pill (Glassy)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green[400], size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Local Discovery',
                                  style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 24),
                                Icon(Icons.check_circle, color: Colors.green[400], size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Live Inventory',
                                  style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 24),
                                Icon(Icons.check_circle, color: Colors.green[400], size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Smart Shopping',
                                  style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Right Panel - Liquid Glass Pane
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.6),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.4),
                              isDark ? Colors.white.withOpacity(0.01) : Colors.white.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                               crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Get Started',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.text,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Choose how you want to use NEST',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 60),
                                
                                _WebRoleCard(
                                  title: "I'm a Customer",
                                  description: 'Browse shops, compare prices, and order essentials.',
                                  icon: Icons.shopping_basket_outlined,
                                  color: const Color(0xFFFF9800),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const CustomerLoginScreen()),
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                _WebRoleCard(
                                  title: "I'm a Shop Owner",
                                  description: 'Register your shop, manage stock, and reach more customers.',
                                  icon: Icons.storefront_outlined,
                                  color: const Color(0xFF4CAF50),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const ShopLoginScreen()),
                                    );
                                  },
                                ),
                                
                                const SizedBox(height: 40),
                                Center(
                                  child: Text(
                                    '© 2026 Near Easy Shop Tracker. All rights reserved.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Theme Toggle
          Positioned(
            top: 24,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const ThemeToggleButton(),
            ),
          ),
        ],
      ),
);
  }
}

class _WebRoleCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _WebRoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_WebRoleCard> createState() => _WebRoleCardState();
}

class _WebRoleCardState extends State<_WebRoleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.6) : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isHovered 
                      ? widget.color 
                      : (isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.6)),
                  width: 2,
                ),
                gradient: LinearGradient(
                  colors: isDark 
                      ? [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.0)]
                      : [Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(_isHovered ? 0.15 : 0),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: widget.color.withOpacity(0.2)),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 32),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: _isHovered ? widget.color : (isDark ? Colors.white54 : Colors.black26),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernRoleCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ModernRoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_ModernRoleCard> createState() => _ModernRoleCardState();
}

class _ModernRoleCardState extends State<_ModernRoleCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extract base color from gradient for icon/text usage
    final Color baseColor = widget.gradient.colors.first;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withOpacity(0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            // Glassy Icon Container
                            gradient: LinearGradient(
                              colors: [
                                baseColor.withOpacity(0.8),
                                widget.gradient.colors.last.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: baseColor.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
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

class _FloatingLogo extends StatefulWidget {
  const _FloatingLogo();

  @override
  State<_FloatingLogo> createState() => _FloatingLogoState();
}

class _FloatingLogoState extends State<_FloatingLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _rotateAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        height: 250,
        width: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Theme.of(context).cardColor : Colors.white,
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, 
            width: 3
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Theme.dart';
import '../provider/admin_auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();

    // Delay initialization to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuth();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeAuth() async {
    final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);

    try {
      print('=== SPLASH SCREEN INIT ===');
      print('Starting authentication initialization...');

      // Add a timeout to prevent infinite loading
      await Future.wait([
        authProvider.initializeAuth().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('Auth initialization timed out');
            throw Exception('Authentication initialization timed out');
          },
        ),
        Future.delayed(const Duration(milliseconds: 1500)), // Minimum 1.5 seconds
      ]);

      print('Auth initialization completed');
    } catch (e) {
      print('Auth initialization error: $e');
      // If initialization fails, assume unauthenticated
      if (mounted) {
        authProvider.clearError();
        // Force set to unauthenticated state to show login
        authProvider.logout();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withValues(alpha: 0.8),
              AppTheme.primaryColor.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Consumer<AdminAuthProvider>(
                builder: (context, authProvider, child) {
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          // Logo
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.admin_panel_settings,
                              size: 60,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // App Title
                          Text(
                            'Aripsalin Admin Dashboard',
                            style: AppTheme.headingLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          Text(
                            'Management System',
                            style: AppTheme.bodyLarge.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 48),
                          
                          // Loading Indicator
                          if (authProvider.status == AuthStatus.loading ||
                              authProvider.status == AuthStatus.unknown)
                            Column(
                              children: [
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _getLoadingMessage(authProvider.status),
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          
                          // Error Message
                          if (authProvider.errorMessage != null)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 32),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          authProvider.errorMessage!,
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () {
                                      authProvider.clearError();
                                      authProvider.logout(); // Force to login screen
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: const Text('Go to Login'),
                                  ),
                                ],
                              ),
                            ),

                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Manual skip button (for debugging)
            Consumer<AdminAuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.status == AuthStatus.loading ||
                    authProvider.status == AuthStatus.unknown) {
                  return Positioned(
                    bottom: 50,
                    right: 20,
                    child: TextButton(
                      onPressed: () {
                        print('Manual skip to login pressed');
                        authProvider.logout(); // Force to login screen
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withValues(alpha: 0.7),
                      ),
                      child: const Text('Skip to Login'),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getLoadingMessage(AuthStatus status) {
    switch (status) {
      case AuthStatus.unknown:
        return 'Initializing...';
      case AuthStatus.loading:
        return 'Checking authentication...';
      default:
        return 'Loading...';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../utils/constants.dart';

/// AuthScreen - Main authentication screen with login options
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),

                  // Logo / App Name
                  Icon(
                    Icons.shopping_bag,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    'Sign in to continue shopping',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Error Message
                  if (authProvider.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: AppConstants.spacingSm),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => authProvider.clearError(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                  ],

                  // Email Sign In
                  FilledButton.icon(
                    onPressed: () => context.push('/auth/email'),
                    icon: const Icon(Icons.email),
                    label: const Text('Continue with Email'),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Google Sign In
                  OutlinedButton.icon(
                    onPressed: () => _signInWithGoogle(context),
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text('Continue with Google'),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Biometric Sign In
                  if (authProvider.biometricAvailable) ...[
                    OutlinedButton.icon(
                      onPressed: () => _signInWithBiometric(context),
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Sign in with Biometrics'),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                  ],

                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
                        child: Text('or'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Guest Checkout
                  TextButton(
                    onPressed: () => _continueAsGuest(context),
                    child: const Text('Continue as Guest'),
                  ),

                  const SizedBox(height: AppConstants.spacingLg),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: () => context.push('/auth/email?signup=true'),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _signInWithGoogle(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();
    if (success && context.mounted) {
      context.go('/');
    }
  }

  void _signInWithBiometric(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithBiometric();
    if (success && context.mounted) {
      context.go('/');
    }
  }

  void _continueAsGuest(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.continueAsGuest();
    if (success && context.mounted) {
      context.go('/');
    }
  }
}

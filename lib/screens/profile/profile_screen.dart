import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../services/services.dart';
import '../../utils/constants.dart';

/// ProfileScreen - User profile with menu options
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (!authProvider.isAuthenticated) {
            return _UnauthenticatedView();
          }

          return ListView(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            children: [
              // User Header
              _UserHeader(
                displayName: authProvider.currentUser?.displayName ?? 'User',
                email: authProvider.currentUser?.email ?? '',
                photoUrl: authProvider.currentUser?.photoURL,
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // Profile Menu
              _MenuSection(
                title: 'Account',
                items: [
                  _MenuItem(
                    icon: Icons.person_outline,
                    label: 'Edit Profile',
                    onTap: () => context.push('/profile/edit'),
                  ),
                  _MenuItem(
                    icon: Icons.location_on_outlined,
                    label: 'Address Book',
                    onTap: () => context.push('/profile/addresses'),
                  ),
                  _MenuItem(
                    icon: Icons.payment_outlined,
                    label: 'Payment Methods',
                    onTap: () => context.push('/profile/payment-methods'),
                  ),
                  _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Order History',
                    onTap: () => context.push('/profile/orders'),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),

              _MenuSection(
                title: 'Settings',
                items: [
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () => _showComingSoon(context),
                  ),
                  _MenuItem(
                    icon: Icons.fingerprint,
                    label: 'Biometric Authentication',
                    onTap: () => _showComingSoon(context),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),

              _MenuSection(
                title: 'Developer',
                items: [
                  _MenuItem(
                    icon: Icons.bug_report_outlined,
                    label: 'Force Crash',
                    onTap: () => _showCrashDialog(context),
                    textColor: Theme.of(context).colorScheme.error,
                  ),
                  _MenuItem(
                    icon: Icons.network_check,
                    label: 'Network Debug',
                    onTap: () => _showComingSoon(context),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),

              _MenuSection(
                title: 'Support',
                items: [
                  _MenuItem(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () => _showComingSoon(context),
                  ),
                  _MenuItem(
                    icon: Icons.policy_outlined,
                    label: 'Terms & Privacy',
                    onTap: () => _showComingSoon(context),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // Sign Out Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _signOut(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // App Version
              Center(
                child: Text(
                  'Version ${AppConstants.appVersion}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }

  void _showCrashDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Force Crash'),
        content: const Text(
          'This will crash the app to test Embrace crash reporting. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              EmbraceService.shared.forceEmbraceCrash();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Crash'),
          ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _UnauthenticatedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'Sign in to access your profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            const Text(
              'Track orders, save addresses, and more',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.push('/auth'),
                child: const Text('Sign In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String? photoUrl;

  const _UserHeader({
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
              child: photoUrl == null
                  ? Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                      style: Theme.of(context).textTheme.headlineMedium,
                    )
                  : null,
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingSm,
            vertical: AppConstants.spacingXs,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (index < items.length - 1)
                    const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(label, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

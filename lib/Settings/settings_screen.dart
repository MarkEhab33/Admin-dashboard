import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Theme.dart';
import '../l10n/app_localizations.dart';
import '../provider/locale_provider.dart';
import '../provider/admin_auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFF),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.settings,
                style: AppTheme.headingLarge,
              ),
              const SizedBox(height: 32),
              _buildAdminManagementSection(context, localizations),
              const SizedBox(height: 24),
              _buildLanguageSection(context, localizations, localeProvider),
              const SizedBox(height: 24),
              _buildAppInfoSection(context, localizations),
              const SizedBox(height: 24), // Extra padding at bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminManagementSection(BuildContext context, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Admin Management',
                style: AppTheme.headingMedium,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Current Admin Info
          Consumer<AdminAuthProvider>(
            builder: (context, authProvider, child) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Admin',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          authProvider.adminName ?? 'Administrator',
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.alternate_email,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          authProvider.adminUsername ?? 'admin',
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          authProvider.adminRole?.replaceAll('_', ' ').toUpperCase() ?? 'SUPER ADMIN',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Register New Admin Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showRegisterAdminDialog(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Register New Admin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, AppLocalizations localizations, LocaleProvider localeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.language,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                localizations.language,
                style: AppTheme.headingMedium,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLanguageOption(
            context,
            localizations.arabic,
            'ar',
            Icons.translate,
            localeProvider.isArabic,
            () => localeProvider.setLocale(const Locale('ar')),
          ),
          const SizedBox(height: 12),
          _buildLanguageOption(
            context,
            localizations.english,
            'en',
            Icons.language,
            localeProvider.isEnglish,
            () => localeProvider.setLocale(const Locale('en')),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String title,
    String languageCode,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTheme.bodyLarge.copyWith(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'معلومات التطبيق',
                style: AppTheme.headingMedium,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('الإصدار', '1.0.0'),
          const SizedBox(height: 12),
          _buildInfoRow('المطور', 'Aripsalin Team'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showRegisterAdminDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    String selectedRole = 'admin';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.person_add,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text('Register New Admin'),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter admin full name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter username',
                    prefixIcon: Icon(Icons.alternate_email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.security),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _registerAdmin(
                context,
                nameController.text,
                usernameController.text,
                passwordController.text,
                selectedRole,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registerAdmin(
    BuildContext context,
    String name,
    String username,
    String password,
    String role,
  ) async {
    if (name.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Call the register API
      final response = await _callRegisterAPI(name, username, password, role);

      // Close loading dialog
      Navigator.pop(context);

      if (response['success'] == true) {
        // Close register dialog
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Admin "${name}" registered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      // Close loading dialog if still open
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _callRegisterAPI(
    String name,
    String username,
    String password,
    String role,
  ) async {
    try {
      print('=== REGISTER ADMIN API CALL ===');
      print('Name: $name');
      print('Username: $username');
      print('Role: $role');

      // This would call your backend register endpoint
      // For now, return success to test the UI
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      return {
        'success': true,
        'message': 'Admin registered successfully',
      };
    } catch (e) {
      print('Register API error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}

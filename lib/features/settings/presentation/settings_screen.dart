import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/spendly_app_bar.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../navigation/presentation/main_navigation_shell.dart';

/// Settings screen for Spendly including theme toggle, user profile and logout action.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const SpendlyAppBar(
        title: 'Settings',
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingSm,
          ),
          children: [
            // User Profile Card
            AppCard(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (user?.displayName?.isNotEmpty == true
                                ? user!.displayName![0]
                                : (user?.email?.isNotEmpty == true
                                      ? user!.email![0]
                                      : 'U'))
                            .toUpperCase(),
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName?.isNotEmpty == true
                              ? user!.displayName!
                              : 'Spendly User',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                        Text(
                          user?.email ?? 'No email provided',
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingSm,
                      vertical: AppDimensions.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? AppColors.successContainerDark
                          : AppColors.successContainer,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                    ),
                    child: Text(
                      'Active',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: theme.brightness == Brightness.dark
                            ? AppColors.onSuccessContainerDark
                            : AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            // Appearance & Theme Section
            const SectionTitle(title: 'Appearance'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(AppDimensions.spacingSm),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        themeMode == ThemeMode.dark
                            ? Icons.dark_mode_rounded
                            : themeMode == ThemeMode.light
                                ? Icons.light_mode_rounded
                                : Icons.brightness_auto_rounded,
                        size: AppDimensions.iconSm,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: Text('Theme Mode', style: theme.textTheme.titleMedium),
                    subtitle: Text(
                      themeMode == ThemeMode.dark
                          ? 'Dark Mode'
                          : themeMode == ThemeMode.light
                              ? 'Light Mode'
                              : 'System Default',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<ThemeMode>(
                        value: themeMode,
                        dropdownColor: theme.cardColor,
                        icon: const Icon(Icons.arrow_drop_down_rounded),
                        onChanged: (mode) {
                          if (mode != null) {
                            ref
                                .read(themeModeProvider.notifier)
                                .setThemeMode(mode);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('System'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark'),
                          ),
                        ],
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingMd,
                      vertical: AppDimensions.spacingXs,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            // Preferences Section
            const SectionTitle(title: 'Preferences'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingTile(
                    context: context,
                    icon: Icons.attach_money_rounded,
                    title: 'Currency',
                    subtitle: 'Default: LKR (Rs.)',
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const Divider(indent: 56),
                  _buildSettingTile(
                    context: context,
                    icon: Icons.calendar_today_outlined,
                    title: 'Date Format',
                    subtitle: 'MMM d, y (e.g. Sep 27, 2026)',
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            // Cloud & Firebase Section
            const SectionTitle(title: 'Backend & Sync'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingTile(
                    context: context,
                    icon: Icons.lock_outline_rounded,
                    title: 'Firebase Authentication',
                    subtitle: user?.email != null
                        ? 'Logged in as ${user!.email}'
                        : 'Connected',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingSm,
                        vertical: AppDimensions.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? AppColors.successContainerDark
                            : AppColors.successContainer,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                      ),
                      child: Text(
                        'Connected',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: theme.brightness == Brightness.dark
                              ? AppColors.onSuccessContainerDark
                              : AppColors.success,
                        ),
                      ),
                    ),
                  ),
                  const Divider(indent: 56),
                  _buildSettingTile(
                    context: context,
                    icon: Icons.cloud_done_outlined,
                    title: 'Cloud Firestore',
                    subtitle: 'Storage Architecture Ready',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingSm,
                        vertical: AppDimensions.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                      ),
                      child: Text(
                        'Ready',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            // Account Actions / Logout Section
            const SectionTitle(title: 'Account'),
            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingSm),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? AppColors.errorContainerDark
                        : AppColors.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: AppDimensions.iconSm,
                    color: AppColors.error,
                  ),
                ),
                title: Text(
                  'Log Out',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Sign out of your Spendly account',
                  style: theme.textTheme.bodySmall,
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingXs,
                ),
                onTap: () => _confirmLogout(context, ref),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            // About Section
            const SectionTitle(title: 'About'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingTile(
                    context: context,
                    icon: Icons.info_outline_rounded,
                    title: 'App Name',
                    subtitle: AppConstants.appName,
                  ),
                  const Divider(indent: 56),
                  _buildSettingTile(
                    context: context,
                    icon: Icons.verified_outlined,
                    title: 'Version',
                    subtitle: AppConstants.appVersion,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXxl),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out of Spendly?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                ref.read(navigationIndexProvider.notifier).state = 0;
                await ref.read(authControllerProvider.notifier).logout();
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingSm),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: AppDimensions.iconSm, color: theme.colorScheme.primary),
      ),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingXs,
      ),
    );
  }
}

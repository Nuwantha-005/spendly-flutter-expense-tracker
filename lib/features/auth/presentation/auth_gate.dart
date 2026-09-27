import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../navigation/presentation/main_navigation_shell.dart';
import 'login_screen.dart';
import 'providers/auth_providers.dart';
import 'splash_screen.dart';

/// Entry boundary managing authentication state.
/// Routes to:
/// - SplashScreen while checking auth
/// - MainNavigationShell when authenticated
/// - LoginScreen when unauthenticated
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure active navigation tab always resets to Dashboard (0) on auth transitions
    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      if (previous?.value?.uid != next.value?.uid) {
        ref.read(navigationIndexProvider.notifier).state = 0;
      }
    });

    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const MainNavigationShell();
        }
        return const LoginScreen();
      },
      loading: () => const SplashScreen(),
      error: (error, _) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingXl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: AppDimensions.iconXl,
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  const Text(
                    'Authentication Error',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    error.toString(),
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  PrimaryButton(
                    label: 'Retry',
                    isFullWidth: false,
                    onPressed: () => ref.invalidate(authStateProvider),
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

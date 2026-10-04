import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../navigation/presentation/main_navigation_shell.dart';
import '../data/auth_service.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

/// Entry boundary managing authentication state.
/// Routes to:
/// - SplashScreen while checking auth
/// - MainNavigationShell when authenticated
/// - LoginScreen when unauthenticated
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();
  Key _streamKey = UniqueKey();

  void _retry() {
    setState(() {
      _streamKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      key: _streamKey,
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasError) {
          return Scaffold(
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
                        snapshot.error.toString(),
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.spacingLg),
                      PrimaryButton(
                        label: 'Retry',
                        isFullWidth: false,
                        onPressed: _retry,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          return const MainNavigationShell();
        }
        return const LoginScreen();
      },
    );
  }
}

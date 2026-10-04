import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import 'auth_exception_handler.dart';
import 'auth_service.dart';
import 'register_screen.dart';

/// Screen allowing existing users to log into Spendly with Email and Password.
/// Seamlessly supports Light and Dark modes.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.loginWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } catch (e) {
      final friendlyMessage = AuthExceptionHandler.getErrorMessage(e);
      if (mounted) {
        setState(() {
          _errorMessage = friendlyMessage;
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.onError,
                  size: AppDimensions.iconSm,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Text(
                    friendlyMessage,
                    style: const TextStyle(color: AppColors.onError),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingLg,
              vertical: AppDimensions.spacingLg,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Brand Header
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: theme.colorScheme.primary,
                        size: AppDimensions.iconLg,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),

                  Center(
                    child: Text(
                      AppConstants.appName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),

                  Center(
                    child: Text(
                      'Welcome back! Log in to continue.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),

                  // Error Banner (if any)
                  if (_errorMessage != null && !_isLoading) ...[
                    AppCard(
                      backgroundColor: theme.brightness == Brightness.dark
                          ? AppColors.errorContainerDark
                          : AppColors.errorContainer,
                      borderColor: AppColors.error.withValues(alpha: 0.4),
                      padding: const EdgeInsets.all(AppDimensions.spacingMd),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.error,
                            size: AppDimensions.iconMd,
                          ),
                          const SizedBox(width: AppDimensions.spacingSm),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.brightness == Brightness.dark
                                    ? AppColors.onErrorContainerDark
                                    : AppColors.onErrorContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                  ],

                  // Email Input Field
                  Text(
                    'Email Address',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    enabled: !_isLoading,
                    validator: _validateEmail,
                    decoration: const InputDecoration(
                      hintText: 'you@example.com',
                      prefixIcon: Icon(
                        Icons.mail_outline_rounded,
                        size: AppDimensions.iconSm,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),

                  // Password Input Field
                  Text(
                    'Password',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    enabled: !_isLoading,
                    validator: _validatePassword,
                    onFieldSubmitted: (_) => _handleLogin(),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        size: AppDimensions.iconSm,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: AppDimensions.iconSm,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),

                  // Login CTA Button
                  PrimaryButton(
                    label: 'Log In',
                    isLoading: !_isLoading ? false : true,
                    onPressed: _isLoading ? null : _handleLogin,
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),

                  // Register Navigation Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _errorMessage = null;
                                });
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                        child: const Text('Sign Up'),
                      ),
                    ],
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

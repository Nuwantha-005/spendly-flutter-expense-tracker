import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_exception_handler.dart';
import '../../data/auth_service.dart';

/// Provider exposing the centralized AuthService instance.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// StreamProvider listening to Firebase Authentication state changes.
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider exposing the currently authenticated User or null.
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value ?? ref.watch(authServiceProvider).currentUser;
});

/// StateNotifier controlling async auth actions (login, register, logout).
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._authService) : super(const AsyncData(null));

  final AuthService _authService;

  /// Logs in a user with email and password.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _authService.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      final friendlyMessage = AuthExceptionHandler.getErrorMessage(e);
      state = AsyncError(friendlyMessage, st);
      return false;
    }
  }

  /// Registers a new user with name, email, and password.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _authService.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      final friendlyMessage = AuthExceptionHandler.getErrorMessage(e);
      state = AsyncError(friendlyMessage, st);
      return false;
    }
  }

  /// Logs out the active user.
  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await _authService.logout();
      state = const AsyncData(null);
    } catch (e, st) {
      final friendlyMessage = AuthExceptionHandler.getErrorMessage(e);
      state = AsyncError(friendlyMessage, st);
    }
  }

  /// Clears any pending error state.
  void clearError() {
    state = const AsyncData(null);
  }
}

/// Provider exposing the AuthController.
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});

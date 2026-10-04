import 'package:firebase_auth/firebase_auth.dart';

/// Helper utility for converting Firebase Authentication error codes
/// into user-friendly messages for Spendly.
class AuthExceptionHandler {
  AuthExceptionHandler._();

  /// Converts a Firebase or generic error into a clear, readable string.
  static String getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'invalid-email':
          return 'The email address format is not valid.';
        case 'operation-not-allowed':
          return 'Email and password accounts are not enabled. Please contact support.';
        case 'weak-password':
          return 'The password is too weak. Please use at least 6 characters.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'user-not-found':
          return 'No account found with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please double check and try again.';
        case 'invalid-credential':
          return 'Invalid email or password. Please verify your credentials.';
        case 'too-many-requests':
          return 'Too many unsuccessful attempts. Please wait a few moments and try again.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection and try again.';
        case 'requires-recent-login':
          return 'This operation is sensitive and requires recent authentication. Please log in again.';
        case 'channel-error':
          return 'Please fill in all required fields.';
        case 'internal-error':
          final msg = (error.message ?? '').toLowerCase();
          if (msg.contains('unexpected end of stream') ||
              msg.contains('network') ||
              msg.contains('socket') ||
              msg.contains('connection')) {
            return 'Network connection error. Please verify internet connectivity and try again.';
          }
          return 'Service temporarily unavailable. Please try again.';
        default:
          final msg = (error.message ?? '').toLowerCase();
          if (msg.contains('unexpected end of stream') ||
              msg.contains('network') ||
              msg.contains('socket') ||
              msg.contains('connection') ||
              msg.contains('timeout')) {
            return 'Network connection error. Please verify internet connectivity and try again.';
          }
          return 'Authentication failed. Please verify your credentials and try again.';
      }
    }
    final msg = error.toString().toLowerCase();
    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('stream') ||
        msg.contains('timeout')) {
      return 'Network connection error. Please verify internet connectivity and try again.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper utility for converting Cloud Firestore error codes
/// into user-friendly messages for Spendly.
class FirestoreExceptionHandler {
  FirestoreExceptionHandler._();

  /// Converts a Firestore exception or generic error into a clear, readable message.
  static String getErrorMessage(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Permission denied. You can only view and manage your own expenses.';
        case 'unavailable':
          return 'Service temporarily unavailable. Please check your connection and try again.';
        case 'not-found':
          return 'The requested expense record was not found.';
        case 'already-exists':
          return 'This expense record already exists.';
        case 'deadline-exceeded':
          return 'Connection timed out. Please check your network and try again.';
        case 'cancelled':
          return 'The operation was cancelled.';
        case 'resource-exhausted':
          return 'Quota exceeded. Please try again later.';
        default:
          return 'A database error occurred. Please try again.';
      }
    }
    final msg = error.toString().toLowerCase();
    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('timeout')) {
      return 'Network connection error. Please verify your connection and try again.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}

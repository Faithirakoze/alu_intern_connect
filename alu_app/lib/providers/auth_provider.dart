import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// Single instance of AuthService used everywhere
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Watches Firebase auth state — tells us if user is logged in
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
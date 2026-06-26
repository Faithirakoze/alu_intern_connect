import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart';
import 'auth_repository.dart';

// Controller
class AuthController extends StateNotifier<AsyncValue<User?>> {
  final Ref ref;

  AuthController(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    final repo = ref.read(authRepositoryProvider);

    repo.authStateChanges().listen((user) {
      state = AsyncValue.data(user);
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = const AsyncValue.loading();

      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signIn(email, password);

      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      state = const AsyncValue.loading();

      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signUp(email, password);

      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    state = const AsyncValue.data(null);
  }
}


final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  return AuthController(ref);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.read(firebaseAuthProvider);
  return AuthRepository(auth);
});
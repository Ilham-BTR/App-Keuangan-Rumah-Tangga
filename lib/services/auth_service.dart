import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_client.dart';

/// Membungkus Supabase Auth (register, login, logout).
class AuthService {
  Session? get currentSession => supabase.auth.currentSession;
  User? get currentUser => supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String nama,
  }) async {
    await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'nama': nama},
    );
  }

  Future<void> signOut() => supabase.auth.signOut();
}

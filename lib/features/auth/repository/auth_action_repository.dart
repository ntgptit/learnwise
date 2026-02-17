abstract class AuthActionRepository {
  Future<void> login({required String email, required String password});

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signOut();
}

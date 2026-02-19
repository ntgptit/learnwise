abstract class AuthActionRepository {
  Future<void> login({required String identifier, required String password});

  Future<void> register({
    required String email,
    String? username,
    required String password,
    required String displayName,
  });

  Future<void> signOut();
}

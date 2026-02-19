abstract class AuthActionRepository {
  Future<void> login({required String identifier, required String password});

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    String? username,
  });

  Future<void> signOut();
}

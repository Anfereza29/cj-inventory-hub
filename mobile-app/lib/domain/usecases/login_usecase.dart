import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<bool> execute(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw Exception("Username and password cannot be empty.");
    }
    return await repository.login(username, password);
  }
}
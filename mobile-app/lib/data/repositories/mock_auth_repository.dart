import 'dart:async';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<bool> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate success/failure condition
    if (username == "user@test.com" && password == "password123") {
      return true;
    } else {
      return false;
    }
  }
}
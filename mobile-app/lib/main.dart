// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/mock_auth_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'presentation/viewmodels/login_viewmodel.dart';
import 'presentation/views/login_page.dart';

void main() {
  // Dependency Injection Assembly
  final authRepository = MockAuthRepository();
  final loginUseCase = LoginUseCase(authRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(loginUseCase),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MVVM Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}
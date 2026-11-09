import 'package:flutter/material.dart';
import 'package:inventory_manager/presentation/views/material_form_page.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/mock_material_repository.dart';
import '../../domain/usecases/get_materials_usecase.dart';
import '../../domain/usecases/submit_form_usecase.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/material_form_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo Placeholder
                  const FlutterLogo(size: 100),
                  const SizedBox(height: 32),

                  // Feedback / Error Message UI
                  if (viewModel.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (viewModel.isSuccess) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            "Login successful!",
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Username Field
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Email or Username",
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              // 1. Trigger the login action asynchronously
                              await viewModel.login(
                                _usernameController.text,
                                _passwordController.text,
                              );

                              // 2. Guard against the async gap immediately before using context
                              if (!context.mounted) return;

                              // 3. Check success and navigate safely
                              if (viewModel.isSuccess) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MultiProvider(
                                      providers: [
                                        ChangeNotifierProvider(
                                          create: (_) => MaterialFormViewModel(
                                            GetMaterialsUseCase(MockMaterialRepository()),
                                            SubmitFormUseCase(MockMaterialRepository()),
                                          ),
                                        ),
                                      ],
                                      child: const MaterialFormPage(),
                                    ),
                                  ),
                                );
                              }
                            },
                      child: viewModel.isLoading
                          ? const CircularProgressIndicator()
                          : const Text("Submit"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
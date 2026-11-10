import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/material_form_viewmodel.dart';
import 'login_page.dart'; // To handle logout navigation back to login

class MaterialFormPage extends StatefulWidget {
  const MaterialFormPage({super.key});

  @override
  State<MaterialFormPage> createState() => _MaterialFormPageState();
}

class _MaterialFormPageState extends State<MaterialFormPage> {
  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _logout(BuildContext context) {
    // Navigate back to Login and remove route history
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MaterialFormViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Material Dashboard"),
        actions: [
          // Nav Bar Logout Option
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Feedback Messages
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

                if (viewModel.successMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            viewModel.successMessage!,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Dropdown Label & Field loaded from config
                const Text(
                  "Material",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                viewModel.isLoadingMaterials
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                        value: viewModel.selectedMaterialId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: viewModel.materials.map((material) {
                          return DropdownMenuItem(
                            value: material.id,
                            child: Text(material.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          viewModel.setSelectedMaterial(value);
                        },
                      ),
                const SizedBox(height: 24),

                // Number Field with label "Cantidad"
                const Text(
                  "Cantidad",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: "Enter quantity",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: viewModel.isSubmitting
                        ? null
                        : () {
                            viewModel.submitForm(_quantityController.text);
                          },
                    child: viewModel.isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Submit Form"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
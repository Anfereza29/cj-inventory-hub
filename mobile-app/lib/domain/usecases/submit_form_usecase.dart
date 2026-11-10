import '../repositories/material_repository.dart';

class SubmitFormUseCase {
  final MaterialRepository repository;

  SubmitFormUseCase(this.repository);

  Future<bool> execute(String? materialId, String quantityStr) async {
    if (materialId == null || materialId.isEmpty) {
      throw Exception("Please select a material.");
    }
    
    final quantity = double.tryParse(quantityStr);
    if (quantity == null) {
      throw Exception("Please enter a valid number for Cantidad.");
    }

    return await repository.submitMaterialForm(materialId, quantity);
  }
}
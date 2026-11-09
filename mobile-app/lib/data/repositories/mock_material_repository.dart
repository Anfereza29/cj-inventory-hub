import 'dart:core';
import '../../domain/models/material_item.dart';
import '../../domain/repositories/material_repository.dart';

class MockMaterialRepository implements MaterialRepository {
  // Simulating a local configuration file data source (e.g., JSON config)
  final List _mockConfigFile = [
    {"id": "mat_1", "name": "Leather (Cowhide)"},
    {"id": "mat_2", "name": "Canvas Fabric"},
    {"id": "mat_3", "name": "Brass Buckles"},
    {"id": "mat_4", "name": "Nylon Thread"},
  ];
  
  @override
  Future<List<MaterialItem>> getMaterials() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate config read delay
    return _mockConfigFile.map((json) => MaterialItem.fromJson(json)).toList();
  }

  @override
  Future<bool> submitMaterialForm(String materialId, double quantity) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network submit delay

    // Simulate success/fail condition (e.g., fail if quantity is <= 0 or extreme)
    if (quantity > 0 && quantity < 1000) {
      return true; // Success response
    } else {
      return false; // Fail response
    }
  }
}
import '../models/material_item.dart';

abstract class MaterialRepository {
  Future<List<MaterialItem>> getMaterials();
  Future<bool> submitMaterialForm(String materialId, double quantity);
}
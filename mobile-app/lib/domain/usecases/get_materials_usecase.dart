import '../models/material_item.dart';
import '../repositories/material_repository.dart';

class GetMaterialsUseCase {
  final MaterialRepository repository;

  GetMaterialsUseCase(this.repository);

  Future<List<MaterialItem>> execute() async {
    return await repository.getMaterials();
  }
}
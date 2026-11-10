import 'package:flutter/foundation.dart';
import '../../domain/models/material_item.dart';
import '../../domain/usecases/get_materials_usecase.dart';
import '../../domain/usecases/submit_form_usecase.dart';

class MaterialFormViewModel extends ChangeNotifier {
  final GetMaterialsUseCase _getMaterialsUseCase;
  final SubmitFormUseCase _submitFormUseCase;

  MaterialFormViewModel(this._getMaterialsUseCase, this._submitFormUseCase) {
    loadMaterials();
  }

  List<MaterialItem> _materials = [];
  List<MaterialItem> get materials => _materials;

  String? _selectedMaterialId;
  String? get selectedMaterialId => _selectedMaterialId;

  bool _isLoadingMaterials = false;
  bool get isLoadingMaterials => _isLoadingMaterials;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  Future<void> loadMaterials() async {
    _isLoadingMaterials = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _materials = await _getMaterialsUseCase.execute();
      if (_materials.isNotEmpty) {
        _selectedMaterialId = _materials.first.id;
      }
    } catch (e) {
      _errorMessage = "Failed to load materials config: ${e.toString()}";
    } finally {
      _isLoadingMaterials = false;
      notifyListeners();
    }
  }

  void setSelectedMaterial(String? id) {
    _selectedMaterialId = id;
    notifyListeners();
  }

  Future<void> submitForm(String quantityText) async {
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final success = await _submitFormUseCase.execute(_selectedMaterialId, quantityText);
      if (success) {
        _successMessage = "Form submitted successfully!";
      } else {
        _errorMessage = "Submission failed. Invalid quantity range.";
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
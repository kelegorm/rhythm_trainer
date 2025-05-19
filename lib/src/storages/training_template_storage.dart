import 'package:rhythm_trainer/src/logic/training_template.dart';

class TrainingTemplateStorage {
  static final List<TrainingTemplate> _templates = [
    TrainingTemplate(id: 1, label: 'Half and Quarters'),
    TrainingTemplate(id: 2, label: 'Quarters Focus'),
    TrainingTemplate(id: 3, label: 'Quarter–Eighth Groove'),
    TrainingTemplate(id: 4, label: 'Sixteenths Rush'),
    TrainingTemplate(id: 5, label: 'Mixed Challenge'),
  ];

  List<TrainingTemplate> getAll() =>
      _templates.where((t) => t.isActive).toList();

  /// Throws state error if id is wrong.
  TrainingTemplate getById(int id) {
    return _templates.firstWhere(
      (t) => t.isActive && t.id == id,
    );
  }
}
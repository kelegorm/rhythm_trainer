class TrainingTemplate {
  final int id;
  final String label;
  /// MArk for soft deleting.
  final bool isActive;

  TrainingTemplate({
    required this.id,
    required this.label,
    this.isActive = true,
  });
}
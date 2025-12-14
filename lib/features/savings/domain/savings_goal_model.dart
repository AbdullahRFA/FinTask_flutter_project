class SavingsGoalModel {
  final String id;
  final String title;
  final double targetAmount;
  final double currentSaved;
  final DateTime deadline;

  SavingsGoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentSaved,
    required this.deadline,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentSaved': currentSaved,
      'deadline': deadline.toIso8601String(),
    };
  }

  factory SavingsGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingsGoalModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      currentSaved: (map['currentSaved'] ?? 0).toDouble(),
      deadline: DateTime.parse(map['deadline']),
    );
  }
}
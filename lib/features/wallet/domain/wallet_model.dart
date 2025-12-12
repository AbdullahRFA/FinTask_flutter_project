class WalletModel {
  final String id;
  final String name;
  final double monthlyBudget;
  final double currentBalance; // This changes when we add expenses
  final int month;
  final int year;

  const WalletModel({
    required this.id,
    required this.name,
    required this.monthlyBudget,
    required this.currentBalance,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'monthlyBudget': monthlyBudget,
      'currentBalance': currentBalance,
      'month': month,
      'year': year,
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Main Wallet',
      // Firebase stores numbers as Integers sometimes.
      // We convert to Double to be safe for currency (e.g., 10.50)
      monthlyBudget: (map['monthlyBudget'] ?? 0).toDouble(),
      currentBalance: (map['currentBalance'] ?? 0).toDouble(),
      month: map['month'] ?? DateTime.now().month,
      year: map['year'] ?? DateTime.now().year,
    );
  }
}
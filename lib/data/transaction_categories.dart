class TransactionCategory {
  final String id;
  final String name;
  final String icon;
  final String type; // 'expense' or 'income'

  const TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
  });
}

class TransactionCategories {
  static const List<TransactionCategory> categories = [
    // Income Categories
    TransactionCategory(
      id: 'salary',
      name: 'Salary',
      icon: '💰',
      type: 'income',
    ),
    TransactionCategory(
      id: 'business',
      name: 'Business',
      icon: '💼',
      type: 'income',
    ),
    TransactionCategory(
      id: 'investments',
      name: 'Investments',
      icon: '📈',
      type: 'income',
    ),
    TransactionCategory(
      id: 'allowance',
      name: 'Allowance',
      icon: '🎁',
      type: 'income',
    ),

    // Expense Categories
    TransactionCategory(
      id: 'food',
      name: 'Food & Dining',
      icon: '🍽️',
      type: 'expense',
    ),
    TransactionCategory(
      id: 'transportation',
      name: 'Transportation',
      icon: '🚗',
      type: 'expense',
    ),
    TransactionCategory(
      id: 'utilities',
      name: 'Utilities',
      icon: '💡',
      type: 'expense',
    ),
    TransactionCategory(
      id: 'housing',
      name: 'Housing',
      icon: '🏠',
      type: 'expense',
    ),
    TransactionCategory(
      id: 'healthcare',
      name: 'Healthcare',
      icon: '🏥',
      type: 'expense',
    ),
    TransactionCategory(
      id: 'education',
      name: 'Education',
      icon: '📚',
      type: 'expense',
    ),
    TransactionCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: '🛍️',
      type: 'expense',
    ),
    TransactionCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: '🎮',
      type: 'expense',
    ),
    TransactionCategory(
      id: 'savings',
      name: 'Savings',
      icon: '🏦',
      type: 'expense',
    ),
    TransactionCategory(
      id: 'others',
      name: 'Others',
      icon: '📝',
      type: 'expense',
    ),
  ];

  static List<TransactionCategory> getByType(String type) {
    return categories.where((category) => category.type == type).toList();
  }

  static TransactionCategory? getById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}

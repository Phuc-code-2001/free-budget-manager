import 'category.dart';

class Expense {
  String name;
  double amount;
  DateTime date;
  Category category;

  Expense({
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
  });

  

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.toJson(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      name: json['name'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      category: Category.fromJson(json['category']),
    );
  }
  
  
  
}

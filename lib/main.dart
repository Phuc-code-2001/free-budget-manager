import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:free_budget/screens/catgory_screen.dart';
import 'package:free_budget/screens/expense_screen.dart';
import 'package:free_budget/screens/statistics_screen.dart';

import 'models/category.dart';
import 'models/expense.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<Category> defaultCategories = getCategoryList(prefs);
  List<Expense> defaultExpenses = getExpenseList(prefs);
  runApp(MyApp(
    defaultCategories: defaultCategories,
    defaultExpenses: defaultExpenses,
    prefs: prefs,
  ));
}

List<Category> getCategoryList(SharedPreferences prefs) {
  List<String>? categoryStrings = prefs.getStringList('categories');
  if (categoryStrings != null) {
    return categoryStrings.map((categoryString) {
      Map<String, dynamic> categoryMap = json.decode(categoryString);
      return Category.fromJson(categoryMap);
    }).toList();
  }
  return List.empty();
}

List<Expense> getExpenseList(SharedPreferences prefs) {
  List<String>? expenseStrings = prefs.getStringList('expenses');
  if (expenseStrings != null) {
    return expenseStrings.map((expenseString) {
      Map<String, dynamic> expenseMap = json.decode(expenseString);
      return Expense.fromJson(expenseMap);
    }).toList();
  }
  return List.empty();
}


class MyApp extends StatelessWidget {
  final List<Category> defaultCategories;
  final List<Expense> defaultExpenses;
  final SharedPreferences prefs;

  const MyApp({
    required this.defaultCategories,
    required this.defaultExpenses,
    required this.prefs,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: ExpenseManagerApp(
        defaultCategories: defaultCategories,
        defaultExpenses: defaultExpenses,
        prefs: prefs,
      ),
      // Các cài đặt khác cho ứng dụng
    );
  }
}


class ExpenseManagerApp extends StatelessWidget {

  final List<Category> defaultCategories;
  final List<Expense> defaultExpenses;
  final SharedPreferences prefs;

  const ExpenseManagerApp({
    required this.defaultCategories,
    required this.defaultExpenses,
    required this.prefs,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
      routes: {
        '/categories': (context) => CategoryScreen(
          categories: defaultCategories,
          prefs: prefs,
        ),
        '/expenses': (context) => ExpenseScreen(
          categories: defaultCategories,
          expenses: defaultExpenses,
          prefs: prefs,
        ),
        '/statistics': (context) => StatisticsScreen(expenses: defaultExpenses),
      },
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Manager'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Categories'),
              onPressed: () {
                Navigator.pushNamed(context, '/categories');
              },
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              child: const Text('Expenses'),
              onPressed: () {
                Navigator.pushNamed(context, '/expenses');
              },
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              child: const Text('Statistics'),
              onPressed: () {
                Navigator.pushNamed(context, '/statistics');
              },
            ),
          ],
        ),
      ),
    );
  }
}

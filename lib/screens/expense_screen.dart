import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/category.dart';

class ExpenseScreen extends StatefulWidget {
  final List<Category> categories;
  final List<Expense> expenses;
  final SharedPreferences prefs;

  const ExpenseScreen({
    required this.categories,
    required this.expenses,
    required this.prefs,
    Key? key,
  }) : super(key: key);

  @override
  ExpenseScreenState createState() => ExpenseScreenState();
}

class ExpenseScreenState extends State<ExpenseScreen> {
  List<Expense> expenses = [];
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    categories = widget.categories;
    expenses = widget.expenses;
    sortExpensesByDate();
  }

  @override
  void dispose() {
    super.dispose();
    saveExpenses();
  }

  void saveExpenses() {
    List<String> expenseStrings = expenses.map((expense) {
      return json.encode(expense.toJson());
    }).toList();
    widget.prefs.setStringList('expenses', expenseStrings);
  }

  void sortExpensesByDate() {
    expenses.sort((a, b) => b.date.compareTo(a.date));
  }

  List<DateTime> getUniqueDates() {
    List<DateTime> uniqueDates = [];
    for (Expense expense in expenses) {
      DateTime expenseDate =
          DateTime(expense.date.year, expense.date.month, expense.date.day);
      if (!uniqueDates.contains(expenseDate)) {
        uniqueDates.add(expenseDate);
      }
    }
    return uniqueDates;
  }

  List<Expense> getExpensesByDate(DateTime date) {
    return expenses
        .where((expense) =>
            DateTime(expense.date.year, expense.date.month, expense.date.day)
                .isAtSameMomentAs(date))
        .toList();
  }

  void showAddDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    Category selectedCategory = categories[0];
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Expense'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Details',
                    ),
                    keyboardType: TextInputType.multiline,
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 18),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 10),
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  DropdownButton<Category>(
                    value: selectedCategory,
                    onChanged: (Category? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    items: categories
                        .map<DropdownMenuItem<Category>>((Category category) {
                      return DropdownMenuItem<Category>(
                        value: category,
                        child: Row(
                          children: [
                            Text(category.iconText),
                            const SizedBox(width: 10),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    String name = nameController.text;
                    double? amount = double.tryParse(amountController.text);
                    Expense newExpense = Expense(
                      name: name,
                      amount: amount ?? 0,
                      date: selectedDate,
                      category: selectedCategory,
                    );

                    setState(() {
                      expenses.add(newExpense);
                      sortExpensesByDate();
                    });

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      setState(() {}); // Update the widget after returning from the dialog
    });
  }

  void showEditDialog(Expense expense) {
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    nameController.text = expense.name;
    amountController.text = expense.amount.toStringAsFixed(0);
    Category selectedCategory = expense.category;
    DateTime selectedDate = expense.date;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Expense'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Details',
                    ),
                    keyboardType: TextInputType.multiline,
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 18),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 10),
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  DropdownButton<int>(
                    value: max(categories.indexOf(selectedCategory), 0),
                    onChanged: (idx) {
                      if (idx != null) {
                        setState(() {
                          selectedCategory = categories[idx];
                        });
                      }
                    },
                    items: categories
                        .asMap()
                        .entries
                        .map<DropdownMenuItem<int>>((item) {
                      return DropdownMenuItem<int>(
                        value: item.key,
                        child: Row(
                          children: [
                            Text(item.value.iconText),
                            const SizedBox(width: 10),
                            Text(item.value.name),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    expense.name = nameController.text;
                    expense.amount =
                        double.tryParse(amountController.text) ?? 0;
                    expense.category = selectedCategory;
                    expense.date = selectedDate;

                    setState(() {
                      sortExpensesByDate();
                    });

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      setState(() {}); // Update the widget after returning from the dialog
    });
  }

  void showDeleteDialog(Expense expense) {
    // Hiển thị hộp thoại xác nhận xóa danh mục
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa mục này'),
        content: const Text('Bạn có chắc chắn muốn xóa mục này?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('Xóa'),
            onPressed: () {
              // Xóa danh mục và cập nhật giao diện
              deleteExpense(expense);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void deleteExpense(Expense expense) {
    setState(() {
      expenses.remove(expense);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: getUniqueDates().length,
          itemBuilder: (context, index) {
            DateTime date = getUniqueDates()[index];
            List<Expense> expensesByDate = getExpensesByDate(date);
            double totalAmount =
                expensesByDate.fold(0, (sum, expense) => sum + expense.amount);
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text(DateFormat('dd/MM/yyyy').format(date)),
                    trailing: Text("Total: ${totalAmount.toStringAsFixed(0)}"),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: expensesByDate.length,
                    itemBuilder: (context, index) {
                      Expense expense = expensesByDate[index];
                      return ListTile(
                        leading: Text(expense.category.iconText,
                            style: const TextStyle(fontSize: 16)),
                        title: Text(expense.category.name),
                        subtitle: Text(expense.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(expense.amount.toStringAsFixed(0)),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                showEditDialog(expense);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDeleteDialog(expense);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(), // Tạo đường ngăn cách giữa các ngày
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

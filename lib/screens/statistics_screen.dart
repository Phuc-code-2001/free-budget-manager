import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:free_budget/models/category.dart';

import '../models/expense.dart';

class StatisticsScreen extends StatefulWidget {

  final List<Expense> expenses;
  const StatisticsScreen({Key? key, required this.expenses}) : super(key: key);

  @override
  StatisticsScreenState createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {

  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  Future<void> pickDateRange() async {

    DateTimeRange? selectedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      currentDate: endDate,
    );

    if (selectedDateRange == null || selectedDateRange.duration.inDays <= 0) return;

    setState(() {
      startDate = selectedDateRange.start;
      endDate = selectedDateRange.end;
    });
  }

  double getTotalAmount(List<Expense> expenses) {
    return expenses.fold<double>(0, (total, exp) => total + exp.amount);
  }

  Map<Category, double> getCategoryStatistics(List<Expense> expenses) {
    Map<Category, double> result = {};
    for (Expense exp in expenses) {
      result.update(exp.category, (amount) => amount += exp.amount, ifAbsent: () => exp.amount);
    }
    return result;
  }

  List<MapEntry<Category, double>> getSortedCategoryStatistics(List<Expense> expenses) {
    final statistics = getCategoryStatistics(expenses);

    final result = statistics.entries.toList();
    result.sort((a, b) => b.value.compareTo(a.value));
    return result;
  }

  List<PieChartSectionData> getSectionDataSet(List<Expense> expenses) {

    final result = <PieChartSectionData>[];
    final generator = Random();
    Map<Category, double> categories = getCategoryStatistics(expenses);
    double total = getTotalAmount(expenses);

    for (Category category in categories.keys) {
      final genColor = Colors.primaries[generator.nextInt(Colors.primaries.length)];
      final percentage = categories[category]! / total * 100;
      final pieData = PieChartSectionData(
        value: categories[category],
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xffffffff),
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
        color: genColor,
        badgeWidget: _BadgeCategoryIcon(
          category.iconText,
          size: 40,
          borderColor: genColor,
        ),
        badgePositionPercentageOffset: .98,
      );

      result.add(pieData);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {

    List<Expense> filteredExpenses = widget.expenses.where((x) => x.date.compareTo(endDate) <= 0 && x.date.compareTo(startDate) >= 0).toList();
    final sections = getSectionDataSet(filteredExpenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(label: Text("${startDate.day}/${startDate.month}/${startDate.year}")),
                Chip(label: Text("${endDate.day}/${endDate.month}/${endDate.year}")),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    pickDateRange();
                  },
                  child: const Text('Select Date Range'),
                ),
              ],
            ),
            const Divider(
              thickness: 2,
            ),

            Row(
              children: getSortedCategoryStatistics(filteredExpenses)
              .map((i) => Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: Chip(
                  avatar: CircleAvatar(
                    backgroundColor: Colors.grey.shade800,
                    child: Text(i.key.iconText),
                  ),
                  label: Text(i.value.toStringAsFixed(1)),
                ),
              )).toList()
            ),

            const Divider(
              thickness: 2,
            ),
            Expanded(
              child: filteredExpenses.isEmpty ? const Text("No data.") : PieChart(
                PieChartData(
                  borderData: FlBorderData(
                    show: true,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: sections,
                ),
              ),
            ),
            
            
          ],
        ),
      ),
    );
  }
}

class _BadgeCategoryIcon extends StatelessWidget {
  const _BadgeCategoryIcon(
    this.iconText, {
    required this.size,
    required this.borderColor,
  });
  final String iconText;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: Text(iconText),
      ),
    );
  }
}
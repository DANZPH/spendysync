import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project/widget/chart.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  // Instance variables
  final SupabaseClient _supabase = Supabase.instance.client;

  // Data tracking variables
  Map<String, double> _incomeVsExpenses = {
    "Income": 0,
    "Expenses": 0,
  };
  Map<String, double> _frequencyCounts = {
    "Daily": 0,
    "Weekly": 0,
    "Monthly": 0,
    "Yearly": 0,
  };
  Map<String, double> _spendingData = {
    "Daily": 0,
    "Weekly": 0,
    "Monthly": 0,
    "Yearly": 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBudgetData();
  }

  // Data fetching method
  Future<void> _fetchBudgetData() async {
    try {
      setState(() => _isLoading = true);

      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        print("User not authenticated!");
        setState(() => _isLoading = false);
        return;
      }

      // Fetch budget data
      final budgetResponse = await _supabase
          .from('budgets')
          .select('amount, category, frequency')
          .eq('user_id', userId);

      // Fetch transaction data
      final transactionResponse = await _supabase
          .from('transactions')
          .select('amount, type')
          .eq('user_id', userId)
          .order('created_at');

      if (budgetResponse.isEmpty) {
        print("No budget data found!");
        setState(() => _isLoading = false);
        return;
      }

      // Process data
      final processedData =
          _processFinancialData(budgetResponse, transactionResponse);

      setState(() {
        _spendingData = processedData['categorySpending'];
        _frequencyCounts = processedData['frequencyCounts'];
        _incomeVsExpenses = processedData['incomeVsExpenses'];
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => _isLoading = false);
    }
  }

  // Data processing method
  Map<String, dynamic> _processFinancialData(
      List<dynamic> budgetResponse, List<dynamic> transactionResponse) {
    Map<String, double> categorySpending = {};
    Map<String, double> tempFrequencyCounts = {
      "Daily": 0,
      "Weekly": 0,
      "Monthly": 0,
      "Yearly": 0,
    };
    Map<String, double> tempIncomeVsExpenses = {
      "Income": 0,
      "Expenses": 0,
    };

    // Process budget data
    for (var row in budgetResponse) {
      String? category = row['category'];
      String? frequency = row['frequency'];
      double amount = (row['amount'] ?? 0).toDouble();

      if (category != null) {
        categorySpending[category] = (categorySpending[category] ?? 0) + amount;
      }

      if (frequency != null && tempFrequencyCounts.containsKey(frequency)) {
        tempFrequencyCounts[frequency] =
            (tempFrequencyCounts[frequency] ?? 0) + amount;
      }
    }

    // Process transaction data
    for (var transaction in transactionResponse) {
      final amount = transaction['amount'] as double;
      final type = transaction['type'] as String;

      if (type == 'income') {
        tempIncomeVsExpenses["Income"] =
            (tempIncomeVsExpenses["Income"] ?? 0) + amount;
      } else if (type == 'expense') {
        tempIncomeVsExpenses["Expenses"] =
            (tempIncomeVsExpenses["Expenses"] ?? 0) + amount.abs();
      }
    }

    // Calculate percentages for pie chart
    double total = tempFrequencyCounts.values.fold(0, (a, b) => a + b);
    if (total > 0) {
      tempFrequencyCounts.updateAll((key, value) => (value / total) * 100);
    }

    return {
      'categorySpending': categorySpending,
      'frequencyCounts': tempFrequencyCounts,
      'incomeVsExpenses': tempIncomeVsExpenses,
    };
  }

  // UI building methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212), // Dark background color
      body:
          _isLoading ? Center(child: CircularProgressIndicator()) : _getBody(),
    );
  }

  Widget _getBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAppBar(),
          const SizedBox(height: 10),
          _buildIncomeVsExpensesPieChart(),
          const SizedBox(height: 20),
          _buildPieChart(),
          const SizedBox(height: 20),
          _buildBarChart(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E), // Darker header color
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 10,
            blurRadius: 3,
          ),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 60, right: 20, left: 20, bottom: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Analytics",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: _fetchBudgetData,
              icon: const Icon(Icons.refresh,
                  color: Colors.white), // Change this line
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeVsExpensesPieChart() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Income vs Expenses",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 1080,
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: _incomeVsExpenses.entries.map((entry) {
                    return PieChartSectionData(
                      color: _getIncomeExpenseColor(entry.key),
                      value: entry.value,
                      title: "₱${entry.value.toStringAsFixed(1)}0",
                      radius: 65,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 1,
                  centerSpaceRadius: 20,
                  borderData: FlBorderData(show: false),
                  startDegreeOffset: 180,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildIncomeExpenseLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 10,
      children: _incomeVsExpenses.keys.map((key) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getIncomeExpenseColor(key),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              key,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPieChart() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "My Budget Frequency",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 1080,
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: _frequencyCounts.entries.map((entry) {
                    return PieChartSectionData(
                      color: _getColor(entry.key),
                      value: entry.value,
                      title: "${entry.value.toStringAsFixed(1)}%",
                      radius: 65,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 1,
                  centerSpaceRadius: 20,
                  borderData: FlBorderData(show: false),
                  startDegreeOffset: 180,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 10,
      children: _frequencyCounts.keys.map((key) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getColor(key),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              key,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBarChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Spending Per Category",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                barGroups: _spendingData.entries.map((entry) {
                  return BarChartGroupData(
                    x: _spendingData.keys.toList().indexOf(entry.key),
                    barRods: [
                      BarChartRodData(
                        fromY: 0,
                        toY: entry.value,
                        color: _getCategoryColor(entry.key),
                        width: 25,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "₱${value.toInt()}",
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  Colors.white), // Change text color to white
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < _spendingData.keys.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _spendingData.keys.elementAt(index),
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .white), // Change text color to white
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 0.8,
                      dashArray: [5, 5],
                    );
                  },
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        "${_spendingData.keys.elementAt(group.x)}\n₱${rod.toY.toStringAsFixed(2)}",
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Existing color methods
  Color _getColor(String frequency) {
    switch (frequency) {
      case "Daily":
        return Colors.blueAccent;
      case "Weekly":
        return Colors.greenAccent;
      case "Monthly":
        return Colors.orangeAccent;
      case "Yearly":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Color _getIncomeExpenseColor(String type) {
    switch (type) {
      case "Income":
        return Colors.green;
      case "Expenses":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getCategoryColor(String category) {
    Map<String, Color> categoryColors = {
      "Auto/Transpo": Colors.blueAccent,
      "Cash": Colors.green,
      "Bills": Colors.yellow,
      "Bank": Colors.orange,
      "Charity": Colors.purple,
      "Food Supply": Colors.redAccent,
      "Gift": Colors.indigo,
      "Travel": Colors.cyan,
      "Online\n Subscription": Colors.tealAccent,
      "Healthcare": Colors.pink,
      "School": Colors.brown,
      "Clothing": Colors.deepOrange,
      "Others": Colors.blueGrey,
    };

    return categoryColors[category] ?? Colors.grey;
  }
}

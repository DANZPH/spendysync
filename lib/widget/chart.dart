import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartWidgets {
  static Widget buildLineChart(
      Map<DateTime, double> incomeData, Map<DateTime, double> expenseData) {
    // Extract and sort unique dates
    final List<DateTime> dates =
        {...incomeData.keys, ...expenseData.keys}.toList()..sort();

    // Return empty container if no data
    if (dates.isEmpty) return Container();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartHeader(),
          const SizedBox(height: 20),
          _buildLineChartWidget(dates, incomeData, expenseData),
        ],
      ),
    );
  }

  static Widget _buildChartHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Income vs Expense Trend",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        _buildLegend(),
      ],
    );
  }

  static Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem(Colors.green, "Income"),
        const SizedBox(width: 12),
        _buildLegendItem(Colors.red, "Expense"),
      ],
    );
  }

  static Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  static Widget _buildLineChartWidget(List<DateTime> dates,
      Map<DateTime, double> incomeData, Map<DateTime, double> expenseData) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: _buildGridData(),
          titlesData: _buildTitlesData(dates),
          borderData: FlBorderData(show: false),
          lineBarsData: _buildLineBarsData(dates, incomeData, expenseData),
          lineTouchData: _buildLineTouchData(),
        ),
      ),
    );
  }

  // Extracted methods for chart configuration
  static FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 1000,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.grey.withOpacity(0.2),
          strokeWidth: 1,
          dashArray: [5, 5],
        );
      },
    );
  }

  static FlTitlesData _buildTitlesData(List<DateTime> dates) {
    return FlTitlesData(
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: _buildBottomTitles(dates),
    );
  }

  static AxisTitles _buildBottomTitles(List<DateTime> dates) {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: 1,
        getTitlesWidget: (value, meta) {
          if (value.toInt() >= 0 && value.toInt() < dates.length) {
            final date = dates[value.toInt()];
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "${date.day}/${date.month}",
                style: const TextStyle(fontSize: 10),
              ),
            );
          }
          return const Text('');
        },
      ),
    );
  }

  static List<LineChartBarData> _buildLineBarsData(List<DateTime> dates,
      Map<DateTime, double> incomeData, Map<DateTime, double> expenseData) {
    return [
      _buildLineChartBarData(dates, incomeData, Colors.green, 0),
      _buildLineChartBarData(dates, expenseData, Colors.red, 1),
    ];
  }

  static LineChartBarData _buildLineChartBarData(List<DateTime> dates,
      Map<DateTime, double> data, Color color, int barIndex) {
    return LineChartBarData(
      spots: dates.asMap().entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          data[entry.value]?.toDouble() ?? 0,
        );
      }).toList(),
      isCurved: true,
      color: color.withOpacity(0.7),
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
      ),
    );
  }

  static LineTouchData _buildLineTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        maxContentWidth: 100,
        rotateAngle: 0,
        fitInsideHorizontally: true,
        tooltipMargin: 8,
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.all(8),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final isIncome = spot.barIndex == 0;
            return LineTooltipItem(
              '${isIncome ? "Income" : "Expense"}\n₱${spot.y.toStringAsFixed(2)}',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList();
        },
      ),
    );
  }
}

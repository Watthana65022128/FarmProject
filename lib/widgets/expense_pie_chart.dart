import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpensePieChart extends StatefulWidget {
  final double managementExpense;
  final double productionExpense;

  const ExpensePieChart({
    super.key,
    required this.managementExpense,
    required this.productionExpense,
  });

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.managementExpense + widget.productionExpense;

    return Column(
      children: [
        Text(
          'สัดส่วนค่าใช้จ่าย',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        if (total == 0) ...[
          const SizedBox(
            height: 240,
            child: Center(
              child: Text(
                'ไม่มีข้อมูลรายจ่าย',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            height: 240,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Colors.orange,
                    value: widget.managementExpense,
                    title: '${((widget.managementExpense / total) * 100).toStringAsFixed(1)}%',
                    radius: touchedIndex == 0 ? 110 : 100,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.green,
                    value: widget.productionExpense,
                    title: '${((widget.productionExpense / total) * 100).toStringAsFixed(1)}%',
                    radius: touchedIndex == 1 ? 110 : 100,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            _buildIndicator(
              color: Colors.orange,
              text: 'ค่าจัดการและการดูแล',
            ),
            _buildIndicator(
              color: Colors.green,
              text: 'ค่าใช้จ่ายในการผลิต',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIndicator({
    required Color color,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
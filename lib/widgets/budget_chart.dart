import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/project_model.dart';
import '../utils/theme.dart';

class BudgetChart extends StatefulWidget {
  final List<ProjectModel> projects;

  const BudgetChart({super.key, required this.projects});

  @override
  State<BudgetChart> createState() => _BudgetChartState();
}

class _BudgetChartState extends State<BudgetChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final totalVotes = widget.projects.fold<int>(0, (sum, p) => sum + p.voteCount);

    if (totalVotes == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada suara',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chart akan muncul setelah ada warga yang memberikan suara',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 250,
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
                  centerSpaceRadius: 50,
                  sections: _showingSections(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: widget.projects.asMap().entries.map((entry) {
                final index = entry.key;
                final project = entry.value;
                return _LegendItem(
                  color: AppTheme.chartColors[index % AppTheme.chartColors.length],
                  text: project.title,
                  percentage: _getPercentage(project.voteCount, totalVotes),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Total Votes
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.how_to_vote,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total Suara: $totalVotes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _showingSections() {
    final totalVotes = widget.projects.fold<int>(0, (sum, p) => sum + p.voteCount);

    return widget.projects.asMap().entries.map((entry) {
      final index = entry.key;
      final project = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 20.0 : 14.0;
      final radius = isTouched ? 90.0 : 80.0;
      final percentage = _getPercentage(project.voteCount, totalVotes);

      return PieChartSectionData(
        color: AppTheme.chartColors[index % AppTheme.chartColors.length],
        value: project.voteCount.toDouble(),
        title: '$percentage%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(blurRadius: 2, color: Colors.black26)],
        ),
        badgeWidget: isTouched
            ? _Badge(
                project.title,
                size: 40,
                borderColor: AppTheme.chartColors[index % AppTheme.chartColors.length],
              )
            : null,
        badgePositionPercentageOffset: .98,
      );
    }).toList();
  }

  int _getPercentage(int votes, int total) {
    if (total == 0) return 0;
    return ((votes / total) * 100).round();
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  final int percentage;

  const _LegendItem({
    required this.color,
    required this.text,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
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
        Text(
          '$text ($percentage%)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final double size;
  final Color borderColor;

  const _Badge(
    this.text, {
    required this.size,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: borderColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

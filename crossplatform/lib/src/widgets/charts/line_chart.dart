import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../../theme/app_theme.dart';

class TagLineChart extends StatelessWidget {
  final List<TagDataPoint> data;
  final String title;
  final String? unit;
  final double? minY;
  final double? maxY;

  const TagLineChart({
    super.key,
    required this.data,
    required this.title,
    this.unit,
    this.minY,
    this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.darkTheme.cardColor,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart Header
            Row(
              children: [
                Text(
                  title,
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 8.0),
                  Text(
                    '($unit)',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
                const Spacer(),
                _buildStats(),
              ],
            ),
            const SizedBox(height: 16.0),

            // Chart
            SizedBox(
              height: 200.0,
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    if (data.isEmpty) return const SizedBox();

    final current = data.last.value;
    final min = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final max = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Row(
      children: [
        _buildStatItem('Текущ.', current),
        const SizedBox(width: 12.0),
        _buildStatItem('Мин.', min),
        const SizedBox(width: 12.0),
        _buildStatItem('Макс.', max),
      ],
    );
  }

  Widget _buildStatItem(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: Colors.white54,
          ),
        ),
        Text(
          value.toStringAsFixed(2),
          style: AppTheme.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Нет данных для отображения',
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.white54,
          ),
        ),
      );
    }

    final series = [
      charts.Series<TagDataPoint, DateTime>(
        id: 'TagValues',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(AppTheme.infoColor),
        domainFn: (TagDataPoint point, _) => point.timestamp,
        measureFn: (TagDataPoint point, _) => point.value,
        data: data,
      )
    ];

    return charts.TimeSeriesChart(
      series,
      animate: true,
      animationDuration: const Duration(milliseconds: 500),
      domainAxis: charts.DateTimeAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: charts.TextStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.white70),
          ),
          lineStyle: charts.LineStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.white30),
          ),
        ),
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.white70),
          ),
          lineStyle: charts.LineStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.white30),
          ),
        ),
        tickProviderSpec: const charts.BasicNumericTickProviderSpec(
          desiredMinTickCount: 4,
          desiredMaxTickCount: 8,
        ),
      ),
      behaviors: [
        charts.ChartTitle(
          '',
          titleStyleSpec: charts.TextStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.white),
          ),
        ),
        charts.PanAndZoomBehavior(),
        charts.LinePointHighlighter(
          symbolRenderer: CustomCircleSymbolRenderer(),
        ),
      ],
    );
  }
}

class CustomCircleSymbolRenderer extends charts.CircleSymbolRenderer {
  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int>? dashPattern,
      charts.Color? fillColor,
      charts.FillPatternType? fillPattern,
      charts.Color? strokeColor,
      double? strokeWidthPx}) {
    
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: charts.ColorUtil.fromDartColor(AppTheme.infoColor),
        strokeColor: charts.ColorUtil.fromDartColor(Colors.white),
        strokeWidthPx: 2.0);
  }
}

class TagDataPoint {
  final DateTime timestamp;
  final double value;
  final int quality;

  const TagDataPoint({
    required this.timestamp,
    required this.value,
    this.quality = 100,
  });
}

class GaugeChart extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final String title;
  final String unit;
  final Color color;

  const GaugeChart({
    super.key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.title,
    required this.unit,
    this.color = AppTheme.infoColor,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedValue = (value - minValue) / (maxValue - minValue);
    final percentage = (normalizedValue * 100).clamp(0.0, 100.0);

    return Card(
      color: AppTheme.darkTheme.cardColor,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: AppTheme.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 120.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white30,
                        width: 8.0,
                      ),
                    ),
                  ),
                  
                  // Progress arc
                  SizedBox(
                    width: 100.0,
                    height: 100.0,
                    child: CircularProgressIndicator(
                      value: normalizedValue,
                      strokeWidth: 8.0,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  
                  // Value display
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        unit,
                        style: AppTheme.caption.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            
            // Limits and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minValue.toStringAsFixed(1),
                  style: AppTheme.caption.copyWith(
                    color: Colors.white54,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: AppTheme.caption.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  maxValue.toStringAsFixed(1),
                  style: AppTheme.caption.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    final normalized = (value - minValue) / (maxValue - minValue);
    
    if (normalized < 0.1 || normalized > 0.9) {
      return AppTheme.criticalColor;
    } else if (normalized < 0.2 || normalized > 0.8) {
      return AppTheme.warningColor;
    }
    return AppTheme.normalColor;
  }

  String _getStatusText() {
    final normalized = (value - minValue) / (maxValue - minValue);
    
    if (normalized < 0.1 || normalized > 0.9) {
      return 'КРИТИЧЕСКИЙ';
    } else if (normalized < 0.2 || normalized > 0.8) {
      return 'ПРЕДУПРЕЖДЕНИЕ';
    }
    return 'НОРМА';
  }
}
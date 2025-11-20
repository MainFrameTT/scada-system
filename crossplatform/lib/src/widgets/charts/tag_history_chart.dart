import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../../models/tag.dart';
import '../../theme/app_theme.dart';

class TagHistoryChart extends StatefulWidget {
  final List<TagValue> historyData;
  final String tagName;
  final String unit;
  final double minValue;
  final double maxValue;
  final Color chartColor;
  final bool showPoints;
  final bool animate;

  const TagHistoryChart({
    super.key,
    required this.historyData,
    required this.tagName,
    required this.unit,
    required this.minValue,
    required this.maxValue,
    this.chartColor = AppTheme.infoColor,
    this.showPoints = true,
    this.animate = true,
  });

  @override
  State<TagHistoryChart> createState() => _TagHistoryChartState();
}

class _TagHistoryChartState extends State<TagHistoryChart> {
  charts.BehaviorPosition _legendPosition = charts.BehaviorPosition.bottom;
  charts.BehaviorPosition _titlePosition = charts.BehaviorPosition.top;
  bool _showLegend = true;

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
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 16.0),
            // Chart
            Expanded(
              child: _buildChart(),
            ),
            // Legend and Controls
            if (_showLegend) _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.tagName,
                style: AppTheme.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'История значений (${widget.historyData.length} точек)',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.white70),
          onSelected: _handleMenuSelected,
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'toggle_points',
              child: Text('Переключить точки'),
            ),
            const PopupMenuItem(
              value: 'toggle_legend',
              child: Text('Переключить легенду'),
            ),
            const PopupMenuItem(
              value: 'export_data',
              child: Text('Экспорт данных'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChart() {
    if (widget.historyData.isEmpty) {
      return _buildEmptyState();
    }

    final series = [
      charts.Series<TagValue, DateTime>(
        id: widget.tagName,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(widget.chartColor),
        domainFn: (TagValue value, _) => value.timestamp,
        measureFn: (TagValue value, _) => value.value,
        data: widget.historyData,
      )..setAttribute(charts.rendererIdKey, 'customLine'),
    ];

    return charts.TimeSeriesChart(
      series,
      animate: widget.animate,
      defaultRenderer: charts.LineRendererConfig(
        includePoints: widget.showPoints,
        strokeWidthPx: 2.0,
        radiusPx: 3.0,
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(
          zeroBound: false,
          desiredMinTickCount: 5,
          desiredMaxTickCount: 8,
        ),
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.white70),
            fontSize: 12,
          ),
          lineStyle: charts.LineStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.white30),
          ),
        ),
        tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
          (value) => '${value.toStringAsFixed(1)} ${widget.unit}',
        ),
      ),
      domainAxis: charts.DateTimeAxisSpec(
        tickProviderSpec: charts.DayTickProviderSpec(
          increments: [1],
        ),
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.white70),
            fontSize: 12,
          ),
          lineStyle: charts.LineStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.white30),
          ),
        ),
        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
          day: charts.TimeFormatterSpec(
            format: 'dd/MM',
            transitionFormat: 'dd/MM HH:mm',
          ),
        ),
      ),
      behaviors: [
        if (_showLegend)
          charts.SeriesLegend(
            position: _legendPosition,
            desiredMaxRows: 1,
            outsideJustification: charts.OutsideJustification.start,
            cellPadding: EdgeInsets.zero,
            showMeasures: true,
            measureFormatter: (num? value) {
              if (value == null) return '';
              return '${value.toStringAsFixed(2)} ${widget.unit}';
            },
          ),
        charts.ChartTitle(
          'Значение (${widget.unit})',
          behaviorPosition: _titlePosition,
          titleStyleSpec: charts.TextStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.white),
            fontSize: 12,
          ),
        ),
        charts.PanAndZoomBehavior(),
        charts.SelectNearest(
          eventTrigger: charts.SelectionTrigger.tapAndDrag,
        ),
        charts.LinePointHighlighter(
          showHorizontalFollowLine: charts.LinePointHighlighterFollowLineType.all,
          showVerticalFollowLine: charts.LinePointHighlighterFollowLineType.all,
        ),
      ],
    );
  }

  Widget _buildLegend() {
    if (widget.historyData.isEmpty) return const SizedBox();

    final latestValue = widget.historyData.last;
    final minVal = widget.historyData.map((v) => v.value).reduce((a, b) => a < b ? a : b);
    final maxVal = widget.historyData.map((v) => v.value).reduce((a, b) => a > b ? a : b);
    final avgVal = widget.historyData.map((v) => v.value).reduce((a, b) => a + b) / widget.historyData.length;

    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('Текущее', '${latestValue.value.toStringAsFixed(2)} ${widget.unit}'),
          _buildLegendItem('Мин', '${minVal.toStringAsFixed(2)} ${widget.unit}'),
          _buildLegendItem('Макс', '${maxVal.toStringAsFixed(2)} ${widget.unit}'),
          _buildLegendItem('Среднее', '${avgVal.toStringAsFixed(2)} ${widget.unit}'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: AppTheme.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart_outlined,
            size: 48.0,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16.0),
          Text(
            'Нет данных для графика',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Исторические данные появятся со временем',
            style: AppTheme.caption.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleMenuSelected(String value) {
    switch (value) {
      case 'toggle_points':
        setState(() {
          // Toggle points - would need to rebuild with different renderer
        });
        break;
      case 'toggle_legend':
        setState(() {
          _showLegend = !_showLegend;
        });
        break;
      case 'export_data':
        _exportChartData();
        break;
    }
  }

  void _exportChartData() {
    // Implementation for exporting chart data
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Экспорт данных'),
        content: const Text('Функция экспорта данных будет реализована в будущем'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class MultiTagChart extends StatelessWidget {
  final Map<String, List<TagValue>> tagHistories;
  final Map<String, Color> tagColors;

  const MultiTagChart({
    super.key,
    required this.tagHistories,
    required this.tagColors,
  });

  @override
  Widget build(BuildContext context) {
    final seriesList = tagHistories.entries.map((entry) {
      final tagName = entry.key;
      final history = entry.value;
      final color = tagColors[tagName] ?? AppTheme.infoColor;

      return charts.Series<TagValue, DateTime>(
        id: tagName,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(color),
        domainFn: (TagValue value, _) => value.timestamp,
        measureFn: (TagValue value, _) => value.value,
        data: history,
      );
    }).toList();

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
              'Сравнение тегов',
              style: AppTheme.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: charts.TimeSeriesChart(
                seriesList,
                animate: true,
                defaultRenderer: charts.LineRendererConfig(
                  includePoints: false,
                  strokeWidthPx: 1.5,
                ),
                behaviors: [
                  charts.SeriesLegend(
                    position: charts.BehaviorPosition.bottom,
                    desiredMaxRows: 2,
                  ),
                  charts.PanAndZoomBehavior(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleSparkline extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double height;

  const SimpleSparkline({
    super.key,
    required this.values,
    this.color = AppTheme.infoColor,
    this.height = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Center(
          child: Text(
            'Нет данных',
            style: AppTheme.caption.copyWith(color: Colors.grey),
          ),
        ),
      );
    }

    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;

    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: CustomPaint(
        painter: _SparklinePainter(values, color, minVal, range),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final double minVal;
  final double range;

  _SparklinePainter(this.values, this.color, this.minVal, this.range);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final xStep = size.width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = i * xStep;
      final normalizedValue = range > 0 ? (values[i] - minVal) / range : 0.5;
      final y = size.height * (1 - normalizedValue);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw last value point
    if (values.isNotEmpty) {
      final lastX = (values.length - 1) * xStep;
      final lastNormalizedValue = range > 0 ? (values.last - minVal) / range : 0.5;
      final lastY = size.height * (1 - lastNormalizedValue);

      canvas.drawCircle(
        Offset(lastX, lastY),
        2.0,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
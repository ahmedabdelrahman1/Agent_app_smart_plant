import 'package:flutter/material.dart';

class SimpleHistoryChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String sensorType;
  final String unit;
  
  const SimpleHistoryChart({
    Key? key,
    required this.data,
    required this.sensorType,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$sensorType Over Time',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.0),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: SimpleChartPainter(
                data: data,
                unit: unit,
                lineColor: _getColorForSensorType(sensorType),
                isDarkMode: isDarkMode,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getColorForSensorType(String type) {
    if (type.contains('Temperature')) {
      return Colors.redAccent;
    } else if (type.contains('Moisture') || type.contains('Humidity')) {
      return Colors.blueAccent;
    } else {
      return Colors.amberAccent;
    }
  }
}

class SimpleChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final String unit;
  final Color lineColor;
  final bool isDarkMode;
  
  SimpleChartPainter({
    required this.data,
    required this.unit,
    required this.lineColor,
    required this.isDarkMode,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final double padding = 40.0;
    final chartWidth = size.width - (padding * 2);
    final chartHeight = size.height - (padding * 2);
    
    // Find min and max values
    final values = data.map((e) => e['value'] as double).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final valueRange = maxValue - minValue;
    
    // Set up paint for grid lines
    final gridPaint = Paint()
      ..color = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Set up paint for the line graph
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    // Set up paint for points
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    
    final textStyle = TextStyle(
      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
      fontSize: 12.0,
    );
    
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Draw horizontal grid lines and labels
    for (int i = 0; i <= 4; i++) {
      final y = padding + (chartHeight * (1 - (i / 4)));
      
      // Draw grid line
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
      
      // Draw value label
      final value = minValue + (valueRange * (i / 4));
      textPainter.text = TextSpan(
        text: '${value.toStringAsFixed(1)}$unit',
        style: textStyle,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(5, y - (textPainter.height / 2)),
      );
    }
    
    // Draw data points and connect them
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final value = data[i]['value'] as double;
      final normalizedValue = valueRange == 0 ? 0.5 : (value - minValue) / valueRange;
      
      final x = padding + (i / (data.length - 1)) * chartWidth;
      final y = padding + chartHeight - (normalizedValue * chartHeight);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      // Draw point
      canvas.drawCircle(Offset(x, y), 4.0, pointPaint);
      
      // Draw time label for some points (to avoid crowding)
      if (i % 4 == 0 || i == data.length - 1) {
        final time = data[i]['time'] as DateTime;
        final timeString = '${time.hour}:00';
        textPainter.text = TextSpan(
          text: timeString,
          style: textStyle,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            x - (textPainter.width / 2),
            size.height - (textPainter.height),
          ),
        );
      }
    }
    
    // Draw the line connecting all points
    canvas.drawPath(path, linePaint);
    
    // Draw axes
    final axesPaint = Paint()
      ..color = isDarkMode ? Colors.grey[600]! : Colors.grey[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // X-axis
    canvas.drawLine(
      Offset(padding, padding + chartHeight),
      Offset(size.width - padding, padding + chartHeight),
      axesPaint,
    );
    
    // Y-axis
    canvas.drawLine(
      Offset(padding, padding),
      Offset(padding, padding + chartHeight),
      axesPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
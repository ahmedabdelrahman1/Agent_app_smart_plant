import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../utils/constants.dart';

class ModernSensorCard extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;
  final double minValue;
  final double maxValue;
  final String idealRange;
  final VoidCallback onViewHistory;
  final double delay;
  final AnimationController controller;

  const ModernSensorCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.gradientColors,
    required this.minValue,
    required this.maxValue,
    required this.idealRange,
    required this.onViewHistory,
    required this.delay,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final normalizedValue = ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    
    // Determine status color based on value
    Color statusColor = Colors.green;
    if (normalizedValue < 0.3 || normalizedValue > 0.8) {
      statusColor = Colors.red;
    } else if (normalizedValue < 0.4 || normalizedValue > 0.7) {
      statusColor = Colors.orange;
    }
    
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(delay, delay + 0.6, curve: Curves.easeOut),
      )),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Interval(delay, delay + 0.6, curve: Curves.easeOut),
        )),
        child: Container(
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDarkMode 
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.15),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            borderRadius: BorderRadius.circular(24),
            color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onViewHistory,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Icon with gradient background
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              idealRange,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        // Current timestamp indicator
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? Colors.grey[800] 
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: isDarkMode 
                                    ? Colors.grey[400] 
                                    : Colors.grey[700],
                              ),
                              SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode 
                                      ? Colors.grey[400] 
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        // Circular progress indicator
                        CircularPercentIndicator(
                          radius: 50.0,
                          lineWidth: 10.0,
                          percent: normalizedValue,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                value.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                unit,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: isDarkMode ? Color(0xFF2A2A2A) : Colors.grey[200]!,
                          progressColor: statusColor,
                          circularStrokeCap: CircularStrokeCap.round,
                          animation: true,
                          animationDuration: 1000,
                        ),
                        SizedBox(width: 24),
                        // Status and additional info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    _getStatusText(normalizedValue),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                _getRecommendation(title, normalizedValue),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 12),
                              // History link
                              InkWell(
                                onTap: onViewHistory,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'View History',
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: color,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  String _getStatusText(double normalizedValue) {
    if (normalizedValue < 0.3) {
      return 'Too Low';
    } else if (normalizedValue > 0.8) {
      return 'Too High';
    } else if (normalizedValue < 0.4) {
      return 'Slightly Low';
    } else if (normalizedValue > 0.7) {
      return 'Slightly High';
    } else {
      return 'Optimal';
    }
  }
  
  String _getRecommendation(String sensorType, double normalizedValue) {
    if (sensorType == 'Temperature') {
      if (normalizedValue < 0.3) {
        return 'Consider moving to a warmer location';
      } else if (normalizedValue > 0.8) {
        return 'Move to shade or cooler area';
      } else {
        return 'Temperature is in ideal range';
      }
    } else if (sensorType == 'Soil Moisture') {
      if (normalizedValue < 0.3) {
        return 'Plant needs watering soon';
      } else if (normalizedValue > 0.8) {
        return 'Soil is too wet, reduce watering';
      } else {
        return 'Moisture level is good';
      }
    } else if (sensorType == 'Humidity') {
      if (normalizedValue < 0.3) {
        return 'Increase humidity for your plant';
      } else if (normalizedValue > 0.8) {
        return 'Humidity too high, improve air circulation';
      } else {
        return 'Humidity level is ideal';
      }
    } else { // Light
      if (normalizedValue < 0.3) {
        return 'Plant needs more light exposure';
      } else if (normalizedValue > 0.8) {
        return 'Too much direct light, consider shade';
      } else {
        return 'Light level is ideal';
      }
    }
  }
}

// SensorCardSkeleton can be used while loading data
class SensorCardSkeleton extends StatelessWidget {
  final AnimationController controller;
  final double delay;

  const SensorCardSkeleton({
    Key? key,
    required this.controller,
    required this.delay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final skeletonColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(delay, delay + 0.3, curve: Curves.easeOut),
      )),
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.15),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  // Icon skeleton
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: skeletonColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title skeleton
                      Container(
                        width: 100,
                        height: 18,
                        decoration: BoxDecoration(
                          color: skeletonColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Subtitle skeleton
                      Container(
                        width: 140,
                        height: 12,
                        decoration: BoxDecoration(
                          color: skeletonColor.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  // Circular indicator skeleton
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: skeletonColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status skeleton
                        Container(
                          width: 80,
                          height: 14,
                          decoration: BoxDecoration(
                            color: skeletonColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: 12),
                        // Recommendation skeleton
                        Container(
                          width: double.infinity,
                          height: 12,
                          decoration: BoxDecoration(
                            color: skeletonColor.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: 6),
                        Container(
                          width: 120,
                          height: 12,
                          decoration: BoxDecoration(
                            color: skeletonColor.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: 12),
                        // View History button skeleton
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 100,
                            height: 30,
                            decoration: BoxDecoration(
                              color: skeletonColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class ModernControlWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSlider;
  final double? sliderValue;
  final Function(double)? onSliderChanged;
  final bool? switchValue;
  final Function(bool)? onSwitchChanged;
  final Color activeColor;
  final double delay;
  final AnimationController controller;

  const ModernControlWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSlider,
    this.sliderValue,
    this.onSliderChanged,
    this.switchValue,
    this.onSwitchChanged,
    required this.activeColor,
    required this.delay,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
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
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: activeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          icon,
                          color: activeColor,
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
                            description,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  if (isSlider && sliderValue != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Closed',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Open',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: activeColor,
                            inactiveTrackColor: activeColor.withOpacity(0.2),
                            thumbColor: activeColor,
                            trackHeight: 4.0,
                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                            overlayColor: activeColor.withOpacity(0.2),
                            overlayShape: RoundSliderOverlayShape(overlayRadius: 16.0),
                          ),
                          child: Slider(
                            value: sliderValue!,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            onChanged: onSliderChanged,
                          ),
                        ),
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(top: 8),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: activeColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${sliderValue!.round()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: activeColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else if (!isSlider && switchValue != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              switchValue! 
                                  ? Icons.check_circle_outline
                                  : Icons.do_not_disturb_on_outlined,
                              color: switchValue! ? activeColor : Colors.grey,
                            ),
                            SizedBox(width: 8),
                            Text(
                              switchValue! ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: switchValue! ? activeColor : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: switchValue!,
                          onChanged: onSwitchChanged,
                          activeColor: Colors.white,
                          activeTrackColor: activeColor,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
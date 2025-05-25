import 'package:flutter/material.dart';

// App colors
const kPrimaryColor = Color(0xFF4CAF50);
const kPrimaryLightColor = Color(0xFF81C784);
const kPrimaryDarkColor = Color(0xFF388E3C);
const kAccentColor = Color(0xFFFFEB3B);
const kBackgroundColor = Color(0xFFF5F5F5);

// Text colors
const kPrimaryTextColor = Color(0xFF212121);
const kSecondaryTextColor = Color(0xFF757575);

// Sensor Colors
const kTemperatureColor = Color(0xFFE57373);
const kLightColor = Color(0xFFFFD54F);
const kMoistureColor = Color(0xFF64B5F6);
const kShieldColor = Color(0xFFBA68C8);
const kPumpColor = Color(0xFF4DB6AC);

// Padding & Sizing
const kDefaultPadding = 16.0;
const kCardPadding = 16.0;
const kCardElevation = 2.0;
const kCardBorderRadius = 12.0;

// Status Colors
const kHealthyColor = Color(0xFF66BB6A);
const kWarningColor = Color(0xFFFFB74D);
const kDangerColor = Color(0xFFEF5350);

// Thresholds
const kMoistureMinThreshold = 20.0;
const kMoistureMaxThreshold = 80.0;
const kTemperatureMinThreshold = 15.0;
const kTemperatureMaxThreshold = 30.0;
const kLightMinThreshold = 30.0;
const kLightMaxThreshold = 85.0;

// API & Storage
const kBaseApiUrl = 'https://plantmonitor-api.example.com';
const kStorageKey = 'plant_monitor_app_storage';
const kUserPrefsKey = 'user_preferences';

// Image Assets
const kPlantPlaceholderImage = 'assets/images/plant_placeholder.png';
const kLogoImage = 'assets/images/logo.png';
const kLeafIcon = 'assets/icons/leaf.png';

// Chart settings
const kChartGridColor = Color(0xFFE0E0E0);
const kChartLineColor = Color(0xFF2196F3);
const kChartPointColor = Color(0xFF1976D2);
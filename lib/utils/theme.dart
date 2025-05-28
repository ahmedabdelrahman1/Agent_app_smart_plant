import 'package:flutter/material.dart';
import 'constants.dart';

// Main app theme configuration
final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.green,
  primaryColor: kPrimaryColor,
  colorScheme: ColorScheme.light(
    primary: kPrimaryColor,
    secondary: kAccentColor, // Replaces accentColor
  ),
  scaffoldBackgroundColor: kBackgroundColor,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  
  // Text theme - updated with new naming conventions
  textTheme: TextTheme(
    displayLarge: TextStyle(  // was headline1
      color: kPrimaryTextColor,
      fontWeight: FontWeight.bold,
      fontSize: 32,
    ),
    displayMedium: TextStyle(  // was headline2
      color: kPrimaryTextColor,
      fontWeight: FontWeight.bold,
      fontSize: 28,
    ),
    displaySmall: TextStyle(  // was headline3
      color: kPrimaryTextColor,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    headlineMedium: TextStyle(  // was headline4
      color: kPrimaryTextColor,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    headlineSmall: TextStyle(  // was headline5
      color: kPrimaryTextColor,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    titleLarge: TextStyle(  // was headline6
      color: kPrimaryTextColor,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    bodyLarge: TextStyle(  // was bodyText1
      color: kSecondaryTextColor,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(  // was bodyText2
      color: kSecondaryTextColor,
      fontSize: 14,
    ),
    labelLarge: TextStyle(  // was button
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  ),
  
  // Button theme - updated properties
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryColor,  // was primary
      foregroundColor: Colors.white,  // was onPrimary
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),
  
  // Input decoration theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
  ),
  
  // Card theme - FIXED: Changed CardTheme to CardThemeData
  cardTheme: CardThemeData(
    elevation: 2.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    margin: EdgeInsets.symmetric(vertical: 8.0),
  ),
  
  // App bar theme
  appBarTheme: AppBarTheme(
    backgroundColor: kPrimaryColor,
    elevation: 0,
    centerTitle: false,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
  ),
  
  // Bottom navigation bar theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: kPrimaryColor,
    unselectedItemColor: Colors.grey[600],
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
  ),
);

// Dark theme configuration
final ThemeData darkAppTheme = ThemeData(
  primarySwatch: Colors.green,
  primaryColor: kPrimaryColor,
  colorScheme: ColorScheme.dark(
    primary: kPrimaryColor,
    secondary: kAccentColor, // Replaces accentColor
  ),
  scaffoldBackgroundColor: Color(0xFF121212),
  brightness: Brightness.dark,
  
  // Text theme - dark - updated with new naming conventions
  textTheme: TextTheme(
    displayLarge: TextStyle(  // was headline1
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 32,
    ),
    displayMedium: TextStyle(  // was headline2
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 28,
    ),
    displaySmall: TextStyle(  // was headline3
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    headlineMedium: TextStyle(  // was headline4
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    headlineSmall: TextStyle(  // was headline5
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    titleLarge: TextStyle(  // was headline6
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    bodyLarge: TextStyle(  // was bodyText1
      color: Colors.grey[300],
      fontSize: 16,
    ),
    bodyMedium: TextStyle(  // was bodyText2
      color: Colors.grey[400],
      fontSize: 14,
    ),
    labelLarge: TextStyle(  // was button
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  ),
  
  // Card theme - dark - FIXED: Changed CardTheme to CardThemeData
  cardTheme: CardThemeData(
    color: Color(0xFF1E1E1E),
    elevation: 2.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    margin: EdgeInsets.symmetric(vertical: 8.0),
  ),
  
  // Bottom navigation bar theme - dark
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    selectedItemColor: kAccentColor,
    unselectedItemColor: Colors.grey[400],
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
  ),
);
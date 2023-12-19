import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Some padding for all the forms to use
const formPadding = EdgeInsets.symmetric(vertical: 20, horizontal: 16);

/// Simple sized box to space out form elements
const formSpacer = SizedBox(width: 16, height: 16);

/// Simple preloader inside a Center widget
const preloader =
    Center(child: CircularProgressIndicator(color: Colors.orange));

/// Error message to display the user when unexpected error occurs.
const unexpectedErrorMessage = 'Unexpected error occured.';

/// Basic theme to change the look and feel of the app
final appTheme = ThemeData.light().copyWith(
  primaryColorDark: Colors.orange,
  appBarTheme: const AppBarTheme(
    elevation: 1,
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 18,
    ),
  ),
  primaryColor: Colors.orange,
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.orange,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.orange,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    floatingLabelStyle: const TextStyle(
      color: Colors.orange,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.grey,
        width: 2,
      ),
    ),
    focusColor: Colors.orange,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.orange,
        width: 2,
      ),
    ),
  ),
);

const String PERMISSION_LEVEL_FOLLOWABLE = "followable";
const String PERMISSION_LEVEL_NOT_ACCESSIBLE = "not_accessible";
const String PERMISSION_LEVEL_NOT_FOLLOWABLE = "not_followable";

/// Supabase client
final supabase = Supabase.instance.client;

CircleAvatar getCircleAvatarBasedOnText(String text) {
  String textForAvatar = "";
  if (text.isEmpty) {
    textForAvatar = "UN";
  } else if (text.length == 1) {
    textForAvatar = text[0];
  } else {
    textForAvatar = text.substring(0, 2);
  }
  return CircleAvatar(
    child: Text(textForAvatar),
  );
}

/// Set of extension methods to easily display a snackbar
extension ShowSnackBar on BuildContext {
  /// Displays a red snackbar indicating error
  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }

  /// Displays a basic snackbar
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }
}

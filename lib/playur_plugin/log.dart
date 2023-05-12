import 'package:flutter/foundation.dart';

class PlayURPluginLogger
{
static const String _TAG = "[PLAYUR]";

  static void log(String message)
  {
    if (kDebugMode) {
      print("$_TAG: $message");
    }
  }
  static void error(String message)
  {
    if (kDebugMode) {
      print("$_TAG: $message");
    }
  }
}
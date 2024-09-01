import 'package:flutter/material.dart';

class RouteSettingsController {
  double speed;
  double inaccuracy;
  String? selectedLoopMode;
  bool isWalking = true;
  bool isCycling = false;
  bool isDriving = false;

  RouteSettingsController({
    required this.speed,
    required this.inaccuracy,
    required this.selectedLoopMode,
  });

  void updateSpeed(double newSpeed) {
    speed = newSpeed;
    isWalking = newSpeed <= 10.0;
    isCycling = newSpeed > 10.0 && newSpeed <= 25.0;
    isDriving = newSpeed > 25.0;
  }

  void updateInaccuracy(double newInaccuracy) {
    inaccuracy = newInaccuracy;
  }

  void updateLoopMode(String? newLoopMode) {
    selectedLoopMode = newLoopMode;
  }
}

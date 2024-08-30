import 'package:flutter/material.dart';

class SharedState extends ChangeNotifier {
  bool _isMoving = false;
  double _speed = 0.5; // New speed property
  double _inaccuracy = 0.0;
  String _loopMode = 'stop';

  bool get isMoving => _isMoving;
  double get speed => _speed; // Getter for speed
  double get inaccuracy => _inaccuracy;
  String get loopMode => _loopMode;

  void setIsMoving(bool value) {
    _isMoving = value;
    notifyListeners();
  }

  void setSpeed(double value) {
    _speed = value;
    notifyListeners();
  }

  void setInaccuracy(double value) {
    _inaccuracy = value;
    notifyListeners();
  }

  void setLoopMode(String value) {
    _loopMode = value;
    notifyListeners();
  }
}

import 'dart:async';

class OrderEvents {
  static final StreamController<bool> orderStatusChanged = StreamController<bool>.broadcast();
}
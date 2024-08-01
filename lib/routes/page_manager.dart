import 'dart:async';

import 'package:flutter/material.dart';

class PageManager extends ChangeNotifier {
  late Completer<PickedLocation> _completer;

  Future<PickedLocation> waitForResult() async {
    _completer = Completer<PickedLocation>();
    return _completer.future;
  }

  void returnData(PickedLocation value) {
    _completer.complete(value);
  }
}

class PickedLocation {
  final double latitude;
  final double longitude;
  final String address;

  PickedLocation(this.latitude, this.longitude, this.address);
}

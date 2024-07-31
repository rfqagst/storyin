import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  final LatLng latLng;
  final String address;

  PickedLocation(this.latLng, this.address);
}

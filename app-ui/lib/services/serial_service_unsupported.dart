import 'dart:async';
import 'serial_service.dart';

class SerialServiceImpl implements SerialService {
  @override
  Stream<double> get distanceStream => Stream.value(0.0);

  @override
  String get statusMessage => "Unsupported platform";

  @override
  void dispose() {}

  @override
  void initialize() {}
}

SerialService getSerialService() => SerialServiceImpl();

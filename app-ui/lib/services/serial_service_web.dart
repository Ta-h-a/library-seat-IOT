import 'dart:async';
import 'serial_service.dart';

class SerialServiceImpl implements SerialService {
  final _distanceController = StreamController<double>.broadcast();
  String _statusMessage = "Not available on web";

  @override
  Stream<double> get distanceStream => _distanceController.stream;

  @override
  String get statusMessage => _statusMessage;

  @override
  void initialize() {
    // Do nothing on the web, the UI will show "-"
    _distanceController.add(-1.0);
  }

  @override
  void dispose() {
    _distanceController.close();
  }
}

SerialService getSerialService() => SerialServiceImpl();

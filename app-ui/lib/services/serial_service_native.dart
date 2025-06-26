import 'dart:async';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'serial_service.dart';

class SerialServiceImpl implements SerialService {
  final _distanceController = StreamController<double>.broadcast();
  SerialPort? _port;
  String _statusMessage = "Disconnected";

  @override
  Stream<double> get distanceStream => _distanceController.stream;

  @override
  String get statusMessage => _statusMessage;

  @override
  void initialize() {
    _statusMessage = "Initializing...";
    var com3 = SerialPort.availablePorts.contains("COM3") ? "COM3" : null;

    if (com3 == null) {
      _statusMessage = "COM3 not found.";
      _distanceController.add(-1.0); // Signal to UI that it's disconnected
      return;
    }

    _port = SerialPort(com3);

    if (_port!.openReadWrite()) {
      _statusMessage = "Connected to COM3";
      SerialPortReader reader = SerialPortReader(_port!);
      reader.stream.listen((data) {
        try {
          String receivedData = String.fromCharCodes(data);
          var distance = double.parse(receivedData.trim());
          _distanceController.add(distance);
        } catch (e) {
          // Handle parsing errors, maybe send a specific signal
          _distanceController.add(-1.0);
        }
      });
    } else {
      _statusMessage = "Failed to open COM3.";
      _distanceController.add(-1.0); // Signal to UI that it's disconnected
    }
  }

  @override
  void dispose() {
    _port?.close();
    _distanceController.close();
  }
}

SerialService getSerialService() => SerialServiceImpl();

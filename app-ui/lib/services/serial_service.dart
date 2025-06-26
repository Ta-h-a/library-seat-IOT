import 'dart:async';

abstract class SerialService {
  Stream<double> get distanceStream;
  String get statusMessage;
  void initialize();
  void dispose();
}

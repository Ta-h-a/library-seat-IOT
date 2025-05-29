import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppStateNotRandom();
}

class _MyAppStateNotRandom extends State<MyApp> {
  final _port = SerialPort('COM5'); // change COM port accordingly
  SerialPortReader? _reader;
  String _data = '';

  @override
  void initState() {
    super.initState();
    if (_port.openRead()) {
      _reader = SerialPortReader(_port);
      _reader!.stream.listen((event) {
        setState(() {
          _data += String.fromCharCodes(event);
        });
      });
    } else {
      setState(() {
        _data = 'Failed to open serial port.';
      });
    }
  }

  @override
  void dispose() {
    _reader?.close();
    _port.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Serial Port Data')),
        body: Center(child: Text(_data)),
      ),
    );
  }
}

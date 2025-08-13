import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'analytics_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library Seat IoT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _port = SerialPort('COM3'); // Changed to COM3 as per your Python script
  SerialPortReader? _reader;
  String _rawData = '';
  double? _currentDistance;
  bool _isConnected = false;
  List<double> _distanceHistory = [];

  @override
  void initState() {
    super.initState();
    _connectToSerial();
  }

  void _connectToSerial() {
    try {
      if (_port.openRead()) {
        setState(() {
          _isConnected = true;
        });
        _reader = SerialPortReader(_port);
        _reader!.stream.listen((event) {
          final data = String.fromCharCodes(event).trim();
          setState(() {
            _rawData = data;
            try {
              final distance = double.parse(data);
              _currentDistance = distance;
              _distanceHistory.add(distance);
              // Keep only last 100 readings
              if (_distanceHistory.length > 100) {
                _distanceHistory.removeAt(0);
              }
            } catch (e) {
              // Invalid data, ignore
            }
          });
        });
      } else {
        setState(() {
          _isConnected = false;
          _rawData = 'Failed to open serial port COM3';
        });
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
        _rawData = 'Error: $e';
      });
    }
  }

  String _getSeatStatus() {
    if (_currentDistance == null) return 'Unknown';
    if (_currentDistance! < 50) return 'Occupied';
    return 'Available';
  }

  Color _getStatusColor() {
    if (_currentDistance == null) return Colors.grey;
    if (_currentDistance! < 50) return Colors.red;
    return Colors.green;
  }

  @override
  void dispose() {
    _reader?.close();
    _port.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Library Seat Monitor'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Connection Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.wifi : Icons.wifi_off,
                      color: _isConnected ? Colors.green : Colors.red,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isConnected ? 'Connected to COM3' : 'Disconnected',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Seat Status Card
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [_getStatusColor().withOpacity(0.1), _getStatusColor().withOpacity(0.3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.chair,
                      size: 60,
                      color: _getStatusColor(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getSeatStatus(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                    if (_currentDistance != null)
                      Text(
                        '${_currentDistance!.toStringAsFixed(1)} cm',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Analytics Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnalyticsPage(distanceHistory: _distanceHistory),
                    ),
                  );
                },
                icon: const Icon(Icons.analytics),
                label: const Text('View Analytics'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Raw Data Card
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Raw Serial Data:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _rawData.isEmpty ? 'No data received...' : _rawData,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: Colors.green,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

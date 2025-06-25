import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_libserialport/flutter_libserialport.dart';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Table UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Sans',
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});


  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  String _userRole = 'staff'; // Default to staff for demo purposes


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // Watermark background
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Center(
                child: SizedBox(
                  width: 250, // Adjust the width as needed
                  height: 250, // Adjust the height as needed
                  child: Image.asset(
                    'assets/rv_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo section
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      size: 40,
                      color: Colors.blue.shade400,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // App name
                  const Text(
                    'DineFlow',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Welcome text
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'Choose your role to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(flex: 1),
                  // Staff Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TableOverviewPage(userRole: 'staff'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade400,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Staff Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Customer Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TableOverviewPage(userRole: 'customer'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade400,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_menu, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'View Table Status',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  // Bottom indicator (home indicator style)
                  Container(
                    width: 134,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class TableOverviewPage extends StatefulWidget {
  final String userRole;
  const TableOverviewPage({super.key, required this.userRole});


  @override
  State<TableOverviewPage> createState() => _TableOverviewPageState();
}


class _TableOverviewPageState extends State<TableOverviewPage> {
  String _selectedFilter = 'All Tables';
  bool _isTableOneOccupied = false;
  bool _wasTableOneOccupied = false;


  void updateTableOneStatus(double distance) {
    setState(() {
      if (distance < 20.0) {
        // When object is detected (distance < 20cm)
        _isTableOneOccupied = true;
        _wasTableOneOccupied = false;
      } else if (_isTableOneOccupied) {
        // When object moves away (distance >= 20cm) and table was occupied
        _isTableOneOccupied = false;
        _wasTableOneOccupied = true;
      }
      // Note: We don't automatically change from Needs Cleaning to Available
      // That will only happen when the table is tapped
    });
  }


  List<TableData> get _allTables => [
        TableData(
            'T1',
            _isTableOneOccupied
                ? Colors.red.shade400
                : (_wasTableOneOccupied
                    ? Colors.orange.shade400
                    : Colors.green.shade400),
            _isTableOneOccupied
                ? Icons.person_outline
                : (_wasTableOneOccupied
                    ? Icons.cleaning_services_outlined
                    : Icons.check_circle_outlined),
            _isTableOneOccupied
                ? 'Occupied'
                : (_wasTableOneOccupied ? 'Needs Cleaning' : 'Available')),
        TableData('T2', Colors.red.shade400, Icons.person_outline, 'Occupied'),
        TableData('T3', Colors.blue.shade400, Icons.lock_outline, 'Reserved'),
        TableData('T4', Colors.orange.shade400,
            Icons.cleaning_services_outlined, 'Needs Cleaning'),
        TableData('T5', Colors.green.shade400, Icons.check_circle_outlined,
            'Available'),
        TableData('T6', Colors.red.shade400, Icons.person_outline, 'Occupied'),
        TableData('T7', Colors.orange.shade400,
            Icons.cleaning_services_outlined, 'Needs Cleaning'),
        TableData('T8', Colors.blue.shade400, Icons.lock_outline, 'Reserved'),
      ];


  List<TableData> get _filteredTables {
    if (_selectedFilter == 'All Tables') return _allTables;
    return _allTables
        .where((table) => table.status == _selectedFilter)
        .toList();
  }


  @override
  Widget build(BuildContext context) {
    final tables = _filteredTables.map((table) {
      if (table.name == 'T1') {
        return TableOneCard(
          key: ValueKey(table.name),
          label: table.name,
          color: table.color,
          icon: table.icon,
          status: table.status,
          userRole: widget.userRole,
          isOccupied: _isTableOneOccupied,
          wasOccupied: _wasTableOneOccupied,
        );
      }


      // For other tables, use the regular TableCard
      bool isRectangular = false;
      switch (table.name) {
        case 'T3':
          isRectangular = true;
          break;
        case 'T6':
          isRectangular = true;
          break;
        default:
          isRectangular = false;
      }


      return TableCard(
        key: ValueKey(table.name),
        label: table.name,
        color: table.color,
        icon: table.icon,
        status: table.status,
        isRectangular: isRectangular,
        userRole: widget.userRole,
      );
    }).toList();


    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Table Overview"),
              const SizedBox(height: 4),
              Text(
                "8 Tables • 2 Occupied • 2 Reserved",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                "Logged in as: ${widget.userRole.toUpperCase()}",
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
        toolbarHeight: 100,
      ),
      body: Column(
        children: [
          FilterChips(
            selectedFilter: _selectedFilter,
            onFilterSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: tables.length,
                itemBuilder: (context, index) => tables[index],
              ),
            ),
          ),
          SensorDataWidget(
            onDistanceUpdate: updateTableOneStatus,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 8,
        selectedItemColor: Colors.blue.shade400,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: "Overview"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined), label: "Analytics"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: "Settings"),
        ],
      ),
      floatingActionButton: widget.userRole == 'staff'
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.blue.shade400,
              elevation: 4,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}


class TableCard extends StatefulWidget {
  final String label;
  final Color color;
  final IconData icon;
  final String status;
  final bool isRectangular;
  final String userRole;


  const TableCard({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
    required this.status,
    this.isRectangular = false,
    required this.userRole,
  });


  @override
  State<TableCard> createState() => _TableCardState();
}


class _TableCardState extends State<TableCard> {
  late String _status;
  late Color _color;
  late IconData _icon;


  @override
  void initState() {
    super.initState();
    _status = widget.status;
    _color = widget.color;
    _icon = widget.icon;
  }


  void _toggleStatus() {
    setState(() {
      if (_status == 'Reserved' || _status == 'Needs Cleaning') {
        _status = 'Available';
        _color = Colors.green.shade400;
        _icon = Icons.check_circle_outlined;
      } else if (_status == 'Available') {
        _status = 'Reserved';
        _color = Colors.blue.shade400;
        _icon = Icons.lock_outline;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.userRole == 'staff' && _status != 'Occupied'
          ? _toggleStatus
          : null,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              widget.isRectangular
                  ? buildRectangularTable(_color)
                  : buildRoundTable(_color),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_icon, color: _color, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    _status,
                    style: TextStyle(
                      color: _color,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildRoundTable(Color color) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 0, child: seatDot(color)),
          Positioned(bottom: 0, child: seatDot(color)),
          Positioned(left: 0, child: seatDot(color)),
          Positioned(right: 0, child: seatDot(color)),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.table_restaurant_outlined,
                color: color,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget buildRectangularTable(Color color) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 0, left: 20, child: seatDot(color)),
          Positioned(top: 0, right: 20, child: seatDot(color)),
          Positioned(bottom: 0, left: 20, child: seatDot(color)),
          Positioned(bottom: 0, right: 20, child: seatDot(color)),
          Positioned(left: 0, top: 30, child: seatDot(color)),
          Positioned(right: 0, top: 30, child: seatDot(color)),
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.table_restaurant_outlined,
                color: color,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget seatDot(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}


class TableOneCard extends StatefulWidget {
  final String label;
  final Color color;
  final IconData icon;
  final String status;
  final String userRole;
  final bool isOccupied;
  final bool wasOccupied;


  const TableOneCard({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
    required this.status,
    required this.userRole,
    required this.isOccupied,
    required this.wasOccupied,
  });


  @override
  State<TableOneCard> createState() => _TableOneCardState();
}


class _TableOneCardState extends State<TableOneCard> {
  late String _status;
  late Color _color;
  late IconData _icon;


  @override
  void initState() {
    super.initState();
    _updateStatus();
  }


  @override
  void didUpdateWidget(TableOneCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOccupied != widget.isOccupied ||
        oldWidget.wasOccupied != widget.wasOccupied) {
      _updateStatus();
    }
  }


  void _updateStatus() {
    setState(() {
      if (widget.isOccupied) {
        _status = 'Occupied';
        _color = Colors.red.shade400;
        _icon = Icons.person_outline;
      } else if (widget.wasOccupied) {
        _status = 'Needs Cleaning';
        _color = Colors.orange.shade400;
        _icon = Icons.cleaning_services_outlined;
      } else {
        _status = 'Available';
        _color = Colors.green.shade400;
        _icon = Icons.check_circle_outlined;
      }
    });
  }


  void _toggleStatus() {
    setState(() {
      if (_status == 'Available') {
        _status = 'Reserved';
        _color = Colors.blue.shade400;
        _icon = Icons.lock_outline;
      } else if (_status == 'Reserved') {
        _status = 'Available';
        _color = Colors.green.shade400;
        _icon = Icons.check_circle_outlined;
      } else if (_status == 'Needs Cleaning') {
        _status = 'Available';
        _color = Colors.green.shade400;
        _icon = Icons.check_circle_outlined;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.userRole == 'staff' && _status != 'Occupied'
          ? _toggleStatus
          : null,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildRectangularTable(_color),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_icon, color: _color, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    _status,
                    style: TextStyle(
                      color: _color,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildRectangularTable(Color color) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 0, left: 20, child: seatDot(color)),
          Positioned(top: 0, right: 20, child: seatDot(color)),
          Positioned(bottom: 0, left: 20, child: seatDot(color)),
          Positioned(bottom: 0, right: 20, child: seatDot(color)),
          Positioned(left: 0, top: 30, child: seatDot(color)),
          Positioned(right: 0, top: 30, child: seatDot(color)),
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.table_restaurant_outlined,
                color: color,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget seatDot(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}


class TableData {
  final String name;
  final Color color;
  final IconData icon;
  final String status;


  TableData(this.name, this.color, this.icon, this.status);
}


class FilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  const FilterChips(
      {super.key,
      required this.selectedFilter,
      required this.onFilterSelected});


  @override
  Widget build(BuildContext context) {
    final filters = [
      "All Tables",
      "Available",
      "Occupied",
      "Reserved",
      "Needs Cleaning",
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (final filter in filters) ...[
            buildChip(filter, isSelected: selectedFilter == filter),
            if (filter != filters.last) const SizedBox(width: 8),
          ]
        ],
      ),
    );
  }


  Widget buildChip(String label, {bool isSelected = false}) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      selectedColor: Colors.blue.shade400,
      backgroundColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onSelected: (_) => onFilterSelected(label),
    );
  }
}


class SensorDataWidget extends StatefulWidget {
  final Function(double) onDistanceUpdate;


  const SensorDataWidget({
    super.key,
    required this.onDistanceUpdate,
  });


  @override
  State<SensorDataWidget> createState() => _SensorDataWidgetState();
}


class _SensorDataWidgetState extends State<SensorDataWidget> {
  final _port = SerialPort('COM5');
  SerialPortReader? _reader;
  String _data = '';
  double _distance = 0.0;


  @override
  void initState() {
    super.initState();
    _initializeSerialPort();
  }


  void _initializeSerialPort() {
    try {
      if (_port.openRead()) {
        _reader = SerialPortReader(_port);
        _reader!.stream.listen((event) {
          if (mounted) {
            setState(() {
              String rawData = String.fromCharCodes(event).trim();
              try {
                _distance = double.tryParse(rawData) ?? 0.0;
                _data = 'Distance: ${_distance.toStringAsFixed(1)} inch';
                // Notify parent about distance update
                widget.onDistanceUpdate(_distance);
              } catch (e) {
                print('Error parsing distance data: $e');
                _data = 'Error reading data';
              }
            });
          }
        });
      } else {
        setState(() {
          _data = 'Failed to open serial port COM5';
        });
      }
    } catch (e) {
      setState(() {
        _data = 'Error: ${e.toString()}';
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.sensors,
                      color: Colors.blue.shade400,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Ultrasonic Sensor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Live',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _data,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

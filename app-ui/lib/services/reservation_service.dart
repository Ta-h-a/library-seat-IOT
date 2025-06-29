import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class ReservationRequest {
  final String tableId;
  final String customerName;
  final DateTime requestTime;
  bool isApproved;

  ReservationRequest({
    required this.tableId,
    required this.customerName,
    required this.requestTime,
    this.isApproved = false,
  });
}

class ReservationService extends ChangeNotifier {
  final List<ReservationRequest> _pendingRequests = [];
  final List<String> _reservedTables = [];

  List<ReservationRequest> get pendingRequests => _pendingRequests;
  List<String> get reservedTables => _reservedTables;

  void addReservationRequest(String tableId, String customerName) {
    if (_reservedTables.contains(tableId) ||
        _pendingRequests.any((req) => req.tableId == tableId)) {
      // Table is already reserved or has a pending request
      return;
    }
    final request = ReservationRequest(
      tableId: tableId,
      customerName: customerName,
      requestTime: DateTime.now(),
    );
    _pendingRequests.add(request);
    notifyListeners();
  }

  void approveReservation(ReservationRequest request) {
    request.isApproved = true;
    _reservedTables.add(request.tableId);
    _pendingRequests.remove(request);
    notifyListeners();
  }

  void rejectReservation(ReservationRequest request) {
    _pendingRequests.remove(request);
    notifyListeners();
  }

  bool isTableReserved(String tableId) {
    return _reservedTables.contains(tableId);
  }

  bool hasPendingRequest(String tableId) {
    return _pendingRequests.any((req) => req.tableId == tableId);
  }
}

// Simple service locator for ReservationService
ReservationService? _reservationService;

ReservationService getReservationService() {
  _reservationService ??= ReservationService();
  return _reservationService!;
}

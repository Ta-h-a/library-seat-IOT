export 'serial_service_unsupported.dart'
    if (dart.library.io) 'serial_service_native.dart'
    if (dart.library.html) 'serial_service_web.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class PibleDevice {
  final String name;
  final BluetoothDevice device;
  final bool hasAccess;

  PibleDevice({
    required this.name,
    required this.device,
    required this.hasAccess,
  });

  Future<void> connect() async {
    await device.connect(timeout: const Duration(seconds: 3));
  }
}

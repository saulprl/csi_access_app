import 'dart:async';
import 'dart:io';

import 'package:csi_door_logs/models/room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:csi_door_logs/models/pible_device.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

class PibleProvider with ChangeNotifier {
  final _flutterBlue = FlutterBluePlus.instance;
  final _serviceUuid = dotenv.env["SERVICE_UUID"];

  Timer? _periodicTimer;

  final List<PibleDevice> _pibles = [];
  List<Room> _rooms = [];
  var _emptyResults = 0;

  List<Room> get rooms => [..._rooms];
  List<PibleDevice> get pibles => [..._pibles];
  Stream<List<ScanResult>> get scanResults => _flutterBlue.scanResults;
  Stream<bool> get isScanning => _flutterBlue.isScanning;
  bool get isActive => _periodicTimer?.isActive ?? false;

  PibleProvider({List<Room>? rooms}) {
    if (rooms != null && rooms.isNotEmpty) {
      setRooms(rooms);
    }

    startTimer();
  }

  void setRooms(List<Room> rooms) {
    _rooms = rooms;
    _initScanSub();

    notifyListeners();
  }

  void startTimer() {
    if (_periodicTimer?.isActive ?? false) {
      return;
    }

    _periodicScan();
    _periodicTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _periodicScan();
    });

    notifyListeners();
  }

  void pauseTimer() {
    _periodicTimer?.cancel();
    notifyListeners();
  }

  Future<void> _periodicScan() async {
    final isBluetoothOn = await _flutterBlue.isOn;

    if (Platform.isAndroid) {
      if (await Permission.bluetoothConnect.isGranted && !isBluetoothOn) {
        _flutterBlue.turnOn();
      } else if (!isBluetoothOn) {
        PermissionStatus status = await Permission.bluetoothConnect.request();
        if (status == PermissionStatus.granted) {
          _flutterBlue.turnOn();
        }
      }
    }

    await _flutterBlue.stopScan();

    _flutterBlue.startScan(
      scanMode: ScanMode.balanced,
      timeout: const Duration(seconds: 3),
      withServices: [Guid(_serviceUuid!)],
    );
  }

  void _initScanSub() {
    _flutterBlue.scanResults.skip(1).listen(
      (results) {
        if (_emptyResults >= 3) {
          _emptyResults = 0;
          _pibles.clear();
          notifyListeners();

          return;
        }

        if (results.isEmpty) {
          _emptyResults++;
          return;
        }

        for (final result in results) {
          if (_pibles.any((pible) => pible.device.id == result.device.id)) {
            return;
          }

          _pibles.add(
            PibleDevice(
              name: result.advertisementData.localName,
              device: result.device,
              hasAccess: rooms.any(
                (room) =>
                    room.name ==
                    result.advertisementData.localName.replaceAll("PiBLE-", ""),
              ),
            ),
          );

          _pibles.sort((a, b) => a.name.compareTo(b.name));
          notifyListeners();
        }

        _pibles.removeWhere(
          (pible) =>
              !results.any((result) => result.device.id == pible.device.id),
        );

        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();

    super.dispose();
  }
}

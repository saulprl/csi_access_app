import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:csi_door_logs/providers/room_provider.dart';
import 'package:csi_door_logs/models/pible_device.dart';

enum PibleState {
  scanning,
  connecting,
  stopped,
}

class PibleProvider with ChangeNotifier {
  final _timerDuration = const Duration(seconds: 8);
  final _scanDuration = const Duration(seconds: 2);
  final _flutterBlue = FlutterBluePlus.instance;
  final _serviceUuid = dotenv.env["SERVICE_UUID"];

  Timer? _periodicTimer;
  PibleState _pibleState = PibleState.stopped;

  List<PibleDevice> _pibles = [];
  var _emptyResults = 0;
  var _scans = 0;
  final _scanLimit = 3;

  RoomProvider? _rooms;

  RoomProvider? get rooms => _rooms;
  List<PibleDevice> get pibles => [..._pibles];
  Stream<List<ScanResult>> get scanResults => _flutterBlue.scanResults;
  Stream<bool> get isScanning => _flutterBlue.isScanning;
  bool get isActive => _periodicTimer?.isActive ?? false;
  PibleState get pibleState => _pibleState;
  int get scans => _scans;

  PibleProvider({RoomProvider? rooms}) {
    if (rooms != null) {
      setRoomProvider(rooms);
    }

    startTimer();
  }

  void setRoomProvider(RoomProvider rooms) {
    _rooms = rooms;
    _initScanSub();

    notifyListeners();
  }

  void startTimer() {
    _scans = 0;
    if (_periodicTimer?.isActive ?? false) {
      return;
    }

    _periodicScan();
    _periodicTimer = Timer.periodic(_timerDuration, (_) {
      _periodicScan();
    });

    notifyListeners();
  }

  void pauseTimer({bool isConnecting = false}) {
    if (isConnecting) {
      _pibleState = PibleState.connecting;
    }

    _flutterBlue.stopScan();
    _periodicTimer?.cancel();
    notifyListeners();
  }

  void stopTimer() {
    _periodicTimer?.cancel();
    _pibleState = PibleState.stopped;
    notifyListeners();
  }

  Future<void> _periodicScan() async {
    _pibleState = PibleState.scanning;

    _scans++;
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

    if (_scans > _scanLimit) {
      stopTimer();

      return;
    }

    _flutterBlue.startScan(
      timeout: _scanDuration,
      withServices: [Guid(_serviceUuid!)],
    );
  }

  void _initScanSub() {
    _flutterBlue.scanResults.skip(1).listen(
      (results) {
        if (_rooms == null) {
          return;
        }

        if (_emptyResults >= 2) {
          _emptyResults = 0;
          _pibles.clear();
          notifyListeners();

          return;
        }

        if (results.isEmpty) {
          _emptyResults++;
          return;
        }

        _pibles = results
            .map(
              (result) => PibleDevice(
                device: result.device,
                name: result.advertisementData.localName,
                hasAccess: _rooms!.accessibleRooms.any(
                  (room) =>
                      result.advertisementData.localName.contains(room.name),
                ),
              ),
            )
            .toList();
        _pibles.sort((a, b) => a.name.compareTo(b.name));

        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _pibleState = PibleState.stopped;

    super.dispose();
  }
}

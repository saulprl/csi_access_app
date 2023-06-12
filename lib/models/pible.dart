import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:steel_crypt/steel_crypt.dart';

enum BTConnectionState {
  starting,
  discovering,
  connecting,
  authenticating,
  authenticationFailed,
  failed,
  done,
}

class Pible with ChangeNotifier {
  final _flutterBlue = FlutterBluePlus.instance;
  final _localAuth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();
  ValueNotifier<BTConnectionState> pibleState =
      ValueNotifier<BTConnectionState>(BTConnectionState.starting);

  BluetoothDevice? pible;
  final String ivValue;
  final String aesKey;
  final String serviceUuid;
  final String pibleAddress;
  final String tokenCharUuid;

  Pible({
    required this.ivValue,
    required this.aesKey,
    required this.serviceUuid,
    required this.pibleAddress,
    required this.tokenCharUuid,
  });

  String _generateNonce() {
    final random = Random.secure();
    final nonceBytes = List.generate(16, (_) => random.nextInt(256));
    final nonce = base64.encode(nonceBytes);

    return nonce;
  }

  Future<void> discoverDevices() async {
    if (Platform.isAndroid) {
      if (await Permission.bluetoothConnect.isGranted &&
          !await _flutterBlue.isOn) {
        _flutterBlue.turnOn();
      } else if (!await _flutterBlue.isOn) {
        PermissionStatus permissionStatus =
            await Permission.bluetoothConnect.request();
        if (permissionStatus == PermissionStatus.granted) {
          _flutterBlue.turnOn();
        }
      }
    }

    pibleState.value = BTConnectionState.discovering;

    _flutterBlue.startScan(
      timeout: const Duration(seconds: 6),
      macAddresses: [pibleAddress],
    ).then((_) {
      if (pible == null) {
        pibleState.value = BTConnectionState.done;
      }
    });

    _flutterBlue.scanResults.listen((results) {
      for (ScanResult sr in results) {
        if (sr.device.name == "PiBLE") {
          pible = sr.device;
          pibleState.value = BTConnectionState.connecting;

          _flutterBlue.stopScan();
          _handleConnection();
        }
      }
    });
  }

  Future<void> _handleConnection() async {
    if (pible == null) {
      pibleState.value = BTConnectionState.done;
      return;
    }

    await pible!.connect(autoConnect: false);

    List<BluetoothService> services = await pible!.discoverServices();
    for (final svc in services) {
      if (svc.uuid.toString() != serviceUuid) break;

      pibleState.value = BTConnectionState.authenticating;
      final isAuth = await handleAuthentication();

      if (!isAuth) {
        pibleState.value = BTConnectionState.authenticationFailed;
      }

      String nonce = _generateNonce();
      String uid = await _storage.read(key: "CSIPRO-ACCESS-FIREBASE-UID") ?? "";
      String passcode = await _storage.read(key: "CSIPRO-PASSCODE") ?? "";
      String concatenated = "$nonce:$uid:$passcode";
      final cipher = AesCrypt(
        padding: PaddingAES.pkcs7,
        key: base64.encode(aesKey.codeUnits),
      );

      final encryptedString = base64.encode(cipher.cbc
          .encrypt(
            inp: concatenated,
            iv: base64.encode(ivValue.codeUnits),
          )
          .codeUnits);

      final tokenChar = svc.characteristics.firstWhere(
        (cha) => cha.uuid.toString() == tokenCharUuid,
      );

      await tokenChar.write(encryptedString.codeUnits);

      pibleState.value = BTConnectionState.done;
    }
  }

  Future<bool> handleAuthentication() async {
    return await _localAuth.authenticate(
      localizedReason: "PiBLE required authentication in order to continue.",
    );
  }
}

import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:math";

import "package:csi_door_logs/utils/enums.dart";
import "package:csi_door_logs/widgets/main/csi_appbar.dart";
import "package:csi_door_logs/widgets/pible/index.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_blue_plus/flutter_blue_plus.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:local_auth/local_auth.dart";
import "package:permission_handler/permission_handler.dart";
import "package:steel_crypt/steel_crypt.dart";

class PibleScreen extends StatefulWidget {
  const PibleScreen({super.key});

  @override
  State<PibleScreen> createState() => _PibleScreenState();
}

class _PibleScreenState extends State<PibleScreen> {
  final flutterBlue = FlutterBluePlus.instance;
  final localAuth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();

  final ivValue = dotenv.env["IV_VALUE"];
  final encryptionString = dotenv.env["AES_ENCRYPTION_KEY"];
  final serviceUuid = dotenv.env["SERVICE_UUID"];
  final pibleAddress = dotenv.env["PIBLE_ADDRESS"];
  final tokenCharacteristicUuid = dotenv.env["TOKEN_CHARACTERISTIC_UUID"];
  final ivCharacteristicUuid = dotenv.env["IV_CHARACTERISTIC_UUID"];

  BluetoothDevice? pible;
  bool _isInit = false;

  bool isBluetoothOn = false;
  bool isScanning = false;
  bool canRescan = false;
  BTServiceState servicesState = BTServiceState.waiting;
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;
  LocalAuthState authState = LocalAuthState.waiting;
  EncryptionState encryptionState = EncryptionState.waiting;

  StreamSubscription? scanningSub;
  StreamSubscription? scanResultsSub;
  StreamSubscription? deviceStateSub;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      flutterBlue.isOn.then((value) => setState(() => isBluetoothOn = value));
      scanningSub = flutterBlue.isScanning.listen(
        (state) => setState(() => isScanning = state),
      );

      // Discover devices
      discoverDevices();

      _isInit = true;
    }

    super.didChangeDependencies();
  }

  void popBack() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void schedulePopBack({int seconds = 2}) {
    Future.delayed(
      Duration(seconds: seconds),
      () => popBack(),
    );
  }

  String generateNonce() {
    final random = Random.secure();
    final nonceBytes = List.generate(16, (_) => random.nextInt(256));
    final nonce = base64.encode(nonceBytes);

    return nonce;
  }

  Future<void> _restartScan() async {
    await scanResultsSub?.cancel();
    await deviceStateSub?.cancel();

    discoverDevices();
  }

  Future<void> discoverDevices() async {
    if (Platform.isAndroid) {
      if (await Permission.bluetoothConnect.isGranted && !isBluetoothOn) {
        flutterBlue.turnOn();
      } else if (!isBluetoothOn) {
        PermissionStatus status = await Permission.bluetoothConnect.request();
        if (status == PermissionStatus.granted) {
          flutterBlue.turnOn();
        }
      }
    }

    if (!await Permission.locationWhenInUse.isGranted) {
      PermissionStatus status = await Permission.locationWhenInUse.request();
      if (status == PermissionStatus.denied) {
        popBack();
      }
    }

    setState(() => canRescan = false);

    flutterBlue.startScan(
      timeout: const Duration(seconds: 5),
      macAddresses: [pibleAddress!],
    );

    scanResultsSub = flutterBlue.scanResults.skip(1).listen((result) {
      for (ScanResult scanResult in result) {
        // debugPrint("Advertisement data: ${scanResult.advertisementData}");
        if (scanResult.advertisementData.localName == "PiBLE" &&
            scanResult.advertisementData.connectable) {
          if (mounted) {
            flutterBlue.stopScan();

            pible = scanResult.device;
            pible!.connect(timeout: const Duration(seconds: 3));
            Future.delayed(
              const Duration(seconds: 3),
              () => setState(() => canRescan = true),
            );

            try {
              deviceStateSub = pible!.state.listen(
                (state) {
                  if (mounted) {
                    debugPrint("device_state -> $state");
                    setState(() => deviceState = state);
                  }

                  if (state == BluetoothDeviceState.connected) {
                    handleConnection();
                  }
                },
              );
            } on PlatformException catch (error) {
              debugPrint("Error code: ${error.code}");

              if (error.code != "already_connected") {
                rethrow;
              }
            }
          }
        }
      }
    });
  }

  Future<void> handleConnection() async {
    try {
      if (pible == null) return;

      setState(() => servicesState = BTServiceState.discovering);
      List<BluetoothService> services = await pible!.discoverServices();

      final service = services.firstWhere(
        (svc) => svc.uuid.toString() == serviceUuid,
      );
      setState(() => servicesState = BTServiceState.done);

      if (!await handleAuthentication()) {
        setState(() => authState = LocalAuthState.failed);
        popBack();
      }
      setState(() => authState = LocalAuthState.done);

      try {
        await encryptData(service);
        setState(() => encryptionState = EncryptionState.done);
      } catch (error) {
        setState(() => encryptionState = EncryptionState.failed);
        rethrow;
      } finally {
        schedulePopBack();
      }
    } on PlatformException catch (error) {
      debugPrint(error.toString());
    } on TimeoutException catch (error) {
      debugPrint(error.toString());
    } on StateError catch (_) {
      setState(() => servicesState = BTServiceState.failed);
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }

  Future<bool> handleAuthentication() async {
    setState(() => authState = LocalAuthState.authenticating);

    return await localAuth.authenticate(
      localizedReason: "PiBLE requires authentication in order to continue.",
    );
  }

  Future<void> encryptData(BluetoothService service) async {
    setState(() => encryptionState = EncryptionState.encrypting);

    String nonce = generateNonce();
    String uid = await _storage.read(key: "CSIPRO-ACCESS-FIREBASE-UID") ?? "";
    String passcode = await _storage.read(key: "CSIPRO-PASSCODE") ?? "";
    int expiryDate =
        DateTime.now().add(const Duration(seconds: 30)).millisecondsSinceEpoch;
    String concatenated = "$nonce:$uid:$passcode:$expiryDate";
    final cipher = AesCrypt(
      padding: PaddingAES.pkcs7,
      key: base64.encode(encryptionString!.codeUnits),
    );

    final encryptedString = base64.encode(
      cipher.cbc
          .encrypt(inp: concatenated, iv: base64.encode(ivValue!.codeUnits))
          .codeUnits,
    );

    final tokenCharacteristic = service.characteristics.firstWhere(
      (cha) => cha.uuid.toString() == tokenCharacteristicUuid,
    );

    await tokenCharacteristic.write(encryptedString.codeUnits);
  }

  @override
  void dispose() {
    if (isScanning) {
      flutterBlue.stopScan();
    }

    scanningSub?.cancel();
    scanResultsSub?.cancel();
    deviceStateSub?.cancel();

    pible?.disconnect();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CSIAppBar("PiBLE"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BluetoothBubble(isBluetoothOn: isBluetoothOn),
              ScanningBubble(
                isScanning: isScanning,
                onTap: !isScanning && pible == null || canRescan
                    ? _restartScan
                    : null,
              ),
              DeviceBubble(state: deviceState),
              ServicesBubble(state: servicesState),
              AuthBubble(state: authState),
              Flexible(child: EncryptionBubble(state: encryptionState)),
            ].reversed.toList(),
          ),
        ),
      ),
    );
  }
}

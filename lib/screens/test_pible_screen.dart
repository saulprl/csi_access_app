import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:math";

import "package:csi_door_logs/utils/enums.dart";
import "package:csi_door_logs/utils/routes.dart";
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

class TestPibleScreen extends StatefulWidget {
  const TestPibleScreen({super.key});

  @override
  State<TestPibleScreen> createState() => _TestPibleScreenState();
}

class _TestPibleScreenState extends State<TestPibleScreen> {
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
  BTServiceState servicesState = BTServiceState.waiting;
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;
  LocalAuthState authState = LocalAuthState.waiting;
  EncryptionState encryptionState = EncryptionState.waiting;

  late StreamSubscription scanningSub;
  late StreamSubscription scanResultsSub;
  late StreamSubscription deviceStateSub;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      flutterBlue.isOn.then((value) => setState(() => isBluetoothOn = value));
      scanningSub = flutterBlue.isScanning.listen(
        (state) => setState(() => isScanning = state),
      );

      // flutterBlue.connectedDevices.then((devices) {
      //   if (mounted) {
      //     debugPrint("Found connected devices: $devices");
      //     devices.firstWhere((device) => device.name == "PiBLE").disconnect();
      //   }
      // });
      // const duration = Duration(seconds: 4);
      // Future.delayed(
      //   duration,
      //   () => setState(() => deviceState = BluetoothDeviceState.connecting),
      // ).then((_) {
      //   Future.delayed(
      //     duration,
      //     () {
      //       setState(() => deviceState = BluetoothDeviceState.connected);
      //       setState(() => servicesState = BTServiceState.discovering);
      //     },
      //   ).then((_) {
      //     Future.delayed(
      //       duration,
      //       () {
      //         setState(() => servicesState = BTServiceState.done);
      //         setState(() => authState = LocalAuthState.authenticating);
      //       },
      //     ).then((_) {
      //       Future.delayed(
      //         duration,
      //         () {
      //           setState(() => authState = LocalAuthState.done);
      //           setState(() => encryptionState = EncryptionState.encrypting);
      //         },
      //       ).then((_) {
      //         Future.delayed(
      //           duration,
      //           () {
      //             setState(() => encryptionState = EncryptionState.done);
      //             schedulePopBack();
      //           },
      //         );
      //       });
      //     });
      //   });
      // });

      // Discover devices
      discoverDevices();

      _isInit = true;
    }

    super.didChangeDependencies();
  }

  void popBack() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(Routes.dashboard);
    }
  }

  void schedulePopBack({int seconds = 3}) {
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

    flutterBlue.startScan(
      timeout: const Duration(seconds: 6),
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
            pible!.connect(
              autoConnect: true,
              timeout: const Duration(seconds: 8),
            );

            try {
              deviceStateSub = pible!.state.listen(
                (state) {
                  if (mounted) {
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

    final isBiometricSupported = await localAuth.isDeviceSupported();

    final authenticated = await localAuth.authenticate(
      localizedReason: "PiBLE requires authentication in order to continue.",
      options: AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
      ),
    );

    return authenticated;
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

    scanningSub.cancel();
    scanResultsSub.cancel();
    deviceStateSub.cancel();

    if (deviceState != BluetoothDeviceState.disconnected && pible != null) {
      pible!.disconnect();
    }
    pible = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CSIAppBar("PiBLE"),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            BluetoothBubble(isBluetoothOn: isBluetoothOn),
            ScanningBubble(
              isScanning: isScanning,
              onTap: !isScanning && pible == null ? discoverDevices : null,
            ),
            DeviceBubble(state: deviceState),
            ServicesBubble(state: servicesState),
            AuthBubble(state: authState),
            Flexible(child: EncryptionBubble(state: encryptionState)),
          ].reversed.toList(),
        ),
      ),
    );
  }
}

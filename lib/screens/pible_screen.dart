import 'dart:async';
import 'dart:io';
import "dart:math";
import "dart:convert";

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import "package:local_auth/local_auth.dart";
import 'package:permission_handler/permission_handler.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import 'package:steel_crypt/steel_crypt.dart';

enum BTConnectionState {
  starting,
  discovering,
  connecting,
  authenticating,
  failed,
  done,
}

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
  var pibleState = BTConnectionState.starting;
  bool _isInit = false;

  @override
  didChangeDependencies() {
    if (!_isInit) {
      _isInit = true;

      discoverDevices();
    }

    super.didChangeDependencies();
  }

  void popBack() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String generateNonce() {
    final random = Random.secure();
    final nonceBytes = List.generate(16, (_) => random.nextInt(256));
    final nonce = base64.encode(nonceBytes);

    return nonce;
  }

  Future<void> discoverDevices() async {
    if (Platform.isAndroid) {
      if (await Permission.bluetoothConnect.isGranted &&
          !await flutterBlue.isOn) {
        flutterBlue.turnOn();
      } else if (!await flutterBlue.isOn) {
        PermissionStatus status = await Permission.bluetoothConnect.request();
        if (status == PermissionStatus.granted) {
          flutterBlue.turnOn();
        }
      }
    }

    setState(() {
      pibleState = BTConnectionState.discovering;
    });
    flutterBlue.startScan(
      timeout: const Duration(seconds: 6),
      macAddresses: [pibleAddress!],
    ).then((_) {
      if (mounted) {
        if (pible == null) {
          setState(() {
            pibleState = BTConnectionState.done;
          });
        }
      }
    });

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        print("Connetable ${r.advertisementData.connectable}");
        if (r.advertisementData.localName == "PiBLE") {
          // print("Found PiBLE!");
          if (mounted) {
            setState(() {
              pible = r.device;
              pibleState = BTConnectionState.connecting;
            });

            flutterBlue.stopScan();
            handleConnection();
          }
        }
      }
    });
  }

  Future<void> handleConnection() async {
    try {
      if (pible == null) {
        setState(() {
          pibleState = BTConnectionState.done;
        });

        return;
      }

      try {
        await pible!.connect(
          autoConnect: true,
          timeout: const Duration(seconds: 8),
        );
      } on PlatformException catch (error) {
        print(error);
        await flutterBlue.stopScan();
        await discoverDevices();
      }

      pible!.state.listen((event) async {
        if (pible != null && event == BluetoothDeviceState.connected) {
          List<BluetoothService> services = await pible!.discoverServices();
          bool foundService = false;
          for (final svc in services) {
            // print(svc.uuid);
            if (svc.uuid.toString() == serviceUuid) {
              // print("Found the service!");
              foundService = true;

              final auth = await handleAuthentication();
              setState(() {
                pibleState = BTConnectionState.authenticating;
              });

              if (auth) {
                String nonce = generateNonce();
                String uid =
                    await _storage.read(key: "CSIPRO-ACCESS-FIREBASE-UID") ??
                        "";
                String passcode =
                    await _storage.read(key: "CSIPRO-PASSCODE") ?? "";
                int expiryDate = DateTime.now()
                    .add(const Duration(seconds: 30))
                    .millisecondsSinceEpoch;
                String concatenated = "$nonce:$uid:$passcode:$expiryDate";
                final cipher = AesCrypt(
                  padding: PaddingAES.pkcs7,
                  key: base64.encode(encryptionString!.codeUnits),
                );

                final encryptedString = base64.encode(cipher.cbc
                    .encrypt(
                      inp: concatenated,
                      iv: base64.encode(ivValue!.codeUnits),
                    )
                    .codeUnits);

                final tokenCharacteristic = svc.characteristics.firstWhere(
                  (cha) => cha.uuid.toString() == tokenCharacteristicUuid,
                );

                await tokenCharacteristic.write(encryptedString.codeUnits);
              } else {
                popBack();
              }
            }
          }

          await pible!.disconnect();
          pible = null;
          if (mounted) {
            if (foundService) {
              setState(() {
                pibleState = BTConnectionState.done;
              });
              Future.delayed(const Duration(seconds: 3), () => popBack());
            } else {
              setState(() {
                pibleState = BTConnectionState.failed;
              });
            }
          }
        }
      });
    } on TimeoutException catch (error) {
      print(error.toString());
      setState(() {
        pibleState = BTConnectionState.failed;
      });
    } catch (error) {
      print(error.toString());
      print(error.hashCode);
    }
  }

  Future<bool> handleAuthentication() async {
    final isBiometricSupported = await localAuth.isDeviceSupported();
    // print("handleAuth - isBioSupp: $isBiometricSupported");

    final canCheckBiometrics = await localAuth.canCheckBiometrics;
    // print("handleAuth - canCheckBio: $canCheckBiometrics");

    final biometricTypes = await localAuth.getAvailableBiometrics();
    // print("handleAuth - bioTypes: $biometricTypes");

    final authenticated = await localAuth.authenticate(
      localizedReason: "PiBLE requires authentication in order to continue.",
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
        sensitiveTransaction: true,
        useErrorDialogs: true,
      ),
    );

    return authenticated;
  }

  @override
  void dispose() {
    if (pible != null) {
      pible!.disconnect();
      pible = null;
    }

    if (pibleState == BTConnectionState.discovering) {
      flutterBlue.stopScan();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PiBLE"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bluetooth,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16.0),
                if (pibleState == BTConnectionState.discovering)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Looking for ",
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.black54,
                          ),
                          children: [
                            TextSpan(
                              text: "PiBLE",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const TextSpan(text: "..."),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const CircularProgressIndicator(),
                    ],
                  ),
                if (pibleState == BTConnectionState.starting)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Preparing ",
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.black54,
                          ),
                          children: [
                            TextSpan(
                              text: "Bluetooth",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const TextSpan(text: "..."),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (pibleState == BTConnectionState.connecting)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Connecting to ",
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.black54,
                          ),
                          children: [
                            TextSpan(
                              text: "PiBLE",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const TextSpan(text: "..."),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const CircularProgressIndicator(),
                    ],
                  ),
                if (pibleState == BTConnectionState.authenticating)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: const TextSpan(
                          text: "Authenticating...",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const CircularProgressIndicator(),
                    ],
                  ),
                if (pible != null && pibleState == BTConnectionState.done)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Don't forget to ",
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.black54,
                          ),
                          children: [
                            TextSpan(
                              text: "close the door",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const TextSpan(text: "!"),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: "Navigating back to ",
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.black54,
                          ),
                          children: [
                            TextSpan(
                              text: "Dashboard",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const TextSpan(text: "..."),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (pible == null && pibleState == BTConnectionState.done)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Unable to find ",
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.black54,
                          ),
                          children: [
                            TextSpan(
                              text: "PiBLE",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        style: ButtonStyle(
                          padding: const MaterialStatePropertyAll(
                            EdgeInsets.all(12.0),
                          ),
                          shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        onPressed: discoverDevices,
                        child: const Text(
                          "Retry",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (pibleState == BTConnectionState.failed)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Unable to connect to ",
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.black54,
                          ),
                          children: [
                            TextSpan(
                              text: "PiBLE",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        style: ButtonStyle(
                          padding: const MaterialStatePropertyAll(
                            EdgeInsets.all(12.0),
                          ),
                          shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        onPressed: discoverDevices,
                        child: const Text(
                          "Retry",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

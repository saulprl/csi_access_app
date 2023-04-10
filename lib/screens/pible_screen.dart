import 'dart:io';
import "dart:math";
import "dart:convert";

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import "package:local_auth/local_auth.dart";
import 'package:permission_handler/permission_handler.dart';

const serviceUuid = "4655318c-0b41-4725-9c64-44f9fb6098a2";
const pibleAddress = "B8:27:EB:07:51:17";
const tokenCharacteristicUuid = "4d493467-5cd5-4a9c-8389-2e569f68bb10";
const chunkCharacteristicUuid = "23c3e9a5-b0ee-45d7-97e1-3163519edd4e";
const characteristicValue = "CSIPRO_PiBLE__AUTH";

class PibleScreen extends StatefulWidget {
  const PibleScreen({super.key});

  @override
  State<PibleScreen> createState() => _PibleScreenState();
}

class _PibleScreenState extends State<PibleScreen> {
  final auth = FirebaseAuth.instance;
  final flutterBlue = FlutterBluePlus.instance;
  final localAuth = LocalAuthentication();

  BluetoothDevice? pible;
  bool _isConnecting = false;
  bool _isDiscovering = false;
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
    Navigator.of(context).pop();
  }

  Future<String> generateToken() async {
    final token = await auth.currentUser!.getIdToken();

    return token;
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
      _isDiscovering = true;
    });
    flutterBlue.startScan(
      timeout: const Duration(seconds: 6),
      macAddresses: [pibleAddress],
    ).then((_) {
      setState(() {
        _isDiscovering = false;
      });

      if (pible == null) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });
      }
    });

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name == "PiBLE" &&
            r.device.id.toString() == pibleAddress) {
          // print("Found PiBLE!");
          if (mounted) {
            setState(() {
              pible = r.device;
              _isDiscovering = false;
              _isConnecting = true;
            });

            flutterBlue.stopScan();
            handleConnection();
          }
        }
      }
    });
  }

  Future<void> handleConnection() async {
    if (pible == null) return;

    await pible!.connect(autoConnect: false);
    List<BluetoothService> services = await pible!.discoverServices();
    for (final svc in services) {
      // print(svc.uuid);
      if (svc.uuid.toString() == serviceUuid) {
        // print("Found the service!");

        final chunkCharacteristic = svc.characteristics.firstWhere(
          (cha) => cha.uuid.toString() == chunkCharacteristicUuid,
        );
        final auth = await handleAuthentication();
        print("handleConn - auth: $auth");
        setState(() {
          _isConnecting = false;
        });

        if (auth) {
          String token = await generateToken();
          const chunkSize = 425;

          final chunks = List.generate(
            (token.length / chunkSize).ceil(),
            (i) => token.substring(
              i * chunkSize,
              min((i + 1) * chunkSize, token.length),
            ),
          );
          await chunkCharacteristic.write([chunks.length]);
          debugPrint(chunks.length.toString());

          final tokenCharacteristic = svc.characteristics.firstWhere(
            (cha) => cha.uuid.toString() == tokenCharacteristicUuid,
          );

          for (final chunk in chunks) {
            await tokenCharacteristic.write(utf8.encode(chunk));
          }
        }
      }
    }

    await pible!.disconnect();
    popBack();
  }

  Future<bool> handleAuthentication() async {
    final isBiometricSupported = await localAuth.isDeviceSupported();
    print("handleAuth - isBioSupp: $isBiometricSupported");

    final canCheckBiometrics = await localAuth.canCheckBiometrics;
    print("handleAuth - canCheckBio: $canCheckBiometrics");

    final biometricTypes = await localAuth.getAvailableBiometrics();
    print("handleAuth - bioTypes: $biometricTypes");

    final authenticated = await localAuth.authenticate(
      localizedReason: "PiBLE requires authentication in order to continue.",
      options: const AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
        sensitiveTransaction: false,
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
                if (pible != null)
                  RichText(
                    text: TextSpan(
                      text: !_isConnecting ? "Connected to " : "Connecting to ",
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black54,
                      ),
                      children: [
                        TextSpan(
                          text: "PiBLE",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (_isConnecting) const TextSpan(text: "..."),
                      ],
                    ),
                  )
                else if (_isDiscovering)
                  RichText(
                    text: TextSpan(
                      text: "Scanning ",
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black54,
                      ),
                      children: [
                        TextSpan(
                          text: "Bluetooth",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const TextSpan(
                          text: " devices...",
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Unable to find ",
                          style: const TextStyle(
                            fontSize: 16.0,
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
                      RichText(
                        text: TextSpan(
                          text: "Navigating back to ",
                          style: const TextStyle(
                            fontSize: 16.0,
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
                            const TextSpan(
                              text: "...",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16.0),
                if (_isDiscovering || _isConnecting || pible != null)
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

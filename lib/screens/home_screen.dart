import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:local_auth/local_auth.dart";
// import "package:flutter_blue/flutter_blue.dart";
import "package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart";

import "package:csi_door_logs/widgets/main/csi_drawer.dart";
import "package:csi_door_logs/widgets/dashboard/summary/summary.dart";

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // FlutterBlue flutterBlue = FlutterBlue.instance;
  final auth = LocalAuthentication();
  bool? canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = "Not authorized";
  bool _isAuthenticating = false;
  StreamSubscription<BluetoothDiscoveryResult>? discoverySub;
  BluetoothConnection? connection;
  late FlutterBluetoothSerial btInstance;

  @override
  void initState() {
    super.initState();

    btInstance = FlutterBluetoothSerial.instance;
  }

  void _handleBluetoothConnection(BluetoothDevice host) async {
    print("Handling connection");
    connection = await BluetoothConnection.toAddress(host.address);
    print(connection!.isConnected);

    connection!.input!.listen((Uint8List data) async {
      print("Incoming data");

      String dataString = String.fromCharCodes(data);
      print(dataString);

      await _checkBiometrics();
    });
  }

  Future<void> _checkBiometrics() async {
    print("Checking");
    final result = await auth.authenticate(
      localizedReason: "Identify yourself!",
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
        sensitiveTransaction: true,
        useErrorDialogs: false,
      ),
    );

    if (result && connection != null) {
      connection!.output.add(Uint8List.fromList(utf8.encode("1#112C83")));
      await connection!.output.allSent;
      await connection!.close();

      _removeBottomSheet();
    }
  }

  void _startDiscovering() {
    discoverySub = btInstance.startDiscovery().listen((discovered) async {
      if (discovered.device.name == "raspberrypi") {
        print("Found device: ${discovered.device.toString()}");
        _handleBluetoothConnection(discovered.device);
      }
    });

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          height: 250.0,
          child: Column(
            children: [
              const Text("Connecting..."),
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeBottomSheet() {
    print("remove");
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    if (discoverySub != null) {
      discoverySub!.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      drawer: const CSIDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Summary(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startDiscovering,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.fingerprint, color: Colors.white),
      ),
    );
  }
}

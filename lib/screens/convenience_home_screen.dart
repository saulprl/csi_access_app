import 'package:csi_door_logs/widgets/pible/pible_device.dart';
import 'package:flutter/material.dart';
import 'package:csi_door_logs/widgets/main/csi_appbar.dart';
import 'package:csi_door_logs/widgets/main/csi_drawer.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConvenienceHomeScreen extends StatefulWidget {
  const ConvenienceHomeScreen({super.key});

  @override
  State<ConvenienceHomeScreen> createState() => _ConvenienceHomeScreenState();
}

class _ConvenienceHomeScreenState extends State<ConvenienceHomeScreen> {
  final flutterBlue = FlutterBluePlus.instance;

  final serviceUuid = dotenv.env["SERVICE_UUID"];

  final _devices = <ScanResult>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    discoverDevices();
  }

  Future<void> discoverDevices() async {
    flutterBlue.startScan(withServices: [Guid(serviceUuid!)]);

    flutterBlue.scanResults.listen((results) {
      setState(() {
        _devices.clear();
        _devices.addAll(results);
      });
    });
  }

  @override
  void dispose() {
    flutterBlue.stopScan();
    _devices.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CSIAppBar("Nearby Rooms"),
      drawer: CSIDrawer(),
      body: SafeArea(
        child: ListView.builder(
          itemCount: _devices.length,
          itemBuilder: (ctx, index) {
            final items = [..._devices];

            items.sort(
              (a, b) => a.advertisementData.localName
                  .compareTo(b.advertisementData.localName),
            );

            return PibleDevice(scanItem: items[index]);
          },
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:csi_door_logs/widgets/main/adaptive_spinner.dart';
import 'package:csi_door_logs/widgets/pible/pible_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PibleSlider extends StatefulWidget {
  const PibleSlider({super.key});

  @override
  State<PibleSlider> createState() => _PibleSliderState();
}

class _PibleSliderState extends State<PibleSlider> {
  final flutterBlue = FlutterBluePlus.instance;

  final serviceUuid = dotenv.env["SERVICE_UUID"];

  var _isConnecting = false;

  @override
  void initState() {
    discoverDevices();
    Timer.periodic(const Duration(seconds: 5), (_) {
      if (_isConnecting) {
        return;
      }

      discoverDevices();
    });

    super.initState();
  }

  Future<void> discoverDevices() async {
    setIsConnecting(false);
    await flutterBlue.stopScan();

    flutterBlue.startScan(
      scanMode: ScanMode.balanced,
      timeout: const Duration(seconds: 3),
      withServices: [Guid(serviceUuid!)],
    );
  }

  void setIsConnecting(bool value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isConnecting = value;
      });
    });
  }

  @override
  void dispose() {
    flutterBlue.stopScan();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8.0),
      height: 60.0,
      width: double.infinity,
      child: Stack(
        children: [
          StreamBuilder(
            stream: flutterBlue.scanResults,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final devices = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(4.0),
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: devices.length,
                  itemBuilder: (ctx, index) {
                    final items = [...devices];
                    items.sort(
                      (a, b) => a.advertisementData.localName
                          .compareTo(b.advertisementData.localName),
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: PibleChip(
                        scanItem: items[index],
                        onConnect: setIsConnecting,
                        isConnecting: _isConnecting,
                      ),
                    );
                  },
                );
              }

              return const Center(
                child: Text("No nearby devices"),
              );
            },
          ),
          if (_isConnecting)
            Center(
              child: AdaptiveSpinner(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}

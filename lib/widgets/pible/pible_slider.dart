import 'package:csi_door_logs/widgets/main/adaptive_spinner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:csi_door_logs/providers/pible_provider.dart';
import 'package:csi_door_logs/widgets/pible/pible_chip.dart';
import 'package:csi_door_logs/utils/styles.dart';

class PibleSlider extends StatefulWidget {
  const PibleSlider({super.key});

  @override
  State<PibleSlider> createState() => _PibleSliderState();
}

class _PibleSliderState extends State<PibleSlider> {
  final flutterBlue = FlutterBluePlus.instance;

  final serviceUuid = dotenv.env["SERVICE_UUID"];

  @override
  void initState() {
    // discoverDevices();
    // Timer.periodic(const Duration(seconds: 5), (_) {
    //   if (_isConnecting) {
    //     return;
    //   }

    //   discoverDevices();
    // });

    super.initState();
  }

  @override
  void dispose() {
    flutterBlue.stopScan();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pibleProvider = Provider.of<PibleProvider>(context);

    return Stack(
      children: [
        SizedBox(
          height: 48.0,
          child: pibleProvider.pibles.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: pibleProvider.pibles.length,
                  itemBuilder: (ctx, index) {
                    final items = [...pibleProvider.pibles];
                    items.sort(
                      (a, b) => a.name.compareTo(b.name),
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: PibleChip(pible: items[index]),
                    );
                  },
                )
              : Center(
                  child: Text(
                    "no nearby rooms",
                    style: pibleBubbleTextStyle.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
        ),
        if (!pibleProvider.isActive)
          Center(
            child: AdaptiveSpinner(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }
}

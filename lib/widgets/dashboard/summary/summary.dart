import "package:flutter/material.dart";

import 'package:provider/provider.dart';

import 'package:csi_door_logs/providers/logs_provider.dart';
import 'package:csi_door_logs/providers/pible_provider.dart';
import 'package:csi_door_logs/providers/room_provider.dart';

import 'package:csi_door_logs/widgets/dashboard/summary/bubble.dart';
import 'package:csi_door_logs/widgets/main/adaptive_spinner.dart';
import 'package:csi_door_logs/widgets/pible/pible_slider.dart';

import 'package:csi_door_logs/models/access_log.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  final skeletonHeight = 145.0;

  late DateTime now;

  @override
  void initState() {
    super.initState();

    now = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final rooms = Provider.of<RoomProvider>(context);
    final logs = Provider.of<LogsProvider>(context);

    if (rooms.selectedRoom.isEmpty) {
      return const Center(
        child: Text(
          "You haven't selected a room yet. You can do so at the top!",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.0,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // buildDivider(context, "Summary"),
        if (!rooms.isRoomless) logsBuilder(context, logs.currentDayLogs),
      ],
    );
  }

  Widget logsBuilder(BuildContext context, List<AccessLog> logs) {
    final pibleProvider = Provider.of<PibleProvider>(context);

    var accessCount = 0;
    var failedCount = 0;
    var unknownCount = 0;
    var bluetoothCount = 0;

    for (final log in logs) {
      if (log.accessed) {
        accessCount++;
      }
      if (!log.accessed) {
        failedCount++;
      }
      if (log.attempt?.csiId != null) {
        unknownCount++;
      }
      if (log.bluetooth) {
        bluetoothCount++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [successfulBubble(context, accessCount)]),
        Row(children: [bluetoothBubble(context, bluetoothCount)]),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "nearby rooms",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const PibleSlider(),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: Center(
                              child: pibleProvider.isConnecting
                                  ? const Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 12.0,
                                          height: 12.0,
                                          child: AdaptiveSpinner(
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 4.0),
                                        Text(
                                          "connecting",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  : StreamBuilder(
                                      stream: pibleProvider.isScanning,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          if (snapshot.data!) {
                                            return const Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 12.0,
                                                  height: 12.0,
                                                  child: AdaptiveSpinner(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(width: 4.0),
                                                Text(
                                                  "scanning",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            );
                                          }
                                        }

                                        return const Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.stop,
                                              color: Colors.white,
                                              size: 12.0,
                                            ),
                                            SizedBox(width: 4.0),
                                            Text(
                                              "stopped",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                            ),
                          ),
                          IconButton(
                            onPressed: pibleProvider.isActive
                                ? pibleProvider.pauseTimer
                                : pibleProvider.startTimer,
                            style: ButtonStyle(
                              side: MaterialStateProperty.all<BorderSide>(
                                const BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            icon: Icon(
                              pibleProvider.isActive
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            failedBubble(context, failedCount),
            unknownBubble(context, unknownCount),
          ],
        ),
      ],
    );
  }

  Expanded successfulBubble(BuildContext context, int? accessCount) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Bubble(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          color: Theme.of(context).colorScheme.primary,
          data: accessCount,
          label: 'successful attempts',
          crossAlignment: CrossAxisAlignment.end,
          reversed: true,
          textAlign: TextAlign.end,
        ),
      ),
    );
  }

  Expanded bluetoothBubble(BuildContext context, int? bluetoothCount) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Bubble(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          color: Theme.of(context).colorScheme.tertiary,
          data: bluetoothCount,
          label: 'bluetooth attempts',
          crossAlignment: CrossAxisAlignment.start,
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  Expanded failedBubble(BuildContext context, int? failedCount) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Bubble(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          color: Theme.of(context).colorScheme.secondary,
          data: failedCount,
          label: 'failed\nattempts',
          crossAlignment: CrossAxisAlignment.start,
          reversed: true,
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  Expanded unknownBubble(BuildContext context, int? unknownCount) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Bubble(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          color: Theme.of(context).colorScheme.error,
          data: unknownCount,
          reversed: true,
          label: 'unknown\nattempts',
          crossAlignment: CrossAxisAlignment.end,
          textAlign: TextAlign.end,
        ),
      ),
    );
  }

  Column skeletons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [successfulBubble(context, null)]),
        Row(children: [bluetoothBubble(context, null)]),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            failedBubble(context, null),
            unknownBubble(context, null),
          ],
        ),
      ],
    );
  }
}

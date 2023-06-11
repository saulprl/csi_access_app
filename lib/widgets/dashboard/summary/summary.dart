import "package:flutter/material.dart";

import 'package:firebase_database/firebase_database.dart';

import 'package:skeleton_animation/skeleton_animation.dart';

import 'package:csi_door_logs/widgets/dashboard/summary/bubble.dart';

import 'package:csi_door_logs/models/access_log.dart';
import 'package:csi_door_logs/utils/enums.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  final skeletonHeight = 145.0;
  late Query query;
  EncryptionState encryptionState = EncryptionState.encrypting;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    query = FirebaseDatabase.instance
        .ref("history")
        .orderByChild("timestamp")
        .startAt(
          DateTime(now.year, now.month, now.day).millisecondsSinceEpoch,
          key: "timestamp",
        );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: query.onValue,
      builder: (ctx, snapshot) {
        var accessCount = 0;
        var failedCount = 0;
        var unknownCount = 0;
        var bluetoothCount = 0;

        if (snapshot.hasData) {
          final accessLogs =
              AccessLog.fromStreamSnapshot(snapshot.data!.snapshot);
          for (var log in accessLogs) {
            if (log.accessed!) {
              accessCount++;
            }
            if (!log.accessed!) {
              failedCount++;
            }
            if (log.attemptData != null) {
              unknownCount++;
            }
            if (log.bluetooth != null && log.bluetooth!) {
              bluetoothCount++;
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Bubble(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32.0,
                          vertical: 16.0,
                        ),
                        borderRadius: BorderRadius.circular(32.0),
                        color: Theme.of(context).colorScheme.primary,
                        data: accessCount,
                        label: 'successful attempts',
                        crossAlignment: CrossAxisAlignment.end,
                        reversed: true,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Bubble(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32.0,
                          vertical: 16.0,
                        ),
                        borderRadius: BorderRadius.circular(32.0),
                        color: Theme.of(context).colorScheme.tertiary,
                        data: bluetoothCount,
                        label: 'bluetooth attempts',
                        crossAlignment: CrossAxisAlignment.start,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Bubble(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32.0),
                          topRight: Radius.circular(12.0),
                          bottomRight: Radius.circular(32.0),
                          bottomLeft: Radius.circular(12.0),
                        ),
                        color: Theme.of(context).colorScheme.secondary,
                        data: failedCount,
                        label: 'failed\nattempts',
                        crossAlignment: CrossAxisAlignment.start,
                        reversed: true,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Bubble(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(32.0),
                          bottomRight: Radius.circular(12.0),
                          bottomLeft: Radius.circular(32.0),
                        ),
                        color: Theme.of(context).colorScheme.error,
                        data: unknownCount,
                        reversed: true,
                        label: 'unknown\nattempts',
                        crossAlignment: CrossAxisAlignment.end,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Skeleton(
                        height: skeletonHeight,
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Skeleton(
                        height: skeletonHeight,
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Skeleton(
                        height: skeletonHeight * 1.2,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32.0),
                          topRight: Radius.circular(12.0),
                          bottomRight: Radius.circular(32.0),
                          bottomLeft: Radius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Skeleton(
                        height: skeletonHeight * 1.2,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(32.0),
                          bottomRight: Radius.circular(12.0),
                          bottomLeft: Radius.circular(32.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

import "package:flutter/material.dart";
import 'package:firebase_database/firebase_database.dart';
import 'package:skeleton_animation/skeleton_animation.dart';

import 'package:csi_door_logs/widgets/dashboard/summary/bubble.dart';

import 'package:csi_door_logs/models/access_log.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  late Query query;

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

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                right: 8.0,
                bottom: 16.0,
                left: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  accessCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 56.0,
                                  ),
                                ),
                                const Text(
                                  'successful attempts',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ],
                            ),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bluetoothCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 56.0,
                                  ),
                                ),
                                const Text(
                                  'bluetooth attempts',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  failedCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 52.0,
                                  ),
                                ),
                                const Text(
                                  'failed\nattempts',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 4.0,
                            top: 4.0,
                            right: 4.0,
                            bottom: 4.0,
                          ),
                          child: Bubble(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12.0),
                              topRight: Radius.circular(32.0),
                              bottomRight: Radius.circular(12.0),
                              bottomLeft: Radius.circular(32.0),
                            ),
                            color: Theme.of(context).colorScheme.error,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  unknownCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 52.0,
                                  ),
                                ),
                                const Text(
                                  'unknown\nattempts',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
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
                          height: 150.0,
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
                          height: 150.0,
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
                          height: 150.0,
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
                          height: 150.0,
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
          ),
        );
      },
    );
  }
}

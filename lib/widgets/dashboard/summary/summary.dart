import 'package:csi_door_logs/utils/utils.dart';
import "package:flutter/material.dart";

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:skeleton_animation/skeleton_animation.dart';

import 'package:csi_door_logs/widgets/dashboard/summary/bubble.dart';

import 'package:csi_door_logs/models/access_log.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  final _firestore = FirebaseFirestore.instance;
  final skeletonHeight = 145.0;

  late DateTime now;

  @override
  void initState() {
    super.initState();

    now = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildDashboardDivider(context, "Summary"),
        StreamBuilder(
          stream: _firestore
              .collection("logs")
              .where(
                "timestamp",
                isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(now.year, now.month, now.day),
                ),
              )
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: streamBuilder,
        ),
      ],
    );
  }

  Widget streamBuilder(
    BuildContext context,
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
  ) {
    var accessCount = 0;
    var failedCount = 0;
    var unknownCount = 0;
    var bluetoothCount = 0;

    if (snapshot.hasData && snapshot.data != null) {
      final docs = snapshot.data!.docs;

      for (final doc in docs) {
        final log = AccessLog.fromQueryDocSnapshot(doc);

        if (log.accessed) {
          accessCount++;
        }
        if (!log.accessed) {
          failedCount++;
        }
        if (log.attemptData != null) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              failedBubble(context, failedCount),
              unknownBubble(context, unknownCount),
            ],
          ),
        ],
      );
    }

    return skeletons;
  }

  Expanded successfulBubble(BuildContext context, int accessCount) {
    return Expanded(
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
    );
  }

  Expanded bluetoothBubble(BuildContext context, int bluetoothCount) {
    return Expanded(
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
    );
  }

  Expanded failedBubble(BuildContext context, int failedCount) {
    return Expanded(
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
    );
  }

  Expanded unknownBubble(BuildContext context, int unknownCount) {
    return Expanded(
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
    );
  }

  SizedBox get skeletons {
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
  }
}

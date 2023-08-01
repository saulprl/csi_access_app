import 'package:csi_door_logs/providers/room_provider.dart';
import 'package:csi_door_logs/utils/utils.dart';
import "package:flutter/material.dart";

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:csi_door_logs/widgets/dashboard/summary/bubble.dart';

import 'package:csi_door_logs/models/access_log.dart';
import 'package:provider/provider.dart';

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
    final rooms = Provider.of<RoomProvider>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildDivider(context, "Summary"),
        if (!rooms.isRoomless)
          FutureBuilder(
            future: _firestore.doc("rooms/${rooms.selectedRoom}").get(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return skeletons(context);
              }

              if (snap.hasData && snap.data != null) {
                final roomRef = snap.data!.reference;

                return StreamBuilder(
                  stream: _firestore
                      .collection("logs")
                      .where("room", isEqualTo: roomRef)
                      .where(
                        "timestamp",
                        isGreaterThanOrEqualTo: Timestamp.fromDate(
                          DateTime(now.year, now.month, now.day),
                        ),
                      )
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: streamBuilder,
                );
              }

              return const Center(
                child: Text(
                  "You haven't selected a room yet. You can do so at the top!",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18.0,
                  ),
                ),
              );
            },
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
        if (log.attempt != null) {
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

    return skeletons(context);
  }

  Expanded successfulBubble(BuildContext context, int? accessCount) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Bubble(
          padding: const EdgeInsets.symmetric(
            horizontal: 32.0,
            vertical: 16.0,
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(32.0),
            bottom: Radius.circular(12.0),
          ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: 32.0,
            vertical: 16.0,
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(12.0),
            bottom: Radius.circular(32.0),
          ),
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
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(32.0),
            right: Radius.circular(12.0),
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

  Expanded unknownBubble(BuildContext context, int? unknownCount) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Bubble(
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(12.0),
            right: Radius.circular(32.0),
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

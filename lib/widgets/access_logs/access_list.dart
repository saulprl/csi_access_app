import "package:flutter/material.dart";

import "package:cloud_firestore/cloud_firestore.dart";

import "package:csi_door_logs/widgets/access_logs/access_log_item.dart";
import "package:csi_door_logs/widgets/admin/skeleton_list.dart";

import 'package:csi_door_logs/models/models.dart';

class AccessList extends StatefulWidget {
  const AccessList({super.key});

  @override
  State<AccessList> createState() => _AccessListState();
}

class _AccessListState extends State<AccessList> {
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestore
            .collection("logs")
            .orderBy(
              "timestamp",
              descending: true,
            )
            .limit(20)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final logItems = <Widget>[];

            for (final doc in snapshot.data!.docs) {
              logItems.add(AccessLogItem(AccessLog.fromQueryDocSnapshot(doc)));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: logItems,
            );
          }

          return const SkeletonList(count: 20, height: 60.0);
        });
    // ListView.builder(
    //   padding: const EdgeInsets.symmetric(
    //     horizontal: 8.0,
    //     vertical: 4.0,
    //   ),
    //   itemCount: _accessLogs.length,
    //   reverse: false,
    //   itemBuilder: (ctx, index) {
    //     final csiId = _accessLogs[index].csiId!;
    //     final dateTime =
    //         DateTime.fromMillisecondsSinceEpoch(_accessLogs[index].timestamp!);
    //     final accessed = _accessLogs[index].accessed!;

    //     return AccessLogItem(
    //       key: ValueKey(dateTime.millisecondsSinceEpoch),
    //       csiId: csiId,
    //       date: dateTime,
    //       accessed: accessed,
    //     );
    //   },
    // );
  }
}

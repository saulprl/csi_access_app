import "dart:async";

import "package:flutter/material.dart";

import "package:firebase_database/firebase_database.dart";

import "package:csi_door_logs/widgets/access_logs/access_log_item.dart";

import 'package:csi_door_logs/models/models.dart';

class AccessList extends StatefulWidget {
  const AccessList({super.key});

  @override
  State<AccessList> createState() => _AccessListState();
}

class _AccessListState extends State<AccessList> {
  final query = FirebaseDatabase.instance
      .ref("history")
      .orderByChild("timestamp")
      .limitToLast(20);

  final _accessLogs = <AccessLog>[];
  late StreamSubscription<DatabaseEvent> logAdd;
  late StreamSubscription<DatabaseEvent> logRemove;

  @override
  void initState() {
    super.initState();

    // logAdd = query.onChildAdded.listen((event) {
    //   onLogAdded(event.snapshot);
    // });

    // logRemove = query.onChildRemoved.listen((event) {
    //   onLogRemoved(event.snapshot);
    // });
  }

  // void onLogAdded(DataSnapshot snapshot) {
  //   setState(() {
  //     _accessLogs.insert(0, AccessLog.fromSnapshot(snapshot));
  //   });
  // }

  // void onLogRemoved(DataSnapshot snapshot) {
  //   setState(() {
  //     _accessLogs.removeWhere((log) => log.key == snapshot.key);
  //   });
  // }

  @override
  void dispose() {
    // logAdd.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: query.onValue,
        builder: (ctx, snapshot) {
          final logItems = <Widget>[];
          if (snapshot.hasData) {
            final accessLogs =
                AccessLog.fromStreamSnapshot(snapshot.data!.snapshot);

            for (final log in accessLogs) {
              logItems.insert(
                0,
                AccessLogItem(
                  key: ValueKey(log.timestamp!),
                  csiId: log.csiId!,
                  date: DateTime.fromMillisecondsSinceEpoch(log.timestamp!),
                  accessed: log.accessed!,
                ),
              );
            }
          }

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 4.0,
              vertical: 4.0,
            ),
            children: logItems,
          );
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

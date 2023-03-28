import "dart:async";

import "package:csi_door_logs/widgets/access_logs/access_log_item.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/material.dart";
import "package:firebase_database/firebase_database.dart";

import 'package:csi_door_logs/models/models.dart';

class AccessList extends StatefulWidget {
  const AccessList({super.key});

  @override
  State<AccessList> createState() => _AccessListState();
}

class _AccessListState extends State<AccessList> {
  final fcm = FirebaseMessaging.instance;
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

    fcm.subscribeToTopic("access_logs");
    fcm.subscribeToTopic("event_logs");
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
            (snapshot.data!.snapshot.value as Map<dynamic, dynamic>)
                .forEach((key, value) {
              final accessLog = AccessLog.fromValue(key, value);
              print(accessLog.toJson());
              final logItem = AccessLogItem(
                key: ValueKey(accessLog.timestamp),
                csiId: accessLog.csiId!,
                date: DateTime.fromMillisecondsSinceEpoch(accessLog.timestamp!),
                accessed: accessLog.accessed!,
              );

              logItems.add(logItem);
            });
          }

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
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

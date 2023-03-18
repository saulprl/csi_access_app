import "dart:async";

import "package:csi_door_logs/widgets/access_logs/access_log_item.dart";
import "package:flutter/material.dart";
import "package:firebase_database/firebase_database.dart";

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
  late StreamSubscription<DatabaseEvent> updates;

  @override
  void initState() {
    super.initState();

    updates = query.onChildAdded.listen((event) {
      onLogAdded(event.snapshot);
    });
  }

  void onLogAdded(DataSnapshot snapshot) {
    setState(() {
      _accessLogs.add(AccessLog.fromSnapshot(snapshot));
    });
  }

  @override
  void dispose() {
    updates.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _accessLogs.length,
      reverse: false,
      itemBuilder: (ctx, index) {
        final csiId = _accessLogs[index].csiId!;
        final dateTime =
            DateTime.fromMillisecondsSinceEpoch(_accessLogs[index].timestamp!);
        final accessed = _accessLogs[index].accessed!;

        return AccessLogItem(
          key: ValueKey(dateTime.millisecondsSinceEpoch),
          csiId: csiId,
          date: dateTime,
          accessed: accessed,
        );
      },
    );
  }
}

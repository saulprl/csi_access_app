import "dart:async";

import "package:firebase_database/firebase_database.dart";
import "package:flutter/material.dart";

import "package:csi_door_logs/models/models.dart";

class AccessLogItem extends StatefulWidget {
  final int csiId;
  final DateTime date;
  final bool accessed;
  final Attempt? attempt;

  const AccessLogItem({
    required this.csiId,
    required this.date,
    required this.accessed,
    this.attempt,
    super.key,
  });

  @override
  State<AccessLogItem> createState() => _AccessLogItemState();
}

class _AccessLogItemState extends State<AccessLogItem> {
  final ref = FirebaseDatabase.instance.ref("users");
  User? _user;
  late StreamSubscription<DatabaseEvent> updates;

  @override
  void initState() {
    super.initState();

    updates = ref
        .orderByChild("csiId")
        .equalTo(widget.csiId)
        .limitToFirst(1)
        .onValue
        .listen((event) => setUser(event.snapshot));
  }

  @override
  void dispose() {
    updates.cancel();

    super.dispose();
  }

  void setUser(DataSnapshot snapshot) {
    setState(() {
      _user = User.fromSnapshot(snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: _user != null
          ? ListTile(
              title: Text(
                _user!.name ?? "Loading",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32.0,
                ),
                textAlign: TextAlign.center,
              ),
              subtitle: Text(
                widget.date.toIso8601String().split("T").join(" "),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
              contentPadding: const EdgeInsets.only(bottom: 4.0),
              style: ListTileStyle.list,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              tileColor: Theme.of(context).colorScheme.primary,
            )
          : ListTile(
              title: const Text(
                "Usuario desconocido",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              ),
              subtitle: Text(
                widget.date.toIso8601String().split("T").join(" "),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
              contentPadding: const EdgeInsets.only(bottom: 4.0),
              style: ListTileStyle.list,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              tileColor: Theme.of(context).colorScheme.secondary,
            ),
    );
  }
}

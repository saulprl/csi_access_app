import "dart:async";

import "package:flutter/material.dart";
import "package:firebase_database/firebase_database.dart";
import "package:skeleton_animation/skeleton_animation.dart";

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
  CSIUser? _user;
  late StreamSubscription<DatabaseEvent> updates;

  @override
  void initState() {
    super.initState();

    updates = ref
        .orderByChild("csiId")
        .equalTo(widget.csiId)
        .limitToFirst(1)
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        setUser(event.snapshot);
      }
    });
  }

  @override
  void dispose() {
    updates.cancel();

    super.dispose();
  }

  void setUser(DataSnapshot snapshot) {
    setState(() {
      _user = CSIUser.fromSnapshot(snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: ListTile(
        tileColor: widget.accessed
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        style: ListTileStyle.list,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 2.0,
        ),
        title: widget.accessed
            ? _user != null
                ? Text(
                    _user!.name!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  )
                : Skeleton(
                    textColor: Colors.white24,
                    style: SkeletonStyle.text,
                    height: 32.0,
                  )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Usuario desconocido",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.date
                            .toIso8601String()
                            .split("T")
                            .last
                            .split(".")
                            .first,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                      ),
                      Text(
                        widget.date.toIso8601String().split("T").first,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        subtitle: widget.accessed
            ? RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.date.toIso8601String().split("T").first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                    const TextSpan(text: " "),
                    TextSpan(
                      text: widget.date
                          .toIso8601String()
                          .split("T")
                          .last
                          .split(".")
                          .first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}

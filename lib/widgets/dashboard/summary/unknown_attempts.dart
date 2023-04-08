import "package:csi_door_logs/models/models.dart";
import "package:firebase_database/firebase_database.dart";
import "package:flutter/material.dart";

class UnknownAttempts extends StatefulWidget {
  const UnknownAttempts({super.key});

  @override
  State<UnknownAttempts> createState() => _UnknownAttemptsState();
}

class _UnknownAttemptsState extends State<UnknownAttempts> {
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
        var unknownAttempts = 0;
        if (snapshot.hasData) {
          final accessLogs =
              AccessLog.fromStreamSnapshot(snapshot.data!.snapshot);
          accessLogs.removeWhere((log) => log.attemptData == null);

          unknownAttempts = accessLogs.length;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 130.0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    unknownAttempts.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 64.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "unknown",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 24.0,
                    ),
                  ),
                  const Text(
                    "attempts",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 24.0,
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

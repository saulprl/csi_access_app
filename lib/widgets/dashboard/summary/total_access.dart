import "package:flutter/material.dart";

import "package:firebase_database/firebase_database.dart";

import "package:csi_door_logs/models/models.dart";

class TotalAccess extends StatefulWidget {
  const TotalAccess({super.key});

  @override
  State<TotalAccess> createState() => _TotalAccessState();
}

class _TotalAccessState extends State<TotalAccess> {
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
        if (snapshot.hasData) {
          final accessLogs =
              AccessLog.fromStreamSnapshot(snapshot.data!.snapshot);

          accessLogs.removeWhere((log) => !log.accessed!);
          accessCount = accessLogs.length;
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
                    color: Theme.of(context).colorScheme.tertiary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    accessCount.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 64.0,
                      fontWeight: FontWeight.normal,
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
                    "successful",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
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

        // return RichText(
        //   text: TextSpan(
        //     text: accessCount.toString(),
        //     style: const TextStyle(
        //       fontSize: 56.0,
        //       fontFamily: "Poppins",
        //       fontWeight: FontWeight.bold,
        //       color: Colors.black87,
        //     ),
        //     children: const [
        //       TextSpan(
        //         text: "successful\naccesses",
        //         style: TextStyle(fontSize: 28.0),
        //       ),
        //     ],
        //   ),
        // );
      },
    );
  }
}

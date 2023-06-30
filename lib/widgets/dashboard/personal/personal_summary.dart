import "package:csi_door_logs/utils/utils.dart";
import "package:flutter/material.dart";

import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

import "package:skeleton_animation/skeleton_animation.dart";

import "package:csi_door_logs/widgets/dashboard/summary/bubble.dart";

import "package:csi_door_logs/models/models.dart";

class PersonalSummary extends StatefulWidget {
  const PersonalSummary({super.key});

  @override
  State<PersonalSummary> createState() => _PersonalSummaryState();
}

class _PersonalSummaryState extends State<PersonalSummary> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final skeletonHeight = 145.0;
  late DateTime now;
  late CSIUser csiUser;

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
        buildDashboardDivider(context, "Personal Data"),
        FutureBuilder(
          future:
              _firestore.collection("users").doc(_auth.currentUser!.uid).get(),
          builder: futureBuilder,
        ),
      ],
    );
  }

  Widget futureBuilder(
    BuildContext ctx,
    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
  ) {
    if (snapshot.hasData && snapshot.data != null) {
      final userRef = snapshot.data!.reference;

      return StreamBuilder(
        stream: _firestore
            .collection("logs")
            .where("user", isEqualTo: userRef)
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

    return skeletons;
  }

  Widget streamBuilder(
    BuildContext ctx,
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
  ) {
    var accessed = 0;
    var failed = 0;

    if (snapshot.hasData && snapshot.data != null) {
      final docs = snapshot.data!.docs;

      for (final doc in docs) {
        final log = AccessLog.fromQueryDocSnapshot(doc);

        if (log.accessed) {
          accessed++;
        } else {
          failed++;
        }
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          successfulBubble(accessed),
          failedBubble(failed),
        ],
      );
    }

    return skeletons;
  }

  Expanded successfulBubble(int accessed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Bubble(
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(32.0),
            right: Radius.circular(12.0),
          ),
          color: Theme.of(context).colorScheme.primary,
          data: accessed,
          label: 'your\naccesses',
          crossAlignment: CrossAxisAlignment.start,
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  Expanded failedBubble(int failed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Bubble(
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(12.0),
            right: Radius.circular(32.0),
          ),
          color: Theme.of(context).colorScheme.secondary,
          data: failed,
          label: 'your failed\nattempts',
          crossAlignment: CrossAxisAlignment.end,
          textAlign: TextAlign.end,
        ),
      ),
    );
  }

  Row get skeletons => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
        ],
      );
}

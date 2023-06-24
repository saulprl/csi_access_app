import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:skeleton_animation/skeleton_animation.dart";

import "package:csi_door_logs/models/models.dart";

import "package:csi_door_logs/utils/styles.dart";

class AccessLogItem extends StatelessWidget {
  final AccessLog log;

  const AccessLogItem(this.log, {super.key});

  Color generateTileColor(BuildContext ctx) {
    if (log.accessed && log.bluetooth) {
      return Theme.of(ctx).colorScheme.tertiary;
    }

    if (log.accessed) {
      return Theme.of(ctx).colorScheme.primary;
    }

    return Theme.of(ctx).colorScheme.secondary;
  }

  Widget getTileTitle() {
    if (log.user == null) return Text("Unknown user", style: failedLogTitle);

    return StreamBuilder(
      stream: log.user!.snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final csiUser = CSIUser.fromDocSnapshot(snapshot.data!);

          return Expanded(
            child: Text(
              csiUser.name!,
              style: log.accessed ? successfulLogTitle : failedLogTitle,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }

        return SkeletonText(
          height: log.accessed
              ? successfulLogTitle.fontSize!
              : failedLogTitle.fontSize!,
        );
      },
    );
  }

  List<Widget> getTileTimestamp() {
    final timestamp = log.timestamp.toDate();

    return <Widget>[
      Text(
        DateFormat.Hms().format(timestamp),
        style: failedLogTimestamp,
        textAlign: TextAlign.right,
      ),
      Text(
        DateFormat.yMMMd().format(timestamp),
        style: failedLogTimestamp,
        textAlign: TextAlign.right,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        tileColor: generateTileColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        style: ListTileStyle.list,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 2.0,
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getTileTitle(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: getTileTimestamp(),
            ),
          ],
        ),
      ),
    );
  }
}

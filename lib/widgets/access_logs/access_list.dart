import "package:csi_door_logs/utils/styles.dart";
import "package:flutter/material.dart";

import "package:provider/provider.dart";

import "package:csi_door_logs/providers/logs_provider.dart";

import "package:csi_door_logs/widgets/access_logs/access_log_item.dart";

class AccessList extends StatelessWidget {
  const AccessList({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = Provider.of<LogsProvider>(context);

    if (logs.logs.isEmpty) {
      return const Center(
        child: Text("No logs found", style: baseTextStyle),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: logs.logs.map((log) => AccessLogItem(log)).toList(),
    );
  }
}

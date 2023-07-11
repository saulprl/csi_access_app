import "package:flutter/material.dart";

import "package:provider/provider.dart";

import "package:csi_door_logs/providers/logs_provider.dart";

import "package:csi_door_logs/widgets/access_logs/access_log_item.dart";
import "package:csi_door_logs/widgets/admin/skeleton_list.dart";

class AccessList extends StatelessWidget {
  const AccessList({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = Provider.of<LogsProvider>(context);

    return logs.isLoading
        ? const SkeletonList(count: 20, height: 60.0)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: logs.logs.map((log) => AccessLogItem(log)).toList(),
          );
  }
}

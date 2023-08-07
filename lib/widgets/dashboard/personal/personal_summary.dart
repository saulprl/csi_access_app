import "package:flutter/material.dart";

import "package:provider/provider.dart";

import "package:csi_door_logs/providers/auth_provider.dart";
import "package:csi_door_logs/providers/logs_provider.dart";

import "package:csi_door_logs/widgets/dashboard/summary/bubble.dart";

import "package:csi_door_logs/utils/utils.dart";

class PersonalSummary extends StatefulWidget {
  const PersonalSummary({super.key});

  @override
  State<PersonalSummary> createState() => _PersonalSummaryState();
}

class _PersonalSummaryState extends State<PersonalSummary> {
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<AuthProvider>(context).userData;
    final currentDayLogs = Provider.of<LogsProvider>(context).currentDayLogs;

    final userLogs = currentDayLogs.where((log) => log.user == userData?.key);

    var accessed = 0;
    var failed = 0;

    for (final log in userLogs) {
      if (log.accessed) {
        accessed++;
      } else {
        failed++;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildDivider(context, "Personal Data"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [successfulBubble(accessed), failedBubble(failed)],
        ),
      ],
    );
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
}

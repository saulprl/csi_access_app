import 'package:flutter/material.dart';

import 'package:csi_door_logs/utils/styles.dart';

Row buildDashboardDivider(BuildContext ctx, String title) {
  return Row(
    children: [
      const SizedBox(width: 4.0),
      const Expanded(child: Divider(thickness: 2.0)),
      const SizedBox(width: 4.0),
      Text(
        title,
        style: screenSubtitle.copyWith(
          color: Theme.of(ctx).colorScheme.primary,
        ),
      ),
      const SizedBox(width: 4.0),
      const Expanded(child: Divider(thickness: 2.0)),
      const SizedBox(width: 4.0),
    ],
  );
}

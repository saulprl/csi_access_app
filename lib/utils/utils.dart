import 'package:flutter/material.dart';

import 'package:csi_door_logs/utils/styles.dart';

Padding buildDashboardDivider(BuildContext ctx, String title) {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.primary,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            title,
            style: screenSubtitle.copyWith(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

import "package:flutter/material.dart";

import 'package:csi_door_logs/widgets/dashboard/summary/total_access.dart';
import 'package:csi_door_logs/widgets/dashboard/summary/failed_access.dart';
import 'package:csi_door_logs/widgets/dashboard/summary/unknown_attempts.dart';

class Summary extends StatelessWidget {
  const Summary({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
          right: 8.0,
          bottom: 16.0,
          left: 8.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Summary",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Divider(),
            SizedBox(height: 12.0),
            TotalAccess(),
            SizedBox(height: 12.0),
            FailedAccess(),
            SizedBox(height: 12.0),
            UnknownAttempts(),
          ],
        ),
      ),
    );
  }
}

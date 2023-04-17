import "package:flutter/material.dart";

import "package:csi_door_logs/widgets/access_logs/access_list.dart";

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Access Logs"),
      ),
      body: const SafeArea(
        child: AccessList(),
      ),
    );
  }
}

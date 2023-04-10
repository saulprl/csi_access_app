import "package:csi_door_logs/widgets/access_logs/access_list.dart";
import "package:csi_door_logs/widgets/main/csi_drawer.dart";
import "package:flutter/material.dart";

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de acceso"),
      ),
      drawer: CSIDrawer(),
      body: const SafeArea(
        child: AccessList(),
      ),
    );
  }
}

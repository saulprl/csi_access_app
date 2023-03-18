import "package:csi_door_logs/widgets/access_logs/access_list.dart";
import "package:flutter/material.dart";

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: AccessList()),
    );
  }
}

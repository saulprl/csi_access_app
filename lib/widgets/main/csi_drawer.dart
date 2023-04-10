import "package:csi_door_logs/utils/routes.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

import "package:flutter_secure_storage/flutter_secure_storage.dart";

class CSIDrawer extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage();

  CSIDrawer({super.key});

  Widget _buildTile(String title, IconData icon, VoidCallback tapHandler) {
    return ListTile(
      leading: Icon(icon, size: 24.0, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(fontSize: 20.0),
      ),
      onTap: tapHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            title: const Text("CSI PRO Access"),
          ),
          const SizedBox(height: 8.0),
          _buildTile(
            "Dashboard",
            Icons.dashboard_outlined,
            () => Navigator.of(context).pushReplacementNamed(Routes.dashboard),
          ),
          _buildTile(
            "Access Logs",
            Icons.list_alt,
            () => Navigator.of(context).pushReplacementNamed(Routes.accessLogs),
          ),
          _buildTile(
            "CSI Credentials",
            Icons.settings,
            () => Navigator.of(context).pushNamed(
              Routes.csiCredentials,
              arguments: {"edit": true},
            ),
          ),
          const Expanded(child: SizedBox()),
          _buildTile(
            "Sign out",
            Icons.logout,
            () async {
              await _storage.deleteAll();

              await _auth.signOut();
            },
          ),
        ],
      ),
    );
  }
}

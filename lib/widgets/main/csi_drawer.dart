import "package:csi_door_logs/utils/routes.dart";
import "package:csi_door_logs/utils/utils.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

import "package:flutter_secure_storage/flutter_secure_storage.dart";

class CSIDrawer extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage();

  CSIDrawer({super.key});

  Widget _buildTile(
    BuildContext ctx,
    String title,
    IconData icon,
    VoidCallback tapHandler,
  ) {
    return ListTile(
      leading: Icon(icon, size: 24.0, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(fontSize: 20.0),
      ),
      onTap: () {
        Navigator.of(ctx).pop();
        tapHandler();
      },
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
            context,
            "Dashboard",
            dashboardIcon,
            () => Navigator.of(context).pushReplacementNamed(Routes.dashboard),
          ),
          _buildTile(
            context,
            "Access Logs",
            listIcon,
            () => Navigator.of(context).pushNamed(Routes.accessLogs),
          ),
          _buildTile(
            context,
            "CSI Credentials",
            settingsIcon,
            () => Navigator.of(context).pushNamed(
              Routes.csiCredentials,
              arguments: {"edit": true},
            ),
          ),
          const Expanded(child: SizedBox()),
          _buildTile(
            context,
            "Sign out",
            logoutIcon,
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

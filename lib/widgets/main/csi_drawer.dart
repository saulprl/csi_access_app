import "package:flutter/material.dart";

import "package:firebase_auth/firebase_auth.dart";

import "package:provider/provider.dart";

import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "package:csi_door_logs/providers/csi_users.dart";

import "package:csi_door_logs/screens/screens.dart";

import "package:csi_door_logs/utils/routes.dart";
import "package:csi_door_logs/utils/utils.dart";

class CSIDrawer extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage();

  CSIDrawer({super.key});

  Widget _buildTile(
    BuildContext ctx,
    String title,
    IconData icon,
    bool enabled,
    VoidCallback tapHandler,
  ) {
    return ListTile(
      leading: Icon(icon, size: 24.0, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(fontSize: 20.0),
      ),
      enabled: enabled,
      onTap: () {
        Navigator.of(ctx).pop();
        tapHandler();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<CSIUsers>(context).role;

    return Drawer(
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            title: const Text("CSI PRO Access"),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Column(
              children: [
                _buildTile(
                  context,
                  "Dashboard",
                  dashboardIcon,
                  role != null ? role.canAccess : true,
                  () => Navigator.of(context)
                      .pushReplacementNamed(Routes.dashboard),
                ),
                _buildTile(
                  context,
                  "Access Logs",
                  listIcon,
                  role != null ? role.canReadLogs : false,
                  () => Navigator.of(context).pushNamed(Routes.accessLogs),
                ),
                _buildTile(
                  context,
                  "CSI Credentials",
                  settingsIcon,
                  true,
                  () => Navigator.of(context).pushNamed(
                    Routes.csiCredentials,
                    arguments: {"edit": true},
                  ),
                ),
                _buildTile(
                  context,
                  "Manage Users",
                  Icons.group,
                  role != null
                      ? role.canAllowAndRevokeAccess || role.canSetRoles
                      : false,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => ManagementScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: _buildTile(
              context,
              "Sign out",
              logoutIcon,
              true,
              () async {
                await _storage.deleteAll();

                await _auth.signOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}

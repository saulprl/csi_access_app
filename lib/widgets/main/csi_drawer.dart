import "package:flutter/material.dart";

import "package:firebase_auth/firebase_auth.dart";

import "package:provider/provider.dart";

import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "package:csi_door_logs/providers/csi_users.dart";

import "package:csi_door_logs/screens/screens.dart";

import "package:csi_door_logs/utils/routes.dart";
import "package:csi_door_logs/utils/styles.dart";

class CSIDrawer extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage();
  final _key = GlobalKey<ScaffoldState>(debugLabel: "drawer_key");

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
      key: _key,
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              "CSI PRO Access",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
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
                  () {},
                ),
                _buildTile(
                  context,
                  "Access Logs",
                  listIcon,
                  role != null ? role.canReadLogs : false,
                  () => Navigator.of(context).push(
                    Routes.pushFromRight(const LogsScreen()),
                  ),
                ),
                _buildTile(
                  context,
                  "CSI Credentials",
                  settingsIcon,
                  true,
                  () => Navigator.of(context).push(
                    Routes.pushFromRight(
                      const CSICredentialsScreen(isEdit: true),
                    ),
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
                    Routes.pushFromRight(ManagementScreen()),
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

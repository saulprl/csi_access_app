import "package:csi_door_logs/providers/auth_provider.dart";
import "package:csi_door_logs/providers/role_provider.dart";
import "package:flutter/material.dart";

import "package:firebase_auth/firebase_auth.dart";

import "package:provider/provider.dart";

import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "package:shared_preferences/shared_preferences.dart";

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
    VoidCallback tapHandler, {
    bool enabled = true,
  }) {
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
    final user = Provider.of<AuthProvider>(context).userData;
    final role = Provider.of<RoleProvider>(context).userRole;

    return Drawer(
      key: _key,
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              "CSI PRO Access",
              style: TextStyle(color: Colors.white),
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
                  () {},
                ),
                _buildTile(
                  context,
                  "Access Logs",
                  listIcon,
                  () => Navigator.of(context).push(
                    Routes.pushFromRight(const LogsScreen()),
                  ),
                  enabled: (role?.canReadLogs ?? false) ||
                      (user?.isRootUser ?? false),
                ),
                _buildTile(
                  context,
                  "CSI Credentials",
                  settingsIcon,
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
                  () => Navigator.of(context).push(
                    Routes.pushFromRight(ManagementScreen()),
                  ),
                  enabled: ((role?.canGrantOrRevokeAccess ?? false) ||
                          (role?.canSetRoles ?? false)) ||
                      (user?.isRootUser ?? false),
                ),
              ],
            ),
          ),
          SafeArea(
            child: _buildTile(
              context,
              "Sign out",
              logoutIcon,
              () async {
                await _storage.deleteAll();
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                await _auth.signOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}

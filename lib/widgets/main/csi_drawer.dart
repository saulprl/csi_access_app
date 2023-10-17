import "package:csi_door_logs/screens/convenience_home_screen.dart";
import "package:csi_door_logs/screens/qr_screen.dart";
import "package:flutter/material.dart";

import "package:provider/provider.dart";

import "package:shared_preferences/shared_preferences.dart";

import "package:csi_door_logs/providers/auth_provider.dart";
import "package:csi_door_logs/providers/role_provider.dart";

import "package:csi_door_logs/screens/screens.dart";

import "package:csi_door_logs/utils/routes.dart";
import "package:csi_door_logs/utils/styles.dart";

class CSIDrawer extends StatelessWidget {
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
    final auth = Provider.of<AuthProvider>(context);
    final role = Provider.of<RoleProvider>(context).userRole;
    final user = auth.userData;

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
                  () => Navigator.of(context).pushReplacement(
                    Routes.pushFromRight(const DashboardScreen()),
                  ),
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
                  "Rooms",
                  roomIcon,
                  () => Navigator.of(context).push(
                    Routes.pushFromRight(const RoomsScreen()),
                  ),
                ),
                _buildTile(
                  context,
                  "Manage Users",
                  Icons.group,
                  () => Navigator.of(context).push(
                    Routes.pushFromRight(const ManagementScreen()),
                  ),
                  enabled: ((role?.canGrantOrRevokeAccess ?? false) ||
                          (role?.canSetRoles ?? false)) ||
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
                  "QR Code",
                  Icons.qr_code,
                  () => Navigator.of(context).push(
                    Routes.pushFromRight(const QRScreen()),
                  ),
                ),
                _buildTile(
                  context,
                  "Convenience",
                  Icons.home,
                  () => Navigator.of(context).push(
                    Routes.pushFromRight(const ConvenienceHomeScreen()),
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
              () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                await auth.signOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}

import "package:flutter/material.dart";

class CSIDrawer extends StatelessWidget {
  const CSIDrawer({super.key});

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
            () => Navigator.of(context).pushReplacementNamed("/"),
          ),
          _buildTile(
            "Historial de acceso",
            Icons.list_alt,
            () => Navigator.of(context).pushReplacementNamed("/access-logs"),
          ),
          const Expanded(child: SizedBox()),
          _buildTile(
            "Cerrar sesión",
            Icons.logout,
            () => print("Log out"),
          ),
        ],
      ),
    );
  }
}

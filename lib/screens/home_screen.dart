import "package:csi_door_logs/widgets/dashboard/personal/personal_summary.dart";
import "package:csi_door_logs/widgets/main/csi_appbar.dart";
import "package:flutter/material.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "package:csi_door_logs/screens/screens.dart";

import "package:csi_door_logs/widgets/main/csi_drawer.dart";
import "package:csi_door_logs/widgets/dashboard/summary/summary.dart";

import "package:csi_door_logs/utils/routes.dart";

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _hasStorage = false;

  @override
  void initState() {
    super.initState();

    _readStorage();
  }

  void _readStorage() {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    _storage.readAll().then((value) async {
      if (value.isNotEmpty) {
        if (mounted) {
          setState(() {
            _hasStorage = value.containsKey("CSIPRO-PASSCODE");
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasStorage = false;
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CSIAppBar("Dashboard"),
      drawer: CSIDrawer(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding:
              const EdgeInsets.all(8.0) + const EdgeInsets.only(bottom: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Summary(),
              PersonalSummary(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading
            ? () {}
            : _hasStorage
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const TestPibleScreen(),
                      ),
                    )
                : () async {
                    await Navigator.of(context)
                        .pushNamed(Routes.csiCredentials);
                    _readStorage();
                  },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : _hasStorage
                ? Image.asset("assets/Access_logo.png")
                : const Icon(
                    Icons.error_rounded,
                    size: 40.0,
                    color: Colors.white,
                  ),
      ),
    );
  }
}

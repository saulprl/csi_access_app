import "package:flutter/material.dart";

import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "package:csi_door_logs/screens/screens.dart";

import "package:csi_door_logs/widgets/dashboard/personal/personal_summary.dart";
import "package:csi_door_logs/widgets/dashboard/summary/summary.dart";
import "package:csi_door_logs/widgets/main/index.dart";

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
  bool _shouldPop = false;

  @override
  void initState() {
    super.initState();

    _readStorage();
  }

  Future<void> _readStorage() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    await Future.delayed(const Duration(milliseconds: 1250));

    final storage = await _storage.readAll();
    if (storage.isNotEmpty) {
      if (mounted) {
        setState(() {
          _hasStorage = storage.containsKey("CSIPRO-PASSCODE");
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
  }

  SnackBar get snackBar => const SnackBar(
        content: Text(
          "Press again to exit",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 18.0,
          ),
        ),
        duration: Duration(seconds: 2),
      );

  Future<bool> willPopHandler() async {
    if (_shouldPop) return true;

    _shouldPop = true;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _shouldPop = false;
    });

    return false;
  }

  Widget get floatingActionButton => FloatingActionButton(
        onPressed: _isLoading
            ? () {}
            : _hasStorage
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const PibleScreen(),
                      ),
                    )
                : () async {
                    await Navigator.of(context)
                        .pushNamed(Routes.csiCredentials);
                    _readStorage();
                  },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: _isLoading
            ? const AdaptiveSpinner(color: Colors.white)
            : _hasStorage
                ? Image.asset("assets/Access_logo.png")
                : const Icon(
                    Icons.error_rounded,
                    size: 40.0,
                    color: Colors.white,
                  ),
      );

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: willPopHandler,
      child: Scaffold(
        appBar: const CSIAppBar("Dashboard"),
        drawer: CSIDrawer(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding:
                const EdgeInsets.all(8.0) + const EdgeInsets.only(bottom: 80.0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Summary(),
                PersonalSummary(),
              ],
            ),
          ),
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}

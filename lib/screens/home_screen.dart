import "package:flutter/material.dart";
import "package:flutter/services.dart";

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
    if (_shouldPop) {
      SystemNavigator.pop();

      return true;
    }

    _shouldPop = true;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _shouldPop = false;
    });

    return false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: willPopHandler,
      child: Scaffold(
        appBar: const CSIAppBar("Dashboard", roomSelector: true),
        drawer: CSIDrawer(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Builder(
              builder: builder,
            ),
          ),
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }

  Widget builder(BuildContext ctx) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 3) {
          Scaffold.of(ctx).openDrawer();
        }

        if (details.delta.dx < -7 && !_isLoading) {
          onAttemptAccess();
        }
      },
      child: dashboardContent,
    );
  }

  Padding get dashboardContent {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Summary(),
          PersonalSummary(),
          SizedBox(height: 80.0),
        ],
      ),
    );
  }

  Widget get floatingActionButton => FloatingActionButton(
        onPressed: _isLoading ? null : onAttemptAccess,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: _isLoading
            ? const AdaptiveSpinner(color: Colors.white)
            : floatingChild,
      );

  void Function() get onAttemptAccess => _hasStorage
      ? () => Navigator.of(context).push(
            Routes.pushFromRight(const PibleScreen()),
          )
      : () async {
          await Navigator.of(context).push(
            Routes.pushFromRight(const CSICredentialsScreen()),
          );
          _readStorage();
        };

  Widget get floatingChild => _hasStorage
      ? Image.asset("assets/Access_logo.png")
      : const Icon(
          Icons.error_rounded,
          size: 40.0,
          color: Colors.white,
        );
}

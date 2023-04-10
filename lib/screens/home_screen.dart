import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:csi_door_logs/models/models.dart";
import "package:csi_door_logs/screens/screens.dart";
import "package:csi_door_logs/utils/routes.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_database/firebase_database.dart";
import "package:flutter/material.dart";
import "package:flutter_blue_plus/flutter_blue_plus.dart";

import "package:local_auth/local_auth.dart";

import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "package:csi_door_logs/widgets/main/csi_drawer.dart";
import "package:csi_door_logs/widgets/dashboard/summary/summary.dart";
import "package:permission_handler/permission_handler.dart";

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
        final dbUser = await FirebaseDatabase.instance
            .ref("users/${FirebaseAuth.instance.currentUser!.uid}")
            .get();
        final csiUser = CSIUser.fromDirectSnapshot(dbUser);
        final validCredentials = await csiUser.compareCredentials(
          value["CSIPRO-UNISONID"]!,
          value["CSIPRO-CSIID"]!,
          value["CSIPRO-PASSCODE"]!,
        );

        if (!validCredentials) {
          _storage.deleteAll();
        }

        if (mounted) {
          setState(() {
            _hasStorage = validCredentials;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasStorage = value.isNotEmpty;
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
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      drawer: CSIDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Summary(),
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
            ? const CircularProgressIndicator(color: Colors.white)
            : Icon(
                _hasStorage ? Icons.fingerprint : Icons.warning,
                color: Colors.white,
              ),
      ),
    );
  }
}

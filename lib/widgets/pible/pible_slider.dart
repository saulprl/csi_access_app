import 'package:csi_door_logs/screens/csi_credentials_screen.dart';
import 'package:csi_door_logs/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:csi_door_logs/providers/pible_provider.dart';
import 'package:csi_door_logs/widgets/main/adaptive_spinner.dart';
import 'package:csi_door_logs/widgets/pible/pible_chip.dart';
import 'package:csi_door_logs/utils/styles.dart';

class PibleSlider extends StatefulWidget {
  const PibleSlider({super.key});

  @override
  State<PibleSlider> createState() => _PibleSliderState();
}

class _PibleSliderState extends State<PibleSlider> {
  final serviceUuid = dotenv.env["SERVICE_UUID"];
  final _storage = const FlutterSecureStorage();

  var _isLoading = false;
  var _hasStorage = false;

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
    await Future.delayed(const Duration(milliseconds: 500));

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

  @override
  Widget build(BuildContext context) {
    final pibleProvider = Provider.of<PibleProvider>(context);

    return Stack(
      children: [
        SizedBox(
          height: 48.0,
          child: _isLoading
              ? null
              : _hasStorage
                  ? pibleProvider.pibles.isNotEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: pibleProvider.pibles.length,
                          itemBuilder: (ctx, index) {
                            final items = [...pibleProvider.pibles];

                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: PibleChip(
                                pible: items[index],
                                key: ValueKey(items[index].name),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            "no nearby rooms",
                            style: pibleBubbleTextStyle.copyWith(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        )
                  : Center(
                      child: FilledButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.white,
                          ),
                        ),
                        onPressed: () async {
                          await Navigator.of(context).push(
                            Routes.pushFromRight(const CSICredentialsScreen()),
                          );
                          _readStorage();
                        },
                        child: Text(
                          "Finish setup",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                    ),
        ),
        if (_isLoading)
          const Center(
            child: AdaptiveSpinner(),
          ),
      ],
    );
  }
}

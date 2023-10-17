import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:csi_door_logs/screens/screens.dart';
import 'package:csi_door_logs/utils/routes.dart';
import 'package:csi_door_logs/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:steel_crypt/steel_crypt.dart';

class PibleDevice extends StatefulWidget {
  final ScanResult scanItem;

  const PibleDevice({
    required this.scanItem,
    super.key,
  });

  @override
  State<PibleDevice> createState() => _PibleDeviceState();
}

class _PibleDeviceState extends State<PibleDevice> {
  final _storage = const FlutterSecureStorage();
  final localAuth = LocalAuthentication();

  final ivValue = dotenv.env["IV_VALUE"];
  final encryptionString = dotenv.env["AES_ENCRYPTION_KEY"];
  final serviceUuid = dotenv.env["SERVICE_UUID"];
  final pibleAddress = dotenv.env["PIBLE_ADDRESS"];
  final tokenCharacteristicUuid = dotenv.env["TOKEN_CHARACTERISTIC_UUID"];
  final ivCharacteristicUuid = dotenv.env["IV_CHARACTERISTIC_UUID"];

  bool _hasStorage = false;

  @override
  void initState() {
    super.initState();

    _readStorage();
  }

  Future<void> _readStorage() async {
    await Future.delayed(const Duration(milliseconds: 750));

    final storage = await _storage.readAll();
    if (storage.isNotEmpty) {
      if (mounted) {
        setState(() {
          _hasStorage = storage.containsKey("CSIPRO-PASSCODE");
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _hasStorage = false;
        });
      }
    }
  }

  String generateNonce() {
    final random = Random.secure();
    final nonceBytes = List.generate(16, (_) => random.nextInt(256));
    final nonce = base64.encode(nonceBytes);

    return nonce;
  }

  Future<void> handleConnection() async {
    try {
      await scanItem.device.connect(timeout: const Duration(seconds: 2));
      List<BluetoothService> services =
          await scanItem.device.discoverServices();

      final service = services.firstWhere(
        (svc) => svc.uuid.toString() == serviceUuid,
      );

      if (!await handleAuthentication()) {
        return;
      }

      try {
        await encryptData(service);
      } catch (error) {
        rethrow;
      } finally {
        await scanItem.device.disconnect();
      }
    } on PlatformException catch (error) {
      debugPrint(error.toString());
    } on TimeoutException catch (error) {
      debugPrint(error.toString());
    } on StateError catch (_) {
      rethrow;
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }

  Future<bool> handleAuthentication() async {
    return await localAuth.authenticate(
      localizedReason: "PiBLE requires authentication in order to continue.",
    );
  }

  Future<void> encryptData(BluetoothService service) async {
    String nonce = generateNonce();
    String uid = await _storage.read(key: "CSIPRO-ACCESS-FIREBASE-UID") ?? "";
    String passcode = await _storage.read(key: "CSIPRO-PASSCODE") ?? "";
    int expiryDate =
        DateTime.now().add(const Duration(seconds: 30)).millisecondsSinceEpoch;
    String concatenated = "$nonce:$uid:$passcode:$expiryDate";
    final cipher = AesCrypt(
      padding: PaddingAES.pkcs7,
      key: base64.encode(encryptionString!.codeUnits),
    );

    final encryptedString = base64.encode(
      cipher.cbc
          .encrypt(inp: concatenated, iv: base64.encode(ivValue!.codeUnits))
          .codeUnits,
    );

    final tokenCharacteristic = service.characteristics.firstWhere(
      (cha) => cha.uuid.toString() == tokenCharacteristicUuid,
    );

    await tokenCharacteristic.write(encryptedString.codeUnits);
  }

  @override
  void dispose() {
    scanItem.device.disconnect();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ListTile(
        tileColor: Theme.of(context).colorScheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        title: Text(
          scanItem.advertisementData.localName,
          style: pibleBubbleTextStyle.copyWith(fontWeight: FontWeight.normal),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.door_sliding, color: Colors.white),
          onPressed: onAttemptAccess,
        ),
      ),
    );
  }

  void Function() get onAttemptAccess => _hasStorage
      ? () => handleConnection()
      : () async {
          await Navigator.of(context).push(
            Routes.pushFromRight(const CSICredentialsScreen()),
          );
          _readStorage();
        };

  ScanResult get scanItem => widget.scanItem;
}

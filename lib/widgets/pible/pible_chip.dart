import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:csi_door_logs/models/pible_device.dart';
import 'package:csi_door_logs/providers/pible_provider.dart';
import 'package:csi_door_logs/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:steel_crypt/steel_crypt.dart';

class PibleChip extends StatefulWidget {
  final PibleDevice pible;

  const PibleChip({
    required this.pible,
    super.key,
  });

  @override
  State<PibleChip> createState() => _PibleChipState();
}

class _PibleChipState extends State<PibleChip> {
  final _storage = const FlutterSecureStorage();
  final localAuth = LocalAuthentication();

  final ivValue = dotenv.env["IV_VALUE"];
  final encryptionString = dotenv.env["AES_ENCRYPTION_KEY"];
  final serviceUuid = dotenv.env["SERVICE_UUID"];
  final pibleAddress = dotenv.env["PIBLE_ADDRESS"];
  final tokenCharacteristicUuid = dotenv.env["TOKEN_CHARACTERISTIC_UUID"];
  final ivCharacteristicUuid = dotenv.env["IV_CHARACTERISTIC_UUID"];

  String generateNonce() {
    final random = Random.secure();
    final nonceBytes = List.generate(16, (_) => random.nextInt(256));
    final nonce = base64.encode(nonceBytes);

    return nonce;
  }

  Future<void> handleConnection() async {
    final pibleProvider = Provider.of<PibleProvider>(context, listen: false);
    pibleProvider.pauseTimer(isConnecting: true);

    try {
      await pible.connect();
      List<BluetoothService> services = await pible.device.discoverServices();

      final service = services.firstWhere(
        (svc) => svc.uuid.toString() == serviceUuid,
      );

      if (!await handleAuthentication()) {
        pibleProvider.startTimer();
        _showSnackBar("Authentication failed");

        return;
      }

      try {
        await encryptData(service);
        pibleProvider.stopTimer();

        _showSnackBar("Welcome in!", backgroundColor: successColor);
      } catch (error) {
        _showSnackBar("Something went wrong while encrypting your data");
      } finally {
        await pible.disconnect();
      }
    } on PlatformException catch (error) {
      pibleProvider.startTimer();
      debugPrint(error.toString());
      _showSnackBar("Error while attempting to connect");
    } on TimeoutException catch (error) {
      pibleProvider.startTimer();
      debugPrint(error.toString());
      _showSnackBar("Connection timed out");
    } on StateError catch (_) {
      pibleProvider.startTimer();
      _showSnackBar("Something went wrong");
      // rethrow;
    } catch (error) {
      pibleProvider.startTimer();

      _showSnackBar("Something went wrong");
      // rethrow;
    }
  }

  Future<bool> handleAuthentication() async {
    return await localAuth.authenticate(
      localizedReason:
          "${pible.name} requires authentication in order to access.",
    );
  }

  Future<void> encryptData(BluetoothService service) async {
    String nonce = generateNonce();
    String uid = await _storage.read(key: "CSIPRO-ACCESS-FIREBASE-UID") ?? "";
    String passcode = await _storage.read(key: "CSIPRO-PASSCODE") ?? "";
    int expiryDate =
        DateTime.now().add(const Duration(seconds: 15)).millisecondsSinceEpoch;
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

  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: backgroundColor,
      content: Text(message, style: baseTextStyle),
    ));
  }

  @override
  void dispose() {
    pible.disconnect();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnecting = !Provider.of<PibleProvider>(context).isActive;
    final isPressable = !isConnecting && pible.hasAccess;

    return ElevatedButton(
      onPressed: isPressable ? handleConnection : null,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          isPressable ? Colors.white : Colors.white.withOpacity(0.75),
        ),
      ),
      child: Text(
        pible.name.replaceAll("PiBLE-", ""),
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
          fontWeight: isPressable ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  PibleDevice get pible => widget.pible;
}

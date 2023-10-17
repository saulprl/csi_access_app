import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:steel_crypt/steel_crypt.dart';

class PibleChip extends StatefulWidget {
  final ScanResult scanItem;
  final void Function(bool value) onConnect;
  final bool isConnecting;

  const PibleChip({
    required this.scanItem,
    required this.onConnect,
    required this.isConnecting,
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
    onConnect(true);

    try {
      await scanItem.device.connect(timeout: const Duration(seconds: 3));
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
        onConnect(false);
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
    } finally {
      onConnect(false);
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
    onConnect(false);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isConnecting ? () {} : handleConnection,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: isConnecting
              ? Theme.of(context).colorScheme.tertiary.withOpacity(0.45)
              : Theme.of(context).colorScheme.tertiary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Center(
          child: Text(
            scanItem.advertisementData.localName.replaceAll("PiBLE-", ""),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  ScanResult get scanItem => widget.scanItem;
  void Function(bool value) get onConnect => widget.onConnect;
  bool get isConnecting => widget.isConnecting;
}

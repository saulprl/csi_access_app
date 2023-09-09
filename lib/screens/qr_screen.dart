import 'dart:convert';
import 'dart:math';

import 'package:csi_door_logs/widgets/main/adaptive_spinner.dart';
import 'package:csi_door_logs/widgets/main/csi_appbar.dart';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScreen extends StatelessWidget {
  final _storage = const FlutterSecureStorage();
  final _encryptionString = dotenv.env["AES_ENCRYPTION_KEY"];
  final _ivValue = dotenv.env["IV_VALUE"];

  QRScreen({super.key});

  String _generateNonce() {
    final random = Random.secure();
    final nonceBytes = List.generate(16, (_) => random.nextInt(256));
    final nonce = base64.encode(nonceBytes);

    return nonce;
  }

  Future<String> _encryptData() async {
    String nonce = _generateNonce();
    String uid = await _storage.read(key: "CSIPRO-ACCESS-FIREBASE-UID") ?? "";
    String passcode = await _storage.read(key: "CSIPRO-PASSCODE") ?? "";
    int expiryDate =
        DateTime.now().add(const Duration(seconds: 30)).millisecondsSinceEpoch;
    String concatenated = "$nonce:$uid:$passcode:$expiryDate";
    final cipher = AesCrypt(
      padding: PaddingAES.pkcs7,
      key: base64.encode(_encryptionString!.codeUnits),
    );

    final encryptedString = base64.encode(
      cipher.cbc
          .encrypt(inp: concatenated, iv: base64.encode(_ivValue!.codeUnits))
          .codeUnits,
    );

    return encryptedString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CSIAppBar("QR Code"),
      body: FutureBuilder(
        future: _encryptData(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            final encryptedString = snapshot.data!;

            return QrImageView(data: encryptedString, version: QrVersions.auto);
          }

          if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return const Center(
              child: Text(
                "An error occurred while generating the QR code.",
                style: TextStyle(fontSize: 20.0),
              ),
            );
          }

          return const Center(child: AdaptiveSpinner());
        },
      ),
    );
  }
}

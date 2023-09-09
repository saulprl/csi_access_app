import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:csi_door_logs/utils/styles.dart';
import 'package:csi_door_logs/widgets/main/adaptive_spinner.dart';
import 'package:csi_door_logs/widgets/main/csi_appbar.dart';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  final _encryptionString = dotenv.env["AES_ENCRYPTION_KEY"];
  final _ivValue = dotenv.env["IV_VALUE"];

  final qrDuration = const Duration(seconds: 15);

  late Timer _regenTimer;

  String? _identityToe;
  bool? _rememberIdentity;
  bool _isAuthenticated = false;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInit) {
      _handleAuthentication();

      _regenTimer = Timer.periodic(qrDuration, (timer) async {
        if (mounted) {
          setState(() {});
        }
      });

      _isInit = true;
    }
  }

  Future<bool> _checkForIdToe() async {
    final identityToe = await _storage.read(key: "CSIPRO-ACCESS-ID-TOE");
    return _isExpired(identityToe);
  }

  String _generateNonce() {
    final random = Random.secure();
    final nonceBytes = List.generate(16, (_) => random.nextInt(256));
    final nonce = base64.encode(nonceBytes);

    return nonce;
  }

  Future<String> _encryptData() async {
    String nonce = _generateNonce();
    String uid = await _storage.read(key: "CSIPRO-ACCESS-FIREBASE-UID") ?? "";
    int expiryDate = DateTime.now().add(qrDuration).millisecondsSinceEpoch;
    String concatenated = "$nonce:$uid:$expiryDate";
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

  Future<void> _handleAuthentication() async {
    final shouldAuthenticate = await _checkForIdToe();

    if (!shouldAuthenticate) {
      setState(() => _isAuthenticated = true);
      return;
    }

    final authResult = await _localAuth.authenticate(
      localizedReason: "Please confirm your identity first.",
    );

    if (authResult) {
      final timeOfExpiration = DateTime.now()
          .add(
            const Duration(hours: 6),
          )
          .millisecondsSinceEpoch;
      print(DateTime.fromMillisecondsSinceEpoch(timeOfExpiration));

      await _storage.write(
        key: "CSIPRO-ACCESS-ID-TOE",
        value: timeOfExpiration.toString(),
      );
    }

    setState(() => _isAuthenticated = authResult);
  }

  bool _isExpired(String? toe) {
    if (toe == null) return true;

    final toeDate = DateTime.fromMillisecondsSinceEpoch(int.parse(toe));

    return toeDate.isBefore(DateTime.now());
  }

  @override
  void dispose() {
    _regenTimer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const CSIAppBar("QR Code"),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Column(
            children: [
              if (_isAuthenticated)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: size.height * 0.06),
                    Text(
                      "Show your QR code on the scanner",
                      style: screenSubtitle.copyWith(
                        fontSize: 18.0,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: size.height * 0.02),
                    FutureBuilder(
                      future: _encryptData(),
                      builder: (ctx, snapshot) {
                        if (snapshot.hasData) {
                          final encryptedString = snapshot.data!;

                          return QrImageView(
                            data: encryptedString,
                            version: QrVersions.auto,
                            gapless: false,
                            eyeStyle: const QrEyeStyle(
                              color: darkColor,
                              eyeShape: QrEyeShape.square,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              color: darkColor,
                              dataModuleShape: QrDataModuleShape.square,
                            ),
                          );
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
                    SizedBox(height: size.height * 0.1),
                    RichText(
                      text: TextSpan(
                        text: "Your code will regenerate every",
                        style: baseTextStyle.copyWith(
                          color: darkColor,
                          fontFamily: "Poppins",
                        ),
                        children: [
                          TextSpan(
                            text: " ${qrDuration.inSeconds} seconds",
                            style: baseTextStyle.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              if (!_isAuthenticated)
                SizedBox(
                  height: size.height * 0.8,
                  child: Center(
                    child: FilledButton(
                      onPressed: _handleAuthentication,
                      child: const Text("Generate QR code"),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

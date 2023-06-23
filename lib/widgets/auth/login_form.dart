import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csi_door_logs/models/csi_user.dart';
import 'package:csi_door_logs/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:firebase_auth/firebase_auth.dart';

import "package:flutter_secure_storage/flutter_secure_storage.dart";

import 'package:email_validator/email_validator.dart';

import 'package:csi_door_logs/widgets/main/index.dart';

import 'package:csi_door_logs/utils/styles.dart';
import 'package:csi_door_logs/utils/routes.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = const FlutterSecureStorage();

  final GlobalKey<FormState> _formKey = GlobalKey(debugLabel: "login_form");
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  var _showPassword = false;
  var _isLoading = false;

  void toggleShowPassword() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void showModal(String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                "OK",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _validateEmail(String email) {
    return EmailValidator.validate(email);
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final enteredEmail = _emailCtrl.text;
    final enteredPassword = _passCtrl.text;

    try {
      UserCredential authUser = await _auth.signInWithEmailAndPassword(
        email: enteredEmail,
        password: enteredPassword,
      );

      final uid = authUser.user!.uid;
      final docSnapshot = await _firestore.collection("users").doc(uid).get();
      final user = CSIUser.fromDocSnapshot(docSnapshot);

      await _storage.write(key: firebaseUidStorageKey, value: uid);
      await _storage.write(key: unisonIdStorageKey, value: user.unisonId);
      await _storage.write(key: csiIdStorageKey, value: user.csiId.toString());
    } on FirebaseAuthException catch (error) {
      var message = "An error occurred, please check your credentials!";
      if (error.message != null) {
        message = error.message!;
      }

      showModal(message);
    } catch (error) {
      debugPrint(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailCtrl,
              decoration: mainInputDecoration.copyWith(
                prefixIcon: Icon(emailIcon),
                label: const Text("Email address"),
              ),
              autocorrect: false,
              enabled: !_isLoading,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value!.isEmpty) {
                  return "This field is required.";
                }

                if (!_validateEmail(value)) {
                  return "The email provided is not valid.";
                }

                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _passCtrl,
              decoration: mainInputDecoration.copyWith(
                prefixIcon: Icon(passwordIcon),
                label: const Text("Password"),
                suffixIcon: IconButton(
                  icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: toggleShowPassword,
                ),
              ),
              autocorrect: false,
              enabled: !_isLoading,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.done,
              obscureText: !_showPassword,
              validator: (value) {
                if (value!.isEmpty) {
                  return "This field is required.";
                }

                return null;
              },
            ),
            const SizedBox(height: 16.0),
            _isLoading
                ? AdaptiveSpinner(color: Theme.of(context).colorScheme.primary)
                : ElevatedButton.icon(
                    style: ButtonStyle(
                      padding: const MaterialStatePropertyAll(
                        EdgeInsets.all(12.0),
                      ),
                      shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.login),
                    label: const Text("Login"),
                    onPressed: _saveForm,
                  ),
            const SizedBox(height: 8.0),
            RichText(
              text: TextSpan(
                text: "Don't have an account? ",
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 16.0,
                ),
                children: [
                  TextSpan(
                    text: "Sign up",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).pushNamed(Routes.signup);
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:email_validator/email_validator.dart';

import "package:flutter_secure_storage/flutter_secure_storage.dart";

import 'package:csi_door_logs/widgets/main/adaptive_spinner.dart';

import 'package:csi_door_logs/models/models.dart';

import 'package:csi_door_logs/utils/styles.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _auth = FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage();

  final GlobalKey<FormState> _formKey = GlobalKey(debugLabel: "signup_form");
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final unisonIdCtrl = TextEditingController();
  final csiIdCtrl = TextEditingController();
  final passcodeCtrl = TextEditingController();

  final cPwdFocus = FocusNode();
  final unisonIdFocus = FocusNode();

  var _showPassword = false;
  var _showPasscode = false;
  var _isLoading = false;

  void toggleShowPassword() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void toggleShowPasscode() {
    setState(() {
      _showPasscode = !_showPasscode;
    });
  }

  bool _validateEmail(String email) {
    return EmailValidator.validate(email);
  }

  Widget buildDivider(String label) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 14.0,
          ),
        ),
        const SizedBox(width: 8.0),
        const Expanded(child: Divider()),
      ],
    );
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

  void popBack() {
    Navigator.of(context).pop();
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = emailCtrl.text;
    final password = passwordCtrl.text;
    final unisonId = unisonIdCtrl.text;
    final csiId = csiIdCtrl.text;
    final csiPasscode = passcodeCtrl.text.toUpperCase();

    try {
      final dbInstance = FirebaseDatabase.instance;

      final existingUnisonID = await dbInstance
          .ref("users")
          .orderByChild("unisonId")
          .equalTo(unisonId)
          .get();

      if (existingUnisonID.value == null) {
        showModal("No user with provided UniSon ID found.");
        return;
      }

      final existingUser = CSIUser.fromSnapshot(existingUnisonID);
      if (!await existingUser.compareCredentials(
        unisonId,
        csiId,
        csiPasscode,
      )) {
        showModal("Your CSI Credentials are incorrect.");
        return;
      }

      final authenticatedUser = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      dbInstance.ref("users/${authenticatedUser.user!.uid}").set({
        ...existingUser.toJson()[unisonId],
        "email": email,
      });

      await _storage.deleteAll();
      await _storage.write(
        key: "CSIPRO-ACCESS-FIREBASE-UID",
        value: authenticatedUser.user!.uid,
      );
      await _storage.write(key: "CSIPRO-UNISONID", value: unisonId);
      await _storage.write(key: "CSIPRO-CSIID", value: csiId);
      await _storage.write(key: "CSIPRO-PASSCODE", value: csiPasscode);

      popBack();
    } on FirebaseAuthException catch (error) {
      var message = "An error occurred, please check your credentials!";
      if (error.message != null) {
        message = error.message!;
      }

      showModal(message);
    } catch (error) {
      var message = "An error occurred, please check your credentials!";
      message = error.toString();

      showModal(message);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    unisonIdCtrl.dispose();
    csiIdCtrl.dispose();
    passcodeCtrl.dispose();

    cPwdFocus.dispose();
    unisonIdFocus.dispose();

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildDivider("Credentials"),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: emailCtrl,
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
                controller: passwordCtrl,
                decoration: mainInputDecoration.copyWith(
                  prefixIcon: Icon(passwordIcon),
                  label: const Text("Password"),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: toggleShowPassword,
                  ),
                ),
                autocorrect: false,
                enabled: !_isLoading,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.next,
                obscureText: !_showPassword,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "This field is required.";
                  }

                  return null;
                },
                onEditingComplete: () => cPwdFocus.requestFocus(),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                focusNode: cPwdFocus,
                decoration: mainInputDecoration.copyWith(
                  prefixIcon: Icon(passwordIcon),
                  label: const Text("Confirm password"),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: toggleShowPassword,
                  ),
                ),
                autocorrect: false,
                enabled: !_isLoading,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.next,
                obscureText: !_showPassword,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "This field is required.";
                  }

                  if (value != passwordCtrl.text) {
                    return "Passwords don't match.";
                  }

                  return null;
                },
                onEditingComplete: () => unisonIdFocus.requestFocus(),
              ),
              const SizedBox(height: 16.0),
              buildDivider("CSI PRO Info"),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: unisonIdCtrl,
                focusNode: unisonIdFocus,
                decoration: mainInputDecoration.copyWith(
                  prefixIcon: Icon(unisonIdIcon),
                  label: const Text("UniSon ID"),
                  hintText: "e.g. 217200160",
                ),
                autocorrect: false,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "This field is required.";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      controller: csiIdCtrl,
                      decoration: mainInputDecoration.copyWith(
                        prefixIcon: Icon(csiIdIcon),
                        label: const Text("CSI ID"),
                        hintText: "e.g. 1",
                      ),
                      autocorrect: false,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Required";
                        }

                        if (!RegExp(r"^\d{1,3}$").hasMatch(value)) {
                          return "Invalid";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Expanded(
                    flex: 9,
                    child: TextFormField(
                      controller: passcodeCtrl,
                      decoration: mainInputDecoration.copyWith(
                        prefixIcon: Icon(passcodeIcon),
                        label: const Text("CSI Passcode"),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 17.0),
                        suffixIcon: IconButton(
                          icon: Icon(_showPasscode
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: toggleShowPasscode,
                        ),
                      ),
                      autocorrect: false,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      obscureText: !_showPasscode,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "This field is required.";
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              _isLoading
                  ? AdaptiveSpinner(
                      color: Theme.of(context).colorScheme.primary,
                    )
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
                      icon: Icon(signupIcon),
                      label: const Text("Sign up"),
                      onPressed: _saveForm,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

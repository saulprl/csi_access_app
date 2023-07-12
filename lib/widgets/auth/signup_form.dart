import 'package:csi_door_logs/utils/globals.dart';
import 'package:csi_door_logs/widgets/auth/fetch_field.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import "package:cloud_firestore/cloud_firestore.dart";

import 'package:email_validator/email_validator.dart';

import "package:flutter_secure_storage/flutter_secure_storage.dart";

import 'package:csi_door_logs/widgets/main/adaptive_spinner.dart';

import 'package:csi_door_logs/models/models.dart';

import 'package:csi_door_logs/utils/styles.dart';
import 'package:intl/intl.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _auth = FirebaseAuth.instance;
  final _dbInstance = FirebaseDatabase.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = const FlutterSecureStorage();

  final GlobalKey<FormState> _formKey = GlobalKey(debugLabel: "signup_form");
  final unisonIdCtrl = TextEditingController();
  final passcodeCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final roleCtrl = TextEditingController()..text = "Guest";
  DateTime? dob;

  final cPwdFocus = FocusNode();
  final unisonIdFocus = FocusNode();
  final passcodeFocus = FocusNode();
  final nameFocus = FocusNode();

  var _isAllowedAccess = false;
  var _showPassword = false;
  var _showPasscode = false;
  var _editPasscode = false;
  var _editName = false;
  var _isLoading = false;

  Widget get sizedBox => const SizedBox(height: 12.0);

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

  Future<void> _fetchUser() async {
    if (unisonIdCtrl.text.isEmpty) {
      return;
    }

    final existingSnapshot = await _dbInstance
        .ref("users")
        .orderByChild("unisonId")
        .equalTo(unisonIdCtrl.text)
        .get();

    if (existingSnapshot.value == null) {
      setState(() {
        _editName = true;
        _editPasscode = true;
      });

      return;
    }

    final existingUser = existingSnapshot.value as Map;
    final existingUserKey = existingUser.keys.first;

    roleCtrl.text = "Member";
    nameCtrl.text = existingUser[existingUserKey]["name"];

    setState(() {
      _editName = true;
      _editPasscode = true;
      _isAllowedAccess = true;
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

  Future<void> _showDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (pickedDate != null) {
      dob = pickedDate;
      dateCtrl.text = DateFormat("MMMM dd, yyyy").format(pickedDate);
    }
  }

  void popBack() {
    Navigator.of(context).pop();
  }

  void _saveForm() async {
    _auth.signOut();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // if (dob == null) {
    //   showModal("Something went wrong while validating the date of birth.");
    //   return;
    // }

    // setState(() {
    //   _isLoading = true;
    // });

    // final unisonId = unisonIdCtrl.text;
    // final csiPasscode = passcodeCtrl.text.toUpperCase();
    // final name = nameCtrl.text;
    // final role = roleCtrl.text;

    // try {
    //   final existingUnisonID = await _dbInstance
    //       .ref("users")
    //       .orderByChild("unisonId")
    //       .equalTo(unisonId)
    //       .get();

    //   if (existingUnisonID.value == null) {
    //     showModal("No user with provided UniSon ID found.");
    //     return;
    //   }

    //   final existingUser = existingUnisonID.value as Map;
    //   final existingKey = existingUser.keys.first;
    //   if (!await CSIUser.globalCompareCredentials(
    //     unisonId: existingUser[existingKey]["unisonId"],
    //     csiId: existingUser[existingKey]["csiId"].toString(),
    //     passcode: existingUser[existingKey]["passcode"],
    //     inputUnisonId: unisonId,
    //     inputCsiId: csiId,
    //     inputPasscode: csiPasscode,
    //   )) {
    //     showModal("Your CSI Credentials are incorrect.");
    //     return;
    //   }

    //   final authenticatedUser = await _auth.createUserWithEmailAndPassword(
    //     email: email,
    //     password: password,
    //   );

    //   final roleRef = await _firestore
    //       .collection("roles")
    //       .where("name", isEqualTo: role)
    //       .limit(1)
    //       .get();

    //   final migratedUser = CSIUser(
    //     csiId: int.parse(csiId),
    //     name: name,
    //     unisonId: unisonId,
    //     email: email,
    //     passcode: existingUser[existingKey]["passcode"],
    //     role: roleRef.docs[0].reference,
    //     isAllowedAccess: _isAllowedAccess,
    //     createdAt: Timestamp.now(),
    //     dateOfBirth: Timestamp.fromDate(dob!),
    //   );

    //   await _firestore
    //       .collection("users")
    //       .doc(authenticatedUser.user!.uid)
    //       .set(migratedUser.toJson(keyless: true));

    //   await _storage.deleteAll();
    //   await _storage.write(
    //       key: firebaseUidStorageKey, value: authenticatedUser.user!.uid);
    //   await _storage.write(key: unisonIdStorageKey, value: unisonId);
    //   await _storage.write(key: csiIdStorageKey, value: csiId);
    //   await _storage.write(key: passcodeStorageKey, value: csiPasscode);

    //   popBack();
    // } on FirebaseAuthException catch (error) {
    //   var message = "An error occurred, please check your credentials!";
    //   if (error.message != null) {
    //     message = error.message!;
    //   }

    //   showModal(message);
    // } catch (error) {
    //   var message = "An error occurred, please check your credentials!";
    //   message = error.toString();

    //   showModal(message);
    // } finally {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }
  }

  @override
  void dispose() {
    unisonIdCtrl.dispose();
    passcodeCtrl.dispose();
    nameCtrl.dispose();
    dateCtrl.dispose();
    roleCtrl.dispose();

    cPwdFocus.dispose();
    unisonIdFocus.dispose();
    nameFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        child: Column(
          children: [
            buildDivider("CSI PRO Data"),
            sizedBox,
            FetchField(
              ctrl: unisonIdCtrl,
              focus: unisonIdFocus,
              onPressed: _fetchUser,
              onEditingComplete: () {
                unisonIdFocus.unfocus();
                _fetchUser();
              },
            ),
            sizedBox,
            TextFormField(
              focusNode: passcodeFocus,
              controller: passcodeCtrl,
              decoration: mainInputDecoration.copyWith(
                prefixIcon: Icon(passcodeIcon),
                label: const Text("CSI Passcode"),
                contentPadding: const EdgeInsets.symmetric(vertical: 17.0),
                suffixIcon: IconButton(
                  icon: Icon(
                      _showPasscode ? Icons.visibility_off : Icons.visibility),
                  onPressed: toggleShowPasscode,
                ),
              ),
              autocorrect: false,
              enabled: !_isLoading,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              obscureText: !_showPasscode,
              validator: (value) {
                if (value!.isEmpty) {
                  return "This field is required.";
                }

                if (!RegExp(
                  r"(?=.*[\d])(?=.*[A-D])[\dA-D]{4,8}",
                  caseSensitive: false,
                ).hasMatch(value)) {
                  return "Passcode must be 4 to 8 characters long and contain at least one number and one letter from A to D.";
                }

                return null;
              },
              onEditingComplete: () => nameFocus.requestFocus(),
            ),
            sizedBox,
            TextFormField(
              controller: roleCtrl,
              decoration: mainInputDecoration.copyWith(
                prefixIcon: Icon(roleIcon),
                label: const Text("Role"),
              ),
              autocorrect: false,
              enabled: false,
              validator: (value) {
                if (value!.isEmpty) {
                  return "This field is required.";
                }

                return null;
              },
            ),
            sizedBox,
            buildDivider("Personal Data"),
            sizedBox,
            TextFormField(
              focusNode: nameFocus,
              controller: nameCtrl,
              decoration: mainInputDecoration.copyWith(
                prefixIcon: Icon(nameIcon),
                label: const Text("Name"),
                hintText: "e.g. Saúl Ramos",
              ),
              autocorrect: false,
              enabled: !_isLoading && _editName,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value!.isEmpty) {
                  return "This field is required.";
                }

                return null;
              },
            ),
            sizedBox,
            TextFormField(
              controller: dateCtrl,
              decoration: mainInputDecoration.copyWith(
                prefixIcon: Icon(calendarIcon),
                label: const Text("Date of birth"),
              ),
              autocorrect: false,
              enabled: !_isLoading,
              readOnly: true,
              onTap: () async {
                _showDatePicker();
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return "This field is required.";
                }

                return null;
              },
            ),
            sizedBox,
            _isLoading
                ? AdaptiveSpinner(
                    color: Theme.of(context).colorScheme.primary,
                  )
                : FilledButton.icon(
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
            sizedBox,
          ],
        ),
      ),
    );
  }
}

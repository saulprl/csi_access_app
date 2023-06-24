import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import "package:cloud_firestore/cloud_firestore.dart";

import 'package:email_validator/email_validator.dart';

import "package:flutter_secure_storage/flutter_secure_storage.dart";

import 'package:csi_door_logs/firebase_options.dart';

import 'package:csi_door_logs/widgets/auth/fetch_field.dart';
import 'package:csi_door_logs/widgets/main/adaptive_spinner.dart';

import 'package:csi_door_logs/models/models.dart';

import 'package:csi_door_logs/utils/styles.dart';
import 'package:csi_door_logs/utils/globals.dart';

class CreateUserForm extends StatefulWidget {
  const CreateUserForm({super.key});

  @override
  State<CreateUserForm> createState() => _CreateUserFormState();
}

class _CreateUserFormState extends State<CreateUserForm> {
  final _dbInstance = FirebaseDatabase.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = const FlutterSecureStorage();

  final GlobalKey<FormState> _formKey = GlobalKey(debugLabel: "add_user_form");
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final unisonIdCtrl = TextEditingController();
  final csiIdCtrl = TextEditingController();
  final passcodeCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final roleCtrl = TextEditingController()..text = "Provisional";
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

    final existingUser = CSIUser.fromDataSnapshot(existingSnapshot);
    csiIdCtrl.text = existingUser.csiId.toString();
    roleCtrl.text = "Member";
    nameCtrl.text = existingUser.name;

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (dob == null) {
      showModal("Something went wrong while validating the date of birth.");
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
    final name = nameCtrl.text;
    final role = roleCtrl.text;

    try {
      final secondaryApp = await Firebase.initializeApp(
        name: 'ephimeral',
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final existingUnisonID = await _dbInstance
          .ref("users")
          .orderByChild("unisonId")
          .equalTo(unisonId)
          .get();

      if (existingUnisonID.value == null) {
        showModal("No user with provided UniSon ID found.");
        return;
      }

      final existingUser = CSIUser.fromDataSnapshot(existingUnisonID);
      if (!await existingUser.compareCredentials(
        unisonId,
        csiId,
        csiPasscode,
      )) {
        showModal("Your CSI Credentials are incorrect.");
        return;
      }

      final authenticatedUser =
          await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final roleRef = await _firestore
          .collection("roles")
          .where("name", isEqualTo: role)
          .limit(1)
          .get();

      existingUser.name = name;
      existingUser.email = email;
      existingUser.role = roleRef.docs[0].reference;
      existingUser.isAllowedAccess = _isAllowedAccess;
      existingUser.createdAt = Timestamp.now();
      existingUser.dateOfBirth = Timestamp.fromDate(dob!);

      await _firestore
          .collection("users")
          .doc(authenticatedUser.user!.uid)
          .set(existingUser.toJson(keyless: true));

      await _storage.deleteAll();
      await _storage.write(
          key: firebaseUidStorageKey, value: authenticatedUser.user!.uid);
      await _storage.write(key: unisonIdStorageKey, value: unisonId);
      await _storage.write(key: csiIdStorageKey, value: csiId);
      await _storage.write(key: passcodeStorageKey, value: csiPasscode);
      await secondaryApp.delete();

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
            buildDivider("Credentials"),
            sizedBox,
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
            sizedBox,
            TextFormField(
              controller: passwordCtrl,
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
            sizedBox,
            TextFormField(
              focusNode: cPwdFocus,
              decoration: mainInputDecoration.copyWith(
                prefixIcon: Icon(passwordIcon),
                label: const Text("Confirm password"),
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
            sizedBox,
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
                    enabled: false,
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
                    focusNode: passcodeFocus,
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
                    enabled: !_isLoading && _editPasscode,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    obscureText: !_showPasscode,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "This field is required.";
                      }

                      return null;
                    },
                    onEditingComplete: () => nameFocus.requestFocus(),
                  ),
                ),
              ],
            ),
            sizedBox,
            TextFormField(
              controller: roleCtrl,
              decoration: mainInputDecoration.copyWith(
                prefixIcon: Icon(roleIcon),
                label: const Text("CSI Role"),
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
                    icon: Icon(createUserIcon),
                    label: const Text("Create account"),
                    onPressed: _saveForm,
                  ),
            sizedBox,
          ],
        ),
      ),
    );
  }
}

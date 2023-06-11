import "package:flutter/material.dart";

import "package:firebase_database/firebase_database.dart";

import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "package:csi_door_logs/models/models.dart";
import "package:csi_door_logs/utils/styles.dart";
import "package:csi_door_logs/widgets/main/index.dart";

class CSICredentialsScreen extends StatefulWidget {
  const CSICredentialsScreen({super.key});

  @override
  State<CSICredentialsScreen> createState() => _CSICredentialsScreenState();
}

class _CSICredentialsScreenState extends State<CSICredentialsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _storage = const FlutterSecureStorage();

  final unisonIdCtrl = TextEditingController();
  final csiIdCtrl = TextEditingController();
  final passcodeCtrl = TextEditingController();

  var _showPasscode = false;
  var _isLoading = false;

  void toggleShowPasscode() {
    setState(() {
      _showPasscode = !_showPasscode;
    });
  }

  void popBack() {
    Navigator.of(context).pop();
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

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

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

      await _storage.deleteAll();
      await _storage.write(
        key: "CSIPRO-ACCESS-FIREBASE-UID",
        value: existingUser.key,
      );
      await _storage.write(key: "CSIPRO-UNISONID", value: unisonId);
      await _storage.write(key: "CSIPRO-CSIID", value: csiId);
      await _storage.write(key: "CSIPRO-PASSCODE", value: csiPasscode);

      popBack();
    } catch (error) {
      var message = "An error occurred, please check your credentials!";
      message = error.toString();

      showModal(message);
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
    unisonIdCtrl.dispose();
    csiIdCtrl.dispose();
    passcodeCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    var prompt = RichText(
      text: TextSpan(
        text: "Couldn't find your ",
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 16.0,
        ),
        children: [
          TextSpan(
            text: "CSI Credentials",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(
            text: ". Please provide them using this form.",
          ),
        ],
      ),
    );

    if (args != null && (args as Map<String, bool>).containsKey("edit")) {
      prompt = RichText(
        text: TextSpan(
          text: "Here you can set up your ",
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 16.0,
          ),
          children: [
            TextSpan(
              text: "CSI Credentials",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: ". Please provide them using this form.",
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: const CSIAppBar("CSI Credentials"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  prompt,
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: unisonIdCtrl,
                    // focusNode: unisonIdFocus,
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
                              return "Required.";
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
                          icon: const Icon(Icons.save),
                          label: const Text("Save"),
                          onPressed: _saveForm,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

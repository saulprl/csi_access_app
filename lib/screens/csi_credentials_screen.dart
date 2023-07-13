import "package:flutter/material.dart";

import "package:provider/provider.dart";

import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "package:csi_door_logs/providers/auth_provider.dart";

import "package:csi_door_logs/widgets/main/index.dart";

import "package:csi_door_logs/utils/styles.dart";
import "package:csi_door_logs/utils/globals.dart";

class CSICredentialsScreen extends StatefulWidget {
  final bool isEdit;

  const CSICredentialsScreen({this.isEdit = false, super.key});

  @override
  State<CSICredentialsScreen> createState() => _CSICredentialsScreenState();
}

class _CSICredentialsScreenState extends State<CSICredentialsScreen> {
  final _storage = const FlutterSecureStorage();

  final GlobalKey<FormState> _formKey = GlobalKey();
  final unisonIdCtrl = TextEditingController();
  final csiIdCtrl = TextEditingController();
  final passcodeCtrl = TextEditingController();

  var _showPasscode = false;
  var _isLoading = false;
  var _canEditPasscode = false;

  @override
  void initState() {
    super.initState();

    _readStorage();
  }

  Future<void> _readStorage() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final unisonId = await _storage.read(key: unisonIdStorageKey);
      final csiId = await _storage.read(key: csiIdStorageKey);

      unisonIdCtrl.text = auth.userData?.unisonId ?? unisonId ?? "";
      csiIdCtrl.text = auth.userData?.csiId.toString() ?? csiId ?? "";

      setState(() {
        _canEditPasscode = true;
      });
    } catch (error) {
      showModal(error.toString());
    }
  }

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
          content: Text(
            message,
            style: const TextStyle(fontSize: 18.0),
          ),
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

    final passcode = passcodeCtrl.text.toUpperCase();

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      if (!(await auth.compareCredentials(passcode))) {
        throw "Your CSI Passcode does not match";
      }

      await _storage.write(key: passcodeStorageKey, value: passcode);

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
    var prompt = RichText(
      text: TextSpan(
        text: "Couldn't find your ",
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 16.0,
        ),
        children: [
          TextSpan(
            text: "CSI Passcode",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(
            text: ". Please provide it using this form.",
          ),
        ],
      ),
    );

    if (isEdit) {
      prompt = RichText(
        text: TextSpan(
          text: "Here you can set up your ",
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 16.0,
          ),
          children: [
            TextSpan(
              text: "CSI Passcode",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: ". Please provide it using this form.",
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
                    decoration: InputDecoration(
                      prefixIcon: Icon(unisonIdIcon),
                      label: const Text("UniSon ID"),
                      hintText: "e.g. 217200160",
                    ),
                    autocorrect: false,
                    readOnly: true,
                    enabled: false,
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
                  TextFormField(
                    controller: csiIdCtrl,
                    decoration: InputDecoration(
                      prefixIcon: Icon(csiIdIcon),
                      label: const Text("CSI ID"),
                      hintText: "e.g. 1",
                    ),
                    autocorrect: false,
                    readOnly: true,
                    enabled: false,
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
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: passcodeCtrl,
                    decoration: InputDecoration(
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
                    enabled: !_isLoading && _canEditPasscode,
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
                  const SizedBox(height: 16.0),
                  FilledButton(
                    onPressed: !_isLoading ? _saveForm : null,
                    child: const Text(
                      "Save credentials",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (_isLoading)
                    AdaptiveSpinner(
                      color: Theme.of(context).colorScheme.primary,
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get isEdit => widget.isEdit;
}

import 'package:csi_door_logs/utils/utils.dart';
import 'package:csi_door_logs/widgets/main/adaptive_spinner.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:csi_door_logs/providers/auth_provider.dart';

import 'package:csi_door_logs/widgets/auth/room_field.dart';

import 'package:csi_door_logs/utils/globals.dart';
import 'package:csi_door_logs/utils/styles.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  double _getStartedTransitionValue = 0.0;

  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>(debugLabel: "signup_form");
  final _unisonIdKey = GlobalKey<FormFieldState>(debugLabel: "unison_id");
  final _passcodeKey = GlobalKey<FormFieldState>(debugLabel: "passcode");
  final _nameKey = GlobalKey<FormFieldState>(debugLabel: "name");
  final _dateKey = GlobalKey<FormFieldState>(debugLabel: "date");
  final _roleKey = GlobalKey<FormFieldState>(debugLabel: "role");
  final _roomKey = GlobalKey<FormFieldState>(debugLabel: "room");

  final unisonIdCtrl = TextEditingController();
  final passcodeCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final roleCtrl = TextEditingController()..text = "Guest";
  final roomCtrl = TextEditingController();
  DateTime? _dob;

  final unisonIdFocus = FocusNode();
  final passcodeFocus = FocusNode();
  final nameFocus = FocusNode();

  String? _room;
  var _showPassword = false;
  var _showPasscode = false;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTransition();
  }

  void _startTransition() {
    Future.delayed(const Duration(milliseconds: 1950), () {
      setState(() {
        _getStartedTransitionValue = 1.0;
      });
    });
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

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

  void setRoom(String? value) {
    if (value == null) return;

    setState(() {
      _room = value;
    });
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

  void showModal({String title = "Error", required String message}) {
    showAlertDialog(context: context, title: title, message: message);
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
      _dob = pickedDate;
      dateCtrl.text = DateFormat("MMMM dd, yyyy").format(pickedDate);
    }
  }

  void popBack() {
    Navigator.of(context).pop();
  }

  Future<bool> _validatePersonalData() async {
    setState(() => _isLoading = true);

    bool isValid = true;
    final fieldKeys = [_unisonIdKey, _nameKey, _dateKey];

    for (final key in fieldKeys) {
      final fieldState = key.currentState;

      if (fieldState == null || !fieldState.validate()) {
        isValid = false;
      }
    }

    if (!isValid) {
      return false;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (await auth.unisonIdExists(unisonIdCtrl.text.trim())) {
      setState(() => _isLoading = false);
      showModal(message: "Unison ID already in use.");
      return false;
    }

    setState(() => _isLoading = false);

    return true;
  }

  void _saveForm() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_dob == null) {
      showModal(message: "Your date of birth is required.");
      return;
    }

    if (_room == null) {
      showModal(message: "You must select a room.");
    }

    setState(() {
      _isLoading = true;
    });

    if (auth.user == null) {
      showModal(message: "Something went wrong. Please try again later.");
      return;
    }

    final unisonId = unisonIdCtrl.text.trim();
    final passcode = passcodeCtrl.text.trim().toUpperCase();
    final name = nameCtrl.text.trim();
    final role = roleCtrl.text.trim();
    final room = _room!;
    final dob = _dob!;
    try {
      await auth.populateUserData(
        name: name,
        unisonId: unisonId,
        passcode: passcode,
        dob: dob,
        roomId: room,
        roleName: role,
      );
    } catch (error) {
      showModal(message: error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    unisonIdCtrl.dispose();
    passcodeCtrl.dispose();
    nameCtrl.dispose();
    dateCtrl.dispose();
    roleCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 750),
            curve: Curves.easeInOutCubic,
            opacity: _getStartedTransitionValue,
            child: buildWelcomePage(),
          ),
          buildPersonalDataSection(),
          buildAccessDataSection(),
        ],
      ),
    );
  }

  Widget buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Welcome",
            style: TextStyle(
              fontSize: 48.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            "It seems you're new here",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          FilledButton(
            onPressed: _nextPage,
            child: const Text(
              "Get started",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPersonalDataSection() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildSectionTitle("Personal data"),
            sizedBox,
            TextFormField(
              key: _unisonIdKey,
              controller: unisonIdCtrl,
              focusNode: unisonIdFocus,
              decoration: InputDecoration(
                prefixIcon: Icon(unisonIdIcon),
                label: const Text("Unison ID"),
                hintText: "e.g. 217200160",
                counterText: "",
              ),
              enabled: !_isLoading,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              maxLength: 9,
              validator: (value) {
                if (value!.isEmpty) {
                  return "This field is required.";
                }

                if (value.length < 5) {
                  return "Your ID must be at least 5 characters long.";
                }

                return null;
              },
            ),
            sizedBox,
            TextFormField(
              key: _nameKey,
              focusNode: nameFocus,
              controller: nameCtrl,
              decoration: InputDecoration(
                prefixIcon: Icon(nameIcon),
                label: const Text("Name"),
                hintText: "e.g. Saúl Ramos",
                counterText: "",
              ),
              maxLength: 50,
              autocorrect: false,
              enabled: !_isLoading,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
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
              key: _dateKey,
              controller: dateCtrl,
              decoration: InputDecoration(
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
                  _pageController.jumpToPage(1);
                  return "This field is required.";
                }

                return null;
              },
            ),
            sizedBox,
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: !_isLoading
                        ? () async {
                            setState(() => _isLoading = true);

                            final isValid = await _validatePersonalData();

                            setState(() => _isLoading = false);

                            if (!isValid) {
                              return;
                            }

                            _nextPage();
                          }
                        : null,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 8.0,
                      ),
                      child: Text(
                        "Next step",
                        style: signupButtonTextStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            sizedBox,
            if (_isLoading)
              AdaptiveSpinner(color: Theme.of(context).colorScheme.primary)
          ],
        ),
      ),
    );
  }

  Widget buildAccessDataSection() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          children: [
            buildSectionTitle("Access data"),
            sizedBox,
            TextFormField(
              key: _passcodeKey,
              focusNode: passcodeFocus,
              controller: passcodeCtrl,
              decoration: InputDecoration(
                prefixIcon: Icon(passcodeIcon),
                label: const Text("CSI Passcode"),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPasscode ? Icons.visibility : Icons.visibility_off,
                    color: _showPasscode
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  onPressed: toggleShowPasscode,
                ),
                counterText: "",
                errorMaxLines: 4,
              ),
              maxLength: 8,
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
                  return "Must be 4 to 8 characters long and contain at least one number and one letter from A to D.";
                }

                return null;
              },
              onEditingComplete: () => nameFocus.requestFocus(),
            ),
            sizedBox,
            TextFormField(
              key: _roleKey,
              controller: roleCtrl,
              decoration: InputDecoration(
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
            RoomField(
              key: _roomKey,
              value: _room,
              onChange: setRoom,
            ),
            const SizedBox(height: 4.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                roomDisclaimer,
                textAlign: TextAlign.justify,
              ),
            ),
            sizedBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: !_isLoading ? _previousPage : null,
                    child: const Text(
                      "Go back",
                      style: signupButtonTextStyle,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: !_isLoading ? _saveForm : null,
                    child: const Text(
                      "Complete setup",
                      style: signupButtonTextStyle,
                    ),
                  ),
                ),
              ],
            ),
            sizedBox,
            if (_isLoading)
              AdaptiveSpinner(color: Theme.of(context).colorScheme.primary)
          ],
        ),
      ),
    );
  }

  Text buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 20.0,
      ),
    );
  }

  // Widget get signUpButton => _isLoading
  //     ? AdaptiveSpinner(
  //         color: Theme.of(context).colorScheme.primary,
  //       )
  //     : FilledButton.icon(
  //         style: ButtonStyle(
  //           padding: const MaterialStatePropertyAll(
  //             EdgeInsets.all(12.0),
  //           ),
  //           shape: MaterialStatePropertyAll(
  //             RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8.0),
  //             ),
  //           ),
  //         ),
  //         icon: Icon(signupIcon),
  //         label: const Text("Sign up"),
  //         onPressed: _saveForm,
  //       );

  Widget get sizedBox => const SizedBox(height: 16.0);
}

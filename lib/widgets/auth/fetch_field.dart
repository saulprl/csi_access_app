import 'package:flutter/material.dart';

import 'package:csi_door_logs/utils/styles.dart';

class FetchField extends StatefulWidget {
  final TextEditingController ctrl;
  final FocusNode? focus;
  final IconData? icon;
  final String label;
  final String hintText;
  final VoidCallback onPressed;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final VoidCallback? onEditingComplete;

  const FetchField({
    required this.ctrl,
    this.focus,
    this.icon,
    this.label = "UniSon ID",
    this.hintText = "e.g. 217200160",
    required this.onPressed,
    this.enabled = true,
    this.keyboardType = TextInputType.number,
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.onEditingComplete,
    super.key,
  });

  @override
  State<FetchField> createState() => _FetchFieldState();
}

class _FetchFieldState extends State<FetchField> {
  late VoidCallback? _onPressed;
  late Color _iconColor;

  @override
  void initState() {
    super.initState();

    _onPressed = null;
    _iconColor = Colors.black54;

    ctrl.addListener(_controllerListener);
  }

  void _controllerListener() {
    setState(() {
      if (ctrl.text.isEmpty) {
        _onPressed = null;
        _iconColor = Colors.black54;
      } else {
        _onPressed = widget.onPressed;
        _iconColor = Theme.of(context).colorScheme.primary;
      }
    });
  }

  @override
  void dispose() {
    ctrl.removeListener(_controllerListener);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      focusNode: focus,
      decoration: InputDecoration(
        prefixIcon: Icon(icon ?? unisonIdIcon),
        label: Text(label),
        hintText: hintText,
        suffixIcon: IconButton(
          icon: Icon(
            fetchIcon,
            color: _iconColor,
          ),
          onPressed: _onPressed,
        ),
        counterText: "",
      ),
      maxLength: 9,
      autocorrect: false,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onEditingComplete: onEditingComplete,
    );
  }

  TextEditingController get ctrl => widget.ctrl;
  FocusNode? get focus => widget.focus;
  IconData? get icon => widget.icon;
  String get label => widget.label;
  String get hintText => widget.hintText;
  VoidCallback get onPressed => widget.onPressed;
  bool get enabled => widget.enabled;
  TextInputType get keyboardType => widget.keyboardType;
  TextInputAction get textInputAction => widget.textInputAction;
  String? Function(String?)? get validator => widget.validator;
  VoidCallback? get onEditingComplete => widget.onEditingComplete;
}

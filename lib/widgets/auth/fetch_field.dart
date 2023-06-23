import 'package:flutter/material.dart';

import 'package:csi_door_logs/utils/styles.dart';

class FetchField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      focusNode: focus,
      decoration: mainInputDecoration.copyWith(
        prefixIcon: Icon(icon ?? unisonIdIcon),
        label: Text(label),
        hintText: hintText,
        suffixIcon: IconButton(
          icon: Icon(
            fetchIcon,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: onPressed,
        ),
      ),
      autocorrect: false,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onEditingComplete: onEditingComplete,
    );
  }
}

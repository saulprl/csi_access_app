import 'package:flutter/material.dart';

class RoleField extends StatefulWidget {
  final String value;
  final List<String> values;
  final void Function(String?) onChange;

  const RoleField({
    required this.value,
    required this.values,
    required this.onChange,
    super.key,
  });

  @override
  State<RoleField> createState() => _RoleFieldState();
}

class _RoleFieldState extends State<RoleField> {
  late String dropdownValue;

  @override
  void initState() {
    super.initState();

    dropdownValue = widget.value;
  }

  void onChange(String? value) {
    if (value == null) return;

    widget.onChange(value);
    setState(() => dropdownValue = value);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      items: widget.values
          .map((role) => DropdownMenuItem<String>(
                value: role,
                child: Text(role),
              ))
          .toList(),
      onChanged: onChange,
      isExpanded: true,
    );
  }
}

import 'package:csi_door_logs/providers/role_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoleField extends StatefulWidget {
  final String value;
  final void Function(String?) onChange;

  const RoleField({
    required this.value,
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

    dropdownValue = value;
  }

  void onChanged(String? value) {
    if (value == null) return;

    onChange(value);
    setState(() => dropdownValue = value);
  }

  @override
  Widget build(BuildContext context) {
    final roles = Provider.of<RoleProvider>(context).roles;

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: "Role"),
      value: dropdownValue,
      items: roles
          .map((role) => DropdownMenuItem<String>(
                value: role.key,
                child: Text(role.name),
              ))
          .toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }

  String get value => widget.value;
  void Function(String?) get onChange => widget.onChange;
}

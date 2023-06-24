import 'package:csi_door_logs/widgets/admin/create_user_form.dart';
import 'package:csi_door_logs/widgets/main/index.dart';
import 'package:flutter/material.dart';

class CreateUserScreen extends StatelessWidget {
  const CreateUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CSIAppBar('Create Account'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CreateUserForm(),
            ],
          ),
        ),
      ),
    );
  }
}

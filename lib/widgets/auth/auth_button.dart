import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final Widget providerImage;
  final String providerName;
  final Color? color;
  final String? label;
  final String? fontFamily;
  final void Function() onPressed;

  const AuthButton({
    required this.providerImage,
    required this.providerName,
    required this.onPressed,
    this.color,
    this.label,
    this.fontFamily,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ElevatedButton(
      onPressed: onPressed,
      child: Container(
        width: size.width * 0.75,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 40.0,
              width: 40.0,
              child: providerImage,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  label ?? "Sign in with $providerName",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0,
                    color: color,
                    fontFamily: "Roboto",
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

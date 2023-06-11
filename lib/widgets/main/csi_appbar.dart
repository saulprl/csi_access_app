import "package:flutter/material.dart";

class CSIAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  final String title;

  const CSIAppBar(
    this.title, {
    Key? key,
  })  : preferredSize = const Size.fromHeight(56.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title));
  }
}

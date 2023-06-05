import "package:flutter/material.dart";

class CSIAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  final String title;

  CSIAppBar(
    this.title, {
    Key? key,
  })  : preferredSize = const Size.fromHeight(56.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title));
  }
}

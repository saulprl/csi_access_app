import "package:flutter/material.dart";

const iconColor = Colors.white;
const iconSize = 30.0;

const deepGray = Color(0xFF707070);
const lightGray = Color(0xA7FFFFFF);

const doneIcon = Icon(
  Icons.check_circle,
  color: iconColor,
  size: iconSize,
);

const failedIcon = Icon(
  Icons.cancel,
  color: iconColor,
  size: iconSize,
);

const mainInputDecoration = InputDecoration(
  errorStyle: TextStyle(color: Color(0xFFFF1111)),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFFF1111),
    ),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFFF1111),
    ),
  ),
  isDense: true,
  border: OutlineInputBorder(),
);

const pibleBubbleTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 18.0,
  fontWeight: FontWeight.bold,
);

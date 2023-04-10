import "package:flutter/material.dart";

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

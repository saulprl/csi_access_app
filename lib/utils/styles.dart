import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

const iconColor = Colors.white;
const iconSize = 40.0;

const deepGray = Color(0xFF707070);
const lightGray = Color(0xA7FFFFFF);

final doneIcon = Icon(
  Platform.isIOS ? CupertinoIcons.check_mark_circled_solid : Icons.check_circle,
  key: const ValueKey("Check icon"),
  color: iconColor,
  size: iconSize,
);

final failedIcon = Icon(
  Platform.isIOS ? CupertinoIcons.clear_circled_solid : Icons.cancel,
  key: const ValueKey("Failed icon"),
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

const screenSubtitle = TextStyle(
  color: Colors.black45,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const pibleBubbleTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 18.0,
  fontWeight: FontWeight.bold,
);

const accessLog = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
);

final successfulLogTitle = accessLog.copyWith(
  fontSize: 32.0,
);

final successfulLogTimestamp = accessLog.copyWith(
  fontSize: 20.0,
  fontWeight: FontWeight.normal,
);

final failedLogTitle = accessLog.copyWith(
  fontSize: 18.0,
);

final failedLogTimestamp = accessLog.copyWith(
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
);

IconData get emailIcon =>
    Platform.isIOS ? CupertinoIcons.mail_solid : Icons.email;

IconData get passwordIcon =>
    Platform.isIOS ? CupertinoIcons.lock_fill : Icons.lock;

IconData get unisonIdIcon =>
    Platform.isIOS ? CupertinoIcons.person_crop_rectangle_fill : Icons.badge;

IconData get fetchIcon =>
    Platform.isIOS ? CupertinoIcons.search : Icons.search_rounded;

IconData get csiIdIcon =>
    Platform.isIOS ? CupertinoIcons.number_square_fill : Icons.numbers;

IconData get passcodeIcon => Icons.pin;

IconData get roleIcon => Platform.isIOS ? CupertinoIcons.star_fill : Icons.star;

IconData get nameIcon =>
    Platform.isIOS ? CupertinoIcons.person_circle_fill : Icons.person;

IconData get calendarIcon =>
    Platform.isIOS ? CupertinoIcons.calendar : Icons.calendar_today_rounded;

IconData get signupIcon => Platform.isIOS
    ? CupertinoIcons.person_crop_circle_badge_checkmark
    : Icons.how_to_reg;

IconData get refreshIcon =>
    Platform.isIOS ? CupertinoIcons.refresh : Icons.refresh;

IconData get dashboardIcon =>
    Platform.isIOS ? CupertinoIcons.rectangle_3_offgrid_fill : Icons.dashboard;

IconData get listIcon =>
    Platform.isIOS ? CupertinoIcons.square_list : Icons.list_alt;

IconData get settingsIcon =>
    Platform.isIOS ? CupertinoIcons.settings : Icons.settings;

IconData get groupIcon => Platform.isIOS ? CupertinoIcons.group : Icons.group;

IconData get logoutIcon => Platform.isIOS ? Icons.logout_rounded : Icons.logout;

IconData get createUserIcon =>
    Platform.isIOS ? CupertinoIcons.person_add_solid : Icons.person_add;

IconData get editIcon => Platform.isIOS ? CupertinoIcons.pencil : Icons.edit;

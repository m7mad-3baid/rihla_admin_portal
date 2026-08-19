import 'package:flutter/material.dart';

Color metroLineColor(String line) {
  String lowerLine = line.toLowerCase();

  if (lowerLine.contains('red')) {
    return Colors.red;
  }

  if (lowerLine.contains('green')) {
    return Colors.green;
  }

  return Colors.blue;
}

String dateOnly(String date) {
  if (date.contains(' ')) {
    return date.split(' ').first;
  }

  return date;
}

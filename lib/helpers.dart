import 'dart:convert';
import 'dart:io';

void saveCookie(String username, String password) {
  final now = DateTime.now();
  final formattedDate =
      "${now.year.toString().padLeft(4, '0')}/"
      "${now.month.toString().padLeft(2, '0')}/"
      "${now.day.toString().padLeft(2, '0')}";

  final fileInfo = {
    "username": username,
    "password": password,
    "date": formattedDate,
  };

  final file = File("cookie.json");
  file.writeAsStringSync(
    jsonEncode(fileInfo),
    encoding: utf8,
  );
}

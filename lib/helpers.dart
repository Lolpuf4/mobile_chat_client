import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> saveCookie(String username, String password) async {
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

  final dir = await getApplicationDocumentsDirectory();
  final file = File("${dir.path}/cookie.json");

  await file.writeAsString(
    jsonEncode(fileInfo),
    encoding: utf8,
  );
}


Future<Map<String, dynamic>?> loadCookie() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File("${dir.path}/cookie.json");

  if (!await file.exists()) {
    return null;
  }

  final contents = await file.readAsString();
  final data = jsonDecode(contents);

  return {
    "username": data["username"],
    "password": data["password"],
    "date": data["date"],
  };
}

//surely i will not forget to add try at some point


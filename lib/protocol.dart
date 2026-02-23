import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'connection.dart';
import 'package:path_provider/path_provider.dart';


class Protocol {
  static const int headerSize = 64;

  static Future<List<String>> recv(Connection conn) async {
    final headerBytes = await conn.get_info(headerSize);
    final header = utf8.decode(headerBytes);
    print(header);

    final parts = header.split(",");
    final type = parts[0];
    final size = int.parse(parts[1]);

    var fileName = parts[2].replaceAll("*", "");
    fileName = fileName.substring(0, fileName.length - 1);

    final dataBytes = await conn.get_info(size);

    if (type == "TXT" || type == "ERR" || type == "DIC") {
      return [type, utf8.decode(dataBytes)];
    }


    final dir = await getApplicationDocumentsDirectory();
    final recvDir = Directory('${dir.path}/recv_files');

    if (!await recvDir.exists()) {
      await recvDir.create(recursive: true);
    }

    final file = File('${recvDir.path}/$fileName');
    await file.writeAsBytes(dataBytes);
    return [type, file.path];
  }


  static Future<void> send(Socket socket, String type, List<int> data, String filePath) async {
    final dataSize = data.length;
    final sizeStr = dataSize.toString().padLeft(8, '0');

    final fileName = filePath.split("/").last;
    final paddedFile = fileName.padLeft(50, '*');

    final header = "$type,$sizeStr,$paddedFile:";

    socket.add(utf8.encode(header));
    socket.add(data);
    await socket.flush();
  }

  static Future<void> sendText(Socket socket, String text) async {
    await send(socket, "TXT", utf8.encode(text), "");
  }

  static Future<void> sendError(Socket socket, String text) async {
    await send(socket, "ERR", utf8.encode(text), "");
  }

  static Future<void> sendJson(Socket socket, Map<String, dynamic> jsonMap) async {
    final encoded = jsonEncode(jsonMap);
    await send(socket, "DIC", utf8.encode(encoded), "");
  }

  static Future<void> sendFile(Socket socket, String filePath, String type) async {
    final file = File(filePath);
    final data = await file.readAsBytes();
    final name = filePath.split("/").last;
    await send(socket, type, data, name);
  }
}

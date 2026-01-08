import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class Protocol {
  static const int headerSize = 64;
  static Future<List<int>> get_info(Stream<Uint8List> stream, int size) async {      //Future allows for await
    final info = <int>[];
    await for (final chunk in stream) {
      info.addAll(chunk);
        if (info.length >= size) break;
      }

    return info;
  }


  static Future<List<String>> recv(Stream<Uint8List> stream) async {
    final headerBytes = await get_info(stream, headerSize);
    final header = utf8.decode(headerBytes);

    final parts = header.split(",");
    final type = parts[0];
    final size = int.parse(parts[1]);             //int.parse() = int()

    var fileName = parts[2].replaceAll("*", "");
    fileName = fileName.substring(0, fileName.length - 1);       //substring = text[start:finish]

    final dataBytes = await get_info(stream, size);

    if (type == "TXT" || type == "ERR" || type == "DIC") {
      return [type, utf8.decode(dataBytes)];
    }

    final file = File("recv_files/$fileName");         //creates object for file but not the file yet
    await file.writeAsBytes(dataBytes);               //auto opens/closes file
    return [type, file.path];
  }


  static Future<void> send(Socket socket, String type, List<int> data, String filePath) async {
    final dataSize = data.length;
    final sizeStr = dataSize.toString().padLeft(8, '0');           // converts int to str and adds 0s in the beginning to fill up the whole size part

    final fileName = filePath.split("/").last;                   //  filepath/image.png - > [filepath, image.png] -> image.png
    final paddedFile = fileName.padLeft(50, '*');      //adds * to fill up the whole name part

    final header = "$type,$sizeStr,$paddedFile:";       //creates the header

    socket.add(utf8.encode(header));     //add the header to the socket buffer
    socket.add(data);            //add the data to the socket buffer
    await socket.flush();        //sent everything that is in the buffer        await prevents some bugs because it is an asynced action
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

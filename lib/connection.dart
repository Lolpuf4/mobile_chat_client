import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

import 'protocol.dart';
import 'helpers.dart';

const String HOST = "10.0.2.2";
const int PORT = 10009;

class Connection {
  late Socket socket;
  final List<int> _buffer = [];
  late StreamSubscription _sub;
  bool connected = false;

  Connection();

  // Connect to the server and start listening
  Future<void> connect() async {
    socket = await Socket.connect(HOST, PORT);

    _sub = socket.listen((chunk) {
      _buffer.addAll(chunk);
    });

    connected = true;
  }

  // Python-style recv(n) using buffer
  Future<Uint8List> get_info(int size) async {
    final result = BytesBuilder();

    while (result.length < size) {
      // Wait until buffer has something
      while (_buffer.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 1));
      }

      // How many bytes we still need
      final remaining = size - result.length;

      // How many bytes we can take from the buffer
      final take = remaining < _buffer.length ? remaining : _buffer.length;

      // Copy bytes into result
      result.add(_buffer.sublist(0, take));

      // Remove consumed bytes from buffer
      _buffer.removeRange(0, take);
    }

    return result.toBytes();
  }



  Future<(bool, String)> try_login(String username, String password) async {
    await Protocol.sendText(socket, username);
    await Protocol.sendText(socket, password);

    final info = await Protocol.recv(this);

    if (info[0] == "ERR") {
      return (false, "invalid login information");
    } else if (info[0] == "TXT") {
      saveCookie(username, password);
      return (true, "login successful");
    }

    return (false, "server response fail");
  }

  Future<dynamic> getInfo() async {
    final info = await Protocol.recv(this);

    if (info[0] == "TXT") {
      return info[1];
    } else if (info[0] == "JSN") {
      final file = File(info[1]);
      final jsonStr = await file.readAsString();
      print("JSON length: ${jsonStr.length}");
      return jsonDecode(jsonStr);
    }

    return null;
  }

  Future<void> sendInfo(dynamic data, String type) async {
    if (type == "TXT") {
      await Protocol.sendText(socket, data);
    }
  }

  Future<void> disconnect() async {
    try {
      connected = false;
      await Future.delayed(const Duration(milliseconds: 200));
      await Protocol.sendError(socket, "1");
      socket.close();
    } catch (e) {
      print(e);
    }
  }
}

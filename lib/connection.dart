import 'dart:io';
import 'dart:convert';
import 'protocol.dart';
import 'helpers.dart';
import 'dart:typed_data';


const String HOST = "62.60.178.229";
const int PORT = 10009;

class Connection {
  late Socket socket;
  late Stream<Uint8List> socketStream;
  bool connected = false;

  Connection();

  // Connect to the server
  Future<void> connect() async {
    socket = await Socket.connect(HOST, PORT);
    socketStream = socket.asBroadcastStream();
    connected = true;
  }

  Future<(bool, String)> try_login(String username, String password) async {
    await Protocol.sendText(socket, username);        // Send username
    await Protocol.sendText(socket, password);        // Send password
    final info = await Protocol.recv(socketStream);         // recv server response

    if (info[0] == "ERR") {
      return (false, "invalid login information");
    } else if (info[0] == "TXT") {
      saveCookie(username, password);
      return (true, "login successful");
    }

    return (false, "server response fail");
  }

  Future<dynamic> getInfo() async {
    final info = await Protocol.recv(socketStream);

    if (info[0] == "TXT") {
      return info[1];
    } else if (info[0] == "JSN") {
      final file = File(info[1]);
      final jsonStr = await file.readAsString();
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
      await Future.delayed(const Duration(milliseconds: 200));   //sleep

      await Protocol.sendError(socket, "1");

      // Close the socket
      socket.close();
    } catch (e) {
      print(e);
    }
  }


}
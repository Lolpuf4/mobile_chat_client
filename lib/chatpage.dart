import 'package:flutter/material.dart';
import 'connection.dart';

class ChatPage extends StatelessWidget {
  final Connection connection;
  const ChatPage({super.key, required this.connection});       //brings connection object from the login page

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat")),
      body: Center(
        child: Text("Connected: ${connection.connected}"),
      ),
    );
  }
}

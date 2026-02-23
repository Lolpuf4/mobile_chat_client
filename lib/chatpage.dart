import 'package:flutter/material.dart';
import 'connection.dart';
import 'dart:convert';
import 'dart:io';



// class DataReceiver {
//   final Connection connection;
//
//   bool _running = false;
//
//   final void Function(Map<String, dynamic>) onMessage;
//   final void Function(Map<String, dynamic>) onOnlineUsers;
//
//   DataReceiver({
//     required this.connection,
//     required this.onMessage,
//     required this.onOnlineUsers,
//   });
//
//   void start() {
//     _running = true;
//     _listenLoop();
//   }
//
//   void stop() {
//     _running = false;
//   }
//
//   Future<void> _listenLoop() async {
//     while (_running && connection.connected) {
//
//       final info = await connection.getInfo();
//       print("Received data: $info");
//
//       if (info.containsKey("online_users")) {
//         onOnlineUsers(info);
//       } else {
//         onMessage(info);
//       }
//     }
//   }
// }

class ChatPage extends StatefulWidget {
  final Connection connection;

  const ChatPage({super.key, required this.connection});

  @override
  State<ChatPage> createState() => _ChatPageState();
}


class _ChatPageState extends State<ChatPage> {
  String currentUser = "";
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  //late DataReceiver dataReceiver;


  late Future<Map<String, dynamic>> _chatFuture;



  void updateChat(Map<String, dynamic> data) {
    setState(() {
      // add new msgs
    });
  }

  void updateOnlineUsers(Map<String, dynamic> data) {
    setState(() {
      // update online users list
    });
  }

  @override
  void initState() {
    super.initState();
    _chatFuture = getOldChat(); // Load ONCE

    // dataReceiver = DataReceiver(
    //   connection: widget.connection,
    //   onMessage: (data) {
    //     updateChat(data);
    //   },
    //   onOnlineUsers: (data) {
    //     updateOnlineUsers(data);
    //   },
    // );

    //dataReceiver.start();
  }

  void switchUser(String username) {
    setState(() {
      currentUser = username;
    });
  }

  void sendMsg(String message) {
    // lots of stuff goes here
  }

  Future<Map<String, dynamic>> getOldChat() async {
    print("hello");
    final data = await widget.connection.getInfo();
    print("Received data: $data");
    return data;
  }



@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Row(
        children: [
          // LEFT SIDEBAR
          Container(
            width: 120,
            color: Colors.grey[200],
            child: FutureBuilder(
              future: _chatFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final history = snapshot.data!;
                final userNames = history.keys.toList();

                // Set default user once
                if (currentUser.isEmpty && userNames.isNotEmpty) {
                  currentUser = userNames.first;
                }

                return ListView(
                  children: [
                    for (var name in userNames)
                      TextButton(
                        onPressed: () => switchUser(name),
                        child: Text(
                          name,
                          style: TextStyle(
                            fontWeight: name == currentUser
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // RIGHT CHAT AREA
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: FutureBuilder(
                    future: _chatFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final history = snapshot.data!;
                      final messages = history[currentUser]?["msgs"] ?? [];

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                        }
                      });
                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final text = msg["messages.text"] ?? "";
                          final sender = msg["message_history.senderID"];
                          final userSenderID = history[currentUser]["senderID"];

                          final isCurrentUser = sender == userSenderID;


                          return Align(
                            alignment: isCurrentUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isCurrentUser ? Colors.blue[100] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(text),
                            ),
                          );

                        },
                      );
                    },
                  ),
                ),

                // MESSAGE INPUT
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          sendMsg(_messageController.text);
                          _messageController.clear();
                          setState(() {}); // Refresh UI after sending
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

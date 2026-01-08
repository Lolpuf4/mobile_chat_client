import 'package:flutter/material.dart';
import 'connection.dart';
import 'chatpage.dart';


class LoginPage extends StatefulWidget {                                                          //stateful widget allow for updating in real time
  const LoginPage({super.key});                                                                   //super.key gives its on unique identifier to the login page class idk why needed
  // consts means that the value never changes so that flutter/dart can optimize it for memory or smt

  @override                                                                                       //changing existing method by a new one from createState into loginpagestate
  State<LoginPage> createState() => _LoginPageState();                                            // _ in the beggining makes this class only accessable inside this file
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();                      //final - is assinged once
  final TextEditingController _passwordController = TextEditingController();                      // controllers are created to "work" with the input boxes (get data from, clear ect.)
  final Connection connection = Connection();
  String errorMessage = "";

  void _login() async{                                            //checks if the user got correct log in data, returns nothing but will go to the chat window if the log in is successful (not done yet)
    final username = _usernameController.text; //puts the text from the input box into a variable
    final password = _passwordController.text; //puts the text from the input box into a variable
    await connection.connect();
    //login logic
    final result = await connection.try_login(username, password);
    if (result.$1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatPage(connection: connection)),
      );

    } else {
      errorMessage = result.$2;
    }

    print('Username: $username');  //$variable == {variable}
    print('Password: $password');  //${a + b} == {a + b}
  }

  @override
  Widget build(BuildContext context) {                    //rewrites on how the UI looks like, function returns a widget, this func gets called every update that happens on the screen
    return Scaffold(                                                //layout
      appBar: AppBar(                                                  //top bar
        title: const Text('Login'),
      ),
      body: Padding(                                               //main part
        padding: const EdgeInsets.all(20.0),                           //20 pixels of empty space of the sides
        child: Column(   //child - everything inside the padding and its in a shape of a column (vertical)
          mainAxisAlignment: MainAxisAlignment.center, // centered
          children: [           //list of widgets that go inside the column
            TextField(                //one of the widgets
              controller: _usernameController,                 //connects this widget to the controller from line #13
              decoration: const InputDecoration(              //how it looks
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20), //skip 20 pixels between the inputs/widgets
            TextField(
              controller: _passwordController,
              obscureText: true,            //hides the chars when typing cuz its a password and needs to be hidden
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,     //makes the button take up as much space as possible
              child: ElevatedButton(       //looks - adds shadow and a look like its elevated, automatic animation exists
                onPressed: _login,  //login function gets called in when this box is cliccked
                child: const Text('Log In'),
              ),
            ),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
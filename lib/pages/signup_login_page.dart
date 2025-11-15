import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gas_app_project_dev/main_navigation.dart';
import 'package:gas_app_project_dev/services/auth.dart';


class LoginPage extends StatefulWidget{
  const LoginPage ({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerRePassword = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signInWithEmailPassword() async{
    try {
      await Auth().signInWithEmailPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      setState(() {
        isLogin: true;
        errorMessage = '';
      });

      _controllerEmail.clear();
      _controllerPassword.clear();

      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => MainNavigation()),
      );

    } on FirebaseAuthException catch(e) {
      setState(() {
        errorMessage = e.message;
      });
    } 
  }

  Future<void> createUserWithEmailPassword() async {
    final email = _controllerEmail.text.trim();
    final password = _controllerPassword.text.trim();
    final repassword = _controllerRePassword.text.trim();

    if(password != repassword){
      setState(() {
        errorMessage = 'Passwords do not match!';
      });
    }

    try {
      await Auth().createUserWithEmailPassword(
        email: email,
        password: password,
      ); 

      _controllerEmail.clear();
      _controllerPassword.clear();
      _controllerRePassword.clear();

    } on FirebaseAuthException catch(e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _entryField(String title, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: title,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: Color.fromARGB(0, 17, 123, 222),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
        )
      ),
    );
  } 

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : '$errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: isLogin ? signInWithEmailPassword : createUserWithEmailPassword,
      child: Text(isLogin ? 'Login' : 'Register'),
      );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: (){
      setState(() {
        isLogin = !isLogin;
      });
      },
    child: Text(isLogin ? 'Register Instead' : 'Login Instead')
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 119, 134),
      body: Container(
        margin: const EdgeInsets.only(right: 32, top: 128, bottom: 128, left: 32),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 2, 55, 128),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 14, 1, 112),
            width: 2,
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            Text(
              isLogin ? 'Login' : 'SignUp',
              style: const TextStyle(fontSize: 32, color:  Colors.lightBlueAccent),
            ),
            const SizedBox(height: 32),
            _entryField('Email', _controllerEmail, isPassword: false),
            const SizedBox(height: 4),
            _entryField('Password', _controllerPassword, isPassword: true),
            const SizedBox(height: 4),
            if(!isLogin) _entryField('ReEnter Password', _controllerRePassword, isPassword: true),
            if(!isLogin) const SizedBox(height: 4),
            _errorMessage(),
            _submitButton(),
            _loginOrRegisterButton()
          ],
        ),
      ),
    );
  }
}
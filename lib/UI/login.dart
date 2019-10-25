import 'package:flutter/material.dart';
import './dictionary.dart';

class FirebaseAuthentic extends StatefulWidget {
  @override
  Authentic createState() => Authentic();
}

class Authentic extends State<FirebaseAuthentic> {
  final emailInputController = new TextEditingController();
  final passwordInputController = new TextEditingController();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("auth"),
      ),
      body: layoutBody(context),
    );
  }

  Widget layoutBody(BuildContext context) {
    return new Center(
      child: new Form(
        child: new SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 24.0),
              createEmailInputField(),
              const SizedBox(height: 24.0),
              createPasswordInputField(),
              const SizedBox(height: 24.0),
              new Center(child: createLoginButton()),
              const SizedBox(height: 24.0),
              new Center(child: createSignUpButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget createEmailInputField() {
    return new TextFormField(
      controller: emailInputController,
      decoration: const InputDecoration(
        border: const UnderlineInputBorder(),
        labelText: 'Email',
      ),
    );
  }

  Widget createPasswordInputField() {
    return new TextFormField(
      controller: passwordInputController,
      decoration: new InputDecoration(
        border: const UnderlineInputBorder(),
        labelText: 'Password',
      ),
      obscureText: true,
    );
  }

  Widget createLoginButton() {
    return new RaisedButton(
      child: const Text('Login'),
      onPressed: () {
        onPressLoginButton();
      },
    );
  }

  Widget createSignUpButton() {
    return new RaisedButton(
      child: const Text('登録'),
      onPressed: () {},
    );
  }

  void onPressLoginButton() {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => new Dictionary(false)));
  }
}

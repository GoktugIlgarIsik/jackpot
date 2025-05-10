import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: AnimatedLoginPage()),
  );
}

class AnimatedLoginPage extends StatefulWidget {
  const AnimatedLoginPage({super.key});

  @override
  _AnimatedLoginPageState createState() => _AnimatedLoginPageState();
}

class _AnimatedLoginPageState extends State<AnimatedLoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '';

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    print("Trying to login with email: '$email', password: '$password'");

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Email ve şifre boş olamaz!")));
      return;
    }
    if (!email.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Geçerli bir email giriniz!")));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Şifre en az 6 karakter olmalı!")));
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Email ile giriş başarılı!")));
    } catch (e) {
      print("Login2 error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: ${e.toString()}")));
    }
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    print("Trying to sign up with email: '$email', password: '$password'");

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Email ve şifre boş olamaz!")));
      return;
    }
    if (!email.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Geçerli bir email giriniz!")));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Şifre en az 6 karakter olmalı!")));
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kayıt başarılı! Şimdi giriş yapabilirsiniz.")),
      );
    } catch (e) {
      print("Signup error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Kayıt hatası: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF25252B),
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color(0xFF2D2D39),
            boxShadow: [
              BoxShadow(
                color: Colors.orangeAccent.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.rightToBracket,
                      color: Colors.orangeAccent,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "LOGIN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(FontAwesomeIcons.dice, color: Colors.white),
                  ],
                ),
                SizedBox(height: 20),
                _buildTextField("Email", onSaved: (val) => email = val!),
                SizedBox(height: 10),
                _buildTextField(
                  "Password",
                  obscure: true,
                  onSaved: (val) => password = val!,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signInWithEmail,
                  child: Text("Sign In with Email"),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _signUpWithEmail,
                  child: Text("Sign Up"),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Forgot Password",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    bool obscure = false,
    required void Function(String?) onSaved,
  }) {
    return SizedBox(
      width: 250,
      child: TextFormField(
        obscureText: obscure,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.black26,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        validator:
            (val) =>
                val == null || val.isEmpty ? 'Bu alan boş bırakılamaz' : null,
        onSaved: onSaved,
      ),
    );
  }
}

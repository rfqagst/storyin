import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storyin/provider/auth_provider.dart';
import 'package:storyin/utils/auth_state.dart';

class LoginScreen extends StatefulWidget {
  final Function() onLogin;
  final Function() onRegister;

  const LoginScreen(
      {super.key, required this.onLogin, required this.onRegister});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formGlobalKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _showPassword = true;
  String _resultText = '';
  Color _resultColor = Colors.black;
  final RegExp _emailRegExp = RegExp(
    r'^[^@]+@[^@]+\.[^@]+',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Selamat datang kembali!',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Form(
                  key: _formGlobalKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          } else if (!_emailRegExp.hasMatch(value)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value!;
                        },
                        decoration: const InputDecoration(
                            label: Text('Email'),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password = value!;
                        },
                        obscureText: _showPassword,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                                icon: Icon(_showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off)),
                            label: const Text('Password'),
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        _resultText,
                        style: TextStyle(fontSize: 16, color: _resultColor),
                      ),
                      const SizedBox(height: 40),
                      Consumer<AuthProvider>(
                          builder: (context, provider, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF10439F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              if (_formGlobalKey.currentState!.validate()) {
                                _formGlobalKey.currentState!.save();

                                await provider.login(_email, _password);

                                if (provider.state == AuthState.success) {
                                  setState(() {
                                    _resultText = provider.message;
                                    _resultColor = Colors.green;
                                  });
                                  widget.onLogin();
                                } else if (provider.state == AuthState.error) {
                                  setState(() {
                                    _resultText = provider.message;
                                    _resultColor = Colors.red;
                                  });
                                }

                                _formGlobalKey.currentState!.reset();
                              }
                            },
                            child: provider.state == AuthState.loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Login",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                          ),
                        );
                      }),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Belum punya Akun ?",
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => {widget.onRegister()},
                            child: const Text(
                              "Daftar",
                              style: TextStyle(
                                  color: Color(0xFF10439F), fontSize: 18),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

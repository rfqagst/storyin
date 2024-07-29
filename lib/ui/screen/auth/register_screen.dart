import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storyin/provider/auth_provider.dart';
import 'package:storyin/utils/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  final Function() onLogin;
  final Function() onRegister;
  const RegisterScreen(
      {super.key, required this.onLogin, required this.onRegister});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formGlobalKey = GlobalKey<FormState>();
  String _email = '';
  String _name = '';
  String _password = '';
  String _resultText = '';
  Color _resultColor = Colors.black;
  bool _showPassword = true;
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
                      'Daftar',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Daftar akun untuk mengakses aplikasi',
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
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _name = value!;
                        },
                        decoration: const InputDecoration(
                            label: Text('Nama'),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                      ),
                      const SizedBox(height: 30),
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

                                  await Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .register(_name, _email, _password);

                                  if (provider.state == AuthState.success) {
                                    setState(() {
                                      _resultText = provider.message;
                                      _resultColor = Colors.green;
                                    });
                                  } else if (provider.state ==
                                      AuthState.error) {
                                    setState(() {
                                      _resultText = provider.message;
                                      _resultColor = Colors.red;
                                    });
                                  }

                                  if (_formGlobalKey.currentState != null) {
                                    _formGlobalKey.currentState!.reset();
                                  }
                                }
                              },
                              child: provider.state == AuthState.loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Daftar",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Sudah punya Akun ?",
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => {widget.onLogin()},
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                  color: Color(0xFF10439F), fontSize: 18),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

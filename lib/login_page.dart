import 'dart:convert';

import 'package:app_mobile/user_info.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_mobile/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_users.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool isLoading = false;
  bool _verSenha = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) => {value.clear()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Fazer Login'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/site21.png',
                  filterQuality: FilterQuality.high,
                  height: 265,
                  fit: BoxFit.contain,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      label: Text('E-mail'), hintText: 'Digite seu email'),
                  validator: (email) {
                    if (email == null || email.isEmpty) {
                      return 'Digite seu e-mail';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _senhaController,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: _verSenha,
                  decoration: InputDecoration(
                      label: const Text('Senha'),
                      hintText: 'Digite sua senha',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _verSenha = !_verSenha;
                          });
                        },
                        icon: Icon(
                          _verSenha
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      )),
                  validator: (senha) {
                    if (senha == null || senha.isEmpty) {
                      return 'Digite sua senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });

                    if (_formKey.currentState!.validate()) {
                      logar().then((_) {
                        setState(() {
                          isLoading = false;
                        });
                      });
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ))
                      : const Text('Entrar'),
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: RichText(
                    text: TextSpan(
                      style:
                          const TextStyle(color: Colors.black, fontSize: 14.0),
                      children: <TextSpan>[
                        const TextSpan(
                          text: 'Não possui conta? ',
                        ),
                        TextSpan(
                          text: 'Registrar-se',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              showCreateUsers();
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  dynamic showCreateUsers() {
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        context: context,
        builder: (BuildContext context) => const ModalCreateUser());
  }

  dynamic logar() async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    var url = Uri.parse('http://192.168.1.100:3030/users-auth');
    var data = {
      'email': _emailController.text,
      'password': _senhaController.text,
    };
    var response = await http.post(
      url,
      body: data,
    );
    if (response.statusCode == 200) {
      String token = json.decode(response.body)['token'];
      bool adminValue = json.decode(response.body)['user']['is_admin'];
      int userId = json.decode(response.body)['user']['id'];
      String userUrl = json.decode(response.body)['user']['url'];

      print(response.body);
      print(adminValue.runtimeType);
      await _sharedPreferences.setString('token', 'Bearer $token');
      await _sharedPreferences.setBool('admin', adminValue);
      await _sharedPreferences.setString('userId', userId.toString());
      await _sharedPreferences.setString('url', userUrl);

      if (adminValue == false) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const UserInfo(),
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardPage(),
          ),
        );
      }
    } else {
      dynamic jsonResponse = json.decode(response.body);

      if (jsonResponse['error']?['errors'][0]['message'] != null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              jsonResponse['error']['errors'][0]['message'],
              style: const TextStyle(fontSize: 18),
            )));
      }

      if (jsonResponse['message'] != null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              jsonResponse['message'],
              style: const TextStyle(fontSize: 18),
            )));
      }
    }
  }
}

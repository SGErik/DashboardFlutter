import 'package:app_mobile/dashboard_page.dart';
import 'package:app_mobile/login_page.dart';
import 'package:app_mobile/user_info.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    verificarUsuario().then((haveUser) => {
          if (haveUser)
            {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UserInfo()),
              )
            }
          else
            {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              )
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            Text('Carregando...'),
          ],
        ),
      ),
    );
  }

  Future<bool> verificarUsuario() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? token = sharedPreferences.getString('token');

    Bool? adminValue = sharedPreferences.getBool('admin');

    if (token != null && adminValue) {
      return false;
    } else {
      return true;
    }
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_mobile/data/http/http_client.dart';
import 'package:app_mobile/data/models/user_model.dart';
import 'package:app_mobile/data/repositories/user_repository.dart';
import 'package:flutter/services.dart';
import 'package:app_mobile/stores/user_store.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class ModalCreateUser extends StatefulWidget {
  const ModalCreateUser({super.key});

  @override
  State<ModalCreateUser> createState() => _ModalCreateUserState();
}

class _ModalCreateUserState extends State<ModalCreateUser> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final maskTel = MaskTextInputFormatter(
      mask: "(##) #####-####", filter: {"#": RegExp(r'[0-9]')});
  final maskTelFixo = MaskTextInputFormatter(
      mask: "(##) ####-####", filter: {"#": RegExp(r'[0-9]')});
  bool adminUser = false;
  dynamic token;
  File? tempImage;
  String? base64Image;
  ImagePicker imagePicker = ImagePicker();
  bool _verSenha = false;
  final UserStore store = UserStore(
    repository: UserRepository(
      client: HttpClient(),
    ),
  );

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) => {
          setState(
            () {
              token = value.getString('token');
            },
          )
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Column(
                  children: [
                    SizedBox(
                      height: 34,
                    ),
                    Center(
                      child: Text(
                        'Criar Usuário',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(4), // Border radius
                    child: ClipOval(
                        child: tempImage != null
                            ? Image.file(
                                tempImage!,
                                fit: BoxFit.contain,
                              )
                            : Image.network(
                                'https://res.cloudinary.com/dha4qcefw/image/upload/v1694161495/UserImage/szzhkitz5cexxa3lav35.png',
                                fit: BoxFit.contain,
                              )),
                  ),
                ),
                IconButton(
                    iconSize: 40,
                    onPressed: () {
                      pegarImagemGaleria();
                    },
                    icon: const Icon(Icons.add_photo_alternate_rounded)),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      label: Text('Nome'),
                      hintText: 'Digite seu nome'),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                      label: Text('E-mail'),
                      hintText: 'Digite seu email'),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [maskTel],
                  decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.smartphone),
                      border: OutlineInputBorder(),
                      label: Text('Telefone'),
                      hintText: 'Digite seu telefone'),
                ),
                const SizedBox(
                  height: 24,
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _verSenha,
                  decoration: InputDecoration(
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
                      ),
                      border: const OutlineInputBorder(),
                      label: const Text('Senha'),
                      hintText: 'Digite sua senha'),
                ),
                const SizedBox(
                  height: 24,
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _verSenha,
                  decoration: InputDecoration(
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
                      ),
                      border: const OutlineInputBorder(),
                      label: const Text('Confirmar Senha'),
                      hintText: 'Digite a senha escrita acima'),
                ),
                const SizedBox(
                  height: 24,
                ),
                token != null
                    ? const Center(child: Text('Usuário administrador?'))
                    : Container(),
                token != null
                    ? Switch(
                        value: adminUser,
                        onChanged: (value) {
                          setState(() {
                            adminUser = value;
                            print(adminUser);
                          });
                        })
                    : Container(),
                const SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                      });

                      if (base64Image == null) {
                        var data = {
                          "name": _nomeController.text,
                          "email": _emailController.text,
                          "telefone": _telefoneController.text,
                          "password": _passwordController.text,
                          "confirmedPassword": _confirmPasswordController.text,
                        };

                        store.createUser(data, context).then((_) {
                          store.getUser();
                          setState(() {
                            isLoading = false;
                          });
                        });
                      } else {
                        var data = {
                          "name": _nomeController.text,
                          "email": _emailController.text,
                          "telefone": _telefoneController.text,
                          "password": _passwordController.text,
                          "confirmedPassword": _confirmPasswordController.text,
                          "image": base64Image
                        };

                        store.createUser(data, context).then((_) {
                          store.getUser();
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
                        : const Text('Criar usuário')),
                const SizedBox(
                  height: 400,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void pegarImagemGaleria() async {
    try {
      final XFile? imagemTemporaria =
          await imagePicker.pickImage(source: ImageSource.gallery);

      if (imagemTemporaria != null) {
        File? img = File(imagemTemporaria.path);
        img = await _cropImage(imageFile: img);

        setState(() {
          tempImage = img;
          List<int> bytes = tempImage!.readAsBytesSync();
          base64Image = "data:image/jpeg;base64,${base64Encode(bytes)}";
          Navigator.of(context).pop;
        });
      }
    } on PlatformException catch (e) {
      print(e);
      Navigator.of(context).pop;
    }
  }

  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }
}

import 'dart:convert';

import 'package:app_mobile/data/http/http_client.dart';
import 'package:app_mobile/data/repositories/user_repository.dart';
import 'package:app_mobile/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class UpdateUserModal extends StatefulWidget {
  const UpdateUserModal({super.key, required this.userId});

  final String userId;

  @override
  State<UpdateUserModal> createState() => _UpdateUserModalState();
}

class _UpdateUserModalState extends State<UpdateUserModal> {
  final UserStore store = UserStore(
    repository: UserRepository(
      client: HttpClient(),
    ),
  );
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final maskTel = MaskTextInputFormatter(
      mask: "(##) #####-####", filter: {"#": RegExp(r'[0-9]')});
  final GlobalKey<ScaffoldState> _modelScaffoldKey = GlobalKey<ScaffoldState>();

  late String addressInfo = '';
  FocusNode cepFocus = FocusNode();
  ImagePicker imagePicker = ImagePicker();
  File? tempImage;
  String? base64Image;
  bool isLoading = false;

  bool adminValue1 = false;

  @override
  void initState() {
    super.initState();

    store.getOneUser(widget.userId).then((_) {
      setState(() {
        _emailController.text = store.oneUserState.value.email;
        _nomeController.text = store.oneUserState.value.name;
        _telefoneController.text = store.oneUserState.value.telefone;
        adminValue1 = store.oneUserState.value.is_admin;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (store.oneUserLoading.value) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        key: _modelScaffoldKey,
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
                        height: 44,
                      ),
                      Center(
                        child: Text(
                          'Editar Informações',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w500),
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
                      padding: const EdgeInsets.all(5), // Border radius
                      child: ClipOval(
                          child: tempImage != null
                              ? Image.file(tempImage!, fit: BoxFit.cover)
                              : Image.network(
                                  store.oneUserState.value.url.isNotEmpty
                                      ? store.oneUserState.value.url
                                      : 'https://res.cloudinary.com/dha4qcefw/image/upload/v1694161495/UserImage/szzhkitz5cexxa3lav35.png',
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
                  const Center(
                    child: Text('Usuário administrador?'),
                  ),
                  Switch(
                      value: adminValue1,
                      onChanged: (value) {
                        setState(() {
                          adminValue1 = value;
                          print(adminValue1);
                        });
                      }),
                  const SizedBox(
                    height: 24,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (base64Image == null) {
                          var data = {
                            "name": _nomeController.text,
                            "email": _emailController.text,
                            "telefone": _telefoneController.text,
                            "is_admin": adminValue1.toString()
                          };

                          editUser(data).then((_) {
                            store.getUser();
                          });
                        } else {
                          var data = {
                            "name": _nomeController.text,
                            "email": _emailController.text,
                            "telefone": _telefoneController.text,
                            "image": base64Image,
                            "is_admin": adminValue1.toString()
                          };

                          editUser(data).then((_) {
                            store.getUser();
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
                          : const Text('Salvar Informações')),
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
  }

  dynamic editUser(dynamic data) async {
    setState(() {
      isLoading = true;
    });

    final url =
        Uri.parse('http://192.168.1.100:3030/users-update/${widget.userId}');
    final response = await http.put(url, body: data);

    if (response.statusCode == 200) {
      print('Usuário atualizado com sucesso');
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.green,
            dismissDirection: DismissDirection.down,
            content: const Text(
              'Usuário atualizado com sucesso',
              style: TextStyle(fontSize: 20),
            ),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
                // ignore: use_build_context_synchronously
                bottom: MediaQuery.of(context).size.height - 150,
                left: 10,
                right: 10)),
      );

      setState(() {
        isLoading = false;
      });
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

        setState(() {
          isLoading = false;
        });
      }

      if (jsonResponse['message'] != null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            jsonResponse['message'],
            style: const TextStyle(fontSize: 18),
          ),
        ));

        setState(() {
          isLoading = false;
        });
      }
    }
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

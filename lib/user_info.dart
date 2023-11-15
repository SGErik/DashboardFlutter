import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_mobile/data/http/http_client.dart';
import 'package:app_mobile/data/repositories/user_repository.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:app_mobile/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:app_mobile/login_page.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _prevPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _cepController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _bairroController = TextEditingController();
  FocusNode cepFocus = FocusNode();
  bool isLoading = false;
  bool passwordLoading = false;
  bool addressLoading = false;
  String? idUser;
  String? addressInfo;
  String? userUrl;
  final maskTel = MaskTextInputFormatter(
      mask: "(##) #####-####", filter: {"#": RegExp(r'[0-9]')});
  final maskTelFixo = MaskTextInputFormatter(
      mask: "(##) ####-####", filter: {"#": RegExp(r'[0-9]')});

  bool adminUser = false;
  File? tempImage;
  String? base64Image;
  ImagePicker imagePicker = ImagePicker();
  final UserStore store = UserStore(
    repository: UserRepository(
      client: HttpClient(),
    ),
  );
  Future<void> getSharedInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      idUser = prefs.getString('userId');
    });
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefValue) => {
          setState(() {
            idUser = prefValue.getString("userId");
          }),
          store.getOneUser(idUser!).then((_) {
            setState(() {
              _emailController.text = store.oneUserState.value.email;
              _nomeController.text = store.oneUserState.value.name;
              _telefoneController.text = store.oneUserState.value.telefone;
              userUrl = store.oneUserState.value.url;
            });

            store.addressUser(idUser!).then((_) {
              if (store.addressUserState.value.addresses.length != 0) {
                setState(() {
                  _cepController.text =
                      store.addressUserState.value.addresses[0].zipcode;
                  _ruaController.text =
                      store.addressUserState.value.addresses[0].street;
                  _numeroController.text =
                      store.addressUserState.value.addresses[0].addressNumber;
                  _complementoController.text =
                      store.addressUserState.value.addresses[0].complement;
                  _cidadeController.text = store.addressUserState.value
                      .addresses[0].neighborhood.city.city;
                  _estadoController.text = store.addressUserState.value
                      .addresses[0].neighborhood.city.state.state;
                  _bairroController.text = store.addressUserState.value
                      .addresses[0].neighborhood.neighborhood;
                  addressInfo =
                      store.addressUserState.value.addresses[0].id.toString();
                });
              } else {
                print('Não existe endereço');
              }
            });
          })
        });

    cepFocus.addListener(() {
      if (!cepFocus.hasFocus) {
        getCep();
      }
    });
  }

  dynamic getCep() async {
    String cepText = _cepController.text;
    var url = Uri.parse('http://192.168.1.100:3030/sendCep/$cepText');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body)['sendCep'];

      setState(() {
        _ruaController.text = body['street'];
        _cidadeController.text = body['city'];
        _estadoController.text = body['state'];
        _bairroController.text = body['neighborhood'];
      });
    } else {
      print('Deu erro');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (store.oneUserLoading.value) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Minha Dashboard'),
          actions: [
            ElevatedButton(
                onPressed: () {
                  logout();
                },
                child: const Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(
                      width: 3,
                    ),
                    Text('Sair')
                  ],
                )),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Minha Dashboard'),
          actions: [
            ElevatedButton(
                onPressed: () {
                  logout();
                },
                child: const Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(
                      width: 3,
                    ),
                    Text('Sair')
                  ],
                )),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                                  userUrl == null || userUrl!.isEmpty
                                      ? 'https://res.cloudinary.com/dha4qcefw/image/upload/v1694161495/UserImage/szzhkitz5cexxa3lav35.png'
                                      : userUrl!,
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
                    height: 14,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (base64Image == null) {
                          var data = {
                            "name": _nomeController.text,
                            "email": _emailController.text,
                            "telefone": _telefoneController.text
                          };

                          editTest(data);
                        } else {
                          var data = {
                            "name": _nomeController.text,
                            "email": _emailController.text,
                            "telefone": _telefoneController.text,
                            "image": base64Image
                          };

                          editTest(data);
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
                    height: 34,
                  ),
                  TextFormField(
                    controller: _prevPasswordController,
                    decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.password),
                        border: OutlineInputBorder(),
                        label: Text('Senha Antiga'),
                        hintText: 'Digite sua senha'),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.password_outlined),
                        border: OutlineInputBorder(),
                        label: Text('Nova Senha'),
                        hintText: 'Digite a senha escrita acima'),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      var data = {
                        "prevPassword": _prevPasswordController.text,
                        "password": _newPasswordController.text
                      };

                      store.updatePasswordUser(idUser!, data, context);
                    },
                    child: passwordLoading
                        ? const SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ))
                        : const Text('Salvar Senha'),
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  const Center(
                    child: Text('Meu Endereço',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: _cepController,
                    keyboardType: TextInputType.number,
                    focusNode: cepFocus,
                    decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(),
                        label: Text('Cep'),
                        hintText: 'Digite seu cep'),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: _ruaController,
                    enabled: false,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), label: Text('Rua')),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: _numeroController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Numero'),
                        hintText: 'Digite o número da sua casa'),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFormField(
                    controller: _complementoController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Complemento'),
                        hintText: 'Digite o complemento'),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFormField(
                    controller: _cidadeController,
                    enabled: false,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), label: Text('Cidade')),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFormField(
                    controller: _estadoController,
                    enabled: false,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), label: Text('Estado')),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFormField(
                    enabled: false,
                    controller: _bairroController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), label: Text('Bairro')),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      var data = {
                        "zipcode": _cepController.text,
                        "state": _estadoController.text,
                        "city": _cidadeController.text,
                        "neighborhood": _bairroController.text,
                        "street": _ruaController.text,
                        "complement": _complementoController.text,
                        "addressNumber": _numeroController.text
                      };

                      if (store.addressUserState.value.addresses.length == 0) {
                        createAddress(data).then((_) {
                          store.addressUser(idUser!);
                        });
                      } else {
                        updateAddress(data);
                      }
                    },
                    child: addressLoading
                        ? const SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ))
                        : const Text('Salvar Endereço'),
                  ),
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

  dynamic editTest(dynamic data) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('http://192.168.1.100:3030/users-update/$idUser');
    final response = await http.put(url, body: data);

    if (response.statusCode == 200) {
      print('Usuário atualizado com sucesso');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.green,
            dismissDirection: DismissDirection.down,
            content: Text(
              'Usuário atualizado com sucesso',
              style: TextStyle(fontSize: 20),
            )),
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
          ),
          behavior: SnackBarBehavior.floating,
        ));

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
          behavior: SnackBarBehavior.floating,
        ));

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  dynamic updateAddress(dynamic dataUser) async {
    setState(() {
      addressLoading = true;
    });
    final url =
        Uri.parse('http://192.168.1.100:3030/users/upAddress/$addressInfo');
    final response = await http.put(url, body: dataUser);

    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          dismissDirection: DismissDirection.up,
          content: Text(
            'Endereço atualizado com sucesso',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
      setState(() {
        addressLoading = false;
      });
    } else {
      dynamic jsonResponse = jsonDecode(response.body);

      print('Entrei aqui');
      print(jsonDecode(response.body));

      setState(() {
        addressLoading = false;
      });
    }
  }

  dynamic createAddress(dynamic dataUser) async {
    setState(() {
      addressLoading = true;
    });
    final url = Uri.parse('http://192.168.1.100:3030/users/address/$idUser');
    final response = await http.post(url, body: dataUser);

    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          dismissDirection: DismissDirection.up,
          content: Text(
            'Endereço criado com sucesso',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
      setState(() {
        addressLoading = false;
      });
    } else {
      dynamic jsonResponse = jsonDecode(response.body);

      print('Entrei aqui');
      print(jsonDecode(response.body));
      setState(() {
        addressLoading = false;
      });
    }
  }

  dynamic logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();

    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:app_mobile/create_users.dart';
import 'package:app_mobile/data/http/http_client.dart';
import 'package:app_mobile/data/models/user_model.dart';
import 'package:app_mobile/data/repositories/user_repository.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:app_mobile/login_page.dart';
import 'package:app_mobile/update_user.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_mobile/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'dart:async';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final UserStore store = UserStore(
    repository: UserRepository(
      client: HttpClient(),
    ),
  );
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
  final maskCep =
      MaskTextInputFormatter(mask: "########", filter: {"#": RegExp(r'[0-9]')});
  bool addressLoad = false;
  late String addressInfo = '';
  FocusNode cepFocus = FocusNode();
  ImagePicker imagePicker = ImagePicker();
  File? tempImage;
  late String base64Image;
  bool adminValue1 = false;

  @override
  void initState() {
    super.initState();
    cepFocus.addListener(() {
      if (!cepFocus.hasFocus) {
        getCep();
      }
    });
    store.getUser();
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
  void dispose() {
    cepFocus.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Usuários'),
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
      body: AnimatedBuilder(
        animation: Listenable.merge([
          store.isLoading,
          store.error,
          store.state,
        ]),
        builder: (context, child) {
          if (store.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // if (store.error.value.isNotEmpty) {
          //   return Center(
          //     child: Text(
          //       store.error.value,
          //       style: const TextStyle(
          //         color: Colors.black54,
          //         fontWeight: FontWeight.w600,
          //         fontSize: 20,
          //       ),
          //       textAlign: TextAlign.center,
          //     ),
          //   );
          // }

          if (store.state.value.isEmpty) {
            return const Center(
                child: Text(
              'Nenhum item na lista',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ));
          } else {
            return Scaffold(
              body: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                  itemCount: store.state.value.length,
                  itemBuilder: (_, index) {
                    final item = store.state.value[index];
                    // ignore: avoid_print
                    print(item);
                    return ListTile(
                      leading:
                          CircleAvatar(backgroundImage: NetworkImage(item.url)),
                      title: Center(child: Text(item.name)),
                      subtitle: SizedBox(
                        height: 50,
                        child: Column(
                          children: [
                            Text(item.email, textAlign: TextAlign.center),
                            Text(item.telefone)
                          ],
                        ),
                      ),
                      trailing: SizedBox(
                        width: 132,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                showModalUpdate(item.id.toString()).then((_) {
                                  store.getUser();
                                });
                              },
                              child: const Icon(Icons.edit),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            InkWell(
                                onTap: () {
                                  showModalDelete(item.id.toString());
                                },
                                child: const Icon(Icons.delete)),
                            const SizedBox(
                              width: 12,
                            ),
                            InkWell(
                                onTap: () {
                                  showModalPasswordUpdate(item.id.toString());
                                },
                                child: const Icon(Icons.password)),
                            const SizedBox(
                              width: 12,
                            ),
                            InkWell(
                                onTap: () async {
                                  await store.addressUser(item.id.toString());

                                  if (store.addressUserState.value.addresses
                                          .length !=
                                      0) {
                                    setState(() {
                                      _cepController.text = store
                                          .addressUserState
                                          .value
                                          .addresses[0]
                                          .zipcode;
                                      _ruaController.text = store
                                          .addressUserState
                                          .value
                                          .addresses[0]
                                          .street;
                                      _numeroController.text = store
                                          .addressUserState
                                          .value
                                          .addresses[0]
                                          .addressNumber;
                                      _complementoController.text = store
                                          .addressUserState
                                          .value
                                          .addresses[0]
                                          .complement;
                                      _cidadeController.text = store
                                          .addressUserState
                                          .value
                                          .addresses[0]
                                          .neighborhood
                                          .city
                                          .city;
                                      _estadoController.text = store
                                          .addressUserState
                                          .value
                                          .addresses[0]
                                          .neighborhood
                                          .city
                                          .state
                                          .state;
                                      _bairroController.text = store
                                          .addressUserState
                                          .value
                                          .addresses[0]
                                          .neighborhood
                                          .neighborhood;
                                      addressInfo = store.addressUserState.value
                                          .addresses[0].id
                                          .toString();
                                    });
                                  } else {
                                    print('Não existe endereço');
                                  }

                                  await showAddressUpdate(
                                          item.id.toString(), addressInfo)
                                      .then((_) {
                                    store.getUser();
                                    _cepController.text = '';
                                    _ruaController.text = '';
                                    _numeroController.text = '';
                                    _complementoController.text = '';
                                    _cidadeController.text = '';
                                    _estadoController.text = '';
                                    _bairroController.text = '';
                                  });
                                  ;
                                },
                                child: const Icon(Icons.house)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              floatingActionButton: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 163, 30),
                child: FloatingActionButton(
                  onPressed: () async {
                    showCreateUsers().then((_) {
                      store.getUser();
                      setState(() {
                        _emailController.text = '';
                        _nomeController.text = '';
                        _telefoneController.text = '';
                      });
                    });
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _refresh() async {
    await store.getUser();
  }

  dynamic showModalUpdate(String userId) {
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        context: context,
        builder: (BuildContext context) => UpdateUserModal(
              userId: userId,
            ));
  }

  dynamic showAddressUpdate(String userId, String addressId) {
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        const SizedBox(
                          height: 44,
                        ),
                        Center(
                          child: Text(
                            store.addressUserState.value.addresses.length == 0
                                ? 'Criar Endereço'
                                : 'Atualizar Endereço',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: _cepController,
                      inputFormatters: [maskCep],
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
                        setState(() {
                          addressLoad = true;
                        });

                        var data = {
                          "zipcode": _cepController.text,
                          "state": _estadoController.text,
                          "city": _cidadeController.text,
                          "neighborhood": _bairroController.text,
                          "street": _ruaController.text,
                          "complement": _complementoController.text,
                          "addressNumber": _numeroController.text
                        };

                        if (store.addressUserState.value.addresses.length ==
                            0) {
                          await store
                              .createAddress(userId, data, context)
                              .then((_) {
                            setState(() {
                              addressLoad = false;
                            });
                          });
                        } else {
                          await store
                              .updateAddress(addressId, data, context)
                              .then((_) {
                            setState(() {
                              addressLoad = false;
                            });
                          });
                        }
                      },
                      child: addressLoad
                          ? const SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ))
                          : const Text('Salvar'),
                    ),
                    const SizedBox(
                      height: 400,
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  dynamic showModalPasswordUpdate(String userId) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        context: context,
        builder: (BuildContext context) {
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
                          Center(
                            child: Text(
                              'Editar Senha',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        controller: _prevPasswordController,
                        decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.password),
                            border: OutlineInputBorder(),
                            label: Text('Senha Antiga'),
                            hintText: 'Digite sua antiga senha'),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        controller: _newPasswordController,
                        decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.password_outlined),
                            border: OutlineInputBorder(),
                            label: Text('Nova Senha'),
                            hintText: 'Digite sua nova senha'),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            var data = {
                              "prevPassword": _prevPasswordController.text,
                              "password": _newPasswordController.text
                            };

                            await store.updatePasswordUser(
                                userId, data, context);
                          },
                          child: const Text('Salvar')),
                      const SizedBox(
                        height: 400,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  dynamic showModalDelete(userId) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
            child: SizedBox(
                height: 200,
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        'Você tem certeza que deseja excluir este usuário?',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Não')),
                          ElevatedButton(
                              onPressed: () {
                                store.deleteUser(userId, context).then((_) {
                                  store.getUser();
                                });
                              },
                              child: const Text('Sim'))
                        ],
                      ),
                    )
                  ],
                )),
          );
        });
  }

  dynamic showCreateUsers() {
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        context: context,
        builder: (BuildContext context) => const ModalCreateUser());
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

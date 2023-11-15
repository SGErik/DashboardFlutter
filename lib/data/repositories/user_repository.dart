import 'dart:convert';

import 'package:app_mobile/data/http/exceptions.dart';
import 'package:app_mobile/data/http/http_client.dart';
import 'package:app_mobile/data/models/address_model.dart';
import 'package:app_mobile/data/models/oneuser_model.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

abstract class IUserRepository {
  Future<List<UserModel>> getUser();

  Future<dynamic> getOneUser(String userId);

  Future<dynamic> addressUser(String userId);

  Future<void> deleteUser(String userId, context);

  Future<void> updateUser(String userId, dynamic data, context);

  Future<void> updateAddress(String userId, dynamic data, context);

  Future<dynamic> updatePasswordUser(String userId, dynamic dataUser, context);

  Future<dynamic> createAddress(String userId, dynamic data, context);

  Future<dynamic> createUser(dynamic data, context);
}

class UserRepository implements IUserRepository {
  final IHttpClient client;

  UserRepository({required this.client});

  @override
  Future<List<UserModel>> getUser() async {
    final response =
        await client.get(url: 'http://192.168.1.100:3030/users-list');

    if (response.statusCode == 200) {
      final List<UserModel> user = [];
      final body = jsonDecode(response.body);

      body['users'].map((item) {
        final UserModel users = UserModel.fromMap(item);
        user.add(users);
      }).toList();

      print('Entrei aqui $user');

      return user;
    } else if (response.statusCode == 404) {
      throw NotFoundException('Url não encontrada');
    } else {
      throw Exception('Ocorreu um erro inesperado');
    }
  }

  @override
  Future<dynamic> getOneUser(String userId) async {
    final response =
        await client.get(url: 'http://192.168.1.100:3030/users-find/$userId');

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      Map<String, dynamic> userMap = jsonResponse['user'];

      var user = OneUserModel.fromJson(userMap);

      return user;
    } else if (response.statusCode == 404) {
      throw NotFoundException('Url não encontrada');
    } else {
      print(json.decode(response.body));
      throw Exception('Ocorreu um erro inesperado');
    }
  }

  @override
  Future<void> deleteUser(String userId, context) async {
    try {
      final response = await client.delete(
          url: 'http://192.168.1.100:3030/users-delete/$userId');

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.green,
              content: const Text(
                'Usuário deletado com sucesso',
                style: TextStyle(fontSize: 18),
              ),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 150,
                  left: 10,
                  right: 10)),
        );

        // ignore: avoid_print
        print('Usuário excluído com sucesso');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Url não encontrada');
      } else {
        String message = json.decode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                message,
                style: const TextStyle(fontSize: 18),
              ),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 150,
                  left: 10,
                  right: 10)),
        );
        throw Exception('Ocorreu um erro');
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  Future<dynamic> updateUser(String userId, dynamic dataUser, context) async {
    final response = await client.put(
        url: 'http://192.168.1.100:3030/users-update/$userId', data: dataUser);

    if (response.statusCode == 200) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          dismissDirection: DismissDirection.up,
          content: Text(
            'Usuário atualizado com sucesso',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    } else if (response.statusCode == 404) {
      throw NotFoundException('Url não encontrada');
    } else {
      dynamic jsonResponse = json.decode(response.body);

      if (jsonResponse['error']?['errors'][0]['message'] != null) {
        return ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                jsonResponse['error']['errors'][0]['message'],
                style: const TextStyle(fontSize: 18),
              ),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 150,
                  left: 10,
                  right: 10)),
        );
      }

      if (jsonResponse['message'] != null) {
        return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            jsonResponse['message'],
            style: const TextStyle(fontSize: 18),
          ),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
    throw Exception('Ocorreu um erro');
  }

  @override
  Future<dynamic> updatePasswordUser(
      String userId, dynamic dataUser, context) async {
    final response = await client.put(
        url: 'http://192.168.1.100:3030/users-updatepass/$userId',
        data: dataUser);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          dismissDirection: DismissDirection.up,
          content: Text(
            'Senha atualizada com sucesso',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    } else if (response.statusCode == 404) {
      throw NotFoundException('Url não encontrada');
    } else {
      dynamic jsonResponse = json.decode(response.body);

      if (jsonResponse['error']?['errors'][0]['message'] != null) {
        return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            jsonResponse['error']['errors'][0]['message'],
            style: const TextStyle(fontSize: 18),
          ),
        ));
      }

      if (jsonResponse['message'] != null) {
        return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            jsonResponse['message'],
            style: const TextStyle(fontSize: 18),
          ),
        ));
      }
    }
    throw Exception('Ocorreu um erro');
  }

  @override
  Future<dynamic> addressUser(String userId) async {
    final response = await client.get(
        url: 'http://192.168.1.100:3030/users/address/$userId');

    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(response.body);

      var address = Address.fromJson(body);

      print(address);

      return address;
    } else if (response.statusCode == 404) {
      throw NotFoundException('Url não encontrada');
    } else {
      print(jsonDecode(response.body));
      throw Exception('Ocorreu um erro inesperado');
    }
  }

  @override
  Future<dynamic> updateAddress(
      String addressId, dynamic dataUser, context) async {
    final response = await client.put(
        url: 'http://192.168.1.100:3030/users/upAddress/$addressId',
        data: dataUser);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          dismissDirection: DismissDirection.up,
          content: const Text(
            'Endereço atualizado com sucesso',
            style: TextStyle(fontSize: 20),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 10,
              right: 10),
        ),
      );
      Navigator.pop(context);
    } else if (response.statusCode == 404) {
      throw NotFoundException('Url não encontrada');
    } else {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      print('Entrei aqui');
      print(jsonDecode(response.body));
    }
    throw Exception('Ocorreu um erro');
  }

  @override
  Future<dynamic> createAddress(
      String userId, dynamic dataUser, context) async {
    final response = await client.post(
        url: 'http://192.168.1.100:3030/users/address/$userId', data: dataUser);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          dismissDirection: DismissDirection.up,
          content: const Text(
            'Endereço criado com sucesso',
            style: TextStyle(fontSize: 20),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 10,
              right: 10),
        ),
      );
      Navigator.pop(context);
    } else if (response.statusCode == 404) {
      throw NotFoundException('Url não encontrada');
    } else {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      print('Entrei aqui');
      print(jsonDecode(response.body));
    }
    throw Exception('Ocorreu um erro');
  }

  @override
  Future<dynamic> createUser(dynamic dataUser, context) async {
    final response = await client.post(
        url: 'http://192.168.1.100:3030/users-create', data: dataUser);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.green,
            dismissDirection: DismissDirection.up,
            content: Text(
              'Usuário criado com sucesso',
              style: TextStyle(fontSize: 20),
            )),
      );
      Navigator.pop(context);
    } else if (response.statusCode == 404) {
      throw NotFoundException('Url não encontrada');
    } else {
      dynamic jsonResponse = json.decode(response.body);

      if (jsonResponse['error']?['errors'][0]['message'] != null) {
        return ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              jsonResponse['error']['errors'][0]['message'],
              style: const TextStyle(fontSize: 18),
            ),
          ),
        );
      }

      if (jsonResponse['message'] != null) {
        return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              jsonResponse['message'],
              style: const TextStyle(fontSize: 18),
            )));
      }
    }
  }
}

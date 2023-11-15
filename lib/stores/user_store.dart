import 'dart:ffi';

import 'package:app_mobile/data/http/exceptions.dart';
import 'package:app_mobile/data/models/address_model.dart';
import 'package:app_mobile/data/models/oneuser_model.dart';
import 'package:app_mobile/data/models/user_model.dart';
import 'package:app_mobile/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';

class UserStore {
  final IUserRepository repository;

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  final ValueNotifier<bool> oneUserLoading = ValueNotifier<bool>(false);

  final ValueNotifier<bool> updateUserLoading = ValueNotifier<bool>(false);

  final ValueNotifier<bool> createUserLoading = ValueNotifier<bool>(false);

  final ValueNotifier<bool> updatePasswordLoading = ValueNotifier<bool>(false);

  final ValueNotifier<bool> addressLoading = ValueNotifier<bool>(false);

  final ValueNotifier<List<UserModel>> state =
      ValueNotifier<List<UserModel>>([]);

  final ValueNotifier<dynamic> oneUserState = ValueNotifier<dynamic>([]);

  final ValueNotifier<dynamic> addressUserState = ValueNotifier<dynamic>([]);

  final ValueNotifier<dynamic> error = ValueNotifier('');

  UserStore({required this.repository});

  getUser() async {
    isLoading.value = true;

    try {
      final result = await repository.getUser();

      state.value = result;
    } on NotFoundException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    }

    isLoading.value = false;
  }

  getOneUser(String userId) async {
    oneUserLoading.value = true;

    try {
      final result = await repository.getOneUser(userId);

      oneUserState.value = result;
    } on NotFoundException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    }

    oneUserLoading.value = false;
  }

  deleteUser(String userId, context) async {
    isLoading.value = true;

    try {
      final result = await repository.deleteUser(userId, context);
    } on NotFoundException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    }

    isLoading.value = false;
  }

  updateUser(String userId, dynamic dataUser, context) async {
    updateUserLoading.value = true;

    try {
      final result = await repository.updateUser(userId, dataUser, context);
    } on NotFoundException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
      print(e);
      print('entrei aqui doidao');
    }

    updateUserLoading.value = false;
  }

  updatePasswordUser(String userId, dynamic dataUser, context) async {
    updatePasswordLoading.value = true;

    try {
      final result =
          await repository.updatePasswordUser(userId, dataUser, context);
    } on NotFoundException catch (e) {
      error.value = e.message;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              error.value,
              style: const TextStyle(fontSize: 18),
            ),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 150,
                left: 10,
                right: 10)),
      );
    } catch (e) {
      error.value = e.toString();
      print(e);
      print('entrei aqui doidao');
    }

    updatePasswordLoading.value = false;
  }

  addressUser(String userId) async {
    addressLoading.value = true;

    try {
      final result = await repository.addressUser(userId);

      addressUserState.value = result;
    } on NotFoundException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    }

    addressLoading.value = false;
  }

  updateAddress(String addressId, dynamic dataUser, context) async {
    updateUserLoading.value = true;

    try {
      final result =
          await repository.updateAddress(addressId, dataUser, context);
    } on NotFoundException catch (e) {
      error.value = e.message;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              error.value,
              style: const TextStyle(fontSize: 18),
            ),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 150,
                left: 10,
                right: 10)),
      );
    } catch (e) {
      error.value = e.toString();
    }
  }

  createAddress(String userId, dynamic dataUser, context) async {
    updateUserLoading.value = true;

    try {
      final result = await repository.createAddress(userId, dataUser, context);
    } on NotFoundException catch (e) {
      error.value = e.message;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              error.value,
              style: const TextStyle(fontSize: 18),
            ),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 150,
                left: 10,
                right: 10)),
      );
    } catch (e) {
      error.value = e.toString();
      print(e);
      print('entrei aqui doidao');
    }
  }

  createUser(dynamic dataUser, context) async {
    createUserLoading.value = true;

    try {
      final result = await repository.createUser(dataUser, context);
    } on NotFoundException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
      print(e);
      print('entrei aqui no store');
    }

    createUserLoading.value = false;
  }
}

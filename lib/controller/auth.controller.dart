import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:aw/controller/base.controller.dart';
import 'package:aw/models/user.model.dart';
import 'package:aw/providers/auth.riverpod.dart';
import 'package:aw/providers/client.riverpod.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AuthController extends BaseController {
  AuthController(ref) : super(ref);

  void login(String email, String password) async {
    Client client = ref.read(clientProvider);
    Account account = Account(client);
    try {
      Session session =
          await account.createEmailSession(email: email, password: password);
      User user = await account.get();
      UserModel userModel = UserModel.fromJson(user.toMap());
      userModel.sessionId = session.$id;

      if (userModel.status) {
        ref.read(authStateProvider.notifier).state = true;
        ref.read(authUserProvider.notifier).state = userModel;
        // ignore: use_build_context_synchronously
        Navigator.pushNamedAndRemoveUntil(
            ref.context, '/home', (route) => false);
      }
    } on AppwriteException catch (e) {
      if (e.code == 400) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(ref.context).showSnackBar(const SnackBar(
          content: Text('Hatalı e-posta veya şifre girdiniz.'),
        ));
      }
      if (e.code == 429) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(ref.context).showSnackBar(const SnackBar(
          content: Text(
              'Çok fazla istek gönderdiniz. Lütfen daha sonra tekrar deneyiniz.'),
        ));
      }
    } catch (e, st) {
      debugPrint("Appwrite Exception: ${e.toString()}\n${st.toString()}");
    }
  }

  Future<UserModel?> checkLoggedIn() async {
    Client client = ref.read(clientProvider);
    Account account = Account(client);
    try {
      User user = await account.get();
      UserModel userModel = UserModel.fromJson(user.toMap());
      return userModel;
    } on AppwriteException catch (e) {
      debugPrint(e.toString());
      return null;
    } catch (e, st) {
      debugPrint("Appwrite Exception: ${e.toString()}\n${st.toString()}");
      return null;
    }
  }

  void register(String email, String password, String name) async {
    Client client = ref.read(clientProvider);
    Account account = Account(client);
    try {
      // ignore: unused_local_variable
      User user = await account.create(
        userId: const Uuid().v4().substring(0, 36),
        email: email,
        password: password,
        name: name,
      );
      login(email, password);
    } on AppwriteException catch (e) {
      debugPrint(e.toString());
      if (e.code == 400) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(ref.context).showSnackBar(SnackBar(
          content: Text("${e.message}"),
        ));
      }
      if (e.code == 409) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(ref.context).showSnackBar(const SnackBar(
          content: Text('Bu e-posta adresi zaten kullanımda.'),
        ));
      }
      if (e.code == 429) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(ref.context).showSnackBar(const SnackBar(
          content: Text(
              'Çok fazla istek gönderdiniz. Lütfen daha sonra tekrar deneyiniz.'),
        ));
      }
    } catch (e, st) {
      debugPrint("Appwrite Exception: ${e.toString()}\n${st.toString()}");
    }
  }

  void logout() async {
    Client client = ref.read(clientProvider);
    Account account = Account(client);
    try {
      await account.deleteSession(sessionId: 'current');
      ref.read(authStateProvider.notifier).state = false;
      ref.read(authUserProvider.notifier).state = null;
    } catch (e) {
      debugPrint(e.toString());
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(ref.context).showSnackBar(const SnackBar(
        content: Text('İşlem sırasında bir hata oluştu.'),
      ));
      ref.read(authStateProvider.notifier).state = false;
      ref.read(authUserProvider.notifier).state = null;
    }
  }
}

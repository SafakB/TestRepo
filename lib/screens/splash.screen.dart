import 'package:appwrite/appwrite.dart';
import 'package:aw/constants/database.constant.dart';
import 'package:aw/controller/auth.controller.dart';
import 'package:aw/models/user.model.dart';
import 'package:aw/providers/auth.riverpod.dart';
import 'package:aw/providers/client.riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late AuthController _authController;

  @override
  void initState() {
    _authController = AuthController(ref);
    super.initState();
    Client client = Client();
    client
        .setEndpoint(DatabaseConstant.host)
        .setProject(DatabaseConstant.projectId)
        .setSelfSigned(
            status:
                true); // For self signed certificates, only use for development
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(clientProvider.notifier).state = client;
      UserModel? user = await _authController.checkLoggedIn();

      if (user != null) {
        ref.read(authStateProvider.notifier).state = true;
        ref.read(authUserProvider.notifier).state = user;
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/home');
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Splash Screen'),
      ),
    );
  }
}

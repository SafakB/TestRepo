import 'package:aw/screens/conversions.screen.dart';
import 'package:aw/screens/eren1.screen.dart';
import 'package:aw/screens/home.screen.dart';
import 'package:aw/screens/login.screen.dart';
import 'package:aw/screens/message.screen.dart';
import 'package:aw/screens/pages.screen.dart';
import 'package:aw/screens/register.screen.dart';
import 'package:aw/screens/splash.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/pages': (context) => const PagesScreen(),
        '/conversions': (context) => const ConversionsScreen(),
        '/eren1': (context) => const Eren1Screen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/message') {
          final args = settings.arguments as Map;
          return MaterialPageRoute(
            builder: (context) => MessageScreen(
              conversationId: args['conversationId'],
              participants: args['participants'],
            ),
          );
        }
        return null;
      },
    );
  }
}

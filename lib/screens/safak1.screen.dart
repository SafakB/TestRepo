import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Safak1Screen extends ConsumerStatefulWidget {
  const Safak1Screen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _Safak1ScreenState();
}

class _Safak1ScreenState extends ConsumerState<Safak1Screen> {
  @override
  Widget build(BuildContext context) {
    return const Text('safak1');
  }
}

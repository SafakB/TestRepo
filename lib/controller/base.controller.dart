import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaseController {
  final WidgetRef ref;
  BaseController(this.ref) {
    init();
  }

  init() {}

  onLoading() {
    showDialog(
      context: ref.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  onLoaded() {
    Navigator.of(ref.context).pop();
  }

  dynamic erenModal({required Widget child}) {
    showDialog(
      context: ref.context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: child,
        );
      },
    ).then((value) {
      return value;
    });
  }
}

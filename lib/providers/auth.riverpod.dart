import 'package:aw/models/user.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateProvider = StateProvider<bool>((ref) {
  return false;
});

final authUserProvider = StateProvider<UserModel?>((ref) {
  return null;
});

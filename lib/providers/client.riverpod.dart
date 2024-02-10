import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientProvider = StateProvider<Client>((ref) {
  return Client();
});

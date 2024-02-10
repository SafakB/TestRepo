import 'package:aw/models/config.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfigListNotifier extends StateNotifier<List<ConfigModel>> {
  ConfigListNotifier() : super([]);

  void set(List<ConfigModel> configList) {
    state = configList;
  }

  void add(ConfigModel config) {
    state = [...state, config];
  }

  void remove(ConfigModel config) {
    state = state.where((element) => element.id != config.id).toList();
  }

  void update(ConfigModel config) {
    state = state.map((element) {
      if (element.id == config.id) {
        return config;
      }
      return element;
    }).toList();
  }
}

final configListProvider =
    StateNotifierProvider<ConfigListNotifier, List<ConfigModel>>((ref) {
  return ConfigListNotifier();
});

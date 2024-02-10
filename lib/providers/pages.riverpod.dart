import 'package:aw/models/page.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageListNotifier extends StateNotifier<List<PageModel>> {
  PageListNotifier() : super([]);

  void set(List<PageModel> pageList) {
    state = pageList;
  }

  void add(PageModel page) {
    state = [...state, page];
  }

  void addMore(List<PageModel> pageList) {
    state = [...state, ...pageList];
  }

  void remove(PageModel page) {
    state = state.where((element) => element.id != page.id).toList();
  }

  void update(PageModel page) {
    state = state.map((element) {
      if (element.id == page.id) {
        return page;
      }
      return element;
    }).toList();
  }
}

final pageListProvider =
    StateNotifierProvider<PageListNotifier, List<PageModel>>((ref) {
  return PageListNotifier();
});

final searchTermProvider = StateProvider<String>((ref) {
  return "";
});

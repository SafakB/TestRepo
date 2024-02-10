import 'package:appwrite/appwrite.dart';
import 'package:aw/constants/database.constant.dart';
import 'package:aw/controller/page.controller.dart';
import 'package:aw/models/page.model.dart';
import 'package:aw/providers/client.riverpod.dart';
import 'package:aw/providers/pages.riverpod.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PagesScreen extends ConsumerStatefulWidget {
  const PagesScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PagesScreenState();
}

class _PagesScreenState extends ConsumerState<PagesScreen> {
  late PagesController _pagesController;
  final searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int offset = 0;
  int limit = 50;

  void loadPages({String? searchTerm = ""}) async {
    Client client = ref.read(clientProvider);
    final databases = Databases(client);
    _pagesController.onLoading();
    try {
      final documents = await databases.listDocuments(
        databaseId: DatabaseConstant.databaseId,
        collectionId: DatabaseConstant.pagesTableId,
        queries: [
          Query.limit(limit),
          Query.offset(offset),
          Query.orderDesc('\$createdAt'),
          if (searchTerm!.isNotEmpty) Query.search('title', searchTerm),
        ],
      );
      List<PageModel> pageList =
          documents.documents.map((e) => PageModel.fromJson(e.data)).toList();

      ref.read(pageListProvider.notifier).addMore(pageList);
      _pagesController.onLoaded();
    } on AppwriteException catch (e) {
      debugPrint(e.toString());
      _pagesController.onLoaded();
    }
  }

  void search() {
    offset = 0;
    ref.read(pageListProvider.notifier).set([]);
    if (searchController.text.isEmpty) {
      loadPages();
    } else {
      loadPages(searchTerm: searchController.text);
    }
  }

  void scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.offset + 50,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void initState() {
    _pagesController = PagesController(ref);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      EasyDebounce.debounce(
        'load-pages-debounce',
        const Duration(milliseconds: 150),
        () {
          loadPages();
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    List<PageModel> pageList = ref.watch(pageListProvider);
    return PopScope(
      onPopInvoked: (didpop) {
        ref.read(pageListProvider.notifier).set([]);
        // Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pages'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    //ref.read(pageListProvider.notifier).search(value);
                    EasyDebounce.debounce(
                      'search-debounce',
                      const Duration(milliseconds: 300),
                      () {
                        search();
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: pageList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(pageList[index].title.toString()),
                      subtitle: Text(pageList[index].description.toString()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  offset += limit;
                  if (searchController.text.isEmpty) {
                    loadPages();
                  } else {
                    loadPages(searchTerm: searchController.text);
                  }
                  scrollDown();
                },
                child: const Text('Load More'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  ref.read(pageListProvider.notifier).set([]);
                  Navigator.pop(context);
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }
}

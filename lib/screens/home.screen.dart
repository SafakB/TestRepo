import 'package:appwrite/appwrite.dart';
import 'package:aw/constants/database.constant.dart';
import 'package:aw/controller/home.controller.dart';
import 'package:aw/models/config.model.dart';
import 'package:aw/models/user.model.dart';
import 'package:aw/providers/auth.riverpod.dart';
import 'package:aw/providers/client.riverpod.dart';
import 'package:aw/providers/settings.riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late HomeController _homeController;
  late RealtimeSubscription subscription;

  void loadSettings() async {
    Client client = ref.read(clientProvider);
    final databases = Databases(client);

    try {
      final documents = await databases.listDocuments(
        databaseId: DatabaseConstant.databaseId,
        collectionId: DatabaseConstant.settingsTableId,
      );
      List<ConfigModel> configList =
          documents.documents.map((e) => ConfigModel.fromJson(e.data)).toList();

      ref.read(configListProvider.notifier).set(configList);
    } on AppwriteException catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    _homeController = HomeController(ref);
    loadSettings();
    super.initState();

    Client client = ref.read(clientProvider);
    final realtime = Realtime(client);
    listenRealtime(realtime);
  }

  @override
  Widget build(BuildContext context) {
    List<ConfigModel> configList = ref.watch(configListProvider);
    ref.listen(authStateProvider, (previous, next) {
      if (next == false && previous == true) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings List'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: configList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(configList[index].key.toString()),
                    subtitle: Text(configList[index].value.toString()),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                Navigator.pushNamed(context, '/conversions');
              },
              child: const Text('Conversions'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                Navigator.pushNamed(context, '/pages');
              },
              child: const Text('Pages'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                _homeController.logout();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  void listenRealtime(Realtime realtime) {
    UserModel userModel = ref.read(authUserProvider)!;
    subscription = realtime.subscribe([
      'databases.${DatabaseConstant.databaseId}.collections.${DatabaseConstant.settingsTableId}.documents',
      'account'
    ]);

    subscription.stream.listen((response) async {
      if (response.events.contains(
          "databases.${DatabaseConstant.databaseId}.collections.${DatabaseConstant.settingsTableId}.documents.*")) {
        debugPrint("Any change");
      }

      if (response.events.contains(
          "databases.${DatabaseConstant.databaseId}.collections.${DatabaseConstant.settingsTableId}.documents.*.create")) {
        debugPrint("Create document");
        ref
            .read(configListProvider.notifier)
            .add(ConfigModel.fromJson(response.payload));
      }

      if (response.events.contains(
          "databases.${DatabaseConstant.databaseId}.collections.${DatabaseConstant.settingsTableId}.documents.*.delete")) {
        debugPrint("Delete document");
        ref
            .read(configListProvider.notifier)
            .remove(ConfigModel.fromJson(response.payload));
      }

      if (response.events.contains(
          "databases.${DatabaseConstant.databaseId}.collections.${DatabaseConstant.settingsTableId}.documents.*.update")) {
        debugPrint("Update document");
        ref
            .read(configListProvider.notifier)
            .update(ConfigModel.fromJson(response.payload));
      }

      if (response.events.contains(
          'users.${userModel.id}.sessions.${userModel.sessionId}.delete')) {
        debugPrint("Delete this session");
        ref.read(authStateProvider.notifier).state = false;
        ref.read(authUserProvider.notifier).state = null;
      }
    });
  }

  @override
  void dispose() {
    subscription.close();
    super.dispose();
  }
}

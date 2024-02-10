import 'package:appwrite/appwrite.dart';
import 'package:aw/constants/database.constant.dart';
import 'package:aw/models/conversion.model.dart';
import 'package:aw/models/user.model.dart';
import 'package:aw/providers/auth.riverpod.dart';
import 'package:aw/providers/client.riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversionsScreen extends ConsumerStatefulWidget {
  const ConversionsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConversionsScreenState();
}

class _ConversionsScreenState extends ConsumerState<ConversionsScreen> {
  List<ConversionModel> conversionList = [];

  void loadConversions() async {
    Client client = ref.read(clientProvider);
    final databases = Databases(client);

    UserModel user = ref.read(authUserProvider)!;
    print(user.id);

    try {
      final documents = await databases.listDocuments(
        databaseId: DatabaseConstant.databaseId,
        collectionId: DatabaseConstant.conversationsTableId,
        queries: [
          /* participants is array, so we can use contains */
          Query.search(
            'participants',
            user.id,
          ),
        ],
      );
      List<ConversionModel> conversionList = documents.documents
          .map((e) => ConversionModel.fromJson(e.data))
          .toList();

      setState(() {
        this.conversionList = conversionList;
      });
    } on AppwriteException catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadConversions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversions'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: conversionList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/message', arguments: {
                'conversationId': conversionList[index].id,
                'participants': conversionList[index].participants,
              });
            },
            child: ListTile(
              title: Text(conversionList[index].id),
              subtitle: Text(
                conversionList[index].participants.join(', '),
              ),
            ),
          );
        },
      ),
    );
  }
}

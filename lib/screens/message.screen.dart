import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:aw/constants/database.constant.dart';
import 'package:aw/providers/auth.riverpod.dart';
import 'package:aw/providers/client.riverpod.dart';
import 'package:aw/providers/messages.riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:uuid/uuid.dart';

// For the testing purposes, you should probably use https://pub.dev/packages/uuid.
String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class MessageScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final List<String> participants;

  const MessageScreen({
    Key? key,
    required this.conversationId,
    required this.participants,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  final messageController = TextEditingController();
  late RealtimeSubscription subscription;
  ScrollController _scrollController = ScrollController();

  void loadMessages() {
    Client client = ref.read(clientProvider);
    final database = Databases(client);

    try {
      database.listDocuments(
        databaseId: DatabaseConstant.databaseId,
        collectionId: DatabaseConstant.messagesTableId,
        queries: [
          Query.equal('conversationId', widget.conversationId),
        ],
      ).then((response) {
        List<MessageBubble> messages = response.documents
            .map((e) => MessageBubble(
                  type: e.data['senderId'] == ref.read(authUserProvider)!.id
                      ? BubbleType.sendBubble
                      : BubbleType.receiverBubble,
                  message: e.data['text'],
                ))
            .toList();
        ref.read(messageProvider.notifier).load(messages);
        goToEnd();
      });
    } on AppwriteException catch (e) {
      debugPrint(e.toString());
    }
  }

  void goToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void listenMessages() {
    Client client = ref.read(clientProvider);
    final realtime = Realtime(client);

    subscription = realtime.subscribe([
      'databases.${DatabaseConstant.databaseId}.collections.${DatabaseConstant.conversationsTableId}.documents.${widget.conversationId}',
    ]);

    subscription.stream.listen((response) async {
      if (response.events.contains(
          "databases.${DatabaseConstant.databaseId}.collections.${DatabaseConstant.conversationsTableId}.documents.*.update")) {
        debugPrint("Update document");
        loadMessages();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print(widget.conversationId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadMessages();
      listenMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<MessageBubble> messages = ref.watch(messageProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.participants.join(', ')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return messages[index];
                },
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                FloatingActionButton(
                  onPressed: () => sendMessage(messageController.text),
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String text) {
    Client client = ref.read(clientProvider);
    final database = Databases(client);

    final message = {
      'conversationId': widget.conversationId,
      'senderId': ref.read(authUserProvider)!.id,
      'text': text,
      'timestamp': DateTime.now().toIso8601String(),
    };

    database
        .createDocument(
      databaseId: DatabaseConstant.databaseId,
      collectionId: DatabaseConstant.messagesTableId,
      documentId: const Uuid().v4(),
      data: message,
    )
        .then((response) {
      messageController.clear();
    });

    database.updateDocument(
      databaseId: DatabaseConstant.databaseId,
      collectionId: DatabaseConstant.conversationsTableId,
      documentId: widget.conversationId,
      data: {
        'lastUpdate': DateTime.now().toIso8601String(),
      },
    ).then(
      (value) {
        print('update Ok');
        goToEnd();
      },
    );
  }

  @override
  void dispose() {
    subscription.close();
    super.dispose();
  }
}

class MessageBubble extends StatelessWidget {
  final BubbleType type;
  final String message;

  const MessageBubble({Key? key, required this.type, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return type == BubbleType.sendBubble
        ? getSenderView(
            ChatBubbleClipper1(type: BubbleType.sendBubble), context, message)
        : getReceiverView(ChatBubbleClipper1(type: BubbleType.receiverBubble),
            context, message);
  }

  getTitleText(String title) => Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
      );

  getSenderView(CustomClipper clipper, BuildContext context, String text) =>
      ChatBubble(
        clipper: clipper,
        alignment: Alignment.topRight,
        margin: EdgeInsets.only(top: 20),
        backGroundColor: Colors.blue,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

  getReceiverView(CustomClipper clipper, BuildContext context, String text) =>
      ChatBubble(
        clipper: clipper,
        backGroundColor: Color(0xffE7E7ED),
        margin: EdgeInsets.only(top: 20),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Text(
            text,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
}

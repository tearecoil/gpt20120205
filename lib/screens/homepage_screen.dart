import 'package:chat_ai/models/conversation_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'conversation_screen.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  List<Conversation> conversations = [];
  Conversation? selectedConversation;
  int? selectedIndex;
  Future<void> _createNewConversation(BuildContext context) async {
    Conversation newConversation = Conversation(
      id: DateTime.now().toString(),
      messages: [],
    );

    conversations.add(newConversation);
    await _saveConversations();

    setState(() {
      selectedConversation = newConversation;
      selectedIndex = conversations.length - 1;
    });
  }

  Future<void> _saveConversations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String conversationsJson = jsonEncode(
      conversations.map((conversation) => conversation.toJson()).toList(),
    );

    await prefs.setString('conversations', conversationsJson);
  }

  Future<void> _loadConversations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? conversationsJson = prefs.getString('conversations');

    if (conversationsJson != null && conversationsJson.isNotEmpty) {
      dynamic conversationsData = jsonDecode(conversationsJson);

      if (conversationsData is List) {
        conversations = conversationsData
            .map((data) => Conversation.fromJson(data))
            .toList();
      } else if (conversationsData is Map) {
        conversations = [Conversation.fromJson(conversationsData)];
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadConversations().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text(
          'FlutterDemoGPT205',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _createNewConversation(context);
              },
              iconSize: 48,
              color: Colors.white,
              icon: Icon(Icons.add_box))
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity, // Set
              height: 160, // the width to fill the entire space
              color: Colors.blue,
              alignment: Alignment.center,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Previous chats',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text('Thread ${index + 1}'),
                      onTap: () {
                        setState(() {
                          selectedConversation = conversations[index];
                          selectedIndex = index;
                        });
                      });
                },
              ),
            ),
          ],
        ),
      ),
      body: selectedConversation != null
          ? ConversationScreen(
              key: ValueKey(selectedConversation!.id),
              conversation: selectedConversation!,
              index: selectedIndex ?? 0,
            )
          : Container(
              alignment: Alignment.center,
              child: Text('No conversation selected.'),
            ),
    );
  }
}

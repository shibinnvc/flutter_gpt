import 'dart:developer';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'chatmessage.dart';
import 'threedots.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  late OpenAI openAI;
  bool _isImageSearch = false;

  bool _isTyping = false;

  @override
  void initState() {
    openAI = OpenAI.instance.build(
        token: dotenv.env["API_KEY"],
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 6)),
        enableLog: true);
    super.initState();
  }

  @override
  void dispose() {
    // openAI;
    super.dispose();
  }

  // Link for api - https://beta.openai.com/account/api-keys

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    ChatMessage message = ChatMessage(
      text: _controller.text,
      sender: "user",
      isImage: false,
    );

    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    _controller.clear();

    if (_isImageSearch) {
      final request = GenerateImage(message.text, 1, size: ImageSize.size256);

      final response = await openAI.generateImage(request);
      log(response!.data!.last!.url!);
      insertNewData(response.data!.last!.url!, isImage: true);
    } else {
      final request =
          CompleteText(prompt: message.text, model: TextDavinci3Model());

      final response = await openAI.onCompletion(request: request);
      log(response!.choices[0].text);
      insertNewData(response.choices[0].text, isImage: false);
    }
  }

  void insertNewData(String response, {bool isImage = false}) {
    ChatMessage botMessage = ChatMessage(
      text: response,
      sender: "bot",
      isImage: isImage,
    );

    setState(() {
      _isTyping = false;
      _messages.insert(0, botMessage);
    });
  }

  Widget _buildTextComposer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (value) => _sendMessage(),
              decoration: const InputDecoration.collapsed(
                  hintText: "Question/description"),
            ),
          ),
          // ButtonBar(
          //   children: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              _isImageSearch = false;
              _sendMessage();
            },
          ),
          //     TextButton(
          //         onPressed: () {
          //           _isImageSearch = true;
          //           _sendMessage();
          //         },
          //         child: const Text("Generate Image"))
          //   ],
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("FlutterGPT")),
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                  child: ListView.builder(
                reverse: true,
                // padding: Vx.m8,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              )),
              if (_isTyping) const ThreeDots(),
              const Divider(
                height: 1.0,
              ),
              Container(
                decoration: BoxDecoration(
                    // color: context.cardColor,
                    ),
                child: _buildTextComposer(),
              )
            ],
          ),
        ));
  }
}

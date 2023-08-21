import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gpt/models.dart';
import 'package:flutter_gpt/widgets/prompt_builder.dart';
import 'package:flutter_gpt/widgets/prompt_field.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final _speechToText = SpeechToText();
  final List<ChatMessage> _messages = [];
  bool isLoading = false;
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  Future<void> _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _speechToText.stop();
    super.dispose();
  }

  void _sendMessage() async {
    if (!_speechEnabled) {
      if (_controller.text.isEmpty) return;
    }
    ChatMessage message = ChatMessage(
      text: _speechEnabled ? _lastWords : _controller.text,
      sender: "user",
    );
    setState(() {
      _messages.insert(0, message);
      isLoading = true;
    });
    try {
      final response = await http.post(
          Uri.parse("https://api.openai.com/v1/chat/completions"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${dotenv.env["API_KEY"]}"
          },
          body: jsonEncode({
            "model": "text-davinci-003",
            "prompt": _speechEnabled ? _lastWords : _controller.text,
            "max_tokens": 7,
            "temperature": 0,
            "top_p": 1,
          }));

      if (response.statusCode == 200) {
        ResponseModel responseModel = responseModelFromJson(response.body);
        log(response.body.toString());
        log(responseModel.choices[0].text);
        _insertNewChat(responseModel.choices[0].text);
      } else {
        //want to remove
        _insertNewChat(
            "All loading animation APIs are same straight forward. There is a static method for each animation inside LoadingAnimationWidget class, which returns the Object of that animation. Both size and color are required some animations need more than one color.");
        log(response.body);
      }
    } catch (e) {
      log(e.toString());
    }
    if (_speechEnabled) {
      setState(() {
        _speechEnabled = false;
        _lastWords = "";
      });
    } else {
      _controller.clear();
    }
  }

  void _insertNewChat(String response) {
    ChatMessage botMessage = ChatMessage(
      text: response,
      sender: "bot",
    );
    setState(() {
      isLoading = false;
      _messages.insert(0, botMessage);
    });
  }

  Future<void> _speechListening() async {
    if (await _speechToText.hasPermission && _speechToText.isNotListening) {
      setState(() {
        _speechEnabled = true;
      });
      await _startListening();
    } else if (_speechToText.isListening) {
      await _stopListening();
      _sendMessage();
    } else {
      _initSpeech();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Flutter GPT")),
        body: SafeArea(
          child: Column(
            children: [
              PromptBuilder(messages: _messages),
              if (isLoading)
                LoadingAnimationWidget.dotsTriangle(
                  color: const Color.fromARGB(255, 7, 38, 56),
                  size: 60,
                ),
              PromptField(
                controller: _controller,
                speechEnabled: _speechEnabled,
                sendMessage: _sendMessage,
                sendSpeech: _speechListening,
              )
            ],
          ),
        ));
  }
}

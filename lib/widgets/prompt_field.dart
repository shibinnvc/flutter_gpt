// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// ignore: must_be_immutable
class PromptField extends StatefulWidget {
  final TextEditingController controller;
  final void Function() sendMessage;
  final void Function() sendSpeech;
  bool speechEnabled;

  PromptField({
    Key? key,
    required this.controller,
    required this.sendMessage,
    required this.sendSpeech,
    this.speechEnabled = false,
  }) : super(key: key);

  @override
  State<PromptField> createState() => _PromptFieldState();
}

class _PromptFieldState extends State<PromptField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: const Color.fromARGB(255, 7, 38, 56),
      child: Row(
        children: [
          Expanded(
              child: widget.speechEnabled
                  ? Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: Colors.white,
                        size: 40,
                      ),
                    )
                  : TextField(
                      controller: widget.controller,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (value) => widget.sendMessage(),
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: const InputDecoration.collapsed(
                          hintText: "Write a message here...",
                          hintStyle: TextStyle(color: Colors.white)),
                    )),
          IconButton(
              icon: Icon(
                  widget.controller.text.isEmpty ? Icons.mic : Icons.send,
                  color: Colors.white),
              onPressed: widget.controller.text.isEmpty
                  ? widget.sendSpeech
                  : widget.sendMessage),
        ],
      ),
    );
  }
}

import 'package:avatar_glow/avatar_glow.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ml_demo/chat_model.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'api/chat_gpt_api.dart';
import 'chat_msg.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String text = 'Hold the button and start speaking';
  bool isListening = false;
  final List<ChatMsg> messages = [];
  var scrollController = ScrollController();
  static final _speechToText = SpeechToText();
  static final _textToSpeach = FlutterTts();

  scrollMethod() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180), curve: Curves.easeOut);
  }

  @override
  void initState() {
    super.initState();
    _textToSpeach.setLanguage('en');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.content_copy),
              onPressed: () async {
                await FlutterClipboard.copy(text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓   Copied to Clipboard')),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isListening ? Colors.black : Colors.black54),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
                child: DecoratedBox(
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ChatMsg(
                        text: messages[index].text,
                        type: messages[index].type,
                      );
                    }),
              ),
            )),
            const SizedBox(
              height: 64,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isListening,
        endRadius: 70,
        glowColor: Theme.of(context).primaryColor,
        child: _buildFloatingActionButton(),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildFloatingActionButton() {
    return InkWell(
      onTap: () async {
        if (!isListening) {
          var available = await _speechToText.initialize();
          if (available) {
            setState(() {
              isListening = true;
              _speechToText.listen(onResult: whenListen);
            });
          }
        } else {
          await _speechToText.stop();
          if (text.isNotEmpty && text != "Hold the button and start speaking") {
            messages.add(ChatMsg(text: text, type: MsgType.user));
            String? msg = await ChatGptApi.sendMsg(text);
            if (msg != null) {
              setState(() {
                messages.add(ChatMsg(text: msg, type: MsgType.bot));
              });
              await _textToSpeach.awaitSpeakCompletion(true);
              await Future.delayed(const Duration(milliseconds: 500), () {
                _textToSpeach.speak(msg);
              });
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("your voice is not audible")));
          }
          setState(() {
            isListening = false;
          });
        }
      },
      child: SizedBox(
        height: 80,
        width: 80,
        child: DecoratedBox(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.blueGrey),
            child: Icon(
              isListening ? Icons.mic : Icons.mic_off,
              color: Colors.white,
            )),
      ),
    );
  }

  void whenListen(SpeechRecognitionResult result) async {
    setState(() {
      text = result.recognizedWords;
    });
    if (result.finalResult) {
      setState(() {
        isListening = false;
      });
      if (text.isNotEmpty && text != "Hold the button and start speaking") {
        messages.add(ChatMsg(text: text, type: MsgType.user));
        String? msg = await ChatGptApi.sendMsg(text);
        if (msg != null) {
          setState(() {
            messages.add(ChatMsg(text: msg, type: MsgType.bot));
          });
          await _textToSpeach.awaitSpeakCompletion(true);
          await Future.delayed(const Duration(seconds: 1));
          await _textToSpeach.speak(msg);
          await Future.delayed(const Duration(seconds: 1));
          if (messages.length < 10) {
            setState(() {
              isListening = true;
              _speechToText.listen(onResult: whenListen);
            });
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("your voice is not audible")));
      }
    }
  }
}

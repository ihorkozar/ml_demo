import 'package:avatar_glow/avatar_glow.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:ml_demo/api/speech_api.dart';
import 'package:ml_demo/substring_highlighted.dart';
import 'package:ml_demo/utils.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String text = 'Hold the button and start speaking';
  bool isListening = false;

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
      body: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          const Text('Hold the button and start speaking'),
          const SizedBox(
            height: 16,
          ),
          SingleChildScrollView(
            reverse: true,
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                SubstringHighlight(
                  text: text,
                  terms: Command.all,
                  textStyle: const TextStyle(
                    fontSize: 32.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  textStyleHighlight: const TextStyle(
                    fontSize: 32.0,
                    color: Colors.red,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            reverse: true,
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                // SubstringHighlight(
                //   text: text,
                //   terms: Command.all,
                //   textStyle: const TextStyle(
                //     fontSize: 32.0,
                //     color: Colors.black,
                //     fontWeight: FontWeight.w400,
                //   ),
                //   textStyleHighlight: const TextStyle(
                //     fontSize: 32.0,
                //     color: Colors.red,
                //     fontWeight: FontWeight.w400,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isListening,
        endRadius: 75,
        glowColor: Theme.of(context).primaryColor,
        child: FloatingActionButton(
          onPressed: () {
            toggleRecording();
            debugPrint('onPress');
          },
          tooltip: 'Hold it',
          child: Icon(isListening ? Icons.mic : Icons.mic_none),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future toggleRecording() => SpeechApi.toggleRecording(
        onResult: (text) => setState(() => this.text = text),
        onListening: (isListening) {
          debugPrint(isListening.toString());
          setState(() {
            this.isListening = isListening;
          });

          if (!isListening) {
            Utils.scanText(text);
          }
        },
      );
}

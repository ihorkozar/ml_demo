import 'dart:convert';

import 'package:http/http.dart' as http;

String apikey = "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";

class ChatGptApi {
  static String baseurl = "https://api.openai.com/v1/completions";
  static Map<String, String> header = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apikey',
  };
  static Future<String?> sendMsg(String? message) async {
    var res = await http.post(Uri.parse(baseurl),
        headers: header,
        body: jsonEncode({
          "model": "text-davinci-003",
          "prompt": '$message',
          "temperature": 0,
          "max_tokens": 100,
          "top_p": 1,
          "frequency_penalty": 0.0,
          "presence_penalty": 0.0,
          "stop": ["Human:", "AI:"]
        }));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body.toString());
      var msg = data['choices'][0]['text'];
      return msg;
    } else {
      print("failed to fetch data");
      return null;
    }
  }
}

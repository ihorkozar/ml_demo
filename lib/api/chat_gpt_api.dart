import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ml_demo/constants.dart';

class ChatGptApi {
  static String baseurl = 'https://api.openai.com/v1/chat/completions';
  static Map<String, String> header = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${Constants.chatGptApiKey}',
  };
  static Future<String?> sendMsg(String? message) async {
    var res = await http.post(Uri.parse(baseurl),
        headers: header,
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              'role': 'user',
              'content': message,
            },
          ],
          "temperature": 0,
          "max_tokens": 100,
        }));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body.toString());
      var msg = data['choices'][0]['message']['content'];
      return msg;
    } else {
      print(res.reasonPhrase ?? "failed to fetch data");
      return res.reasonPhrase ?? 'Failed to fetch data';
    }
  }
}

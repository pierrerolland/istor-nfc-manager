import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:istor_nfc_manager/config.dart';

class StoriesGateway {
  Future<List<String>> getUnassignedStories() async {
    final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/unassigned-stories'));
    final List<dynamic> body = jsonDecode(response.body);


    return body.map((e) => e.toString()).toList();
  }

  Future<void> assignStoryToCard(String title, String tagId) async {
    final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}/assign-story'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'card_id': tagId,
          'story_title': title
        })
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class PterodactylService {
  final String baseUrl;
  final String apiKey;
  final String serverId;

  PterodactylService({
    required this.baseUrl,
    required this.apiKey,
    required this.serverId,
  });

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Accept': 'Application/vnd.pterodactyl.v1+json',
      };

  Future<Map<String, dynamic>> getServerStatus() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/client/servers/$serverId/resources'),
      headers: _headers,
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getServerInfo() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/client/servers/$serverId'),
      headers: _headers,
    );
    return jsonDecode(res.body);
  }

  Future<bool> sendPowerAction(String action) async {
    // action: start | stop | restart | kill
    final res = await http.post(
      Uri.parse('$baseUrl/api/client/servers/$serverId/power'),
      headers: _headers,
      body: jsonEncode({'signal': action}),
    );
    return res.statusCode == 204;
  }

  Future<bool> sendCommand(String command) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/client/servers/$serverId/command'),
      headers: _headers,
      body: jsonEncode({'command': command}),
    );
    return res.statusCode == 204;
  }

  Future<List<String>> getConsoleOutput() async {
    // Pterodactyl uses WebSocket for live console; this fetches recent logs
    final res = await http.get(
      Uri.parse('$baseUrl/api/client/servers/$serverId/logs'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final logs = data['data'] as List? ?? [];
      return logs.map((l) => l.toString()).toList();
    }
    return [];
  }
}

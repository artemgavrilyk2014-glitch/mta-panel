import 'dart:convert';
import 'package:http/http.dart' as http;

class MtaService {
  final String host;
  final int port;

  MtaService({required this.host, required this.port});

  // Calls the Lua HTTP resource we install on the MTA server
  Future<List<Map<String, dynamic>>> getPlayers() async {
    try {
      final res = await http
          .get(Uri.parse('http://$host:$port/mta_panel/players'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(data['players'] ?? []);
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>> getServerInfo() async {
    try {
      final res = await http
          .get(Uri.parse('http://$host:$port/mta_panel/info'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return {};
  }

  Future<bool> kickPlayer(String playerName, String reason) async {
    try {
      final res = await http
          .post(
            Uri.parse('http://$host:$port/mta_panel/kick'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': playerName, 'reason': reason}),
          )
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> banPlayer(String playerName, String reason) async {
    try {
      final res = await http
          .post(
            Uri.parse('http://$host:$port/mta_panel/ban'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': playerName, 'reason': reason}),
          )
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

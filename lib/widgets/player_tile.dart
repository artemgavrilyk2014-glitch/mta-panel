import 'package:flutter/material.dart';

class PlayerTile extends StatelessWidget {
  final Map<String, dynamic> player;
  final Function(String) onKick;
  final Function(String) onBan;

  const PlayerTile({
    super.key,
    required this.player,
    required this.onKick,
    required this.onBan,
  });

  @override
  Widget build(BuildContext context) {
    final name = player['name'] ?? 'Unknown';
    final ping = player['ping'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131625),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF252840)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text('Ping: ${ping}ms',
                    style:
                        TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.orange, size: 20),
            tooltip: 'Кік',
            onPressed: () => _confirmAction(context, 'Кікнути', name, false),
          ),
          IconButton(
            icon: const Icon(Icons.block, color: Colors.red, size: 20),
            tooltip: 'Бан',
            onPressed: () => _confirmAction(context, 'Забанити', name, true),
          ),
        ],
      ),
    );
  }

  void _confirmAction(
      BuildContext context, String action, String name, bool isBan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D2E),
        title: Text('$action $name?',
            style: const TextStyle(color: Colors.white)),
        content: Text(
          isBan
              ? 'Гравця буде назавжди заблоковано.'
              : 'Гравця буде відключено від сервера.',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Скасувати')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: isBan ? Colors.red : Colors.orange),
            onPressed: () {
              Navigator.pop(ctx);
              isBan ? onBan(name) : onKick(name);
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/pterodactyl_service.dart';
import '../services/mta_service.dart';
import '../services/app_config.dart';
import '../widgets/stat_card.dart';
import '../widgets/player_tile.dart';
import '../widgets/console_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _ptero = PterodactylService(
    baseUrl: AppConfig.panelUrl,
    apiKey: AppConfig.apiKey,
    serverId: AppConfig.serverId,
  );
  final _mta = MtaService(
    host: AppConfig.mtaHost,
    port: AppConfig.mtaHttpPort,
  );

  Map<String, dynamic> _status = {};
  List<Map<String, dynamic>> _players = [];
  bool _loading = true;
  Timer? _timer;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final status = await _ptero.getServerStatus();
      final players = await _mta.getPlayers();
      if (mounted) {
        setState(() {
          _status = status;
          _players = players;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _powerAction(String action) async {
    final labels = {
      'start': 'Запустити',
      'stop': 'Зупинити',
      'restart': 'Рестартити',
      'kill': 'Примусово зупинити',
    };
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D2E),
        title: Text('${labels[action]} сервер?',
            style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Скасувати')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _actionColor(action)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(labels[action]!),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _ptero.sendPowerAction(action);
      _load();
    }
  }

  Color _actionColor(String action) {
    switch (action) {
      case 'start':
        return Colors.green;
      case 'stop':
        return Colors.orange;
      case 'restart':
        return Colors.blue;
      case 'kill':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool get _isOnline {
    final attr = _status['attributes'];
    if (attr == null) return false;
    return attr['current_state'] == 'running';
  }

  double get _cpuUsage {
    try {
      return (_status['attributes']['resources']['cpu_absolute'] as num)
          .toDouble();
    } catch (_) {
      return 0;
    }
  }

  double get _ramUsage {
    try {
      final bytes =
          (_status['attributes']['resources']['memory_bytes'] as num).toDouble();
      return bytes / 1024 / 1024; // MB
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildDashboard(),
                  _buildPlayers(),
                  ConsoleWidget(ptero: _ptero),
                ],
              ),
            ),
            _buildNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF131625),
        border: Border(bottom: BorderSide(color: Color(0xFF252840))),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.sports_esports, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MTA Panel',
                    style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                Text('g1.qniks.me:30319',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _isOnline
                  ? Colors.green.withOpacity(0.15)
                  : Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _isOnline ? Colors.green : Colors.red, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isOnline ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                      color: _isOnline ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _load,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Статистика',
                style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: StatCard(
                  icon: Icons.people,
                  label: 'Гравці',
                  value: '${_players.length}',
                  color: const Color(0xFF6C63FF),
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: StatCard(
                  icon: Icons.memory,
                  label: 'RAM',
                  value: '${_ramUsage.toStringAsFixed(0)} MB',
                  color: const Color(0xFF3ECFCF),
                )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: StatCard(
                  icon: Icons.speed,
                  label: 'CPU',
                  value: '${_cpuUsage.toStringAsFixed(1)}%',
                  color: const Color(0xFFFF6B6B),
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: StatCard(
                  icon: Icons.circle,
                  label: 'Статус',
                  value: _isOnline ? 'Running' : 'Stopped',
                  color: _isOnline ? Colors.green : Colors.grey,
                )),
              ],
            ),
            const SizedBox(height: 24),
            Text('Керування',
                style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _powerBtn('start', Icons.play_arrow, 'Старт', Colors.green),
                _powerBtn('restart', Icons.refresh, 'Рестарт', Colors.blue),
                _powerBtn('stop', Icons.stop, 'Стоп', Colors.orange),
                _powerBtn('kill', Icons.dangerous, 'Kill', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _powerBtn(
      String action, IconData icon, String label, Color color) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.15),
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon),
      label: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      onPressed: () => _powerAction(action),
    );
  }

  Widget _buildPlayers() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_players.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 60, color: Colors.grey[700]),
            const SizedBox(height: 12),
            Text('Гравців немає онлайн',
                style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            const SizedBox(height: 8),
            Text('Або Lua скрипт не встановлено',
                style: TextStyle(color: Colors.grey[700], fontSize: 12)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _players.length,
      itemBuilder: (ctx, i) => PlayerTile(
        player: _players[i],
        onKick: (name) async {
          await _mta.kickPlayer(name, 'Kicked by admin');
          _load();
        },
        onBan: (name) async {
          await _mta.banPlayer(name, 'Banned by admin');
          _load();
        },
      ),
    );
  }

  Widget _buildNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF131625),
        border: Border(top: BorderSide(color: Color(0xFF252840))),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey[600],
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Панель'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Гравці'),
          BottomNavigationBarItem(icon: Icon(Icons.terminal), label: 'Консоль'),
        ],
      ),
    );
  }
}

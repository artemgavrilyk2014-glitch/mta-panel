import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/pterodactyl_service.dart';

class ConsoleWidget extends StatefulWidget {
  final PterodactylService ptero;

  const ConsoleWidget({super.key, required this.ptero});

  @override
  State<ConsoleWidget> createState() => _ConsoleWidgetState();
}

class _ConsoleWidgetState extends State<ConsoleWidget> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<String> _logs = [];
  bool _loading = false;

  Future<void> _sendCommand() async {
    final cmd = _controller.text.trim();
    if (cmd.isEmpty) return;
    setState(() {
      _logs.add('> $cmd');
      _controller.clear();
      _loading = true;
    });
    final ok = await widget.ptero.sendCommand(cmd);
    setState(() {
      _logs.add(ok ? '[OK] Команда відправлена' : '[ERR] Помилка відправки');
      _loading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0C14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF252840)),
            ),
            child: _logs.isEmpty
                ? Center(
                    child: Text('Консоль порожня.\nВведіть команду нижче.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600])),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _logs.length,
                    itemBuilder: (ctx, i) {
                      final log = _logs[i];
                      Color color = Colors.grey[400]!;
                      if (log.startsWith('>')) color = const Color(0xFF6C63FF);
                      if (log.startsWith('[OK]')) color = Colors.green;
                      if (log.startsWith('[ERR]')) color = Colors.red;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(log,
                            style: GoogleFonts.sourceCodePro(
                                color: color, fontSize: 12)),
                      );
                    },
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: GoogleFonts.sourceCodePro(
                      color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Введіть команду...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: const Color(0xFF131625),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF252840)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF252840)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF6C63FF)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  onSubmitted: (_) => _sendCommand(),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send, color: Colors.white),
                  onPressed: _loading ? null : _sendCommand,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

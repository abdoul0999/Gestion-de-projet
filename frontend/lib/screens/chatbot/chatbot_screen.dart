import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class ChatMessage {
  final String role;
  final String content;
  ChatMessage({required this.role, required this.content});
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _loading = false;
  bool _historyLoaded = false;

  final _suggestions = [
    ('📄', 'Comment améliorer mon CV pour la Data Science ?'),
    ('🧠', 'Quelles compétences sont les plus demandées en 2025 ?'),
    ('🤝', 'Comment préparer un entretien technique ?'),
    ('📚', 'Quelle certification pour progresser en ML ?'),
    ('💼', 'Différence entre CDI et alternance ?'),
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await ApiService().getChatHistory();
      setState(() {
        _messages.addAll(history.map((m) => ChatMessage(
              role: m['role'] as String,
              content: m['content'] as String,
            )));
        _historyLoaded = true;
      });
      _scrollToBottom();
    } catch (_) {
      setState(() => _historyLoaded = true);
    }
  }

  Future<void> _send([String? text]) async {
    final message = (text ?? _ctrl.text).trim();
    if (message.isEmpty || _loading) return;
    _ctrl.clear();

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: message));
      _loading = true;
    });
    _scrollToBottom();

    try {
      final data = await ApiService().sendMessage(message);
      setState(() {
        _messages.add(ChatMessage(role: 'assistant', content: data['reply'] as String));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
            role: 'assistant', content: 'Désolé, une erreur est survenue. Réessaie.'));
      });
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _clearHistory() async {
    try {
      await ApiService().clearChatHistory();
      setState(() => _messages.clear());
    } catch (_) {}
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  color: const Color(0xFF0F2D55), borderRadius: BorderRadius.circular(15)),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chatbot AscendIA',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Text('Sources vérifiées · RAG',
                    style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF7DB3D8))),
              ],
            ),
          ],
        ),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: _clearHistory,
              tooltip: 'Effacer l\'historique',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && _historyLoaded
                ? _buildSuggestions()
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const _TypingIndicator();
                      }
                      return _MessageBubble(msg: _messages[index]);
                    },
                  ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clique sur une question pour commencer :',
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMid)),
          const SizedBox(height: 12),
          ..._suggestions.map((s) => GestureDetector(
                onTap: () => _send(s.$2),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Text(s.$1, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(s.$2,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.primaryDark)),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 0.5)),
      ),
      padding: EdgeInsets.only(
        left: 14,
        right: 10,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (v) => _send(),
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Tape ta question...',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      const BorderSide(color: AppColors.primaryLight, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _loading ? null : () => _send(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _loading ? AppColors.textMuted : AppColors.primaryDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _loading
                  ? const Center(
                      child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white)))
                  : const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.80),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryDark : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser
              ? null
              : Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Text(
          msg.content,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isUser ? Colors.white : AppColors.textDark,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('AscendIA réfléchit',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textLight)),
            const SizedBox(width: 8),
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primaryLight),
            ),
          ],
        ),
      ),
    );
  }
}

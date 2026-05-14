import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';

class ChatConsultationScreen extends StatefulWidget {
  const ChatConsultationScreen({super.key});
  @override
  State<ChatConsultationScreen> createState() => _ChatConsultationScreenState();
}

class _ChatConsultationScreenState extends State<ChatConsultationScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <MockChatMessage>[];
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    _messages.addAll(MockData.chatMessages);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(MockChatMessage(
        sender: 'patient',
        text: text.trim(),
        time: DateTime.now(),
      ));
      _typing = true;
    });
    _ctrl.clear();
    _scrollToBottom();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _messages.add(MockChatMessage(
          sender: 'doctor',
          text: 'Thank you for sharing that. Based on your symptoms, I recommend rest and adequate hydration. I\'ll send a prescription shortly.',
          time: DateTime.now(),
        ));
        _typing = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.patientPrimary.withValues(alpha: 0.15),
              child: const Text('AM', style: TextStyle(color: AppColors.patientPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dr. Arjun Mehta', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text('Online', style: TextStyle(fontSize: 11, color: Color(0xFF059669))),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam_rounded), onPressed: () {}),
          IconButton(icon: const Icon(Icons.phone_rounded), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_typing ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == _messages.length) return _TypingBubble(isDoctor: true);
                final msg = _messages[i];
                return _ChatBubble(message: msg);
              },
            ),
          ),
          // Attachments row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _AttachBtn(icon: Icons.image_rounded, onTap: () {}),
                _AttachBtn(icon: Icons.camera_alt_rounded, onTap: () {}),
                _AttachBtn(icon: Icons.description_rounded, onTap: () {}),
                _AttachBtn(icon: Icons.medication_rounded, onTap: () {}),
              ],
            ),
          ),
          // Input
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: AppColors.patientSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: _send,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _send(_ctrl.text),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.patientPrimary,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final MockChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.sender == 'patient';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.patientPrimary.withValues(alpha: 0.15),
              child: const Text('Dr', style: TextStyle(color: AppColors.patientPrimary, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('Dr. Arjun Mehta',
                        style: const TextStyle(color: AppColors.slate500, fontSize: 11)),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.patientPrimary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.slate200.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.slate800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: AppColors.slate400, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  final bool isDoctor;
  const _TypingBubble({required this.isDoctor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.patientPrimary.withValues(alpha: 0.15),
            child: const Text('Dr', style: TextStyle(color: AppColors.patientPrimary, fontSize: 10)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('typing...', style: TextStyle(color: AppColors.slate400, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _AttachBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AttachBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.slate400, size: 22),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      constraints: const BoxConstraints(),
    );
  }
}

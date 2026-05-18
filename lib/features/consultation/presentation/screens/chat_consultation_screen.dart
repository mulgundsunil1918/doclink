import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import 'video_call_screen.dart';

class ChatConsultationScreen extends ConsumerStatefulWidget {
  final String appointmentId;
  const ChatConsultationScreen({super.key, required this.appointmentId});

  @override
  ConsumerState<ChatConsultationScreen> createState() =>
      _ChatConsultationScreenState();
}

class _ChatConsultationScreenState
    extends ConsumerState<ChatConsultationScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _picker = ImagePicker();
  bool _sending = false;

  String? get _myId => Supabase.instance.client.auth.currentUser?.id;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _ctrl.clear();
    try {
      await sendMessage(appointmentId: widget.appointmentId, text: text);
      _scrollToBottom();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendImage(ImageSource source) async {
    try {
      final xfile = await _picker.pickImage(source: source, imageQuality: 70);
      if (xfile == null || !mounted) return;
      final bytes = await xfile.readAsBytes();
      final ext = xfile.path.split('.').last;
      final path =
          'chat/${widget.appointmentId}/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await Supabase.instance.client.storage
          .from('chat-attachments')
          .uploadBinary(path, bytes,
              fileOptions: FileOptions(contentType: 'image/$ext'));
      final url = Supabase.instance.client.storage
          .from('chat-attachments')
          .getPublicUrl(path);
      await sendMessage(
          appointmentId: widget.appointmentId, text: '[IMAGE]:$url');
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  Future<void> _sendDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png']);
      if (result == null || result.files.isEmpty || !mounted) return;
      final file = result.files.first;
      if (file.bytes == null) return;
      final path =
          'chat/${widget.appointmentId}/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      await Supabase.instance.client.storage
          .from('chat-attachments')
          .uploadBinary(path, file.bytes!);
      final url = Supabase.instance.client.storage
          .from('chat-attachments')
          .getPublicUrl(path);
      await sendMessage(
          appointmentId: widget.appointmentId,
          text: '[FILE:${file.name}]:$url');
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
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
    final messagesAsync = ref.watch(messagesProvider(widget.appointmentId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0x261E88E5),
              child: Text('C',
                  style: TextStyle(
                      color: AppColors.patientPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Consultation',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text('Live',
                    style: TextStyle(
                        fontSize: 11, color: Color(0xFF059669))),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_rounded),
            tooltip: 'Switch to Video',
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const VideoCallScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone_rounded),
            tooltip: 'Switch to Voice',
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const VideoCallScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(
                  child: Text('Failed to load messages',
                      style: TextStyle(color: AppColors.slate400))),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Say hello!',
                        style: TextStyle(
                            color: AppColors.slate400, fontSize: 14)),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (ctx, i) => _ChatBubble(
                    message: messages[i],
                    isMe: messages[i].senderId == _myId,
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _AttachBtn(
                    icon: Icons.image_rounded,
                    onTap: () => _sendImage(ImageSource.gallery)),
                _AttachBtn(
                    icon: Icons.camera_alt_rounded,
                    onTap: () => _sendImage(ImageSource.camera)),
                _AttachBtn(
                    icon: Icons.description_rounded,
                    onTap: () => _sendDocument()),
              ],
            ),
          ),
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _sending
                          ? AppColors.slate400
                          : AppColors.patientPrimary,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: _sending
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                          )
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
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
  final AppMessage message;
  final bool isMe;
  const _ChatBubble({required this.message, required this.isMe});

  bool get _isImage => message.text.startsWith('[IMAGE]:');
  bool get _isFile => message.text.startsWith('[FILE:');
  String get _url {
    if (_isImage) return message.text.substring('[IMAGE]:'.length);
    if (_isFile) {
      final colonIdx = message.text.indexOf(']:');
      return message.text.substring(colonIdx + 2);
    }
    return '';
  }

  String get _fileName {
    if (!_isFile) return '';
    final start = message.text.indexOf('[FILE:') + 6;
    final end = message.text.indexOf(']:');
    return message.text.substring(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 14,
              backgroundColor:
                  AppColors.patientPrimary.withValues(alpha: 0.15),
              child: const Text('D',
                  style: TextStyle(
                      color: AppColors.patientPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.patientPrimary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.slate200.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _url,
                            width: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                        )
                      : _isFile
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.description_rounded, size: 16),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    _fileName,
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white
                                          : AppColors.slate800,
                                      fontSize: 13,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              message.text,
                              style: TextStyle(
                                color: isMe ? Colors.white : AppColors.slate800,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      color: AppColors.slate400, fontSize: 10),
                ),
              ],
            ),
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

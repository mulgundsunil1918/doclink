import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class VideoCallScreen extends StatefulWidget {
  final String? patientName;
  final bool isDoctor;
  const VideoCallScreen({super.key, this.patientName, this.isDoctor = true});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _showNotes = false;
  bool _showChat = false;
  int _seconds = 0;
  Timer? _timer;
  final _notesCtrl = TextEditingController();
  final _chatCtrl = TextEditingController();
  final List<MockChatMessage> _messages = List.from(MockData.chatMessages.take(2));
  String _quality = 'HD';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notesCtrl.dispose();
    _chatCtrl.dispose();
    super.dispose();
  }

  String get _duration {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.patientName ?? 'Riya Sharma';
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote video (patient)
          _VideoPlaceholder(
            name: patientName,
            color: const Color(0xFF1E3A5F),
            isFullScreen: true,
            isCameraOff: false,
          ),

          // Self view (doctor)
          Positioned(
            top: 60,
            right: 16,
            child: Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isCameraOff
                    ? Container(
                        color: Colors.black87,
                        child: const Icon(Icons.videocam_off_rounded,
                            color: Colors.white54, size: 30),
                      )
                    : _VideoPlaceholder(
                        name: 'Dr. ${MockData.doctor.name.split(' ').last}',
                        color: const Color(0xFF0F172A),
                        isFullScreen: false,
                        isCameraOff: _isCameraOff,
                      ),
              ),
            ),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patientName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                      const Text('Fever & headache — video consult',
                          style: TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_duration,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              fontFeatures: [FontFeature.tabularFigures()])),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.doctorAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(_quality,
                              style: const TextStyle(
                                  color: AppColors.doctorAccent,
                                  fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Side panels
          if (_showNotes)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.45,
              child: _NotesPanel(controller: _notesCtrl,
                  onClose: () => setState(() => _showNotes = false)),
            ),

          if (_showChat)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.45,
              child: _ChatPanel(
                messages: _messages,
                controller: _chatCtrl,
                onSend: () {
                  if (_chatCtrl.text.trim().isEmpty) return;
                  setState(() {
                    _messages.add(MockChatMessage(
                      text: _chatCtrl.text.trim(),
                      sender: 'doctor',
                      time: DateTime.now(),
                    ));
                    _chatCtrl.clear();
                  });
                },
                onClose: () => setState(() => _showChat = false),
              ),
            ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Column(
                children: [
                  if (widget.isDoctor)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SideBtn(
                            icon: Icons.note_alt_rounded,
                            label: 'Notes',
                            active: _showNotes,
                            onTap: () => setState(() {
                              _showNotes = !_showNotes;
                              _showChat = false;
                            }),
                          ),
                          const SizedBox(width: 12),
                          _SideBtn(
                            icon: Icons.chat_rounded,
                            label: 'Chat',
                            active: _showChat,
                            onTap: () => setState(() {
                              _showChat = !_showChat;
                              _showNotes = false;
                            }),
                          ),
                          const SizedBox(width: 12),
                          _SideBtn(
                            icon: Icons.description_rounded,
                            label: 'Write Rx',
                            active: false,
                            onTap: () => Navigator.pushNamed(context, '/prescription'),
                          ),
                          const SizedBox(width: 12),
                          _SideBtn(
                            icon: Icons.signal_cellular_alt,
                            label: _quality,
                            active: false,
                            onTap: () => setState(() =>
                                _quality = _quality == 'HD' ? 'SD' : 'HD'),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ControlBtn(
                        icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        label: _isMuted ? 'Unmute' : 'Mute',
                        active: _isMuted,
                        onTap: () => setState(() => _isMuted = !_isMuted),
                      ),
                      _ControlBtn(
                        icon: _isCameraOff
                            ? Icons.videocam_off_rounded
                            : Icons.videocam_rounded,
                        label: _isCameraOff ? 'Cam Off' : 'Camera',
                        active: _isCameraOff,
                        onTap: () => setState(() => _isCameraOff = !_isCameraOff),
                      ),
                      GestureDetector(
                        onTap: _endCall,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.call_end_rounded,
                              color: Colors.white, size: 28),
                        ),
                      ),
                      _ControlBtn(
                        icon: Icons.screen_share_rounded,
                        label: 'Share',
                        active: false,
                        onTap: () {},
                      ),
                      _ControlBtn(
                        icon: Icons.flip_camera_ios_rounded,
                        label: 'Flip',
                        active: false,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _endCall() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.doctorCard,
        title: const Text('End Consultation?'),
        content: Text(
          'Duration: $_duration. An AI summary will be generated.',
          style: const TextStyle(color: AppColors.slate400),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Consultation ended. AI summary generating... ✓'),
                  backgroundColor: AppColors.doctorAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('End Call'),
          ),
        ],
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  final String name;
  final Color color;
  final bool isFullScreen, isCameraOff;
  const _VideoPlaceholder({
    required this.name,
    required this.color,
    required this.isFullScreen,
    required this.isCameraOff,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullScreen ? double.infinity : null,
      height: isFullScreen ? double.infinity : null,
      color: color,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: isFullScreen ? 50 : 24,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              child: Text(
                name.split(' ').map((w) => w[0]).take(2).join(),
                style: TextStyle(
                  fontSize: isFullScreen ? 32 : 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (isFullScreen) ...[
              const SizedBox(height: 12),
              Text(name,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ControlBtn(
      {required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.error.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: active ? AppColors.error : Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }
}

class _SideBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _SideBtn(
      {required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? AppColors.doctorPrimary.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _NotesPanel extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClose;
  const _NotesPanel({required this.controller, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.doctorCard,
        border: Border(left: BorderSide(color: AppColors.doctorBorder)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.slate800,
              child: Row(
                children: [
                  const Icon(Icons.note_alt_rounded,
                      size: 16, color: AppColors.doctorPrimary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Consultation Notes',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: onClose,
                      padding: EdgeInsets.zero),
                ],
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'SOAP notes, observations, vitals...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatPanel extends StatelessWidget {
  final List<MockChatMessage> messages;
  final TextEditingController controller;
  final VoidCallback onSend, onClose;

  const _ChatPanel({
    required this.messages,
    required this.controller,
    required this.onSend,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.doctorCard,
        border: Border(left: BorderSide(color: AppColors.doctorBorder)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.slate800,
              child: Row(
                children: [
                  const Icon(Icons.chat_rounded,
                      size: 16, color: AppColors.doctorPrimary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('In-call Chat',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: onClose,
                      padding: EdgeInsets.zero),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final msg = messages[i];
                  final isDoc = msg.sender == 'doctor';
                  return Align(
                    alignment: isDoc ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      constraints: const BoxConstraints(maxWidth: 200),
                      decoration: BoxDecoration(
                        color: isDoc ? AppColors.doctorPrimary : AppColors.slate700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(msg.text,
                          style: const TextStyle(fontSize: 11, color: Colors.white)),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.slate800,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        hintText: 'Type...',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: AppColors.doctorPrimary, size: 20),
                    onPressed: onSend,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

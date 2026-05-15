import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});
  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _messages = <_AiMessage>[];
  bool _loading = false;
  int _mode = 0; // 0=chat, 1=soap, 2=prescribe

  final _modes = [
    (label: 'Chat', icon: Icons.chat_rounded),
    (label: 'SOAP Notes', icon: Icons.note_alt_rounded),
    (label: 'Rx Draft', icon: Icons.medication_rounded),
  ];

  static const _soapTemplate = '''
**SOAP Note — Dr. Arjun Mehta**

**S (Subjective):**
Patient reports fever (101°F) for 3 days, sore throat, and mild fatigue. No cough. No travel history.

**O (Objective):**
- Temp: 101.2°F, BP: 118/76, HR: 88 bpm
- Throat: mild erythema, no exudate
- Lungs: clear bilaterally

**A (Assessment):**
Viral pharyngitis — most likely etiology, rule out Strep if symptoms persist >5 days.

**P (Plan):**
1. Paracetamol 500mg TID PRN fever
2. Warm saline gargles
3. Rest + adequate hydration
4. Follow-up in 5 days or sooner if worsening
''';

  static final _rxDraft = '''
**Prescription Draft**

Pt: [Patient Name], Age: [XX]
Date: ${_today()}

1. Tab. Azithromycin 500mg — Once daily × 3 days
2. Tab. Paracetamol 500mg — TID × 5 days PRN
3. Syr. Benadryl — 10ml TID × 3 days

Advice:
- Complete antibiotic course
- Soft diet, warm fluids
- Avoid cold drinks

*Review after 5 days*
''';

  static String _today() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  @override
  void initState() {
    super.initState();
    _messages.add(const _AiMessage(
      text: 'Hello Dr. Mehta! I\'m your AI assistant. I can help with SOAP notes, prescription drafts, drug interactions, and clinical queries. How can I help you today?',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_AiMessage(text: text.trim(), isUser: true));
      _loading = true;
    });
    _ctrl.clear();
    await Future.delayed(const Duration(milliseconds: 1500));

    String reply;
    final lower = text.toLowerCase();
    if (lower.contains('soap') || _mode == 1) {
      reply = _soapTemplate;
    } else if (lower.contains('prescri') || lower.contains('rx') || _mode == 2) {
      reply = _rxDraft;
    } else if (lower.contains('drug') || lower.contains('interact')) {
      reply = 'No significant interaction found between Azithromycin and Paracetamol. Both are safe to co-prescribe. Monitor for QT prolongation with macrolides in cardiac patients.';
    } else if (lower.contains('dosage') || lower.contains('dose')) {
      reply = 'Standard adult dosage for Azithromycin: 500mg once daily × 3–5 days. Reduce by 50% in hepatic impairment. Safe in pregnancy (Category B).';
    } else {
      reply = 'Based on the clinical picture, this appears to be a viral etiology. I recommend symptomatic management. Would you like me to draft a SOAP note or prescription?';
    }

    if (mounted) {
      setState(() {
        _messages.add(_AiMessage(text: reply, isUser: false));
        _loading = false;
      });
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.doctorAccent, Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Assistant', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text('Powered by GPT-4o', style: TextStyle(fontSize: 10, color: AppColors.slate400)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode selector
          Container(
            color: AppColors.darkCard,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: List.generate(
                _modes.length,
                (i) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _mode = i),
                    child: Container(
                      margin: EdgeInsets.only(right: i < _modes.length - 1 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _mode == i
                            ? AppColors.doctorAccent.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _mode == i ? AppColors.doctorAccent : AppColors.doctorBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_modes[i].icon,
                              size: 14,
                              color: _mode == i ? AppColors.doctorAccent : AppColors.slate400),
                          const SizedBox(width: 4),
                          Text(
                            _modes[i].label,
                            style: TextStyle(
                              color: _mode == i ? AppColors.doctorAccent : AppColors.slate400,
                              fontSize: 12,
                              fontWeight: _mode == i ? FontWeight.w700 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Quick prompts
          if (_messages.length <= 1)
            Container(
              color: AppColors.darkCard,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'Generate SOAP note',
                    'Draft prescription',
                    'Drug interaction check',
                    'Dosage query',
                  ]
                      .map((p) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text(p, style: const TextStyle(fontSize: 11)),
                              onPressed: () => _send(p),
                              backgroundColor: AppColors.doctorAccent.withValues(alpha: 0.1),
                              side: BorderSide(color: AppColors.doctorAccent.withValues(alpha: 0.3)),
                              labelStyle: const TextStyle(color: AppColors.doctorAccent),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == _messages.length) return const _TypingIndicator();
                return _MessageBubble(message: _messages[i]);
              },
            ),
          ),
          // Input
          Container(
            color: AppColors.darkCard,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ask AI anything...',
                      hintStyle: const TextStyle(color: AppColors.slate500),
                      filled: true,
                      fillColor: AppColors.darkBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      gradient: const LinearGradient(
                        colors: [AppColors.doctorAccent, Color(0xFF6366F1)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
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

class _MessageBubble extends StatelessWidget {
  final _AiMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.doctorAccent, Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.doctorAccent.withValues(alpha: 0.2)
                    : AppColors.doctorCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: message.isUser
                      ? AppColors.doctorAccent.withValues(alpha: 0.3)
                      : AppColors.doctorBorder,
                ),
              ),
              child: Text(
                message.text,
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.doctorAccent, Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
          ),
          DlCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(delay: 0),
                const SizedBox(width: 4),
                _Dot(delay: 200),
                const SizedBox(width: 4),
                _Dot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.doctorAccent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _AiMessage {
  final String text;
  final bool isUser;
  const _AiMessage({required this.text, required this.isUser});
}

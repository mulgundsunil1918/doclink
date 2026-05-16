import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const _kDark = Color(0xFF0A0F1E);
const _kCard = Color(0xFF111827);
const _kCard2 = Color(0xFF1C2536);
const _kBorder = Color(0xFF1F2D45);
const _kAccent = Color(0xFF00D4A8);
const _kAccent2 = Color(0xFF6366F1);
const _kText = Colors.white;
const _kMuted = Color(0xFF8B9BB4);

// ─────────────────────────────────────────────────────────────────────────────
// Entry screen
// ─────────────────────────────────────────────────────────────────────────────

class AiAssistantScreen extends StatefulWidget {
  final String? patientName;
  final String? patientId;
  final String? appointmentId;
  const AiAssistantScreen({
    super.key,
    this.patientName,
    this.patientId,
    this.appointmentId,
  });

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  int _tab = 0;
  final _gemini = GeminiService();

  static const _tabs = [
    (label: 'Chat', icon: Icons.chat_bubble_rounded),
    (label: 'Write Rx', icon: Icons.medication_liquid_rounded),
    (label: 'SOAP Note', icon: Icons.assignment_rounded),
    (label: 'Drug Info', icon: Icons.science_rounded),
    (label: 'Interactions', icon: Icons.warning_rounded),
  ];

  static const _tabColors = [
    _kAccent,
    Color(0xFF3B82F6),
    Color(0xFFA78BFA),
    Color(0xFF34D399),
    Color(0xFFFBBF24),
  ];

  @override
  void dispose() {
    _gemini.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDark,
      body: Column(
        children: [
          _Header(
            patientName: widget.patientName,
            onBack: () => context.pop(),
          ),
          _TabBar(
            tabs: _tabs,
            colors: _tabColors,
            selected: _tab,
            onTap: (i) => setState(() => _tab = i),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    return IndexedStack(
      index: _tab,
      children: [
        _ChatTab(gemini: _gemini, patientName: widget.patientName),
        _RxTab(
          gemini: _gemini,
          patientName: widget.patientName,
          patientId: widget.patientId,
          appointmentId: widget.appointmentId,
        ),
        _SoapTab(gemini: _gemini, patientName: widget.patientName),
        _DrugInfoTab(gemini: _gemini),
        _InteractionsTab(gemini: _gemini),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String? patientName;
  final VoidCallback onBack;
  const _Header({this.patientName, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(0, top, 16, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1628), Color(0xFF111827)],
        ),
        border: Border(bottom: BorderSide(color: _kBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: _kMuted, size: 18),
            onPressed: onBack,
          ),
          // Gemini logo
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kAccent, _kAccent2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Doclink AI',
                    style: TextStyle(
                        color: _kText,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.3)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _kAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Gemini 1.5 Flash',
                          style: TextStyle(
                              color: _kAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5)),
                    ),
                    if (patientName != null) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.person_rounded,
                          color: _kMuted, size: 11),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          patientName!,
                          style: const TextStyle(
                              color: _kMuted, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Tab Bar
// ─────────────────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final List<({String label, IconData icon})> tabs;
  final List<Color> colors;
  final int selected;
  final ValueChanged<int> onTap;
  const _TabBar({
    required this.tabs,
    required this.colors,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: _kCard,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: tabs.length,
        itemBuilder: (_, i) {
          final isSelected = i == selected;
          final color = colors[i];
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? color.withValues(alpha: 0.6)
                      : _kBorder,
                  width: isSelected ? 1 : 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tabs[i].icon,
                      size: 13,
                      color: isSelected ? color : _kMuted),
                  const SizedBox(width: 5),
                  Text(
                    tabs[i].label,
                    style: TextStyle(
                      color: isSelected ? color : _kMuted,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 — Chat
// ─────────────────────────────────────────────────────────────────────────────

class _ChatTab extends StatefulWidget {
  final GeminiService gemini;
  final String? patientName;
  const _ChatTab({required this.gemini, this.patientName});

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_Msg>[];
  final _history = <Map<String, dynamic>>[];
  bool _loading = false;

  static const _quickPrompts = [
    'What is the dose of Amoxicillin for a 5-year-old?',
    'Red flags for acute chest pain in OPD',
    'How to manage viral pharyngitis?',
    'Metformin counselling points for T2DM',
  ];

  @override
  void initState() {
    super.initState();
    final greeting = widget.patientName != null
        ? 'Hello Doctor! I\'m ready to assist with ${widget.patientName}\'s case. What would you like to know?'
        : 'Hello Doctor! I\'m Doclink AI, powered by Gemini. Ask me drug doses, clinical guidelines, differential diagnoses, or anything medical.';
    _messages.add(_Msg(text: greeting, isUser: false));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final t = text.trim();
    if (t.isEmpty || _loading) return;
    _ctrl.clear();
    setState(() {
      _messages.add(_Msg(text: t, isUser: true));
      _loading = true;
    });
    _history.add({'role': 'user', 'parts': [{'text': t}]});
    _scrollToBottom();

    try {
      final ctx = widget.patientName != null
          ? 'Patient context: ${widget.patientName}'
          : null;
      final reply = await widget.gemini.chat(
          history: _history, patientContext: ctx);
      _history.add({'role': 'model', 'parts': [{'text': reply}]});
      if (mounted) {
        setState(() {
          _messages.add(_Msg(text: reply, isUser: false));
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_Msg(
              text: 'Error: ${_friendlyError(e)}',
              isUser: false,
              isError: true));
          _loading = false;
        });
        if (_history.isNotEmpty) _history.removeLast();
      }
    }
  }

  void _clear() {
    setState(() {
      _messages.clear();
      _history.clear();
      _messages.add(_Msg(
          text: 'Conversation cleared. How can I help you?', isUser: false));
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Quick prompts
        if (_messages.length <= 1)
          Container(
            color: _kCard,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Try asking:',
                    style: TextStyle(
                        color: _kMuted, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickPrompts
                        .map((p) => GestureDetector(
                              onTap: () => _send(p),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _kAccent.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color:
                                          _kAccent.withValues(alpha: 0.25)),
                                ),
                                child: Text(p,
                                    style: const TextStyle(
                                        color: _kAccent, fontSize: 11)),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _messages.length + (_loading ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == _messages.length) return const _TypingIndicator();
              return _ChatBubble(msg: _messages[i]);
            },
          ),
        ),
        // Input
        _ChatInput(
          ctrl: _ctrl,
          loading: _loading,
          onSend: _send,
          onClear: _messages.length > 1 ? _clear : null,
        ),
      ],
    );
  }
}

class _Msg {
  final String text;
  final bool isUser;
  final bool isError;
  const _Msg(
      {required this.text, required this.isUser, this.isError = false});
}

class _ChatBubble extends StatelessWidget {
  final _Msg msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_kAccent, _kAccent2]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: msg.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Copied'),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: msg.isUser
                      ? _kAccent.withValues(alpha: 0.15)
                      : msg.isError
                          ? AppColors.error.withValues(alpha: 0.12)
                          : _kCard2,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                    bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                  ),
                  border: Border.all(
                    color: msg.isUser
                        ? _kAccent.withValues(alpha: 0.3)
                        : msg.isError
                            ? AppColors.error.withValues(alpha: 0.3)
                            : _kBorder,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  msg.text,
                  style: TextStyle(
                    color: msg.isError ? AppColors.error : _kText,
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
              ),
            ),
          ),
          if (msg.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_rounded,
                  color: AppColors.primary, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: [_kAccent, _kAccent2]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _kCard2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kBorder, width: 0.5),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final opacity = ((_ctrl.value + i / 3) % 1.0);
                    return Container(
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _kAccent.withValues(
                            alpha: 0.3 + opacity * 0.7),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController ctrl;
  final bool loading;
  final ValueChanged<String> onSend;
  final VoidCallback? onClear;
  const _ChatInput({
    required this.ctrl,
    required this.loading,
    required this.onSend,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 10, 12, MediaQuery.of(context).padding.bottom + 10),
      decoration: const BoxDecoration(
        color: _kCard,
        border: Border(top: BorderSide(color: _kBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          if (onClear != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: _kMuted, size: 20),
              onPressed: onClear,
              tooltip: 'Clear chat',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                  minWidth: 36, minHeight: 36),
            ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _kCard2,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _kBorder, width: 0.5),
              ),
              child: TextField(
                controller: ctrl,
                style: const TextStyle(color: _kText, fontSize: 14),
                cursorColor: _kAccent,
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: onSend,
                decoration: InputDecoration(
                  hintText: 'Ask a clinical question...',
                  hintStyle: const TextStyle(color: _kMuted, fontSize: 13),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: _kCard2,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: loading ? null : () => onSend(ctrl.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: loading
                      ? [_kBorder, _kBorder]
                      : [_kAccent, _kAccent2],
                ),
                borderRadius: BorderRadius.circular(21),
              ),
              child: loading
                  ? const Padding(
                      padding: EdgeInsets.all(11),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _kText))
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 — Write Rx
// ─────────────────────────────────────────────────────────────────────────────

class _RxTab extends StatefulWidget {
  final GeminiService gemini;
  final String? patientName;
  final String? patientId;
  final String? appointmentId;
  const _RxTab({
    required this.gemini,
    this.patientName,
    this.patientId,
    this.appointmentId,
  });

  @override
  State<_RxTab> createState() => _RxTabState();
}

class _RxTabState extends State<_RxTab> {
  final _sympCtrl = TextEditingController();
  final _patCtrl = TextEditingController();
  RxDraft? _draft;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.patientName != null) _patCtrl.text = widget.patientName!;
  }

  @override
  void dispose() {
    _sympCtrl.dispose();
    _patCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_sympCtrl.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _draft = null;
    });
    try {
      final d = await widget.gemini.generateRx(
        symptoms: _sympCtrl.text.trim(),
        patientContext: _patCtrl.text.trim().isNotEmpty
            ? _patCtrl.text.trim()
            : null,
      );
      if (mounted) setState(() => _draft = d);
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _rxText() {
    final d = _draft!;
    final buf = StringBuffer()
      ..writeln('PRESCRIPTION — ${_dateStr()}')
      ..writeln('Patient: ${_patCtrl.text.trim().isNotEmpty ? _patCtrl.text.trim() : "—"}')
      ..writeln('Diagnosis: ${d.diagnosis}')
      ..writeln();
    for (var i = 0; i < d.medicines.length; i++) {
      final m = d.medicines[i];
      buf.writeln('${i + 1}. ${m.name} ${m.dose} — ${m.frequency} × ${m.duration}');
      if (m.notes.isNotEmpty) buf.writeln('   ↳ ${m.notes}');
    }
    buf
      ..writeln()
      ..writeln('Advice: ${d.advice}')
      ..writeln('Follow-up: ${d.followUp}');
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('Patient & Symptoms', _kAccent2),
          const SizedBox(height: 10),
          _DarkField(
              ctrl: _patCtrl, hint: 'Patient name (optional)', icon: Icons.person_rounded),
          const SizedBox(height: 10),
          _DarkField(
            ctrl: _sympCtrl,
            hint: 'Describe symptoms, age, duration...\ne.g. 32F with 3-day fever, sore throat',
            icon: Icons.healing_rounded,
            minLines: 3,
            maxLines: 6,
          ),
          const SizedBox(height: 14),
          _GenButton(
            label: 'Generate Prescription Draft',
            icon: Icons.auto_awesome_rounded,
            color: _kAccent2,
            loading: _loading,
            onTap: _generate,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _ErrorCard(_error!),
          ],
          if (_draft != null) ...[
            const SizedBox(height: 18),
            _RxCard(
              draft: _draft!,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 12),
            _ShareRow(
              onSendToRx: () {
                final extra = {
                  'patientName': _patCtrl.text.trim().isNotEmpty
                      ? _patCtrl.text.trim()
                      : widget.patientName,
                  'patientId': widget.patientId,
                  'appointmentId': widget.appointmentId,
                  'aiDiagnosis': _draft!.diagnosis,
                };
                context.push('/doctor/rx', extra: extra);
              },
              onWhatsApp: () => _shareWa(_rxText()),
              onShare: () => Share.share(_rxText(),
                  subject: 'Prescription — ${_draft!.diagnosis}'),
              onCopy: () => _copy(context, _rxText()),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _RxCard extends StatelessWidget {
  final RxDraft draft;
  final VoidCallback onChanged;
  const _RxCard({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _AiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _SectionLabel('Diagnosis', _kAccent2),
            const Spacer(),
            _AiBadge(),
          ]),
          const SizedBox(height: 6),
          _EditableInline(
            value: draft.diagnosis,
            style: const TextStyle(
                color: _kText, fontSize: 14, fontWeight: FontWeight.w600),
            onChanged: (v) {
              draft.diagnosis = v;
              onChanged();
            },
          ),
          const SizedBox(height: 14),
          _SectionLabel('Medicines', _kAccent2),
          const SizedBox(height: 8),
          ...draft.medicines.asMap().entries.map((e) => _DrugRow(
                index: e.key,
                drug: e.value,
                onChanged: onChanged,
              )),
          const SizedBox(height: 10),
          _SectionLabel('Advice', _kAccent2),
          const SizedBox(height: 6),
          _EditableInline(
            value: draft.advice,
            onChanged: (v) {
              draft.advice = v;
              onChanged();
            },
          ),
          const SizedBox(height: 10),
          _SectionLabel('Follow-up', _kAccent2),
          const SizedBox(height: 6),
          _EditableInline(
            value: draft.followUp,
            onChanged: (v) {
              draft.followUp = v;
              onChanged();
            },
          ),
          const SizedBox(height: 8),
          const Text('⚠ AI-generated — verify before prescribing',
              style: TextStyle(color: AppColors.warning, fontSize: 10)),
        ],
      ),
    );
  }
}

class _DrugRow extends StatelessWidget {
  final int index;
  final RxDrug drug;
  final VoidCallback onChanged;
  const _DrugRow(
      {required this.index, required this.drug, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _kAccent2.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text('${index + 1}',
                      style: const TextStyle(
                          color: _kAccent2,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _EditableInline(
                  value: drug.name,
                  style: const TextStyle(
                      color: _kText,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                  onChanged: (v) {
                    drug.name = v;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _Pill('${drug.dose} ${drug.route}', _kAccent2),
              _Pill(drug.frequency, _kAccent),
              _Pill(drug.duration, AppColors.warning),
            ],
          ),
          if (drug.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(drug.notes,
                style:
                    const TextStyle(color: _kMuted, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3 — SOAP Note
// ─────────────────────────────────────────────────────────────────────────────

class _SoapTab extends StatefulWidget {
  final GeminiService gemini;
  final String? patientName;
  const _SoapTab({required this.gemini, this.patientName});

  @override
  State<_SoapTab> createState() => _SoapTabState();
}

class _SoapTabState extends State<_SoapTab> {
  final _descCtrl = TextEditingController();
  SoapNote? _note;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_descCtrl.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _note = null;
    });
    try {
      final n = await widget.gemini.generateSoap(_descCtrl.text.trim());
      if (mounted) setState(() => _note = n);
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _noteText() {
    final n = _note!;
    return 'SOAP NOTE — ${_dateStr()}\n'
        '${widget.patientName != null ? "Patient: ${widget.patientName}\n" : ""}'
        '\nS (Subjective):\n${n.subjective}'
        '\n\nO (Objective):\n${n.objective}'
        '\n\nA (Assessment):\n${n.assessment}'
        '\n\nP (Plan):\n${n.plan}';
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFFA78BFA);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('Visit Description', purple),
          const SizedBox(height: 10),
          _DarkField(
            ctrl: _descCtrl,
            hint: 'Describe the visit in plain language...\ne.g. 28F with 3-day fever, sore throat. BP 120/80, Temp 101°F.',
            icon: Icons.edit_note_rounded,
            minLines: 4,
            maxLines: 8,
          ),
          const SizedBox(height: 14),
          _GenButton(
            label: 'Generate SOAP Note',
            icon: Icons.assignment_rounded,
            color: purple,
            loading: _loading,
            onTap: _generate,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _ErrorCard(_error!),
          ],
          if (_note != null) ...[
            const SizedBox(height: 18),
            _SoapCard(
                note: _note!, onChanged: () => setState(() {})),
            const SizedBox(height: 12),
            _ShareRow(
              showSendToRx: false,
              onWhatsApp: () => _shareWa(_noteText()),
              onShare: () =>
                  Share.share(_noteText(), subject: 'SOAP Note'),
              onCopy: () => _copy(context, _noteText()),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SoapCard extends StatelessWidget {
  final SoapNote note;
  final VoidCallback onChanged;
  const _SoapCard({required this.note, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const sections = [
      (letter: 'S', title: 'Subjective', color: Color(0xFF60A5FA)),
      (letter: 'O', title: 'Objective', color: Color(0xFFA78BFA)),
      (letter: 'A', title: 'Assessment', color: _kAccent),
      (letter: 'P', title: 'Plan', color: Color(0xFFFBBF24)),
    ];

    return _AiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('SOAP Note',
                style: TextStyle(
                    color: _kText,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
            const Spacer(),
            _AiBadge(),
          ]),
          const SizedBox(height: 12),
          ...sections.map((s) {
            final value = switch (s.letter) {
              'S' => note.subjective,
              'O' => note.objective,
              'A' => note.assessment,
              _ => note.plan,
            };
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: _kDark,
                borderRadius: BorderRadius.circular(10),
                border: Border(
                    left: BorderSide(color: s.color, width: 3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: s.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                              child: Text(s.letter,
                                  style: TextStyle(
                                      color: s.color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800))),
                        ),
                        const SizedBox(width: 8),
                        Text(s.title,
                            style: TextStyle(
                                color: s.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: _EditableInline(
                      value: value,
                      onChanged: (v) {
                        switch (s.letter) {
                          case 'S':
                            note.subjective = v;
                          case 'O':
                            note.objective = v;
                          case 'A':
                            note.assessment = v;
                          case 'P':
                            note.plan = v;
                        }
                        onChanged();
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
          const Text('⚠ AI-generated — review before use',
              style: TextStyle(color: AppColors.warning, fontSize: 10)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 4 — Drug Info
// ─────────────────────────────────────────────────────────────────────────────

class _DrugInfoTab extends StatefulWidget {
  final GeminiService gemini;
  const _DrugInfoTab({required this.gemini});

  @override
  State<_DrugInfoTab> createState() => _DrugInfoTabState();
}

class _DrugInfoTabState extends State<_DrugInfoTab> {
  final _ctrl = TextEditingController();
  DrugInfo? _info;
  bool _loading = false;
  String? _error;

  static const _suggestions = [
    'Paracetamol', 'Amoxicillin', 'Metformin',
    'Atorvastatin', 'Amlodipine', 'Pantoprazole',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _info = null;
    });
    try {
      final i = await widget.gemini.lookupDrug(_ctrl.text.trim());
      if (mounted) setState(() => _info = i);
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF34D399);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('Drug Lookup', green),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DarkField(
                  ctrl: _ctrl,
                  hint: 'Drug name (e.g. Amoxicillin)',
                  icon: Icons.search_rounded,
                  onSubmitted: (_) => _lookup(),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _loading ? null : _lookup,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _loading
                          ? [_kBorder, _kBorder]
                          : [green, const Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.science_rounded,
                          color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _suggestions
                .map((s) => GestureDetector(
                      onTap: () {
                        _ctrl.text = s;
                        _lookup();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: green.withValues(alpha: 0.25),
                              width: 0.5),
                        ),
                        child: Text(s,
                            style: const TextStyle(
                                color: green, fontSize: 11)),
                      ),
                    ))
                .toList(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _ErrorCard(_error!),
          ],
          if (_info != null) ...[
            const SizedBox(height: 16),
            _DrugInfoCard(info: _info!),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _DrugInfoCard extends StatelessWidget {
  final DrugInfo info;
  const _DrugInfoCard({required this.info});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF34D399);
    return _AiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.name,
                        style: const TextStyle(
                            color: _kText,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    Text(info.drugClass,
                        style: const TextStyle(
                            color: green, fontSize: 12)),
                  ],
                ),
              ),
              _AiBadge(),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.8,
            children: [
              _InfoTile('Standard Dose', info.standardDose, green),
              _InfoTile('Max Dose', info.maxDose, green),
              _InfoTile('Frequency', info.frequency, _kAccent2),
              _InfoTile('Duration', info.duration, _kAccent2),
              _InfoTile('Pregnancy', info.pregnancyCategory,
                  AppColors.warning),
              _InfoTile('Renal Adj.', info.renalAdjustment,
                  AppColors.warning),
            ],
          ),
          const SizedBox(height: 12),
          _DarkInfoBlock(
              'Side Effects', info.sideEffects, AppColors.warning),
          const SizedBox(height: 8),
          _DarkInfoBlock('Contraindications', info.contraindications,
              AppColors.error),
          const SizedBox(height: 8),
          const Text('⚠ AI-generated — verify with pharmacopoeia',
              style: TextStyle(color: AppColors.warning, fontSize: 10)),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  final Color color;
  const _InfoTile(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _kDark,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 9, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
          Text(value,
              style: const TextStyle(
                  color: _kText, fontSize: 11, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _DarkInfoBlock extends StatelessWidget {
  final String title, content;
  final Color color;
  const _DarkInfoBlock(this.title, this.content, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: color.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(content,
              style: const TextStyle(color: _kMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 5 — Drug Interactions
// ─────────────────────────────────────────────────────────────────────────────

class _InteractionsTab extends StatefulWidget {
  final GeminiService gemini;
  const _InteractionsTab({required this.gemini});

  @override
  State<_InteractionsTab> createState() => _InteractionsTabState();
}

class _InteractionsTabState extends State<_InteractionsTab> {
  final _drugs = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
  ];
  InteractionResult? _result;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _drugs) { c.dispose(); }
    super.dispose();
  }

  Future<void> _check() async {
    final names =
        _drugs.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    if (names.length < 2) return;
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final r = await widget.gemini.checkInteractions(names);
      if (mounted) setState(() => _result = r);
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFBBF24);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SectionLabel('Drugs to Check', yellow),
              const Spacer(),
              if (_drugs.length < 5)
                GestureDetector(
                  onTap: () =>
                      setState(() => _drugs.add(TextEditingController())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: yellow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: yellow.withValues(alpha: 0.3),
                          width: 0.5),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_rounded, color: yellow, size: 14),
                        SizedBox(width: 4),
                        Text('Add drug',
                            style: TextStyle(
                                color: yellow, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ..._drugs.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _DarkField(
                        ctrl: e.value,
                        hint: 'Drug ${e.key + 1} (e.g. Warfarin)',
                        icon: Icons.medication_rounded,
                      ),
                    ),
                    if (e.key >= 2) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() {
                          e.value.dispose();
                          _drugs.removeAt(e.key);
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.remove_rounded,
                              color: AppColors.error, size: 16),
                        ),
                      ),
                    ],
                  ],
                ),
              )),
          const SizedBox(height: 14),
          _GenButton(
            label: 'Check Interactions',
            icon: Icons.warning_rounded,
            color: yellow,
            loading: _loading,
            onTap: _check,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _ErrorCard(_error!),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            _InteractionResultCard(result: _result!),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _InteractionResultCard extends StatelessWidget {
  final InteractionResult result;
  const _InteractionResultCard({required this.result});

  Color get _color => switch (result.overallSeverity) {
        'major' => AppColors.error,
        'caution' => AppColors.warning,
        _ => _kAccent,
      };

  @override
  Widget build(BuildContext context) {
    return _AiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('Interaction Analysis',
                style: TextStyle(
                    color: _kText,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
            const Spacer(),
            _AiBadge(),
          ]),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: _color.withValues(alpha: 0.3), width: 0.5),
            ),
            child: Row(
              children: [
                Icon(
                  result.overallSeverity == 'major'
                      ? Icons.dangerous_rounded
                      : result.overallSeverity == 'caution'
                          ? Icons.warning_rounded
                          : Icons.check_circle_rounded,
                  color: _color,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.overallSeverity.toUpperCase(),
                        style: TextStyle(
                            color: _color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 2),
                      Text(result.summary,
                          style: const TextStyle(
                              color: _kMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (result.pairs.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...result.pairs.map((p) => _PairRow(pair: p)),
          ],
          const SizedBox(height: 6),
          const Text(
              '⚠ Always verify with a pharmacist for critical decisions.',
              style: TextStyle(color: AppColors.warning, fontSize: 10)),
        ],
      ),
    );
  }
}

class _PairRow extends StatelessWidget {
  final InteractionPair pair;
  const _PairRow({required this.pair});

  Color get _color => switch (pair.severity) {
        'major' => AppColors.error,
        'caution' => AppColors.warning,
        _ => _kAccent,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _kDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${pair.drug1} + ${pair.drug2}',
                    style: const TextStyle(
                        color: _kText,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(pair.severity.toUpperCase(),
                    style: TextStyle(
                        color: _color,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(pair.effect,
              style: const TextStyle(color: _kMuted, fontSize: 11)),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.arrow_right_rounded,
                  color: _kAccent, size: 14),
              Expanded(
                child: Text('Action: ${pair.action}',
                    style: const TextStyle(
                        color: _kAccent, fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _AiCard extends StatelessWidget {
  final Widget child;
  const _AiCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder, width: 0.5),
      ),
      child: child,
    );
  }
}

class _AiBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_kAccent, _kAccent2]),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 8),
          SizedBox(width: 3),
          Text('AI',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3),
    );
  }
}

class _DarkField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;
  const _DarkField({
    required this.ctrl,
    required this.hint,
    required this.icon,
    this.minLines = 1,
    this.maxLines = 1,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder, width: 0.5),
      ),
      child: TextField(
        controller: ctrl,
        minLines: minLines,
        maxLines: maxLines == 1 ? null : maxLines,
        style: const TextStyle(color: _kText, fontSize: 13),
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _kMuted, fontSize: 12),
          prefixIcon: Icon(icon, color: _kMuted, size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}

class _GenButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool loading;
  final VoidCallback onTap;
  const _GenButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: loading
                ? [_kBorder, _kBorder]
                : [color, color.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            else
              Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              loading ? 'Generating...' : label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareRow extends StatelessWidget {
  final VoidCallback? onSendToRx;
  final VoidCallback onWhatsApp;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final bool showSendToRx;
  const _ShareRow({
    this.onSendToRx,
    required this.onWhatsApp,
    required this.onShare,
    required this.onCopy,
    this.showSendToRx = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showSendToRx && onSendToRx != null)
          GestureDetector(
            onTap: onSendToRx,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('Send to Prescription Writer',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
                child: _SmallBtn(
                    'WhatsApp', Icons.chat_rounded,
                    const Color(0xFF25D366), onWhatsApp)),
            const SizedBox(width: 8),
            Expanded(
                child: _SmallBtn(
                    'Share', Icons.share_rounded, _kAccent2, onShare)),
            const SizedBox(width: 8),
            Expanded(
                child: _SmallBtn(
                    'Copy', Icons.copy_rounded, _kMuted, onCopy)),
          ],
        ),
      ],
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallBtn(this.label, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: color.withValues(alpha: 0.25), width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: AppColors.error, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: color.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w500)),
    );
  }
}

class _EditableInline extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final TextStyle? style;
  const _EditableInline({
    required this.value,
    required this.onChanged,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(text: value);
    return TextField(
      controller: ctrl,
      style: style ?? const TextStyle(color: _kMuted, fontSize: 13),
      maxLines: null,
      onChanged: onChanged,
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

String _dateStr() {
  final n = DateTime.now();
  const m = ['Jan','Feb','Mar','Apr','May','Jun',
              'Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${n.day} ${m[n.month - 1]} ${n.year}';
}

void _shareWa(String text) {
  launchUrl(
    Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}'),
    mode: LaunchMode.externalApplication,
  );
}

void _copy(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
        content: Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2)),
  );
}

String _friendlyError(Object e) {
  final s = e.toString().toLowerCase();
  if (s.contains('quota') || s.contains('exceeded') || s.contains('429') || s.contains('resource_exhausted')) {
    return 'AI quota exceeded on the server. The Gemini key needs to be rotated (Supabase secret GEMINI_API_KEY).';
  }
  if (s.contains('network') || s.contains('socket') || s.contains('socketexception')) {
    return 'No internet connection.';
  }
  if (s.contains('api_key') || s.contains('401') || s.contains('403') || s.contains('invalid') && s.contains('key')) {
    return 'API key invalid or expired. Get a new key at aistudio.google.com/app/apikey.';
  }
  if (s.contains('400')) return 'Bad request — check your input and try again.';
  if (s.contains('cors') || s.contains('xmlhttprequest') || s.contains('failed to fetch')) {
    return 'AI unavailable on web (CORS). Use the mobile app for full AI access.';
  }
  final trimmed = e.toString();
  return trimmed.length > 100 ? '${trimmed.substring(0, 100)}…' : trimmed;
}

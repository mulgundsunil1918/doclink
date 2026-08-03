import 'package:flutter/material.dart';
import '../../../../shared/widgets/dl_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/prescription_template.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';

class PrescriptionTemplateSettingsScreen extends ConsumerStatefulWidget {
  const PrescriptionTemplateSettingsScreen({super.key});

  @override
  ConsumerState<PrescriptionTemplateSettingsScreen> createState() =>
      _PrescriptionTemplateSettingsScreenState();
}

class _PrescriptionTemplateSettingsScreenState
    extends ConsumerState<PrescriptionTemplateSettingsScreen> {
  late PrescriptionSettings _settings;
  bool _saving = false;
  bool _loaded = false;

  // Text controllers
  final _clinicNameCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _hotlineCtrl = TextEditingController();
  final _degreesCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();

  static const _presetColors = [
    Color(0xFF1D4ED8), // blue
    Color(0xFF059669), // emerald
    Color(0xFF7C3AED), // violet
    Color(0xFFDC2626), // red
    Color(0xFF0F766E), // teal
    Color(0xFF92400E), // amber-brown
  ];

  static const _refillOptions = ['None', '1', '2', '3'];
  static const _followupOptions = [
    '3 Days', '7 Days', '14 Days', '1 Month', 'As Needed'
  ];

  @override
  void dispose() {
    _clinicNameCtrl.dispose();
    _taglineCtrl.dispose();
    _websiteCtrl.dispose();
    _emailCtrl.dispose();
    _hotlineCtrl.dispose();
    _degreesCtrl.dispose();
    _emergencyCtrl.dispose();
    super.dispose();
  }

  void _initFromDoctor(AppDoctor doc) {
    if (_loaded) return;
    _loaded = true;
    _settings = doc.prescriptionSettings;
    _clinicNameCtrl.text = _settings.clinicName;
    _taglineCtrl.text = _settings.clinicTagline;
    _websiteCtrl.text = _settings.clinicWebsite;
    _emailCtrl.text = _settings.clinicEmail;
    _hotlineCtrl.text = _settings.clinicHotline;
    _degreesCtrl.text = _settings.degrees;
    _emergencyCtrl.text = _settings.emergencyText;
  }

  Future<void> _save() async {
    final doc = ref.read(currentDoctorProvider).valueOrNull;
    if (doc == null) return;
    setState(() => _saving = true);
    final updated = _settings.copyWith(
      clinicName: _clinicNameCtrl.text.trim(),
      clinicTagline: _taglineCtrl.text.trim(),
      clinicWebsite: _websiteCtrl.text.trim(),
      clinicEmail: _emailCtrl.text.trim(),
      clinicHotline: _hotlineCtrl.text.trim(),
      degrees: _degreesCtrl.text.trim(),
      emergencyText: _emergencyCtrl.text.trim(),
    );
    try {
      await updateDoctorProfile(
        uid: doc.id,
        prescriptionSettings: updated,
      );
      ref.invalidate(currentDoctorProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorAsync = ref.watch(currentDoctorProvider);
    return doctorAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: DlLoader())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (doc) {
        if (doc != null) _initFromDoctor(doc);
        return _buildBody(context, doc);
      },
    );
  }

  Widget _buildBody(BuildContext context, AppDoctor? doc) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Template'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 18,
                  height: 18,
                  child: DlLoader()),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Save',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.doctorPrimary)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('A — Clinic Header'),
          _field('Clinic Name', _clinicNameCtrl,
              hint: 'e.g. Dr. Mulgund\'s Clinic'),
          _field('Tagline', _taglineCtrl,
              hint: 'TELEHEALTH MEDICAL SERVICES'),
          _field('Website', _websiteCtrl, hint: 'https://yourclinic.com'),
          _field('Email', _emailCtrl, hint: 'support@yourclinic.com'),
          _field('Hotline Label', _hotlineCtrl,
              hint: '24/7 Digital Care'),
          const SizedBox(height: 8),
          _label('Header Colour'),
          const SizedBox(height: 8),
          _ColorPicker(
            selected: _settings.headerColor,
            presets: _presetColors,
            onChanged: (c) => setState(() {
              _settings = _settings.copyWith(headerColor: c);
            }),
          ),
          const SizedBox(height: 20),
          _SectionHeader('B — Doctor Identity'),
          _field('Degrees / Qualifications', _degreesCtrl,
              hint: 'MBBS, MD, DNB'),
          if (doc?.registrationNo != null) ...[
            const SizedBox(height: 4),
            Text(
              'Registration No: ${doc!.registrationNo}  (edit in Profile)',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 20),
          _SectionHeader('C — Section Visibility'),
          SwitchListTile(
            title: const Text('Show Vitals block'),
            subtitle:
                const Text('Temp / BP / HR / Notes on the prescription'),
            value: _settings.showVitals,
            onChanged: (v) =>
                setState(() => _settings = _settings.copyWith(showVitals: v)),
            activeThumbColor: AppColors.doctorPrimary,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Show History / HPI block'),
            subtitle: const Text('History of Present Illness'),
            value: _settings.showHistory,
            onChanged: (v) => setState(
                () => _settings = _settings.copyWith(showHistory: v)),
            activeThumbColor: AppColors.doctorPrimary,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Show Advice & Diet block'),
            subtitle: const Text('Diet, lab tests ordered'),
            value: _settings.showAdvice,
            onChanged: (v) => setState(
                () => _settings = _settings.copyWith(showAdvice: v)),
            activeThumbColor: AppColors.doctorPrimary,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Show Emergency Warning'),
            subtitle: const Text('Red-flag instruction at the bottom'),
            value: _settings.showEmergency,
            onChanged: (v) => setState(
                () => _settings = _settings.copyWith(showEmergency: v)),
            activeThumbColor: AppColors.doctorPrimary,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 20),
          _SectionHeader('D — Defaults'),
          _label('Default Refills'),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: _refillOptions
                .map((o) => ButtonSegment(value: o, label: Text(o)))
                .toList(),
            selected: {_settings.defaultRefills},
            onSelectionChanged: (s) => setState(
                () => _settings = _settings.copyWith(defaultRefills: s.first)),
            style: SegmentedButton.styleFrom(
                selectedBackgroundColor:
                    AppColors.doctorPrimary.withValues(alpha: 0.15),
                selectedForegroundColor: AppColors.doctorPrimary),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Substitution Allowed by default'),
            value: _settings.defaultSubstitution,
            onChanged: (v) => setState(
                () => _settings = _settings.copyWith(defaultSubstitution: v)),
            activeThumbColor: AppColors.doctorPrimary,
            contentPadding: EdgeInsets.zero,
          ),
          _label('Default Follow-up'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _settings.defaultFollowup,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: _followupOptions
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(
                    () => _settings = _settings.copyWith(defaultFollowup: v));
              }
            },
          ),
          const SizedBox(height: 16),
          _label('Emergency Warning Text'),
          const SizedBox(height: 8),
          TextField(
            controller: _emergencyCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Red flag instruction shown on prescriptions...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {String hint = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            decoration: InputDecoration(
              hintText: hint,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87));
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.doctorPrimary,
                  letterSpacing: 0.3)),
          const SizedBox(height: 6),
          Divider(
              height: 1, color: AppColors.doctorPrimary.withValues(alpha: 0.25)),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final Color selected;
  final List<Color> presets;
  final ValueChanged<Color> onChanged;
  const _ColorPicker(
      {required this.selected,
      required this.presets,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        ...presets.map((c) => GestureDetector(
              onTap: () => onChanged(c),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected == c ? Colors.black87 : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: selected == c
                      ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 8)]
                      : null,
                ),
                child: selected == c
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            )),
        GestureDetector(
          onTap: () => _showHexDialog(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: const Icon(Icons.add, size: 20, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  void _showHexDialog(BuildContext context) {
    final ctrl = TextEditingController(
        text: '#${(selected.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter hex colour'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: '#1D4ED8'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final h = ctrl.text.trim().replaceFirst('#', '');
              if (h.length == 6) {
                try {
                  onChanged(Color(int.parse('FF$h', radix: 16)));
                  Navigator.pop(context);
                } catch (_) {}
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/models/prescription_template.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';
import '../../../../core/services/prescription_pdf_service.dart';

// ── Common medicine name suggestions ────────────────────────────────────────
const _kMedicines = [
  'Paracetamol', 'Amoxicillin', 'Ibuprofen', 'Cetirizine',
  'Pantoprazole', 'Metformin', 'Atorvastatin', 'Omeprazole',
  'Dolo 650', 'Azithromycin', 'Ciprofloxacin', 'Metronidazole',
  'Cefixime', 'Ranitidine', 'Montelukast', 'Losartan',
  'Amlodipine', 'Aspirin', 'Vitamin D3', 'Vitamin B12',
  'Iron + Folic Acid', 'Calcium', 'Multivitamin', 'Prednisolone',
  'Salbutamol', 'Budesonide', 'Levocetirizine', 'Domperidone',
  'Ondansetron', 'Diclofenac', 'Tramadol', 'Amitriptyline',
];

const _kDosages = ['½ tablet', '1 tablet', '2 tablets', '5 ml', '10 ml', '15 ml', '1 capsule', '2 capsules'];
const _kRoutes = ['Oral', 'IV', 'IM', 'Topical', 'Inhaled', 'Sublingual', 'Nasal drops', 'Eye drops'];
const _kFrequencies = ['Once daily', 'Twice daily', 'Thrice daily', 'Four times daily', 'Once at night', 'SOS / As needed'];
const _kTimings = ['Before meals', 'After meals', 'With meals', 'At bedtime', 'Empty stomach', 'Any time'];
const _kDurations = ['3 days', '5 days', '7 days', '10 days', '14 days', '30 days', 'Ongoing'];
const _kRefills = ['None', '1', '2', '3'];
const _kFollowups = ['3 Days', '7 Days', '14 Days', '1 Month', 'As Needed'];

// ── Rx entry model ────────────────────────────────────────────────────────────
class _RxEntry {
  String name;
  String strength;
  String dosage;
  String route;
  String frequency;
  String timing;
  String duration;
  String instructions;

  _RxEntry({
    this.name = '',
    this.strength = '',
    this.dosage = '1 tablet',
    this.route = 'Oral',
    this.frequency = 'Twice daily',
    this.timing = 'After meals',
    this.duration = '5 days',
    this.instructions = '',
  });
}

// ── Screen ────────────────────────────────────────────────────────────────────
class PrescriptionWriterScreen extends ConsumerStatefulWidget {
  final String? patientName;
  final String? patientId;
  final String? appointmentId;
  final AppPatient? patient;

  const PrescriptionWriterScreen({
    super.key,
    this.patientName,
    this.patientId,
    this.appointmentId,
    this.patient,
  });

  @override
  ConsumerState<PrescriptionWriterScreen> createState() =>
      _PrescriptionWriterScreenState();
}

class _PrescriptionWriterScreenState
    extends ConsumerState<PrescriptionWriterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _gemini = GeminiService();
  bool _isSaving = false;
  bool _isAiFilling = false;

  // ── Tab 1: Patient ──
  final _ptNameCtrl = TextEditingController();
  final _ptAgeCtrl = TextEditingController();
  final _ptGenderCtrl = TextEditingController();
  final _ptDobCtrl = TextEditingController();
  final _ptContactCtrl = TextEditingController();
  final _ptLocationCtrl = TextEditingController();

  // ── Tab 2: Clinical ──
  final List<TextEditingController> _chiefCtrls = [TextEditingController()];
  final List<TextEditingController> _historyCtrls = [TextEditingController()];
  final _tempCtrl = TextEditingController();
  final _bpCtrl = TextEditingController();
  final _hrCtrl = TextEditingController();
  final _vitalsNotesCtrl = TextEditingController();
  final _primaryDxCtrl = TextEditingController();
  final _secondaryDxCtrl = TextEditingController();

  // ── Tab 3: Rx ──
  final List<_RxEntry> _medicines = [_RxEntry()];
  AppAppointment? _selectedAppointment;

  // ── Tab 4: Advice ──
  final _adviceDietCtrl = TextEditingController();
  final _labTestsCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();
  String _refills = 'None';
  bool _substitutionAllowed = true;
  String _followUp = '3 Days';

  // ── Appointment picker (linked patient) ──
  String? _linkedPatientId;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
    _linkedPatientId = widget.patientId;

    // Pre-fill from passed patient
    if (widget.patient != null) {
      final p = widget.patient!;
      _ptNameCtrl.text = p.name;
      if (p.age != null) _ptAgeCtrl.text = p.age.toString();
      if (p.gender != null) _ptGenderCtrl.text = p.gender!;
      if (p.phone != null) _ptContactCtrl.text = p.phone!;
    } else if (widget.patientName != null) {
      _ptNameCtrl.text = widget.patientName!;
    }

    // Set defaults from doctor's template (loaded after first frame)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doc = ref.read(currentDoctorProvider).valueOrNull;
      if (doc != null) _applyTemplateDefaults(doc.prescriptionSettings);
    });
  }

  void _applyTemplateDefaults(PrescriptionSettings s) {
    if (!mounted) return;
    setState(() {
      _refills = s.defaultRefills;
      _substitutionAllowed = s.defaultSubstitution;
      _followUp = s.defaultFollowup;
      if (_emergencyCtrl.text.isEmpty) _emergencyCtrl.text = s.emergencyText;
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _ptNameCtrl.dispose();
    _ptAgeCtrl.dispose();
    _ptGenderCtrl.dispose();
    _ptDobCtrl.dispose();
    _ptContactCtrl.dispose();
    _ptLocationCtrl.dispose();
    for (final c in _chiefCtrls) c.dispose();
    for (final c in _historyCtrls) c.dispose();
    _tempCtrl.dispose();
    _bpCtrl.dispose();
    _hrCtrl.dispose();
    _vitalsNotesCtrl.dispose();
    _primaryDxCtrl.dispose();
    _secondaryDxCtrl.dispose();
    _adviceDietCtrl.dispose();
    _labTestsCtrl.dispose();
    _emergencyCtrl.dispose();
    _gemini.dispose();
    super.dispose();
  }

  // ── Save ─────────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    final doc = ref.read(currentDoctorProvider).valueOrNull;
    if (doc == null) return;

    final diagnosis = _primaryDxCtrl.text.trim();
    if (diagnosis.isEmpty) {
      _tabs.animateTo(1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a primary diagnosis')),
      );
      return;
    }

    final patId = _linkedPatientId;
    if (patId == null || patId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or link a patient')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final extended = ExtendedRxData(
        chiefComplaints: _chiefCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
        history: _historyCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
        vitals: {
          'temp': _tempCtrl.text.trim(),
          'bp': _bpCtrl.text.trim(),
          'hr': _hrCtrl.text.trim(),
          'notes': _vitalsNotesCtrl.text.trim(),
        },
        secondaryDiagnosis: _secondaryDxCtrl.text.trim(),
        adviceDiet: _adviceDietCtrl.text.trim(),
        labTests: _labTestsCtrl.text.trim(),
        refills: _refills,
        emergencyText: _emergencyCtrl.text.trim(),
        substitutionAllowed: _substitutionAllowed,
      );

      await savePrescription(
        doctorId: doc.id,
        patientId: patId,
        diagnosis: diagnosis,
        notes: _adviceDietCtrl.text.trim().isNotEmpty ? _adviceDietCtrl.text.trim() : null,
        followUpDate: _followUp != 'As Needed' ? _resolveFollowUp(_followUp) : null,
        appointmentId: widget.appointmentId ?? _selectedAppointment?.id,
        medicines: _medicines
            .where((m) => m.name.isNotEmpty)
            .map((m) => {
                  'name': m.name,
                  'strength': m.strength,
                  'dosage': m.dosage,
                  'route': m.route,
                  'frequency': m.frequency,
                  'duration': m.duration,
                  'instructions': m.instructions,
                })
            .toList(),
        extendedData: extended,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  DateTime? _resolveFollowUp(String label) {
    final now = DateTime.now();
    switch (label) {
      case '3 Days': return now.add(const Duration(days: 3));
      case '7 Days': return now.add(const Duration(days: 7));
      case '14 Days': return now.add(const Duration(days: 14));
      case '1 Month': return DateTime(now.year, now.month + 1, now.day);
      default: return null;
    }
  }

  // ── AI Fill ──────────────────────────────────────────────────────────────────
  void _showAiFillSheet() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: const BoxDecoration(
                        color: Color(0xFFD97706), shape: BoxShape.circle),
                    child: const Icon(Icons.bolt, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Fill', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        Text('Describe the case — AI fills all sections', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                maxLines: 5,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. 7yr girl, ear pain 2 days, fever 100.4F, right TM erythema. Likely acute otitis media.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isAiFilling
                      ? null
                      : () async {
                          final text = ctrl.text.trim();
                          if (text.isEmpty) return;
                          setSheet(() => _isAiFilling = true);
                          try {
                            final ctx = _ptNameCtrl.text.isNotEmpty
                                ? 'Patient: ${_ptNameCtrl.text}, Age: ${_ptAgeCtrl.text}, Gender: ${_ptGenderCtrl.text}'
                                : null;
                            final result = await _gemini.generateFullRx(
                                doctorInput: text, patientContext: ctx);
                            _applyAiResult(result);
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('AI filled the prescription — please review each section')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('AI error: $e')),
                              );
                            }
                          } finally {
                            setSheet(() => _isAiFilling = false);
                          }
                        },
                  icon: _isAiFilling
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.bolt),
                  label: Text(_isAiFilling ? 'Generating...' : 'Generate with AI ⚡'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _applyAiResult(Map<String, dynamic> data) {
    if (!mounted) return;
    setState(() {
      // Primary diagnosis
      final diag = data['primaryDiagnosis'] as String? ?? '';
      if (diag.isNotEmpty) _primaryDxCtrl.text = diag;

      // Secondary diagnosis
      final sec = data['secondaryDiagnosis'] as String? ?? '';
      if (sec.isNotEmpty) _secondaryDxCtrl.text = sec;

      // Chief complaints
      final cc = (data['chiefComplaints'] as List? ?? []).map((e) => e.toString()).toList();
      if (cc.isNotEmpty) {
        for (int i = _chiefCtrls.length; i < cc.length; i++) {
          _chiefCtrls.add(TextEditingController());
        }
        for (int i = 0; i < cc.length && i < _chiefCtrls.length; i++) {
          _chiefCtrls[i].text = cc[i];
        }
      }

      // History
      final hist = (data['history'] as List? ?? []).map((e) => e.toString()).toList();
      if (hist.isNotEmpty) {
        for (int i = _historyCtrls.length; i < hist.length; i++) {
          _historyCtrls.add(TextEditingController());
        }
        for (int i = 0; i < hist.length && i < _historyCtrls.length; i++) {
          _historyCtrls[i].text = hist[i];
        }
      }

      // Vitals
      final vitals = data['vitals'] as Map? ?? {};
      _tempCtrl.text = vitals['temp']?.toString() ?? '';
      _bpCtrl.text = vitals['bp']?.toString() ?? '';
      _hrCtrl.text = vitals['hr']?.toString() ?? '';
      _vitalsNotesCtrl.text = vitals['notes']?.toString() ?? '';

      // Medicines
      final meds = (data['medicines'] as List? ?? []);
      if (meds.isNotEmpty) {
        _medicines.clear();
        for (final m in meds) {
          _medicines.add(_RxEntry(
            name: m['name']?.toString() ?? '',
            strength: m['strength']?.toString() ?? '',
            dosage: m['dosage']?.toString() ?? '1 tablet',
            route: m['route']?.toString() ?? 'Oral',
            frequency: m['frequency']?.toString() ?? 'Twice daily',
            timing: m['timing']?.toString() ?? 'After meals',
            duration: m['duration']?.toString() ?? '5 days',
            instructions: m['instructions']?.toString() ?? '',
          ));
        }
        if (_medicines.isEmpty) _medicines.add(_RxEntry());
      }

      // Advice
      _adviceDietCtrl.text = data['adviceDiet']?.toString() ?? '';
      _labTestsCtrl.text = data['labTests']?.toString() ?? '';

      // Follow-up
      final fu = data['followUp']?.toString() ?? '';
      if (_kFollowups.contains(fu)) _followUp = fu;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Prescription'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(icon: Icon(Icons.person_outline, size: 18), text: 'Patient'),
            Tab(icon: Icon(Icons.assignment_outlined, size: 18), text: 'Clinical'),
            Tab(icon: Icon(Icons.medication_outlined, size: 18), text: 'Rx ℞'),
            Tab(icon: Icon(Icons.lightbulb_outline, size: 18), text: 'Advice'),
            Tab(icon: Icon(Icons.visibility_outlined, size: 18), text: 'Preview'),
          ],
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Save',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildPatientTab(),
          _buildClinicalTab(),
          _buildRxTab(),
          _buildAdviceTab(),
          _buildPreviewTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAiFillSheet,
        backgroundColor: const Color(0xFFD97706),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.bolt),
        label: const Text('AI Fill',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── Tab 1: Patient ────────────────────────────────────────────────────────────
  Widget _buildPatientTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (_linkedPatientId == null) _buildAppointmentPicker(),
        _field('Patient Name *', _ptNameCtrl),
        _row([
          _field('Age', _ptAgeCtrl, keyboard: TextInputType.number),
          _field('Gender', _ptGenderCtrl, hint: 'Male / Female / Other'),
        ]),
        _field('Date of Birth', _ptDobCtrl, hint: 'DD-MMM-YYYY'),
        _field('Contact / Email', _ptContactCtrl, keyboard: TextInputType.emailAddress),
        _field('Location', _ptLocationCtrl, hint: 'City / Remote'),
      ],
    );
  }

  Widget _buildAppointmentPicker() {
    final apptAsync = ref.watch(todayQueueProvider);
    return apptAsync.when(
      loading: () => const SizedBox(),
      error: (_, _) => const SizedBox(),
      data: (appts) {
        final active = appts
            .where((a) => a.status != 'cancelled' && a.status != 'completed')
            .toList();
        if (active.isEmpty) return const SizedBox();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Link to today's appointment (optional)",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<AppAppointment>(
                value: _selectedAppointment,
                decoration: InputDecoration(
                  hintText: 'Select patient from today',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: active.map((a) => DropdownMenuItem(
                  value: a,
                  child: Text(a.patientName ?? 'Token ${a.tokenNo ?? "—"}',
                      overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (a) {
                  if (a == null) return;
                  setState(() {
                    _selectedAppointment = a;
                    _linkedPatientId = a.patientId;
                    if (a.patientName != null) _ptNameCtrl.text = a.patientName!;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 2: Clinical ───────────────────────────────────────────────────────────
  Widget _buildClinicalTab() {
    final doc = ref.watch(currentDoctorProvider).valueOrNull;
    final s = doc?.prescriptionSettings ?? PrescriptionSettings.defaults;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _SectionLabel('Chief Complaint'),
        ..._chiefCtrls.asMap().entries.map((e) => _bulletRow(
              e.value,
              canRemove: _chiefCtrls.length > 1,
              onRemove: () => setState(() {
                _chiefCtrls[e.key].dispose();
                _chiefCtrls.removeAt(e.key);
              }),
            )),
        _addBulletBtn('Add Complaint',
            () => setState(() => _chiefCtrls.add(TextEditingController()))),
        const SizedBox(height: 16),
        if (s.showHistory) ...[
          _SectionLabel('History / HPI'),
          ..._historyCtrls.asMap().entries.map((e) => _bulletRow(
                e.value,
                canRemove: _historyCtrls.length > 1,
                onRemove: () => setState(() {
                  _historyCtrls[e.key].dispose();
                  _historyCtrls.removeAt(e.key);
                }),
              )),
          _addBulletBtn('Add History Point',
              () => setState(() => _historyCtrls.add(TextEditingController()))),
          const SizedBox(height: 16),
        ],
        if (s.showVitals) ...[
          _SectionLabel('Vitals'),
          Row(
            children: [
              Expanded(child: _field('Temp (°F)', _tempCtrl, hint: '98.6')),
              const SizedBox(width: 10),
              Expanded(child: _field('BP (mmHg)', _bpCtrl, hint: '120/80')),
              const SizedBox(width: 10),
              Expanded(child: _field('HR (bpm)', _hrCtrl, hint: '72')),
            ],
          ),
          _field('Vitals Notes', _vitalsNotesCtrl, hint: 'SpO2, weight, etc.'),
          const SizedBox(height: 16),
        ],
        _SectionLabel('Diagnosis'),
        _field('Primary Diagnosis *', _primaryDxCtrl,
            hint: 'e.g. Acute Otitis Media'),
        _field('Secondary Diagnosis', _secondaryDxCtrl,
            hint: 'e.g. Iron Deficiency Anemia'),
      ],
    );
  }

  // ── Tab 3: Rx ─────────────────────────────────────────────────────────────────
  Widget _buildRxTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        ..._medicines.asMap().entries.map((e) => _MedicineCard(
              index: e.key,
              entry: e.value,
              canRemove: _medicines.length > 1,
              onRemove: () => setState(() => _medicines.removeAt(e.key)),
              onChanged: () => setState(() {}),
            )),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => setState(() => _medicines.add(_RxEntry())),
          icon: const Icon(Icons.add),
          label: const Text('Add Medicine'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.doctorPrimary,
            side: const BorderSide(color: AppColors.doctorPrimary),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  // ── Tab 4: Advice ─────────────────────────────────────────────────────────────
  Widget _buildAdviceTab() {
    final doc = ref.watch(currentDoctorProvider).valueOrNull;
    final s = doc?.prescriptionSettings ?? PrescriptionSettings.defaults;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (s.showAdvice) ...[
          _SectionLabel('Advice & Instructions'),
          _field('Diet / Lifestyle', _adviceDietCtrl,
              maxLines: 3, hint: 'Plenty of fluids, soft diet, rest...'),
          _field('Lab Tests Ordered', _labTestsCtrl,
              maxLines: 2, hint: 'CBC, CRP, Urine R/E...'),
          const SizedBox(height: 8),
        ],
        if (s.showEmergency) ...[
          _SectionLabel('Emergency Warning'),
          TextField(
            controller: _emergencyCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Red-flag instruction...',
              filled: true,
              fillColor: Colors.red.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red.shade200),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 16),
        ],
        _SectionLabel('Dispensing'),
        _label('Refills'),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: _kRefills
              .map((o) => ButtonSegment(value: o, label: Text(o)))
              .toList(),
          selected: {_refills},
          onSelectionChanged: (s) => setState(() => _refills = s.first),
          style: SegmentedButton.styleFrom(
              selectedBackgroundColor:
                  AppColors.doctorPrimary.withValues(alpha: 0.15),
              selectedForegroundColor: AppColors.doctorPrimary),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Substitution Allowed'),
          value: _substitutionAllowed,
          onChanged: (v) => setState(() => _substitutionAllowed = v),
          activeThumbColor: AppColors.doctorPrimary,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        _label('Follow-up'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _followUp,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: _kFollowups
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) { if (v != null) setState(() => _followUp = v); },
        ),
      ],
    );
  }

  // ── Tab 5: Preview ────────────────────────────────────────────────────────────
  Widget _buildPreviewTab() {
    final doctorAsync = ref.watch(currentDoctorProvider);
    return doctorAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text('Could not load doctor info')),
      data: (doc) {
        if (doc == null) return const Center(child: Text('Not logged in'));
        final extended = ExtendedRxData(
          chiefComplaints: _chiefCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
          history: _historyCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
          vitals: {
            'temp': _tempCtrl.text.trim(),
            'bp': _bpCtrl.text.trim(),
            'hr': _hrCtrl.text.trim(),
            'notes': _vitalsNotesCtrl.text.trim(),
          },
          secondaryDiagnosis: _secondaryDxCtrl.text.trim(),
          adviceDiet: _adviceDietCtrl.text.trim(),
          labTests: _labTestsCtrl.text.trim(),
          refills: _refills,
          emergencyText: _emergencyCtrl.text.trim(),
          substitutionAllowed: _substitutionAllowed,
        );

        final dummyRx = AppPrescription(
          id: 'preview',
          doctorId: doc.id,
          patientId: _linkedPatientId ?? '',
          diagnosis: _primaryDxCtrl.text.trim().isNotEmpty
              ? _primaryDxCtrl.text.trim()
              : '(Primary diagnosis)',
          notes: _adviceDietCtrl.text.trim(),
          verificationCode: 'E-RX-PREVIEW',
          createdAt: DateTime.now(),
          followUpDate: _resolveFollowUp(_followUp),
          medicines: _medicines
              .where((m) => m.name.isNotEmpty)
              .map((m) => AppMedicine(
                    id: '',
                    name: m.name,
                    dosage: m.dosage,
                    frequency: m.frequency,
                    duration: m.duration,
                    instructions: m.instructions.isNotEmpty ? m.instructions : null,
                    strength: m.strength.isNotEmpty ? m.strength : null,
                    route: m.route,
                  ))
              .toList(),
          extended: extended,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Preview card
              _PreviewCard(
                rx: dummyRx,
                doctor: doc,
                patientName: _ptNameCtrl.text.isNotEmpty
                    ? _ptNameCtrl.text
                    : 'Patient Name',
                patientAge: _ptAgeCtrl.text,
                patientGender: _ptGenderCtrl.text,
                patientContact: _ptContactCtrl.text,
                patientLocation: _ptLocationCtrl.text,
              ),
              const SizedBox(height: 20),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final svc = PrescriptionPdfService();
                        final bytes = await svc.generate(
                          dummyRx, doc, doc.prescriptionSettings,
                          patientName: _ptNameCtrl.text,
                          patientAge: _ptAgeCtrl.text,
                          patientGender: _ptGenderCtrl.text,
                          patientContact: _ptContactCtrl.text,
                          patientLocation: _ptLocationCtrl.text,
                        );
                        await svc.share(bytes, 'Rx-Preview.pdf');
                      },
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Download PDF'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final svc = PrescriptionPdfService();
                        final bytes = await svc.generate(
                          dummyRx, doc, doc.prescriptionSettings,
                          patientName: _ptNameCtrl.text,
                          patientAge: _ptAgeCtrl.text,
                          patientGender: _ptGenderCtrl.text,
                          patientContact: _ptContactCtrl.text,
                          patientLocation: _ptLocationCtrl.text,
                        );
                        await svc.printPdf(bytes);
                      },
                      icon: const Icon(Icons.print_outlined, size: 18),
                      label: const Text('Print'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final svc = PrescriptionPdfService();
                    final bytes = await svc.generate(
                      dummyRx, doc, doc.prescriptionSettings,
                      patientName: _ptNameCtrl.text,
                      patientAge: _ptAgeCtrl.text,
                      patientGender: _ptGenderCtrl.text,
                      patientContact: _ptContactCtrl.text,
                      patientLocation: _ptLocationCtrl.text,
                    );
                    final phone = _ptContactCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
                    try {
                      // Try WhatsApp file share via share_plus
                      await svc.share(
                        bytes,
                        'Rx-${dummyRx.id.substring(0, 8)}.pdf',
                      );
                    } catch (_) {
                      // Fallback: open WhatsApp with text if phone available
                      if (phone.isNotEmpty) {
                        final indiaPhone = phone.startsWith('91') ? phone : '91$phone';
                        final uri = Uri.parse('https://wa.me/$indiaPhone');
                        if (await canLaunchUrl(uri)) await launchUrl(uri);
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF25D366),
                    side: const BorderSide(color: Color(0xFF25D366)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('Share on WhatsApp'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────────
  Widget _field(
    String label,
    TextEditingController ctrl, {
    String hint = '',
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: ctrl,
              maxLines: maxLines,
              keyboardType: keyboard,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
      );

  Widget _row(List<Widget> children) => Row(
        children: children
            .expand((w) => [Expanded(child: w), const SizedBox(width: 10)])
            .toList()
          ..removeLast(),
      );

  Widget _bulletRow(TextEditingController ctrl,
      {required bool canRemove, required VoidCallback onRemove}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Text('•  ', style: TextStyle(fontSize: 18, color: Colors.grey)),
          Expanded(
            child: TextField(
              controller: ctrl,
              decoration: InputDecoration(
                hintText: 'Enter point...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          if (canRemove) ...[
            const SizedBox(width: 6),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.red, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _addBulletBtn(String label, VoidCallback onPressed) => TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        style: TextButton.styleFrom(
            foregroundColor: AppColors.doctorPrimary,
            padding: EdgeInsets.zero),
      );

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600));
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 3, height: 16,
              decoration: BoxDecoration(
                  color: AppColors.doctorPrimary,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            Text(text,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.doctorPrimary)),
          ],
        ),
      );
}

// ── Medicine Card ─────────────────────────────────────────────────────────────
class _MedicineCard extends StatefulWidget {
  final int index;
  final _RxEntry entry;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  const _MedicineCard({
    required this.index,
    required this.entry,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });
  @override
  State<_MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<_MedicineCard> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _strengthCtrl;
  late final TextEditingController _instrCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.entry.name);
    _strengthCtrl = TextEditingController(text: widget.entry.strength);
    _instrCtrl = TextEditingController(text: widget.entry.instructions);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _strengthCtrl.dispose();
    _instrCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return DlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: AppColors.doctorPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('${widget.index + 1}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.doctorPrimary)),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Medicine',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const Spacer(),
              if (widget.canRemove)
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Name + Strength
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildNameField(e),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _labeledField('Strength', _strengthCtrl,
                    hint: '500mg', onChanged: (v) {
                  widget.entry.strength = v;
                  widget.onChanged();
                }),
              ),
            ],
          ),

          // Dosage + Route
          Row(
            children: [
              Expanded(
                  child: _dropField('Dosage', _kDosages, e.dosage, (v) {
                setState(() => widget.entry.dosage = v!);
                widget.onChanged();
              })),
              const SizedBox(width: 10),
              Expanded(
                  child: _dropField('Route', _kRoutes, e.route, (v) {
                setState(() => widget.entry.route = v!);
                widget.onChanged();
              })),
            ],
          ),
          const SizedBox(height: 8),

          // Frequency + Timing
          Row(
            children: [
              Expanded(
                  child: _dropField('Frequency', _kFrequencies, e.frequency, (v) {
                setState(() => widget.entry.frequency = v!);
                widget.onChanged();
              })),
              const SizedBox(width: 10),
              Expanded(
                  child: _dropField('Timing', _kTimings, e.timing, (v) {
                setState(() => widget.entry.timing = v!);
                widget.onChanged();
              })),
            ],
          ),
          const SizedBox(height: 8),

          // Duration
          _dropField('Duration', _kDurations, e.duration, (v) {
            setState(() => widget.entry.duration = v!);
            widget.onChanged();
          }),
          const SizedBox(height: 8),

          // Instructions
          _labeledField('Instructions (optional)', _instrCtrl,
              hint: 'Special instructions...', onChanged: (v) {
            widget.entry.instructions = v;
            widget.onChanged();
          }),
        ],
      ),
    );
  }

  Widget _buildNameField(_RxEntry e) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Name',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Autocomplete<String>(
          initialValue: TextEditingValue(text: e.name),
          optionsBuilder: (v) {
            if (v.text.isEmpty) return const [];
            return _kMedicines.where(
                (m) => m.toLowerCase().contains(v.text.toLowerCase()));
          },
          onSelected: (s) {
            widget.entry.name = s;
            widget.onChanged();
          },
          fieldViewBuilder: (ctx, ctrl, focus, onSub) => TextField(
            controller: ctrl,
            focusNode: focus,
            onChanged: (v) {
              widget.entry.name = v;
              widget.onChanged();
            },
            decoration: InputDecoration(
              hintText: 'Drug name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropField(String label, List<String> opts, String current,
      ValueChanged<String?> onChanged) {
    final safeValue = opts.contains(current) ? current : opts.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: safeValue,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            items: opts
                .map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _labeledField(String label, TextEditingController ctrl,
      {String hint = '', required ValueChanged<String> onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Preview Card (in-app) ─────────────────────────────────────────────────────
class _PreviewCard extends StatelessWidget {
  final AppPrescription rx;
  final AppDoctor doctor;
  final String patientName;
  final String patientAge;
  final String patientGender;
  final String patientContact;
  final String patientLocation;

  const _PreviewCard({
    required this.rx,
    required this.doctor,
    required this.patientName,
    this.patientAge = '',
    this.patientGender = '',
    this.patientContact = '',
    this.patientLocation = '',
  });

  @override
  Widget build(BuildContext context) {
    final s = doctor.prescriptionSettings;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            color: s.headerColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.clinicName.isNotEmpty
                      ? s.clinicName
                      : (doctor.clinicName ?? 'Your Clinic'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16),
                ),
                if (s.clinicTagline.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('· ${s.clinicTagline} ·',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11)),
                  ),
                if (s.clinicWebsite.isNotEmpty || s.clinicEmail.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      [s.clinicWebsite, s.clinicEmail, s.clinicHotline]
                          .where((e) => e.isNotEmpty)
                          .join('  ·  '),
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor block
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. ${doctor.name}${s.degrees.isNotEmpty ? ", ${s.degrees}" : ""}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        Text(doctor.specialty,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    if (doctor.registrationNo != null)
                      Text('Reg: ${doctor.registrationNo}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const Divider(height: 16),

                // Patient block
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(patientName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700)),
                        if (patientAge.isNotEmpty || patientGender.isNotEmpty)
                          Text(
                            [
                              if (patientAge.isNotEmpty) 'Age: $patientAge',
                              if (patientGender.isNotEmpty) patientGender,
                            ].join('  |  '),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        if (patientContact.isNotEmpty)
                          Text(patientContact,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(rx.formattedDate,
                            style: const TextStyle(fontSize: 11)),
                        if (rx.verificationCode != null)
                          Text(rx.verificationCode!,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontFamily: 'monospace')),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 16),

                // Chief complaints
                if (rx.extended?.chiefComplaints.isNotEmpty == true) ...[
                  _previewLabel('Chief Complaint'),
                  ...rx.extended!.chiefComplaints
                      .map((c) => _bullet(c)),
                  const SizedBox(height: 8),
                ],

                // History
                if (s.showHistory &&
                    rx.extended?.history.isNotEmpty == true) ...[
                  _previewLabel('History / HPI'),
                  ...rx.extended!.history.map((h) => _bullet(h)),
                  const SizedBox(height: 8),
                ],

                // Vitals
                if (s.showVitals &&
                    rx.extended != null &&
                    [
                      rx.extended!.vitals['temp'],
                      rx.extended!.vitals['bp'],
                      rx.extended!.vitals['hr'],
                    ].any((x) => x != null && x.isNotEmpty)) ...[
                  _previewLabel('Vitals'),
                  Text(
                    [
                      if (rx.extended!.vitals['temp']?.isNotEmpty == true)
                        'Temp: ${rx.extended!.vitals["temp"]}°F',
                      if (rx.extended!.vitals['bp']?.isNotEmpty == true)
                        'BP: ${rx.extended!.vitals["bp"]} mmHg',
                      if (rx.extended!.vitals['hr']?.isNotEmpty == true)
                        'HR: ${rx.extended!.vitals["hr"]} bpm',
                    ].join('   |   '),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                ],

                // Diagnosis
                _previewLabel('Diagnosis'),
                Text('Primary: ${rx.diagnosis}',
                    style: const TextStyle(fontSize: 13)),
                if (rx.extended?.secondaryDiagnosis.isNotEmpty == true)
                  Text('Secondary: ${rx.extended!.secondaryDiagnosis}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                const Divider(height: 16),

                // Rx
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: s.headerColor.withValues(alpha: 0.08),
                  child: const Row(children: [
                    Text('℞  MEDICATIONS',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 13)),
                  ]),
                ),
                const SizedBox(height: 8),
                ...rx.medicines.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${e.key + 1}.  ${e.value.name}${e.value.strength != null && e.value.strength!.isNotEmpty ? "  ${e.value.strength}" : ""}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          Text(
                            [
                              e.value.dosage,
                              if (e.value.route != null) e.value.route!,
                              e.value.frequency,
                              e.value.duration,
                            ].where((x) => x != null && x.isNotEmpty).join(' · '),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          if (e.value.instructions?.isNotEmpty == true)
                            Text('  ${e.value.instructions}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic)),
                        ],
                      ),
                    )),

                // Advice
                if (s.showAdvice &&
                    (rx.extended?.adviceDiet.isNotEmpty == true ||
                        rx.extended?.labTests.isNotEmpty == true)) ...[
                  const Divider(height: 16),
                  _previewLabel('Advice & Instructions'),
                  if (rx.extended!.adviceDiet.isNotEmpty)
                    Text('Diet: ${rx.extended!.adviceDiet}',
                        style: const TextStyle(fontSize: 12)),
                  if (rx.extended!.labTests.isNotEmpty)
                    Text('Lab Tests: ${rx.extended!.labTests}',
                        style: const TextStyle(fontSize: 12)),
                ],

                // Emergency
                if (s.showEmergency &&
                    rx.extended?.emergencyText.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.red, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(rx.extended!.emergencyText,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                ],

                const Divider(height: 16),
                // Dispensing + follow-up
                Text(
                  'Refills: ${rx.extended?.refills ?? "None"}   |   '
                  'Substitution: ${rx.extended?.substitutionAllowed == true ? "Allowed" : "Do not substitute"}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                if (rx.formattedFollowUp != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Follow-up: ${rx.formattedFollowUp}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),

                const Divider(height: 16),
                // Signature block
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dr. ${doctor.name}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.italic,
                                fontSize: 13)),
                        const Text(
                            'Electronically signed following valid tele-consultation.',
                            style:
                                TextStyle(fontSize: 9, color: Colors.grey)),
                        if (rx.verificationCode != null)
                          Text(
                            'Verification: ${rx.verificationCode}',
                            style: const TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                                fontFamily: 'monospace'),
                          ),
                      ],
                    ),
                    Container(
                      width: 50, height: 50,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.qr_code_2,
                          color: Colors.grey, size: 32),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text('Powered by Doclink',
                      style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                          letterSpacing: 0.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: Colors.grey,
                letterSpacing: 0.5)),
      );

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ', style: TextStyle(color: Colors.grey)),
            Expanded(
                child: Text(text, style: const TextStyle(fontSize: 13))),
          ],
        ),
      );
}

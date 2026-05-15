import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

const _kMedicines = [
  'Paracetamol 500mg', 'Amoxicillin 500mg', 'Ibuprofen 400mg', 'Cetirizine 10mg',
  'Pantoprazole 40mg', 'Metformin 500mg', 'Atorvastatin 10mg', 'Omeprazole 20mg',
  'Dolo 650', 'Azithromycin 500mg', 'Ciprofloxacin 500mg', 'Metronidazole 400mg',
  'Cefixime 200mg', 'Ranitidine 150mg', 'Montelukast 10mg', 'Losartan 50mg',
  'Amlodipine 5mg', 'Aspirin 75mg', 'Vitamin D3 60000IU', 'Vitamin B12 500mcg',
  'Iron + Folic Acid', 'Calcium 500mg', 'Multivitamin', 'Prednisolone 5mg',
];

class PrescriptionWriterScreen extends ConsumerStatefulWidget {
  final String? patientName;
  final String? patientId;
  final String? appointmentId;
  const PrescriptionWriterScreen({
    super.key,
    this.patientName,
    this.patientId,
    this.appointmentId,
  });

  @override
  ConsumerState<PrescriptionWriterScreen> createState() =>
      _PrescriptionWriterScreenState();
}

class _PrescriptionWriterScreenState
    extends ConsumerState<PrescriptionWriterScreen> {
  final _diagnosisCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  final _medicineCtrl = TextEditingController();
  final List<_RxEntry> _medicines = [];
  List<String> _suggestions = [];
  String? _followUpDate;
  DateTime? _followUpDateTime;
  bool _showPreview = false;
  bool _isSending = false;
  AppAppointment? _selectedAppointment;

  @override
  void dispose() {
    _diagnosisCtrl.dispose();
    _instructionsCtrl.dispose();
    _medicineCtrl.dispose();
    super.dispose();
  }

  String get _effectivePatientName =>
      widget.patientName ?? _selectedAppointment?.patientName ?? '';

  String? get _effectivePatientId =>
      widget.patientId ?? _selectedAppointment?.patientId;

  void _onMedicineQuery(String q) {
    if (q.length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() {
      _suggestions = _kMedicines
          .where((m) => m.toLowerCase().contains(q.toLowerCase()))
          .take(5)
          .toList();
    });
  }

  void _addMedicine(String name) {
    setState(() {
      _medicines.add(_RxEntry(name: name));
      _suggestions = [];
      _medicineCtrl.clear();
    });
  }

  void _removeMedicine(int i) => setState(() => _medicines.removeAt(i));

  @override
  Widget build(BuildContext context) {
    final doctorAsync = ref.watch(currentDoctorProvider);
    return doctorAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => _buildScaffold(context, null),
      data: (doctor) => _buildScaffold(context, doctor),
    );
  }

  Widget _buildScaffold(BuildContext context, AppDoctor? doctor) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_effectivePatientName.isNotEmpty
            ? 'Rx — $_effectivePatientName'
            : 'Prescription Writer'),
        actions: [
          TextButton(
            onPressed:
                _medicines.isNotEmpty ? () => setState(() => _showPreview = true) : null,
            child:
                const Text('Preview', style: TextStyle(color: AppColors.doctorAccent)),
          ),
        ],
      ),
      body: _showPreview
          ? _PreviewView(
              doctorName: doctor?.name ?? 'Doctor',
              doctorSpecialty: doctor?.specialty ?? '',
              doctorRegNo: doctor?.registrationNo ?? '',
              patientName: _effectivePatientName.isNotEmpty
                  ? _effectivePatientName
                  : 'Patient',
              diagnosis: _diagnosisCtrl.text,
              medicines: _medicines,
              instructions: _instructionsCtrl.text,
              followUpDate: _followUpDate,
              onEdit: () => setState(() => _showPreview = false),
              onSend: doctor != null ? () => _sendPrescription(doctor) : null,
              isSending: _isSending,
            )
          : _buildForm(context, doctor),
    );
  }

  Widget _buildForm(BuildContext context, AppDoctor? doctor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DlCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.doctorPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('℞',
                        style: TextStyle(
                            fontSize: 24,
                            color: AppColors.doctorPrimary,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor?.name ?? 'Doctor',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      Text(
                          '${doctor?.specialty ?? ''} · Reg: ${doctor?.registrationNo ?? '—'}',
                          style: const TextStyle(
                              color: AppColors.slate400, fontSize: 11)),
                    ],
                  ),
                ),
                Text(_today(),
                    style:
                        const TextStyle(color: AppColors.slate400, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (widget.patientId == null) ...[
            _AppointmentPicker(
              selected: _selectedAppointment,
              onSelect: (a) => setState(() => _selectedAppointment = a),
            ),
            const SizedBox(height: 12),
          ] else ...[
            TextFormField(
              initialValue: widget.patientName ?? '',
              decoration: const InputDecoration(
                labelText: 'Patient Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 12),
          ],

          TextFormField(
            controller: _diagnosisCtrl,
            decoration: const InputDecoration(
              labelText: 'Diagnosis / Chief Complaint',
              prefixIcon: Icon(Icons.local_hospital_outlined),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Text('Medicines', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.doctorPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${_medicines.length}',
                    style: const TextStyle(
                        color: AppColors.doctorPrimary, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _medicineCtrl,
            onChanged: _onMedicineQuery,
            decoration: InputDecoration(
              hintText: 'Search medicine name...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _medicineCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _medicineCtrl.clear();
                        setState(() => _suggestions = []);
                      })
                  : null,
            ),
          ),
          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: AppColors.doctorCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.doctorBorder),
              ),
              child: Column(
                children: _suggestions
                    .map((s) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.medication_outlined,
                              size: 18, color: AppColors.doctorAccent),
                          title: Text(s,
                              style: const TextStyle(fontSize: 13)),
                          onTap: () => _addMedicine(s),
                        ))
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 12),

          ..._medicines.asMap().entries.map((e) => _MedicineCard(
                entry: e.value,
                index: e.key,
                onRemove: () => _removeMedicine(e.key),
                onUpdate: (v) => setState(() => _medicines[e.key] = v),
              )),

          if (_medicines.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('No medicines added yet',
                    style: TextStyle(color: AppColors.slate500)),
              ),
            ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _instructionsCtrl,
            decoration: const InputDecoration(
              labelText: 'Special Instructions',
              hintText: 'e.g. Avoid cold water, take medicines after meals',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: _pickFollowUp,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.doctorCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.doctorBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_repeat_rounded,
                      color: AppColors.doctorAccent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _followUpDate ?? 'Set Follow-up Date (optional)',
                      style: TextStyle(
                        color: _followUpDate != null
                            ? Colors.white
                            : AppColors.slate500,
                      ),
                    ),
                  ),
                  if (_followUpDate != null)
                    GestureDetector(
                      onTap: () => setState(() {
                        _followUpDate = null;
                        _followUpDateTime = null;
                      }),
                      child: const Icon(Icons.clear,
                          size: 16, color: AppColors.slate400),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _medicines.isNotEmpty
                      ? () => setState(() => _showPreview = true)
                      : null,
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Preview'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (_medicines.isNotEmpty && !_isSending)
                      ? () {
                          final doctor =
                              ref.read(currentDoctorProvider).valueOrNull;
                          if (doctor != null) _sendPrescription(doctor);
                        }
                      : null,
                  icon: _isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Send Rx'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _today() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Future<void> _pickFollowUp() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.dark(primary: AppColors.doctorPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      setState(() {
        _followUpDateTime = picked;
        _followUpDate =
            '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      });
    }
  }

  Future<void> _sendPrescription(AppDoctor doctor) async {
    final patientId = _effectivePatientId;
    if (patientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient first')),
      );
      return;
    }
    setState(() => _isSending = true);
    try {
      await savePrescription(
        doctorId: doctor.id,
        patientId: patientId,
        diagnosis: _diagnosisCtrl.text.trim(),
        notes: _instructionsCtrl.text.trim().isEmpty
            ? null
            : _instructionsCtrl.text.trim(),
        followUpDate: _followUpDateTime,
        appointmentId: widget.appointmentId ?? _selectedAppointment?.id,
        medicines: _medicines
            .map((m) => {
                  'name': m.name,
                  'dosage': m.dosage,
                  'frequency': m.frequency,
                  'duration': m.duration,
                })
            .toList(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prescription saved'),
          backgroundColor: AppColors.doctorAccent,
          duration: Duration(seconds: 2),
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}

class _AppointmentPicker extends ConsumerWidget {
  final AppAppointment? selected;
  final ValueChanged<AppAppointment> onSelect;
  const _AppointmentPicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aptsAsync = ref.watch(doctorAppointmentsProvider);
    return aptsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
      data: (apts) {
        final active =
            apts.where((a) => a.status != 'cancelled' && a.status != 'completed').toList();
        if (active.isEmpty) {
          return const Text('No active appointments today',
              style: TextStyle(color: AppColors.slate400));
        }
        return DropdownButtonFormField<AppAppointment>(
          value: selected,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Select Patient',
            prefixIcon: Icon(Icons.person_search_rounded),
            border: OutlineInputBorder(),
          ),
          items: active
              .map((a) => DropdownMenuItem(
                    value: a,
                    child: Text(
                        a.patientName ?? 'Patient (#${a.tokenNo ?? '?'})'),
                  ))
              .toList(),
          onChanged: (a) {
            if (a != null) onSelect(a);
          },
        );
      },
    );
  }
}

class _RxEntry {
  String name, dosage, frequency, duration;
  _RxEntry({
    required this.name,
    this.dosage = '1 tablet',
    this.frequency = 'Twice daily',
    this.duration = '5 days',
  });
  _RxEntry copyWith({String? dosage, String? frequency, String? duration}) =>
      _RxEntry(
        name: name,
        dosage: dosage ?? this.dosage,
        frequency: frequency ?? this.frequency,
        duration: duration ?? this.duration,
      );
}

class _MedicineCard extends StatelessWidget {
  final _RxEntry entry;
  final int index;
  final VoidCallback onRemove;
  final ValueChanged<_RxEntry> onUpdate;

  const _MedicineCard({
    required this.entry,
    required this.index,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.doctorCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.doctorBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.doctorPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text('${index + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(entry.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16, color: AppColors.slate400),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DropdownField(
                  label: 'Dosage',
                  value: entry.dosage,
                  options: const [
                    '½ tablet', '1 tablet', '2 tablets', '5ml', '10ml'
                  ],
                  onChanged: (v) => onUpdate(entry.copyWith(dosage: v)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DropdownField(
                  label: 'Frequency',
                  value: entry.frequency,
                  options: const [
                    'Once daily', 'Twice daily', 'Thrice daily',
                    'Once at night', 'SOS', 'Before meals', 'After meals'
                  ],
                  onChanged: (v) => onUpdate(entry.copyWith(frequency: v)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DropdownField(
                  label: 'Duration',
                  value: entry.duration,
                  options: const [
                    '3 days', '5 days', '7 days', '10 days',
                    '14 days', '30 days', 'Ongoing'
                  ],
                  onChanged: (v) => onUpdate(entry.copyWith(duration: v)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label, value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.slate400, fontSize: 9)),
        const SizedBox(height: 2),
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.slate800,
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : options.first,
              isDense: true,
              dropdownColor: AppColors.slate800,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              onChanged: onChanged,
              items: options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewView extends StatelessWidget {
  final String doctorName, doctorSpecialty, doctorRegNo;
  final String patientName, diagnosis, instructions;
  final List<_RxEntry> medicines;
  final String? followUpDate;
  final VoidCallback? onSend;
  final VoidCallback onEdit;
  final bool isSending;

  const _PreviewView({
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorRegNo,
    required this.patientName,
    required this.diagnosis,
    required this.medicines,
    required this.instructions,
    required this.followUpDate,
    required this.onEdit,
    required this.onSend,
    required this.isSending,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12)
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D4ED8),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doctorName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        Text('$doctorSpecialty · $doctorRegNo',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Patient: ',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 12)),
                            Text(patientName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontSize: 13)),
                          ],
                        ),
                        if (diagnosis.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Divider(),
                          const Text('Diagnosis',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(diagnosis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black)),
                        ],
                        const SizedBox(height: 12),
                        const Divider(),
                        const Text('℞ Medicines',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D4ED8))),
                        const SizedBox(height: 8),
                        ...medicines.asMap().entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${e.key + 1}. ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1D4ED8))),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(e.value.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                                fontSize: 13)),
                                        Text(
                                            '${e.value.dosage} · ${e.value.frequency} · ${e.value.duration}',
                                            style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        if (instructions.isNotEmpty) ...[
                          const Divider(),
                          const Text('Instructions',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(instructions,
                              style:
                                  const TextStyle(color: Colors.black87)),
                        ],
                        if (followUpDate != null) ...[
                          const Divider(),
                          Row(
                            children: [
                              const Icon(Icons.event_repeat,
                                  size: 14, color: Colors.black54),
                              const SizedBox(width: 4),
                              Text('Follow-up: $followUpDate',
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                        const Divider(height: 24),
                        const Text("Dr's Signature",
                            style: TextStyle(
                                color: Colors.black54, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(doctorName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                fontStyle: FontStyle.italic)),
                        const Text('Powered by Doclink',
                            style: TextStyle(
                                color: Colors.black38, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.doctorCard,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: isSending ? null : onSend,
                  icon: isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_rounded, size: 16),
                  label: const Text('Save Prescription'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.doctorAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

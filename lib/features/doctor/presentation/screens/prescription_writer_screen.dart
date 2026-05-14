import 'package:flutter/material.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

class PrescriptionWriterScreen extends StatefulWidget {
  final String? patientName;
  final String? appointmentId;
  const PrescriptionWriterScreen({super.key, this.patientName, this.appointmentId});

  @override
  State<PrescriptionWriterScreen> createState() => _PrescriptionWriterScreenState();
}

class _PrescriptionWriterScreenState extends State<PrescriptionWriterScreen> {
  final _diagnosisCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  final _medicineCtrl = TextEditingController();
  final List<_RxEntry> _medicines = [];
  List<String> _suggestions = [];
  String? _followUpDate;
  bool _showPreview = false;

  @override
  void dispose() {
    _diagnosisCtrl.dispose();
    _instructionsCtrl.dispose();
    _medicineCtrl.dispose();
    super.dispose();
  }

  void _onMedicineQuery(String q) {
    if (q.length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() {
      _suggestions = MockData.medicines
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patientName != null
            ? 'Rx — ${widget.patientName}'
            : 'Prescription Writer'),
        actions: [
          TextButton(
            onPressed: _medicines.isNotEmpty ? () => setState(() => _showPreview = true) : null,
            child: const Text('Preview', style: TextStyle(color: AppColors.doctorAccent)),
          ),
        ],
      ),
      body: _showPreview
          ? _PreviewView(
              doctor: MockData.doctor,
              patientName: widget.patientName ?? 'Patient',
              diagnosis: _diagnosisCtrl.text,
              medicines: _medicines,
              instructions: _instructionsCtrl.text,
              followUpDate: _followUpDate,
              onEdit: () => setState(() => _showPreview = false),
              onSend: _sendPrescription,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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
                                  fontWeight: FontWeight.w700,
                                )),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(MockData.doctor.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 13)),
                              Text(
                                  '${MockData.doctor.specialty} · Reg: ${MockData.doctor.regNumber}',
                                  style: const TextStyle(
                                      color: AppColors.slate400, fontSize: 11)),
                            ],
                          ),
                        ),
                        Text(
                          _today(),
                          style: const TextStyle(
                              color: AppColors.slate400, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Patient info
                  TextFormField(
                    initialValue: widget.patientName ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Patient Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    readOnly: widget.patientName != null,
                  ),
                  const SizedBox(height: 12),

                  // Diagnosis
                  TextFormField(
                    controller: _diagnosisCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Diagnosis / Chief Complaint',
                      prefixIcon: Icon(Icons.local_hospital_outlined),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),

                  // Medicines header
                  Row(
                    children: [
                      Text('Medicines',
                          style: Theme.of(context).textTheme.titleMedium),
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

                  // Medicine search
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
                                  title: Text(s, style: const TextStyle(fontSize: 13)),
                                  onTap: () => _addMedicine(s),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Medicine list
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

                  // Instructions
                  TextFormField(
                    controller: _instructionsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Special Instructions',
                      hintText: 'e.g. Avoid cold water, take medicines after meals',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),

                  // Follow-up
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
                              onTap: () => setState(() => _followUpDate = null),
                              child: const Icon(Icons.clear,
                                  size: 16, color: AppColors.slate400),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
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
                          onPressed: _medicines.isNotEmpty ? _sendPrescription : null,
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: const Text('Send Rx'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  String _today() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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
          colorScheme: const ColorScheme.dark(primary: AppColors.doctorPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      setState(() => _followUpDate = '${picked.day} ${months[picked.month - 1]} ${picked.year}');
    }
  }

  void _sendPrescription() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prescription sent via WhatsApp + SMS ✓'),
        backgroundColor: AppColors.doctorAccent,
        duration: Duration(seconds: 3),
      ),
    );
    if (mounted) Navigator.pop(context);
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
                  options: const ['½ tablet', '1 tablet', '2 tablets', '5ml', '10ml'],
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
  final dynamic doctor;
  final String patientName, diagnosis, instructions;
  final List<_RxEntry> medicines;
  final String? followUpDate;
  final VoidCallback onEdit, onSend;

  const _PreviewView({
    required this.doctor,
    required this.patientName,
    required this.diagnosis,
    required this.medicines,
    required this.instructions,
    required this.followUpDate,
    required this.onEdit,
    required this.onSend,
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
                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12)
                ],
              ),
              child: Column(
                children: [
                  // Letterhead
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D4ED8),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doctor.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        Text('${doctor.specialty} · ${doctor.regNumber}',
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
                              style: const TextStyle(color: Colors.black87)),
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
                        const Text('Dr\'s Signature',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(doctor.name,
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
                  onPressed: onSend,
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Send via WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regNumberController = TextEditingController();
  String _selectedSpecialty = '';
  int _step = 0;

  static const _specialties = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Orthopedic',
    'Gynecologist',
    'ENT',
    'Neurologist',
    'Psychiatrist',
    'Ophthalmologist',
    'Dentist',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _regNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Verification'),
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _step--),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_step + 1) / 3,
              backgroundColor: AppColors.slate800,
              color: AppColors.doctorPrimary,
              minHeight: 3,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Form(
                  key: _formKey,
                  child: _buildStep(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _BasicInfoStep(
          nameController: _nameController,
          regController: _regNumberController,
          onNext: () {
            if (_formKey.currentState!.validate()) {
              setState(() => _step = 1);
            }
          },
        ),
      1 => _SpecialtyStep(
          selected: _selectedSpecialty,
          specialties: _specialties,
          onSelect: (s) => setState(() => _selectedSpecialty = s),
          onNext: () {
            if (_selectedSpecialty.isNotEmpty) setState(() => _step = 2);
          },
        ),
      _ => _SubmitStep(
          onSubmit: () {
            // TODO: submit to Supabase
            context.goNamed('doctor-dashboard');
          },
        ),
    };
  }
}

class _BasicInfoStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController regController;
  final VoidCallback onNext;

  const _BasicInfoStep({
    required this.nameController,
    required this.regController,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Basic Information',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Step 1 of 3',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.slate400)),
        const SizedBox(height: 32),
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Full Name'),
          validator: (v) =>
              v == null || v.isEmpty ? 'Name is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: regController,
          decoration: const InputDecoration(
            labelText: 'Medical Registration Number',
            hintText: 'MCI / NMC / State council number',
          ),
          validator: (v) =>
              v == null || v.isEmpty ? 'Registration number is required' : null,
        ),
        const Spacer(),
        ElevatedButton(onPressed: onNext, child: const Text('Next')),
      ],
    );
  }
}

class _SpecialtyStep extends StatelessWidget {
  final String selected;
  final List<String> specialties;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  const _SpecialtyStep({
    required this.selected,
    required this.specialties,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Specialty', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Step 2 of 3',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.slate400)),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: specialties.length,
            itemBuilder: (_, i) {
              final s = specialties[i];
              final isSelected = s == selected;
              return GestureDetector(
                onTap: () => onSelect(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.doctorPrimary.withValues(alpha:0.15)
                        : AppColors.doctorCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.doctorPrimary
                          : AppColors.doctorBorder,
                      width: isSelected ? 1.5 : 0.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    s,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.doctorPrimary : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: selected.isNotEmpty ? onNext : null,
          child: const Text('Next'),
        ),
      ],
    );
  }
}

class _SubmitStep extends StatelessWidget {
  final VoidCallback onSubmit;
  const _SubmitStep({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.doctorAccent.withValues(alpha:0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: AppColors.doctorAccent, size: 48),
        ),
        const SizedBox(height: 24),
        Text('All set!', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Your profile is under review. This usually takes 1–2 business days.',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.slate400),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: onSubmit,
          child: const Text('Go to Dashboard'),
        ),
      ],
    );
  }
}

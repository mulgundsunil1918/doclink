import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/clinic_theme.dart';
import '../../../../shared/widgets/dl_loader.dart';

/// Lets the doctor brand the app as their own clinic.
///
/// Every control writes straight through to [clinicThemeProvider], so the app
/// behind this screen re-skins as the doctor drags a slider — there is no save
/// button to forget to press.
class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cfg = ref.watch(clinicThemeProvider);
    final ctrl = ref.read(clinicThemeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic Appearance'),
        actions: [
          TextButton(
            onPressed: () => _confirmReset(context, ctrl),
            child: const Text('Reset'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          _LivePreview(cfg: cfg),
          const SizedBox(height: 28),

          _Section(
            title: 'Brand colour',
            caption: 'Used across buttons, tabs, highlights and your loader.',
            child: _BrandPicker(cfg: cfg, onPick: ctrl.setBrand),
          ),

          _Section(
            title: 'Appearance',
            caption: 'Dark mode is easier on the eyes for late clinics.',
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('Auto'),
                  icon: Icon(Icons.phone_iphone),
                ),
              ],
              selected: {cfg.mode},
              onSelectionChanged: (s) => ctrl.setMode(s.first),
            ),
          ),

          _Section(
            title: 'Loading animation',
            caption: 'Shown whenever the app is fetching something.',
            child: Column(
              children: [
                for (final style in DlLoaderStyle.values)
                  _LoaderOption(
                    style: style,
                    selected: cfg.loader == style,
                    brand: cfg.brand,
                    onTap: () => ctrl.setLoader(style),
                  ),
              ],
            ),
          ),

          _Section(
            title: 'Layout density',
            caption: 'Compact fits more patients on screen during a busy OPD.',
            child: SegmentedButton<ClinicDensity>(
              segments: [
                for (final d in ClinicDensity.values)
                  ButtonSegment(value: d, label: Text(d.label)),
              ],
              selected: {cfg.density},
              onSelectionChanged: (s) => ctrl.setDensity(s.first),
            ),
          ),

          _Section(
            title: 'Corner rounding',
            caption: '${cfg.cornerRadius.round()} px — sharp and clinical, '
                'or soft and friendly.',
            child: Slider(
              value: cfg.cornerRadius,
              min: 0,
              max: 28,
              divisions: 14,
              label: '${cfg.cornerRadius.round()}',
              onChanged: ctrl.setCornerRadius,
            ),
          ),

          _Section(
            title: 'Text size',
            caption: '${(cfg.fontScale * 100).round()}% of normal.',
            child: Slider(
              value: cfg.fontScale,
              min: 0.85,
              max: 1.30,
              divisions: 9,
              label: '${(cfg.fontScale * 100).round()}%',
              onChanged: ctrl.setFontScale,
            ),
          ),

          _Section(
            title: 'Gradient accents',
            caption: 'Richer headers and buttons, or a flat clinical finish.',
            child: SwitchListTile.adaptive(
              value: cfg.gradientAccents,
              onChanged: ctrl.setGradientAccents,
              contentPadding: EdgeInsets.zero,
              title: Text(cfg.gradientAccents ? 'Gradients on' : 'Flat colours'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    ClinicThemeController ctrl,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset appearance?'),
        content: const Text(
          'Your colour, layout and animation choices go back to the Doclink '
          'defaults. Nothing else about your practice changes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok ?? false) ctrl.reset();
  }
}

/// A miniature of the app rendered with the pending theme, so the doctor can
/// judge a choice without leaving the screen.
class _LivePreview extends StatelessWidget {
  const _LivePreview({required this.cfg});

  final ClinicTheme cfg;

  @override
  Widget build(BuildContext context) {
    // Render the preview against the theme actually being configured, which is
    // not necessarily the one this screen is drawn in (e.g. previewing dark
    // while still in light).
    final previewBrightness = switch (cfg.mode) {
      ThemeMode.dark => Brightness.dark,
      ThemeMode.light => Brightness.light,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };
    final theme = AppTheme.from(cfg, previewBrightness);

    return Theme(
      data: theme,
      child: Builder(
        builder: (ctx) => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(cfg.cornerRadius * 1.2),
            border: Border.all(color: theme.dividerColor),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: cfg.gradientAccents
                          ? LinearGradient(
                              colors: [cfg.brand, cfg.brand.withValues(alpha: 0.6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: cfg.gradientAccents ? null : cfg.brand,
                      borderRadius: BorderRadius.circular(cfg.cornerRadius * 0.6),
                    ),
                    child: const Icon(Icons.favorite, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your clinic', style: theme.textTheme.titleLarge),
                        Text(
                          'This is how the app will look',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  DlLoader(style: cfg.loader, size: 34, color: cfg.brand),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Chip(
                          label: const Text('Consultation'),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 40 * cfg.density.scale,
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('Write prescription'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandPicker extends StatelessWidget {
  const _BrandPicker({required this.cfg, required this.onPick});

  final ClinicTheme cfg;
  final ValueChanged<Color> onPick;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final entry in ClinicTheme.presets.entries)
          _Swatch(
            color: entry.value,
            label: entry.key,
            selected: cfg.brand.toARGB32() == entry.value.toARGB32(),
            onTap: () => onPick(entry.value),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        selected: selected,
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 22)
                : null,
          ),
        ),
      ),
    );
  }
}

class _LoaderOption extends StatelessWidget {
  const _LoaderOption({
    required this.style,
    required this.selected,
    required this.brand,
    required this.onTap,
  });

  final DlLoaderStyle style;
  final bool selected;
  final Color brand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? brand : theme.dividerColor,
              width: selected ? 2 : 1,
            ),
            color: selected ? brand.withValues(alpha: 0.06) : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 76,
                height: 40,
                child: Center(
                  child: DlLoader(style: style, size: 30, color: brand),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(style.label, style: theme.textTheme.titleMedium),
                    Text(style.blurb, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_circle, color: brand, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.caption,
    required this.child,
  });

  final String title;
  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(caption, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

import 'dart:ui';

class PrescriptionSettings {
  final String clinicName;
  final String clinicTagline;
  final String clinicWebsite;
  final String clinicEmail;
  final String clinicHotline;
  final Color headerColor;
  final String degrees;
  final bool showVitals;
  final bool showHistory;
  final bool showAdvice;
  final bool showEmergency;
  final bool defaultSubstitution;
  final String defaultRefills;
  final String defaultFollowup;
  final String emergencyText;

  const PrescriptionSettings({
    required this.clinicName,
    required this.clinicTagline,
    required this.clinicWebsite,
    required this.clinicEmail,
    required this.clinicHotline,
    required this.headerColor,
    required this.degrees,
    required this.showVitals,
    required this.showHistory,
    required this.showAdvice,
    required this.showEmergency,
    required this.defaultSubstitution,
    required this.defaultRefills,
    required this.defaultFollowup,
    required this.emergencyText,
  });

  static const PrescriptionSettings defaults = PrescriptionSettings(
        clinicName: '',
        clinicTagline: 'TELEHEALTH MEDICAL SERVICES',
        clinicWebsite: '',
        clinicEmail: '',
        clinicHotline: '24/7 Digital Care',
        headerColor: Color(0xFF1D4ED8),
        degrees: 'MBBS',
        showVitals: true,
        showHistory: true,
        showAdvice: true,
        showEmergency: true,
        defaultSubstitution: true,
        defaultRefills: 'None',
        defaultFollowup: '3 Days',
        emergencyText:
            'If you experience shortness of breath, severe pain, or high fever, '
            'please proceed to the nearest Emergency Room immediately.',
      );

  factory PrescriptionSettings.fromJson(Map<String, dynamic> j) {
    Color parseColor(String? hex) {
      if (hex == null || hex.isEmpty) return const Color(0xFF1D4ED8);
      final h = hex.replaceFirst('#', '');
      return Color(int.parse('FF$h', radix: 16));
    }

    return PrescriptionSettings(
      clinicName: j['clinic_name'] as String? ?? '',
      clinicTagline:
          j['clinic_tagline'] as String? ?? 'TELEHEALTH MEDICAL SERVICES',
      clinicWebsite: j['clinic_website'] as String? ?? '',
      clinicEmail: j['clinic_email'] as String? ?? '',
      clinicHotline: j['clinic_hotline'] as String? ?? '24/7 Digital Care',
      headerColor: parseColor(j['header_color'] as String?),
      degrees: j['degrees'] as String? ?? 'MBBS',
      showVitals: j['show_vitals'] as bool? ?? true,
      showHistory: j['show_history'] as bool? ?? true,
      showAdvice: j['show_advice'] as bool? ?? true,
      showEmergency: j['show_emergency'] as bool? ?? true,
      defaultSubstitution: j['default_substitution'] as bool? ?? true,
      defaultRefills: j['default_refills'] as String? ?? 'None',
      defaultFollowup: j['default_followup'] as String? ?? '3 Days',
      emergencyText: j['emergency_text'] as String? ??
          'If you experience shortness of breath, severe pain, or high fever, '
              'please proceed to the nearest Emergency Room immediately.',
    );
  }

  Map<String, dynamic> toJson() => {
        'clinic_name': clinicName,
        'clinic_tagline': clinicTagline,
        'clinic_website': clinicWebsite,
        'clinic_email': clinicEmail,
        'clinic_hotline': clinicHotline,
        'header_color':
            '#${(headerColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
        'degrees': degrees,
        'show_vitals': showVitals,
        'show_history': showHistory,
        'show_advice': showAdvice,
        'show_emergency': showEmergency,
        'default_substitution': defaultSubstitution,
        'default_refills': defaultRefills,
        'default_followup': defaultFollowup,
        'emergency_text': emergencyText,
      };

  PrescriptionSettings copyWith({
    String? clinicName,
    String? clinicTagline,
    String? clinicWebsite,
    String? clinicEmail,
    String? clinicHotline,
    Color? headerColor,
    String? degrees,
    bool? showVitals,
    bool? showHistory,
    bool? showAdvice,
    bool? showEmergency,
    bool? defaultSubstitution,
    String? defaultRefills,
    String? defaultFollowup,
    String? emergencyText,
  }) =>
      PrescriptionSettings(
        clinicName: clinicName ?? this.clinicName,
        clinicTagline: clinicTagline ?? this.clinicTagline,
        clinicWebsite: clinicWebsite ?? this.clinicWebsite,
        clinicEmail: clinicEmail ?? this.clinicEmail,
        clinicHotline: clinicHotline ?? this.clinicHotline,
        headerColor: headerColor ?? this.headerColor,
        degrees: degrees ?? this.degrees,
        showVitals: showVitals ?? this.showVitals,
        showHistory: showHistory ?? this.showHistory,
        showAdvice: showAdvice ?? this.showAdvice,
        showEmergency: showEmergency ?? this.showEmergency,
        defaultSubstitution: defaultSubstitution ?? this.defaultSubstitution,
        defaultRefills: defaultRefills ?? this.defaultRefills,
        defaultFollowup: defaultFollowup ?? this.defaultFollowup,
        emergencyText: emergencyText ?? this.emergencyText,
      );
}

class ExtendedRxData {
  final List<String> chiefComplaints;
  final List<String> history;
  final Map<String, String> vitals; // temp, bp, hr, notes
  final String secondaryDiagnosis;
  final String adviceDiet;
  final String labTests;
  final String refills;
  final String emergencyText;
  final bool substitutionAllowed;

  const ExtendedRxData({
    required this.chiefComplaints,
    required this.history,
    required this.vitals,
    required this.secondaryDiagnosis,
    required this.adviceDiet,
    required this.labTests,
    required this.refills,
    required this.emergencyText,
    required this.substitutionAllowed,
  });

  factory ExtendedRxData.empty(PrescriptionSettings s) => ExtendedRxData(
        chiefComplaints: const [],
        history: const [],
        vitals: const {'temp': '', 'bp': '', 'hr': '', 'notes': ''},
        secondaryDiagnosis: '',
        adviceDiet: '',
        labTests: '',
        refills: s.defaultRefills,
        emergencyText: s.emergencyText,
        substitutionAllowed: s.defaultSubstitution,
      );

  factory ExtendedRxData.fromJson(Map<String, dynamic> j) {
    Map<String, String> parseVitals(dynamic v) {
      if (v is Map) {
        return {
          'temp': v['temp']?.toString() ?? '',
          'bp': v['bp']?.toString() ?? '',
          'hr': v['hr']?.toString() ?? '',
          'notes': v['notes']?.toString() ?? '',
        };
      }
      return {'temp': '', 'bp': '', 'hr': '', 'notes': ''};
    }

    List<String> parseList(dynamic l) =>
        (l as List? ?? []).map((e) => e.toString()).toList();

    return ExtendedRxData(
      chiefComplaints: parseList(j['chief_complaints']),
      history: parseList(j['history']),
      vitals: parseVitals(j['vitals']),
      secondaryDiagnosis: j['secondary_diagnosis'] as String? ?? '',
      adviceDiet: j['advice_diet'] as String? ?? '',
      labTests: j['lab_tests'] as String? ?? '',
      refills: j['refills'] as String? ?? 'None',
      emergencyText: j['emergency_text'] as String? ?? '',
      substitutionAllowed: j['substitution_allowed'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'chief_complaints': chiefComplaints,
        'history': history,
        'vitals': vitals,
        'secondary_diagnosis': secondaryDiagnosis,
        'advice_diet': adviceDiet,
        'lab_tests': labTests,
        'refills': refills,
        'emergency_text': emergencyText,
        'substitution_allowed': substitutionAllowed,
      };

  ExtendedRxData copyWith({
    List<String>? chiefComplaints,
    List<String>? history,
    Map<String, String>? vitals,
    String? secondaryDiagnosis,
    String? adviceDiet,
    String? labTests,
    String? refills,
    String? emergencyText,
    bool? substitutionAllowed,
  }) =>
      ExtendedRxData(
        chiefComplaints: chiefComplaints ?? this.chiefComplaints,
        history: history ?? this.history,
        vitals: vitals ?? this.vitals,
        secondaryDiagnosis: secondaryDiagnosis ?? this.secondaryDiagnosis,
        adviceDiet: adviceDiet ?? this.adviceDiet,
        labTests: labTests ?? this.labTests,
        refills: refills ?? this.refills,
        emergencyText: emergencyText ?? this.emergencyText,
        substitutionAllowed: substitutionAllowed ?? this.substitutionAllowed,
      );
}

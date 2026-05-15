import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/ai_config.dart';

const _base =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$geminiApiKey';

const _clinicalSystem =
    'You are an AI clinical assistant for licensed doctors in India using the Doclink app. '
    'Keep responses concise, medically accurate, and relevant to Indian clinical practice. '
    'Always state that doctors must use their own clinical judgement before finalising any output. '
    'When asked for structured data, return ONLY valid JSON matching the schema given — no prose, no markdown fences.';

// ── Models ────────────────────────────────────────────────────────────────────

class RxDrug {
  String name;
  String dose;
  String route;
  String frequency;
  String duration;
  String notes;
  RxDrug({
    required this.name,
    required this.dose,
    required this.route,
    required this.frequency,
    required this.duration,
    required this.notes,
  });
  factory RxDrug.fromJson(Map j) => RxDrug(
        name: j['name'] ?? '',
        dose: j['dose'] ?? '',
        route: j['route'] ?? 'Oral',
        frequency: j['frequency'] ?? '',
        duration: j['duration'] ?? '',
        notes: j['notes'] ?? '',
      );
  Map<String, String> toMap() => {
        'name': name,
        'dose': dose,
        'route': route,
        'frequency': frequency,
        'duration': duration,
        'notes': notes,
      };
}

class RxDraft {
  String diagnosis;
  List<RxDrug> medicines;
  String advice;
  String followUp;
  RxDraft({
    required this.diagnosis,
    required this.medicines,
    required this.advice,
    required this.followUp,
  });
  factory RxDraft.fromJson(Map j) => RxDraft(
        diagnosis: j['diagnosis'] ?? '',
        medicines: ((j['medicines'] ?? j['drugs']) as List? ?? [])
            .map((e) => RxDrug.fromJson(e as Map))
            .toList(),
        advice: j['advice'] ?? '',
        followUp: j['followUp'] ?? '',
      );
}

class SoapNote {
  String subjective;
  String objective;
  String assessment;
  String plan;
  SoapNote({
    required this.subjective,
    required this.objective,
    required this.assessment,
    required this.plan,
  });
  factory SoapNote.fromJson(Map j) => SoapNote(
        subjective: j['subjective'] ?? '',
        objective: j['objective'] ?? '',
        assessment: j['assessment'] ?? '',
        plan: j['plan'] ?? '',
      );
}

class DrugInfo {
  final String name;
  final String drugClass;
  final String standardDose;
  final String maxDose;
  final String frequency;
  final String duration;
  final String sideEffects;
  final String pregnancyCategory;
  final String contraindications;
  final String renalAdjustment;
  const DrugInfo({
    required this.name,
    required this.drugClass,
    required this.standardDose,
    required this.maxDose,
    required this.frequency,
    required this.duration,
    required this.sideEffects,
    required this.pregnancyCategory,
    required this.contraindications,
    required this.renalAdjustment,
  });
  factory DrugInfo.fromJson(Map j) => DrugInfo(
        name: j['name'] ?? '',
        drugClass: j['class'] ?? '',
        standardDose: j['standardDose'] ?? '',
        maxDose: j['maxDose'] ?? '',
        frequency: j['frequency'] ?? '',
        duration: j['duration'] ?? '',
        sideEffects: j['sideEffects'] ?? '',
        pregnancyCategory: j['pregnancyCategory'] ?? '',
        contraindications: j['contraindications'] ?? '',
        renalAdjustment: j['renalAdjustment'] ?? '',
      );
}

class InteractionPair {
  final String drug1;
  final String drug2;
  final String severity; // safe | caution | major
  final String effect;
  final String action;
  const InteractionPair({
    required this.drug1,
    required this.drug2,
    required this.severity,
    required this.effect,
    required this.action,
  });
  factory InteractionPair.fromJson(Map j) => InteractionPair(
        drug1: j['drug1'] ?? '',
        drug2: j['drug2'] ?? '',
        severity: j['severity'] ?? 'safe',
        effect: j['effect'] ?? '',
        action: j['action'] ?? '',
      );
}

class InteractionResult {
  final String overallSeverity;
  final String summary;
  final List<InteractionPair> pairs;
  const InteractionResult({
    required this.overallSeverity,
    required this.summary,
    required this.pairs,
  });
  factory InteractionResult.fromJson(Map j) => InteractionResult(
        overallSeverity: j['overallSeverity'] ?? 'safe',
        summary: j['summary'] ?? '',
        pairs: ((j['pairs'] ?? []) as List)
            .map((e) => InteractionPair.fromJson(e as Map))
            .toList(),
      );
}

// ── Service ───────────────────────────────────────────────────────────────────

class GeminiService {
  final _dio = Dio();

  Future<String> chat({
    required List<Map<String, dynamic>> history,
    String? patientContext,
  }) async {
    final system = patientContext != null
        ? '$_clinicalSystem\nCurrent patient context: $patientContext'
        : _clinicalSystem;
    return _textCall(history, system);
  }

  Future<RxDraft> generateRx({
    required String symptoms,
    String? patientContext,
  }) async {
    const schema = '{"diagnosis":"string","medicines":[{"name":"string","dose":"string",'
        '"route":"string","frequency":"string","duration":"string","notes":"string"}],'
        '"advice":"string","followUp":"string"}';
    final prompt =
        'Generate a prescription JSON for this case. Schema: $schema\n'
        '${patientContext != null ? "Patient: $patientContext\n" : ""}'
        'Symptoms/Diagnosis: $symptoms';
    final raw = await _jsonCall(prompt);
    return RxDraft.fromJson(jsonDecode(raw) as Map);
  }

  Future<SoapNote> generateSoap(String description) async {
    const schema =
        '{"subjective":"string","objective":"string","assessment":"string","plan":"string"}';
    final prompt =
        'Generate a SOAP note JSON. Schema: $schema\nVisit details: $description';
    final raw = await _jsonCall(prompt);
    return SoapNote.fromJson(jsonDecode(raw) as Map);
  }

  Future<DrugInfo> lookupDrug(String drugName) async {
    const schema =
        '{"name":"string","class":"string","standardDose":"string","maxDose":"string",'
        '"frequency":"string","duration":"string","sideEffects":"string",'
        '"pregnancyCategory":"string","contraindications":"string","renalAdjustment":"string"}';
    final prompt = 'Provide drug information JSON for $drugName. Schema: $schema';
    final raw = await _jsonCall(prompt);
    return DrugInfo.fromJson(jsonDecode(raw) as Map);
  }

  Future<InteractionResult> checkInteractions(List<String> drugs) async {
    const schema =
        '{"overallSeverity":"safe|caution|major","summary":"string",'
        '"pairs":[{"drug1":"string","drug2":"string","severity":"safe|caution|major",'
        '"effect":"string","action":"string"}]}';
    final prompt =
        'Check drug interactions between: ${drugs.join(", ")}. Schema: $schema';
    final raw = await _jsonCall(prompt);
    return InteractionResult.fromJson(jsonDecode(raw) as Map);
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  Future<String> _textCall(
      List<Map<String, dynamic>> history, String system) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      _base,
      data: {
        'system_instruction': {
          'parts': [
            {'text': system}
          ]
        },
        'contents': history,
        'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 800},
      },
      options: Options(
        headers: {'Content-Type': 'application/json'},
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    return _extractText(resp.data);
  }

  Future<String> _jsonCall(String prompt) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      _base,
      data: {
        'system_instruction': {
          'parts': [
            {'text': _clinicalSystem}
          ]
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.2,
          'maxOutputTokens': 1200,
          'response_mime_type': 'application/json',
        },
      },
      options: Options(
        headers: {'Content-Type': 'application/json'},
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    return _extractText(resp.data);
  }

  String _extractText(Map<String, dynamic>? data) {
    return (data?['candidates'] as List?)
            ?.firstOrNull?['content']?['parts']
            ?.firstOrNull?['text'] as String? ??
        '{}';
  }

  void dispose() => _dio.close();
}

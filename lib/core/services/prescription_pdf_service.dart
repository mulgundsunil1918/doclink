import 'dart:typed_data';

import 'package:flutter/material.dart' show Color;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/prescription_template.dart';
import '../providers/app_providers.dart';

class PrescriptionPdfService {
  // Convert Flutter Color → PdfColor (.r/.g/.b are already 0.0–1.0)
  static PdfColor _pc(Color c) => PdfColor(c.r, c.g, c.b);

  Future<Uint8List> generate(
    AppPrescription rx,
    AppDoctor? doctor,
    PrescriptionSettings settings, {
    String patientName = '',
    String patientAge = '',
    String patientGender = '',
    String patientContact = '',
    String patientLocation = '',
  }) async {
    final pdf = pw.Document();
    final hc = _pc(settings.headerColor);
    final ext = rx.extended;

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = rx.createdAt;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
    final hh = d.hour;
    final mm = d.minute;
    final period = hh >= 12 ? 'PM' : 'AM';
    final h12 = hh > 12 ? hh - 12 : (hh == 0 ? 12 : hh);
    final timeStr = '$h12:${mm.toString().padLeft(2, '0')} $period';

    final displayName =
        patientName.isNotEmpty ? patientName : 'Patient';
    final verCode = rx.verificationCode ??
        'E-RX-${rx.id.substring(0, 8).toUpperCase()}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 28, 36, 48),
        footer: (ctx) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Powered by Doclink',
                  style: pw.TextStyle(
                      fontSize: 7, color: PdfColors.grey400)),
              pw.Text(
                  'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                  style: pw.TextStyle(
                      fontSize: 7, color: PdfColors.grey400)),
            ],
          ),
        ),
        build: (ctx) => [
          _header(settings, hc, doctor),
          pw.SizedBox(height: 8),
          _doctorRow(settings, doctor, hc),
          _divider(),
          _patientRow(
            rx: rx,
            dateStr: dateStr,
            timeStr: timeStr,
            name: displayName,
            age: patientAge,
            gender: patientGender,
            contact: patientContact,
            location: patientLocation,
            hc: hc,
          ),
          _divider(),
          _clinicalSection(rx.diagnosis, ext, settings, hc),
          _divider(),
          _medicationsSection(rx.medicines, hc),
          _divider(),
          if (settings.showAdvice &&
              ext != null &&
              (ext.adviceDiet.isNotEmpty || ext.labTests.isNotEmpty)) ...[
            _adviceSection(ext, hc),
            _divider(),
          ],
          if (settings.showEmergency &&
              ext != null &&
              ext.emergencyText.isNotEmpty) ...[
            _emergencySection(ext.emergencyText),
            _divider(),
          ],
          _dispensingSection(rx, ext),
          _divider(),
          _signatureSection(rx, doctor, settings, hc, verCode),
        ],
      ),
    );

    return pdf.save();
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  pw.Widget _header(
      PrescriptionSettings s, PdfColor hc, AppDoctor? doc) {
    final clinicName = s.clinicName.isNotEmpty
        ? s.clinicName
        : (doc?.clinicName ?? 'Doclink Medical');
    final infoParts = [
      if (s.clinicWebsite.isNotEmpty) s.clinicWebsite,
      if (s.clinicEmail.isNotEmpty) s.clinicEmail,
      if (s.clinicHotline.isNotEmpty) s.clinicHotline,
    ];
    return pw.Container(
      width: double.infinity,
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: pw.BoxDecoration(
        color: hc,
        borderRadius:
            const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(clinicName,
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold)),
          if (s.clinicTagline.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text(s.clinicTagline,
                style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 8,
                    letterSpacing: 1.8)),
          ],
          if (infoParts.isNotEmpty) ...[
            pw.SizedBox(height: 5),
            pw.Text(infoParts.join('  ·  '),
                style: pw.TextStyle(
                    color: PdfColors.white, fontSize: 8)),
          ],
        ],
      ),
    );
  }

  // ── Doctor row ───────────────────────────────────────────────────────────────

  pw.Widget _doctorRow(
      PrescriptionSettings s, AppDoctor? doc, PdfColor hc) {
    final namePart =
        doc?.name.isNotEmpty == true ? 'Dr. ${doc!.name}' : '';
    final degPart = s.degrees.isNotEmpty ? s.degrees : '';
    final nameDegs = [namePart, degPart]
        .where((v) => v.isNotEmpty)
        .join('  |  ');
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (nameDegs.isNotEmpty)
                pw.Text(nameDegs,
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                        color: hc)),
              if (doc?.specialty.isNotEmpty == true)
                pw.Text(doc!.specialty,
                    style: pw.TextStyle(
                        fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
          if (doc?.registrationNo?.isNotEmpty == true)
            pw.Text('Reg: ${doc!.registrationNo!}',
                style: pw.TextStyle(
                    fontSize: 9, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  // ── Patient row ──────────────────────────────────────────────────────────────

  pw.Widget _patientRow({
    required AppPrescription rx,
    required String dateStr,
    required String timeStr,
    required String name,
    required String age,
    required String gender,
    required String contact,
    required String location,
    required PdfColor hc,
  }) {
    final chips = <pw.Widget>[];
    if (age.isNotEmpty) chips.add(_chip('Age', age));
    if (gender.isNotEmpty) chips.add(_chip('Gender', gender));
    if (contact.isNotEmpty) chips.add(_chip('Contact', contact));
    if (location.isNotEmpty) chips.add(_chip('Location', location));

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius:
            const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('PATIENT',
                  style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: hc,
                      letterSpacing: 0.8)),
              pw.Text('$dateStr  ·  $timeStr',
                  style: pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey600)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(name,
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 14)),
          if (chips.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Wrap(spacing: 14, runSpacing: 2, children: chips),
          ],
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                  'Consult ID: ${rx.id.substring(0, 8).toUpperCase()}',
                  style: pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey500)),
              if (rx.followUpDate != null)
                pw.Text(
                    'Follow-up: ${_fmtDate(rx.followUpDate!)}',
                    style: pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey600,
                        fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _chip(String label, String value) => pw.RichText(
        text: pw.TextSpan(children: [
          pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(
                  fontSize: 9, color: PdfColors.grey600)),
          pw.TextSpan(
              text: value,
              style: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ]),
      );

  // ── Clinical notes ───────────────────────────────────────────────────────────

  pw.Widget _clinicalSection(
    String diagnosis,
    ExtendedRxData? ext,
    PrescriptionSettings s,
    PdfColor hc,
  ) {
    final rows = <pw.Widget>[
      _sectionLabel('CLINICAL NOTES', hc),
      pw.SizedBox(height: 6),
      pw.RichText(
        text: pw.TextSpan(children: [
          pw.TextSpan(
              text: 'Primary Diagnosis: ',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.TextSpan(
              text: diagnosis,
              style: pw.TextStyle(fontSize: 10)),
        ]),
      ),
    ];

    if (ext?.secondaryDiagnosis.isNotEmpty == true) {
      rows.add(pw.SizedBox(height: 2));
      rows.add(pw.RichText(
        text: pw.TextSpan(children: [
          pw.TextSpan(
              text: 'Secondary: ',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                  color: PdfColors.grey700)),
          pw.TextSpan(
              text: ext!.secondaryDiagnosis,
              style: pw.TextStyle(
                  fontSize: 9, color: PdfColors.grey700)),
        ]),
      ));
    }

    if (ext != null) {
      if (ext.chiefComplaints.isNotEmpty) {
        rows.add(pw.SizedBox(height: 6));
        rows.add(pw.Text('Chief Complaints:',
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 9)));
        for (final cc in ext.chiefComplaints) {
          rows.add(pw.Padding(
            padding: const pw.EdgeInsets.only(left: 8, top: 1),
            child: pw.Text('• $cc',
                style: pw.TextStyle(fontSize: 9)),
          ));
        }
      }

      if (s.showHistory && ext.history.isNotEmpty) {
        rows.add(pw.SizedBox(height: 4));
        rows.add(pw.Text('History / HPI:',
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 9)));
        for (final h in ext.history) {
          rows.add(pw.Padding(
            padding: const pw.EdgeInsets.only(left: 8, top: 1),
            child: pw.Text('• $h',
                style: pw.TextStyle(fontSize: 9)),
          ));
        }
      }

      if (s.showVitals) {
        final v = ext.vitals;
        final hasVitals = v.values.any((val) => val.isNotEmpty);
        if (hasVitals) {
          final vParts = <String>[
            if (v['temp']?.isNotEmpty == true) 'Temp: ${v['temp']}°F',
            if (v['bp']?.isNotEmpty == true) 'BP: ${v['bp']} mmHg',
            if (v['hr']?.isNotEmpty == true) 'HR: ${v['hr']} bpm',
            if (v['notes']?.isNotEmpty == true) v['notes']!,
          ];
          rows.add(pw.SizedBox(height: 6));
          rows.add(pw.Container(
            padding: const pw.EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              'Vitals:  ${vParts.join('   |   ')}',
              style: pw.TextStyle(fontSize: 9),
            ),
          ));
        }
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: rows,
    );
  }

  // ── Medications ──────────────────────────────────────────────────────────────

  pw.Widget _medicationsSection(
      List<AppMedicine> medicines, PdfColor hc) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(
              horizontal: 10, vertical: 7),
          decoration: pw.BoxDecoration(
            color: hc,
            borderRadius:
                const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Text('℞  MEDICATIONS',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                  color: PdfColors.white)),
        ),
        pw.SizedBox(height: 8),
        if (medicines.isEmpty)
          pw.Text('No medications listed.',
              style: pw.TextStyle(
                  fontSize: 9, color: PdfColors.grey500))
        else
          ...medicines.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final m = entry.value;
            final details = [
              if (m.dosage?.isNotEmpty == true) m.dosage!,
              if (m.route?.isNotEmpty == true) m.route!,
              if (m.frequency?.isNotEmpty == true) m.frequency!,
              if (m.duration?.isNotEmpty == true) m.duration!,
            ].join('  ·  ');
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 22,
                    child: pw.Text('$idx.',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 11,
                            color: hc)),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment:
                          pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(children: [
                          pw.Text(m.name,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 11)),
                          if (m.strength?.isNotEmpty == true)
                            pw.Text('  ${m.strength}',
                                style: pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.grey600)),
                        ]),
                        if (details.isNotEmpty)
                          pw.Text(details,
                              style: pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColors.grey700)),
                        if (m.instructions?.isNotEmpty == true)
                          pw.Text(
                              'Note: ${m.instructions}',
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  fontStyle: pw.FontStyle.italic,
                                  color: PdfColors.grey500)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ── Advice ───────────────────────────────────────────────────────────────────

  pw.Widget _adviceSection(ExtendedRxData ext, PdfColor hc) {
    final rows = <pw.Widget>[
      _sectionLabel('ADVICE & INSTRUCTIONS', hc),
      pw.SizedBox(height: 6),
    ];
    if (ext.adviceDiet.isNotEmpty) {
      rows.add(pw.RichText(
        text: pw.TextSpan(children: [
          pw.TextSpan(
              text: 'Diet & Lifestyle: ',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 9)),
          pw.TextSpan(
              text: ext.adviceDiet,
              style: pw.TextStyle(fontSize: 9)),
        ]),
      ));
    }
    if (ext.labTests.isNotEmpty) {
      rows.add(pw.SizedBox(height: 3));
      rows.add(pw.RichText(
        text: pw.TextSpan(children: [
          pw.TextSpan(
              text: 'Lab Tests Ordered: ',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 9)),
          pw.TextSpan(
              text: ext.labTests,
              style: pw.TextStyle(fontSize: 9)),
        ]),
      ));
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: rows,
    );
  }

  // ── Emergency warning ────────────────────────────────────────────────────────

  pw.Widget _emergencySection(String text) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border:
              pw.Border.all(color: PdfColors.red200, width: 0.8),
          borderRadius:
              const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('⚠  ',
                style: pw.TextStyle(
                    fontSize: 9, color: PdfColors.red)),
            pw.Expanded(
              child: pw.Text(text,
                  style: pw.TextStyle(
                      fontSize: 8, color: PdfColors.red700)),
            ),
          ],
        ),
      );

  // ── Dispensing ───────────────────────────────────────────────────────────────

  pw.Widget _dispensingSection(
      AppPrescription rx, ExtendedRxData? ext) {
    final refills = ext?.refills ?? 'None';
    final sub =
        ext?.substitutionAllowed ?? true ? 'Allowed' : 'Not Allowed';
    final fu = rx.followUpDate != null
        ? _fmtDate(rx.followUpDate!)
        : 'As Needed';
    return pw.Row(
      children: [
        pw.RichText(
          text: pw.TextSpan(children: [
            pw.TextSpan(
                text: 'Refills: ',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, fontSize: 9)),
            pw.TextSpan(
                text: refills,
                style: pw.TextStyle(fontSize: 9)),
          ]),
        ),
        pw.SizedBox(width: 20),
        pw.RichText(
          text: pw.TextSpan(children: [
            pw.TextSpan(
                text: 'Substitution: ',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, fontSize: 9)),
            pw.TextSpan(
                text: sub,
                style: pw.TextStyle(fontSize: 9)),
          ]),
        ),
        pw.SizedBox(width: 20),
        pw.RichText(
          text: pw.TextSpan(children: [
            pw.TextSpan(
                text: 'Follow-up: ',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, fontSize: 9)),
            pw.TextSpan(
                text: fu,
                style: pw.TextStyle(fontSize: 9)),
          ]),
        ),
      ],
    );
  }

  // ── Signature + QR ───────────────────────────────────────────────────────────

  pw.Widget _signatureSection(
    AppPrescription rx,
    AppDoctor? doctor,
    PrescriptionSettings settings,
    PdfColor hc,
    String verCode,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 28),
            pw.Container(
                width: 160,
                height: 0.5,
                color: PdfColors.grey600),
            pw.SizedBox(height: 4),
            pw.Text(
              doctor != null ? 'Dr. ${doctor.name}' : 'Doctor',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontStyle: pw.FontStyle.italic,
                  fontSize: 10,
                  color: hc),
            ),
            if (settings.degrees.isNotEmpty)
              pw.Text(settings.degrees,
                  style: pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey600)),
            pw.SizedBox(height: 6),
            pw.Text(
                'Electronically signed following valid tele-consultation.',
                style: pw.TextStyle(
                    fontSize: 7, color: PdfColors.grey400)),
            pw.Text('Secure ID: $verCode',
                style: pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.grey500,
                    fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: 'DOCLINK-RX:$verCode',
              width: 72,
              height: 72,
            ),
            pw.SizedBox(height: 4),
            pw.Text(verCode,
                style: pw.TextStyle(
                    fontSize: 7, color: PdfColors.grey500)),
          ],
        ),
      ],
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────────

  pw.Widget _sectionLabel(String text, PdfColor hc) => pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border(
            left: pw.BorderSide(color: hc, width: 3),
          ),
        ),
        padding: const pw.EdgeInsets.only(left: 6),
        child: pw.Text(text,
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
                color: hc,
                letterSpacing: 0.6)),
      );

  pw.Widget _divider() => pw.Divider(
      thickness: 0.5, color: PdfColors.grey300, height: 16);

  String _fmtDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> share(Uint8List bytes, String filename) =>
      Printing.sharePdf(bytes: bytes, filename: filename);

  Future<void> printPdf(Uint8List bytes) =>
      Printing.layoutPdf(onLayout: (_) async => bytes);
}

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:kenwell_health_app/data/repositories_dcl/firestore_cancer_screening_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_hct_screening_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_hra_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_tb_screening_repository.dart';
import 'package:kenwell_health_app/domain/models/cander_screening.dart';
import 'package:kenwell_health_app/domain/models/hct_screening.dart';
import 'package:kenwell_health_app/domain/models/hra_screening.dart';
import 'package:kenwell_health_app/domain/models/tb_screening.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/features/stats_report/widgets/sections/screening_stats_helpers.dart';

/// Generates an Excel workbook for a [WellnessEvent] report and saves it to
/// the application documents directory.
///
/// The workbook contains two sheets:
///   1. **Event Details** – all event metadata fields.
///   2. **Screening Stats** – aggregated HRA, Cancer, TB and HCT statistics.
///
/// Returns the absolute path of the saved `.xlsx` file.
class EventReportExporter {
  EventReportExporter({
    FirestoreHraRepository? hraRepo,
    FirestoreCancerScreeningRepository? cancerRepo,
    FirestoreTbScreeningRepository? tbRepo,
    FirestoreHctScreeningRepository? hctRepo,
  }) : _hraRepo = hraRepo ?? FirestoreHraRepository(),
       _cancerRepo = cancerRepo ?? FirestoreCancerScreeningRepository(),
       _tbRepo = tbRepo ?? FirestoreTbScreeningRepository(),
       _hctRepo = hctRepo ?? FirestoreHctScreeningRepository();

  final FirestoreHraRepository _hraRepo;
  final FirestoreCancerScreeningRepository _cancerRepo;
  final FirestoreTbScreeningRepository _tbRepo;
  final FirestoreHctScreeningRepository _hctRepo;

  /// Exports the report and returns the file path on success.
  Future<String> export(WellnessEvent event) async {
    // 1. Fetch screening data for this event.
    final results = await Future.wait<dynamic>([
      _hraRepo.getHraScreeningsByEvents([event.id]),
      _cancerRepo.getCancerScreeningsByEvents([event.id]),
      _tbRepo.getTbScreeningsByEvents([event.id]),
      _hctRepo.getHctScreeningsByEvents([event.id]),
    ]);

    final hraScreenings = List<HraScreening>.from(results[0] as List);
    final cancerScreenings = List<CancerScreening>.from(results[1] as List);
    final tbScreenings = List<TbScreening>.from(results[2] as List);
    final hctScreenings = List<HctScreening>.from(results[3] as List);

    // 2. Build the workbook.
    final excel = Excel.createExcel();

    // Excel.createExcel() adds a default "Sheet1"; rename it.
    excel.rename('Sheet1', 'Event Details');

    _buildEventDetailsSheet(
      excel['Event Details'],
      event,
      hraScreenings.length,
      cancerScreenings.length,
      tbScreenings.length,
      hctScreenings.length,
    );

    _buildScreeningStatsSheet(
      excel['Screening Stats'],
      _computeHraStats(hraScreenings),
      _computeCancerStats(cancerScreenings),
      _computeTbStats(tbScreenings),
      _computeHctStats(hctScreenings),
    );

    // 3. Save to documents directory.
    final dir = await getApplicationDocumentsDirectory();
    final safeTitle = event.title
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim()
        .replaceAll(' ', '_');
    final dateTag = DateFormat('yyyyMMdd').format(event.date);
    final fileName = 'event_report_${safeTitle}_$dateTag.xlsx';
    final filePath = '${dir.path}/$fileName';

    final fileBytes = excel.save();
    if (fileBytes == null) {
      throw StateError('Excel encoding produced no bytes.');
    }
    await File(filePath).writeAsBytes(fileBytes);
    debugPrint('EventReportExporter: saved to $filePath');
    return filePath;
  }

  // ── Sheet builders ──────────────────────────────────────────────────────────

  void _buildEventDetailsSheet(
    Sheet sheet,
    WellnessEvent event,
    int hraCount,
    int cancerCount,
    int tbCount,
    int hctCount,
  ) {
    _appendTitle(sheet, 'Event Report – ${event.title}');
    _appendBlank(sheet);

    // ── Event Details ─────────────────────────────────────────────────────────
    _appendHeader(sheet, 'Event Details');
    _appendRow(sheet, 'Event Title', event.title);
    _appendRow(sheet, 'Date', DateFormat('MMM dd, yyyy').format(event.date));
    _appendRow(sheet, 'Start Time', event.startTime);
    _appendRow(sheet, 'End Time', event.endTime);
    _appendRow(sheet, 'Set-up Time', event.setUpTime);
    _appendRow(sheet, 'Strike-down Time', event.strikeDownTime);
    _appendRow(sheet, 'Status', event.status);
    _appendBlank(sheet);

    // ── Location ──────────────────────────────────────────────────────────────
    _appendHeader(sheet, 'Location');
    _appendRow(sheet, 'Venue', event.venue);
    _appendRow(sheet, 'Address', event.address);
    _appendRow(sheet, 'Town / City', event.townCity);
    _appendRow(sheet, 'Province', event.province);
    _appendBlank(sheet);

    // ── On-site Contact ───────────────────────────────────────────────────────
    _appendHeader(sheet, 'On-site Contact');
    _appendRow(
      sheet,
      'Name',
      '${event.onsiteContactFirstName} ${event.onsiteContactLastName}',
    );
    _appendRow(sheet, 'Phone', event.onsiteContactNumber);
    _appendRow(sheet, 'Email', event.onsiteContactEmail);
    _appendBlank(sheet);

    if (event.aeContactFirstName.isNotEmpty) {
      _appendHeader(sheet, 'AE Facilitator');
      _appendRow(
        sheet,
        'Name',
        '${event.aeContactFirstName} ${event.aeContactLastName}',
      );
      _appendRow(sheet, 'Phone', event.aeContactNumber);
      _appendRow(sheet, 'Email', event.aeContactEmail);
      _appendBlank(sheet);
    }

    // ── Logistics ─────────────────────────────────────────────────────────────
    _appendHeader(sheet, 'Logistics');
    _appendRow(
      sheet,
      'Expected Participants',
      event.expectedParticipation.toString(),
    );
    _appendRow(sheet, 'Nurses', event.nurses.toString());
    _appendRow(sheet, 'Mobile Booths', event.mobileBooths);
    _appendRow(sheet, 'Medical Aid', event.medicalAid);
    if (event.servicesRequested.isNotEmpty) {
      _appendRow(sheet, 'Services Offered', event.servicesRequested);
    }
    if (event.description != null && event.description!.isNotEmpty) {
      _appendRow(sheet, 'Description', event.description!);
    }
    _appendBlank(sheet);

    // ── Participation Summary ─────────────────────────────────────────────────
    _appendHeader(sheet, 'Participation Summary');
    _appendRow(sheet, 'Expected', event.expectedParticipation.toString());
    _appendRow(sheet, 'Screened', event.screenedCount.toString());
    _appendRow(
      sheet,
      'No-show',
      (event.expectedParticipation - event.screenedCount).toString(),
    );
    _appendBlank(sheet);

    // ── Screening Record Counts ───────────────────────────────────────────────
    _appendHeader(sheet, 'Screening Record Counts');
    _appendRow(sheet, 'HRA Screenings', hraCount.toString());
    _appendRow(sheet, 'Cancer Screenings', cancerCount.toString());
    _appendRow(sheet, 'TB Screenings', tbCount.toString());
    _appendRow(sheet, 'HCT Screenings', hctCount.toString());

    sheet.setColumnWidth(0, 30);
    sheet.setColumnWidth(1, 45);
  }

  void _buildScreeningStatsSheet(
    Sheet sheet,
    HraStats hra,
    CancerStats cancer,
    TbStats tb,
    HctStats hct,
  ) {
    // Column headers.
    sheet.appendRow([
      TextCellValue('Metric'),
      TextCellValue('Count'),
      TextCellValue('Total'),
      TextCellValue('Percentage'),
    ]);
    _appendBlank(sheet);

    // ── HRA ───────────────────────────────────────────────────────────────────
    _appendHeader(sheet, 'Health Risk Assessment (HRA)');
    _appendStatRow(sheet, 'Total Screened', hra.total, hra.total);
    _appendStatRow(
      sheet,
      'Underweight (BMI < 18.5)',
      hra.underweight,
      hra.total,
    );
    _appendStatRow(
      sheet,
      'Normal Weight (BMI 18.5–24.9)',
      hra.normal,
      hra.total,
    );
    _appendStatRow(
      sheet,
      'Overweight (BMI 25–29.9)',
      hra.overweight,
      hra.total,
    );
    _appendStatRow(sheet, 'Obese (BMI ≥ 30)', hra.obese, hra.total);
    _appendStatRow(sheet, 'Hypertension', hra.hypertension, hra.total);
    _appendStatRow(sheet, 'High Blood Sugar', hra.highBloodSugar, hra.total);
    _appendStatRow(sheet, 'High Cholesterol', hra.highCholesterol, hra.total);
    _appendStatRow(sheet, 'Smokers', hra.smokers, hra.total);
    if (hra.topConditions.isNotEmpty) {
      _appendBlank(sheet);
      _appendHeader(sheet, 'Top Chronic Conditions');
      for (final entry in hra.topConditions) {
        _appendStatRow(sheet, entry.key, entry.value, hra.total);
      }
    }
    _appendBlank(sheet);

    // ── Cancer ────────────────────────────────────────────────────────────────
    _appendHeader(sheet, 'Cancer Screening');
    _appendStatRow(sheet, 'Total Screened', cancer.total, cancer.total);
    _appendStatRow(
      sheet,
      'PAP Smear Collected',
      cancer.papCollected,
      cancer.total,
    );
    _appendStatRow(
      sheet,
      'PAP Positive / Abnormal',
      cancer.papPositive,
      cancer.papCollected,
    );
    _appendStatRow(sheet, 'PSA Done', cancer.psaDone, cancer.total);
    _appendStatRow(
      sheet,
      'PSA Abnormal (> 4.0)',
      cancer.psaAbnormal,
      cancer.psaDone,
    );
    _appendStatRow(sheet, 'Symptomatic', cancer.symptomatic, cancer.total);
    _appendStatRow(sheet, 'Referred', cancer.referred, cancer.total);
    _appendBlank(sheet);

    // ── TB ────────────────────────────────────────────────────────────────────
    _appendHeader(sheet, 'TB Screening');
    _appendStatRow(sheet, 'Total Screened', tb.total, tb.total);
    _appendStatRow(sheet, 'Symptomatic', tb.symptomatic, tb.total);
    _appendStatRow(sheet, 'Cough (≥ 2 weeks)', tb.cough, tb.total);
    _appendStatRow(sheet, 'Blood in Sputum', tb.bloodInSputum, tb.total);
    _appendStatRow(sheet, 'Weight Loss', tb.weightLoss, tb.total);
    _appendStatRow(sheet, 'Night Sweats', tb.nightSweats, tb.total);
    _appendStatRow(sheet, 'Previously Treated', tb.treatedBefore, tb.total);
    _appendStatRow(sheet, 'Contact with TB', tb.contactWithTB, tb.total);
    _appendStatRow(sheet, 'Referred', tb.referred, tb.total);
    _appendBlank(sheet);

    // ── HCT ──────────────────────────────────────────────────────────────────
    _appendHeader(sheet, 'HIV Counselling & Testing (HCT)');
    _appendStatRow(sheet, 'Total Screened', hct.total, hct.total);
    _appendStatRow(
      sheet,
      'First-time Testers',
      hct.firstTimeTesters,
      hct.total,
    );
    _appendStatRow(sheet, 'High Risk', hct.highRisk, hct.total);
    _appendStatRow(sheet, 'Known Positive', hct.knownPositive, hct.total);

    sheet.setColumnWidth(0, 38);
    sheet.setColumnWidth(1, 10);
    sheet.setColumnWidth(2, 10);
    sheet.setColumnWidth(3, 12);
  }

  // ── Row helpers ─────────────────────────────────────────────────────────────

  void _appendTitle(Sheet sheet, String title) {
    sheet.appendRow([TextCellValue(title)]);
  }

  void _appendBlank(Sheet sheet) {
    sheet.appendRow([TextCellValue('')]);
  }

  void _appendHeader(Sheet sheet, String label) {
    sheet.appendRow([TextCellValue(label.toUpperCase())]);
  }

  void _appendRow(Sheet sheet, String label, String value) {
    sheet.appendRow([TextCellValue(label), TextCellValue(value)]);
  }

  /// Appends a stat row: label | count | total | percentage.
  void _appendStatRow(Sheet sheet, String label, int count, int total) {
    sheet.appendRow([
      TextCellValue(label),
      IntCellValue(count),
      IntCellValue(total),
      TextCellValue(screeningPct(count, total)),
    ]);
  }

  // ── Stat calculators (mirror logic from HealthScreeningStatsSection) ─────────

  HraStats _computeHraStats(List<HraScreening> list) {
    int underweight = 0, normal = 0, overweight = 0, obese = 0;
    int hypertension = 0, highBloodSugar = 0, highCholesterol = 0, smokers = 0;
    final Map<String, int> conditionCounts = {};

    for (final s in list) {
      final bmi = double.tryParse(s.bmi ?? '');
      if (bmi != null) {
        if (bmi < 18.5) {
          underweight++;
        } else if (bmi < 25.0) {
          normal++;
        } else if (bmi < 30.0) {
          overweight++;
        } else {
          obese++;
        }
      }
      final sys = int.tryParse(s.bloodPressureSystolic ?? '');
      final dia = int.tryParse(s.bloodPressureDiastolic ?? '');
      if ((sys != null && sys >= 140) || (dia != null && dia >= 90)) {
        hypertension++;
      }
      final sugar = double.tryParse(s.bloodSugar ?? '');
      if (sugar != null && sugar >= 7.0) highBloodSugar++;
      final chol = double.tryParse(s.cholesterol ?? '');
      if (chol != null && chol >= 5.2) highCholesterol++;
      final smoke = s.dailySmoke?.trim() ?? '';
      if (smoke.isNotEmpty && smoke != '0') smokers++;
      s.chronicConditions.forEach((condition, present) {
        if (present && condition != 'None') {
          conditionCounts[condition] = (conditionCounts[condition] ?? 0) + 1;
        }
      });
    }

    final topConditions = conditionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return HraStats(
      total: list.length,
      underweight: underweight,
      normal: normal,
      overweight: overweight,
      obese: obese,
      hypertension: hypertension,
      highBloodSugar: highBloodSugar,
      highCholesterol: highCholesterol,
      smokers: smokers,
      topConditions: topConditions.take(5).toList(),
    );
  }

  CancerStats _computeCancerStats(List<CancerScreening> list) {
    int papCollected = 0, papPositive = 0;
    int psaDone = 0, psaAbnormal = 0;
    int symptomatic = 0, referred = 0;

    for (final s in list) {
      final papResult = s.papSmearResults?.toLowerCase();
      if (s.papSmearSpecimenCollected?.toLowerCase() == 'yes') papCollected++;
      if (papResult != null &&
          (papResult.contains('positive') || papResult.contains('abnormal'))) {
        papPositive++;
      }
      if (s.psaResults != null && s.psaResults!.isNotEmpty) psaDone++;
      final psaValue = double.tryParse(s.psaResults ?? '');
      if (psaValue != null && psaValue > 4.0) {
        psaAbnormal++;
      }
      if (s.breastLightExamFindings != null &&
          s.breastLightExamFindings!.isNotEmpty)
        symptomatic++;
      if (s.nursingReferral != null && s.nursingReferral!.isNotEmpty)
        referred++;
    }

    return CancerStats(
      total: list.length,
      papCollected: papCollected,
      papPositive: papPositive,
      psaDone: psaDone,
      psaAbnormal: psaAbnormal,
      symptomatic: symptomatic,
      referred: referred,
    );
  }

  TbStats _computeTbStats(List<TbScreening> list) {
    int symptomatic = 0, cough = 0, bloodInSputum = 0;
    int weightLoss = 0, nightSweats = 0;
    int treatedBefore = 0, contactWithTB = 0, referred = 0;

    bool isYes(String? v) =>
        v?.toLowerCase() == 'yes' || v?.toLowerCase() == 'true';

    for (final s in list) {
      final hasCough = isYes(s.coughTwoWeeks);
      final hasBlood = isYes(s.bloodInSputum);
      final hasWeightLoss = isYes(s.weightLoss);
      final hasNightSweats = isYes(s.nightSweats);
      if (hasCough) cough++;
      if (hasBlood) bloodInSputum++;
      if (hasWeightLoss) weightLoss++;
      if (hasNightSweats) nightSweats++;
      if (hasCough || hasBlood || hasWeightLoss || hasNightSweats) {
        symptomatic++;
      }
      if (isYes(s.treatedBefore)) treatedBefore++;
      if (isYes(s.contactWithTB)) contactWithTB++;
      if (s.nursingReferral?.toLowerCase() == 'yes') referred++;
    }

    return TbStats(
      total: list.length,
      symptomatic: symptomatic,
      cough: cough,
      bloodInSputum: bloodInSputum,
      weightLoss: weightLoss,
      nightSweats: nightSweats,
      treatedBefore: treatedBefore,
      contactWithTB: contactWithTB,
      referred: referred,
    );
  }

  HctStats _computeHctStats(List<HctScreening> list) {
    int firstTimeTesters = 0, highRisk = 0, knownPositive = 0;

    for (final s in list) {
      if (s.firstHctTest?.toLowerCase() == 'yes') firstTimeTesters++;
      if (s.sharedNeedles?.toLowerCase() == 'yes' ||
          s.unprotectedSex?.toLowerCase() == 'yes')
        highRisk++;
      if (s.lastTestResult?.toLowerCase() == 'positive') knownPositive++;
    }

    return HctStats(
      total: list.length,
      firstTimeTesters: firstTimeTesters,
      highRisk: highRisk,
      knownPositive: knownPositive,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/kenwell_form_card.dart';
import '../../../../../data/repositories_dcl/firestore_cancer_screening_repository.dart';
import '../../../../../data/repositories_dcl/firestore_hiv_screening_repository.dart';
import '../../../../../data/repositories_dcl/firestore_hra_repository.dart';
import '../../../../../data/repositories_dcl/firestore_tb_screening_repository.dart';
import '../../../../../domain/models/cander_screening.dart';
import '../../../../../domain/enums/service_type.dart';
import '../../../../../domain/models/wellness_event.dart';

/// Displays per-service screening counts as a grid of small stat cards.
///
/// Used on both the Live Events view (title: "Live Screening Counts") and the
/// Past Events view (title: "Health Screening Analytics").  Pass [isLiveTab]
/// to control the label and empty-state copy.
class LiveScreeningCountsSection extends StatefulWidget {
  const LiveScreeningCountsSection({
    super.key,
    required this.eventIds,
    required this.events,
    this.isLiveTab = true,
  });

  final List<String> eventIds;
  final List<WellnessEvent> events;

  /// When false the section uses "Health Screening Analytics" as its title and
  /// adjusts empty-state copy to refer to past events.
  final bool isLiveTab;

  @override
  State<LiveScreeningCountsSection> createState() =>
      _LiveScreeningCountsSectionState();
}

class _LiveScreeningCountsSectionState
    extends State<LiveScreeningCountsSection> {
  final _hraRepo = FirestoreHraRepository();
  final _cancerRepo = FirestoreCancerScreeningRepository();
  final _tbRepo = FirestoreTbScreeningRepository();
  final _hivRepo = FirestoreHivScreeningRepository();

  bool _isLoading = true;
  int _hraCount = 0;
  int _hctCount = 0;
  int _tbCount = 0;
  int _papSmearCount = 0;
  int _breastScreeningCount = 0;
  int _psaCount = 0;

  Set<ServiceType> get _activeServices {
    final services = <ServiceType>{};
    for (final event in widget.events) {
      services.addAll(
          ServiceTypeConverter.fromStorageString(event.servicesRequested));
    }
    return services;
  }

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  @override
  void didUpdateWidget(LiveScreeningCountsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldSet = oldWidget.eventIds.toSet();
    final newSet = widget.eventIds.toSet();
    if (oldSet.length != newSet.length || !oldSet.containsAll(newSet)) {
      _loadCounts();
    }
  }

  Future<void> _loadCounts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final ids = widget.eventIds;
      if (ids.isEmpty) {
        if (mounted) {
          setState(() {
            _hraCount = _hctCount = _tbCount = 0;
            _papSmearCount = _breastScreeningCount = _psaCount = 0;
            _isLoading = false;
          });
        }
        return;
      }
      final results = await Future.wait(<Future<dynamic>>[
        _hraRepo.getHraScreeningsByEvents(ids),
        _cancerRepo.getCancerScreeningsByEvents(ids),
        _tbRepo.getTbScreeningsByEvents(ids),
        _hivRepo.getHivScreeningsByEvents(ids),
      ]);
      final hraList = List<dynamic>.from(results[0] as List);
      final cancerList = List<CancerScreening>.from(results[1] as List);
      final tbList = List<dynamic>.from(results[2] as List);
      final hivList = List<dynamic>.from(results[3] as List);

      final papCount = cancerList
          .where((s) => s.papSmearSpecimenCollected?.toLowerCase() == 'yes')
          .length;
      final breastCount = cancerList
          .where((s) =>
              s.breastLightExamFindings != null &&
              s.breastLightExamFindings!.isNotEmpty)
          .length;
      final psaCount = cancerList
          .where((s) => s.psaResults != null && s.psaResults!.isNotEmpty)
          .length;

      if (mounted) {
        setState(() {
          _hraCount = hraList.length;
          _hctCount = hivList.length;
          _tbCount = tbList.length;
          _papSmearCount = papCount;
          _breastScreeningCount = breastCount;
          _psaCount = psaCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('LiveScreeningCounts: failed to load: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final allScreenings = [
      _ScreeningCount(ServiceType.hra, 'HRA', _hraCount,
          Icons.monitor_heart_outlined, Colors.teal.shade600),
      _ScreeningCount(ServiceType.hct, 'HCT', _hctCount,
          Icons.bloodtype_outlined, Colors.red.shade600),
      _ScreeningCount(ServiceType.tbTest, 'TB', _tbCount, Icons.air_outlined,
          Colors.amber.shade700),
      _ScreeningCount(ServiceType.papSmear, 'Pap Smear', _papSmearCount,
          Icons.science_outlined, Colors.purple.shade500),
      _ScreeningCount(ServiceType.breastScreening, 'Breast',
          _breastScreeningCount, Icons.favorite_border, Colors.pink.shade500),
      _ScreeningCount(ServiceType.psa, 'PSA', _psaCount, Icons.biotech_outlined,
          Colors.indigo.shade500),
    ];

    final activeServices = _activeServices;
    final screenings = activeServices.isEmpty
        ? allScreenings
        : allScreenings
            .where((s) => activeServices.contains(s.serviceType))
            .toList();

    final sectionTitle =
        widget.isLiveTab ? 'Live Screening Counts' : 'Health Screening Analytics';
    final emptyLabel = widget.isLiveTab
        ? 'No live events to show screening data for'
        : 'No past events to show screening data for';

    return KenwellFormCard(
      useGradient: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_hospital_outlined,
                    color: KenwellColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sectionTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: KenwellColors.secondaryNavy,
                      ),
                    ),
                    Text(
                      'People screened for each requested service',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: KenwellColors.primaryGreen,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Content ────────────────────────────────────────────────────
          if (widget.eventIds.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  emptyLabel,
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
            )
          else
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.05,
              children: screenings
                  .map((s) => _ScreeningCountCard(
                        label: s.label,
                        count: _isLoading ? null : s.count,
                        icon: s.icon,
                        color: s.color,
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

// ── Internal data + card widgets ─────────────────────────────────────────────

class _ScreeningCount {
  const _ScreeningCount(
      this.serviceType, this.label, this.count, this.icon, this.color);

  final ServiceType serviceType;
  final String label;
  final int count;
  final IconData icon;
  final Color color;
}

class _ScreeningCountCard extends StatelessWidget {
  const _ScreeningCountCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  final String label;
  final int? count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: KenwellColors.primaryGreen.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          count == null
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: color),
                )
              : Text(
                  count.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: KenwellColors.secondaryNavy,
                    fontSize: 22,
                  ),
                ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

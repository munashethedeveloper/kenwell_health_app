import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/kenwell_form_card.dart';
import '../../../../../data/repositories_dcl/firestore_cancer_screening_repository.dart';
import '../../../../../data/repositories_dcl/firestore_hct_screening_repository.dart';
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
///
/// When [onCardTapped] is provided, each card becomes interactive. The parent
/// can track which service type was selected and show the detailed analytics
/// section accordingly.
class LiveScreeningCountsSection extends StatefulWidget {
  const LiveScreeningCountsSection({
    super.key,
    required this.eventIds,
    required this.events,
    this.isLiveTab = true,
    this.onCardTapped,
    this.selectedServiceType,
    this.midSectionWidget,
  });

  final List<String> eventIds;
  final List<WellnessEvent> events;

  /// When false the section uses "Health Screening Analytics" as its title and
  /// adjusts empty-state copy to refer to past events.
  final bool isLiveTab;

  /// Called with the [ServiceType] label (e.g. `'hra'`, `'hct'`, `'tb'`) when
  /// a screening card is tapped. Tap the same card again to deselect.
  final void Function(String? serviceKey)? onCardTapped;

  /// The currently selected service key — the corresponding card is
  /// highlighted to indicate it is active.
  final String? selectedServiceType;

  /// Optional widget injected between the HRA/HCT/TB row and the cancer
  /// (Pap Smear/Breast/PSA) row.  Used to place HRA/HCT/TB analytics
  /// immediately below the first row of screening count cards.
  final Widget? midSectionWidget;

  @override
  State<LiveScreeningCountsSection> createState() =>
      _LiveScreeningCountsSectionState();
}

class _LiveScreeningCountsSectionState
    extends State<LiveScreeningCountsSection> {
  final _hraRepo = FirestoreHraRepository();
  final _cancerRepo = FirestoreCancerScreeningRepository();
  final _tbRepo = FirestoreTbScreeningRepository();
  final _hctRepo = FirestoreHctScreeningRepository();

  // Holds the latest list from each Firestore stream.
  List<dynamic> _hraList = [];
  List<CancerScreening> _cancerList = [];
  List<dynamic> _tbList = [];
  List<dynamic> _hctList = [];

  bool _isLoading = true;

  // Active Firestore stream subscriptions.
  StreamSubscription<dynamic>? _hraSub;
  StreamSubscription<dynamic>? _cancerSub;
  StreamSubscription<dynamic>? _tbSub;
  StreamSubscription<dynamic>? _hctSub;

  Set<ServiceType> get _activeServices {
    final services = <ServiceType>{};
    for (final event in widget.events) {
      services.addAll(
          ServiceTypeConverter.fromStorageString(event.servicesRequested));
    }
    return services;
  }

  // Derived counts from the current list snapshots.
  int get _hraCount => _hraList.length;
  int get _hctCount => _hctList.length;
  int get _tbCount => _tbList.length;
  int get _papSmearCount => _cancerList
      .where((s) => s.papSmearSpecimenCollected?.toLowerCase() == 'yes')
      .length;
  int get _breastScreeningCount => _cancerList
      .where((s) =>
          s.breastLightExamFindings != null &&
          s.breastLightExamFindings!.isNotEmpty)
      .length;
  int get _psaCount => _cancerList
      .where((s) => s.psaResults != null && s.psaResults!.isNotEmpty)
      .length;

  @override
  void initState() {
    super.initState();
    _subscribeToStreams(widget.eventIds);
  }

  @override
  void didUpdateWidget(LiveScreeningCountsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldSet = oldWidget.eventIds.toSet();
    final newSet = widget.eventIds.toSet();
    if (oldSet.length != newSet.length || !oldSet.containsAll(newSet)) {
      _cancelSubscriptions();
      _subscribeToStreams(widget.eventIds);
    }
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  void _cancelSubscriptions() {
    _hraSub?.cancel();
    _cancerSub?.cancel();
    _tbSub?.cancel();
    _hctSub?.cancel();
    _hraSub = _cancerSub = _tbSub = _hctSub = null;
  }

  void _subscribeToStreams(List<String> ids) {
    if (!mounted) return;
    setState(() => _isLoading = true);

    if (ids.isEmpty) {
      setState(() {
        _hraList = [];
        _cancerList = [];
        _tbList = [];
        _hctList = [];
        _isLoading = false;
      });
      return;
    }

    var initialised = 0;
    const totalStreams = 4;

    void markReady() {
      initialised++;
      if (initialised >= totalStreams && mounted) {
        setState(() => _isLoading = false);
      }
    }

    _hraSub = _hraRepo.watchHraScreeningsByEvents(ids).listen(
      (list) {
        if (!mounted) return;
        setState(() => _hraList = list);
        markReady();
      },
      onError: (Object e) {
        debugPrint('LiveScreeningCounts HRA stream error: $e');
        markReady();
      },
    );

    _cancerSub = _cancerRepo.watchCancerScreeningsByEvents(ids).listen(
      (list) {
        if (!mounted) return;
        setState(() => _cancerList = list);
        markReady();
      },
      onError: (Object e) {
        debugPrint('LiveScreeningCounts Cancer stream error: $e');
        markReady();
      },
    );

    _tbSub = _tbRepo.watchTbScreeningsByEvents(ids).listen(
      (list) {
        if (!mounted) return;
        setState(() => _tbList = list);
        markReady();
      },
      onError: (Object e) {
        debugPrint('LiveScreeningCounts TB stream error: $e');
        markReady();
      },
    );

    _hctSub = _hctRepo.watchHctScreeningsByEvents(ids).listen(
      (list) {
        if (!mounted) return;
        setState(() => _hctList = list);
        markReady();
      },
      onError: (Object e) {
        debugPrint('LiveScreeningCounts HCT stream error: $e');
        markReady();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final allScreenings = [
      _ScreeningCount(ServiceType.hra, 'hra', 'HRA', _hraCount,
          Icons.monitor_heart_outlined, Colors.teal.shade600),
      _ScreeningCount(ServiceType.hct, 'hct', 'HCT', _hctCount,
          Icons.bloodtype_outlined, Colors.red.shade600),
      _ScreeningCount(ServiceType.tbTest, 'tb', 'TB', _tbCount,
          Icons.air_outlined, Colors.amber.shade700),
      _ScreeningCount(ServiceType.papSmear, 'cancer', 'Pap Smear',
          _papSmearCount, Icons.science_outlined, Colors.purple.shade500),
      _ScreeningCount(ServiceType.breastScreening, 'cancer', 'Breast',
          _breastScreeningCount, Icons.favorite_border, Colors.pink.shade500),
      _ScreeningCount(ServiceType.psa, 'cancer', 'PSA', _psaCount,
          Icons.biotech_outlined, Colors.indigo.shade500),
    ];

    final activeServices = _activeServices;
    final screenings = activeServices.isEmpty
        ? allScreenings
        : allScreenings
            .where((s) => activeServices.contains(s.serviceType))
            .toList();

    final sectionTitle = widget.isLiveTab
        ? 'Live Screening Counts'
        : 'Health Screening Analytics';
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
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
            )
          else ...[
            // Row 1: HRA / HCT / TB
            _buildScreeningRow(
              screenings
                  .where((s) =>
                      s.serviceKey == 'hra' ||
                      s.serviceKey == 'hct' ||
                      s.serviceKey == 'tb')
                  .toList(),
            ),

            // Injected mid-section (HRA/HCT/TB analytics)
            if (widget.midSectionWidget != null) ...[
              const SizedBox(height: 12),
              widget.midSectionWidget!,
            ],

            // Row 2: Cancer screenings (Pap Smear / Breast / PSA)
            if (screenings.any((s) => s.serviceKey == 'cancer')) ...[
              const SizedBox(height: 10),
              _buildScreeningRow(
                screenings.where((s) => s.serviceKey == 'cancer').toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// Renders a row of up to 3 [_ScreeningCount] cards in an evenly-spaced Row.
  Widget _buildScreeningRow(List<_ScreeningCount> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _ScreeningCountCard(
              label: items[i].label,
              count: _isLoading ? null : items[i].count,
              icon: items[i].icon,
              color: items[i].color,
              isSelected: widget.selectedServiceType == items[i].serviceKey,
              onTap: widget.onCardTapped != null
                  ? () {
                      final next =
                          widget.selectedServiceType == items[i].serviceKey
                              ? null
                              : items[i].serviceKey;
                      widget.onCardTapped!(next);
                    }
                  : null,
            ),
          ),
        ],
        // Pad with invisible spacers if the row has fewer than 3 items,
        // so cards stay the same size as a full 3-column row.
        for (int i = items.length; i < 3; i++) ...[
          const SizedBox(width: 10),
          const Expanded(child: SizedBox()),
        ],
      ],
    );
  }
}

// ── Internal data + card widgets ─────────────────────────────────────────────

class _ScreeningCount {
  const _ScreeningCount(this.serviceType, this.serviceKey, this.label,
      this.count, this.icon, this.color);

  final ServiceType serviceType;

  /// Short key used to group cards for the detail panel (e.g. 'hra', 'hct',
  /// 'tb', 'cancer').
  final String serviceKey;
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
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final int? count;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.18)
              : theme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : KenwellColors.primaryGreen.withValues(alpha: 0.45),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
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
                    child:
                        CircularProgressIndicator(strokeWidth: 2, color: color),
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
            if (onTap != null) ...[
              const SizedBox(height: 2),
              Text(
                isSelected ? 'Tap to hide' : 'Tap for details',
                style: TextStyle(
                  fontSize: 9,
                  color: color.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

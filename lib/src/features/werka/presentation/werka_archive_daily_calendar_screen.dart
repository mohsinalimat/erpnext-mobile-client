import '../../../app/app_router.dart';
import '../../../core/api/mobile_api.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_retry_state.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/native_back_button.dart';
import '../../shared/models/app_models.dart';
import 'werka_archive_list_screen.dart';
import 'widgets/werka_dock.dart';
import 'package:flutter/material.dart';

class WerkaArchiveDailyCalendarScreen extends StatefulWidget {
  const WerkaArchiveDailyCalendarScreen({
    super.key,
    required this.kind,
    this.archiveLoader,
  });

  final WerkaArchiveKind kind;
  final Future<WerkaArchiveResponse> Function({
    required WerkaArchiveKind kind,
    required WerkaArchivePeriod period,
    DateTime? from,
    DateTime? to,
  })? archiveLoader;

  @override
  State<WerkaArchiveDailyCalendarScreen> createState() =>
      _WerkaArchiveDailyCalendarScreenState();
}

class _WerkaArchiveDailyCalendarScreenState
    extends State<WerkaArchiveDailyCalendarScreen> {
  late DateTime _displayMonth;
  bool _loading = true;
  Object? _error;
  Set<int> _activeDays = <int>{};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month, 1);
    _loadMonth();
  }

  Future<WerkaArchiveResponse> _archiveLoader({
    required WerkaArchiveKind kind,
    required WerkaArchivePeriod period,
    DateTime? from,
    DateTime? to,
  }) {
    final loader = widget.archiveLoader;
    if (loader != null) {
      return loader(
        kind: kind,
        period: period,
        from: from,
        to: to,
      );
    }
    return MobileApi.instance.werkaArchive(
      kind: kind,
      period: period,
      from: from,
      to: to,
    );
  }

  Future<void> _loadMonth() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final monthStart = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final monthEnd = DateTime(_displayMonth.year, _displayMonth.month + 1, 0);
    try {
      final result = await _archiveLoader(
        kind: widget.kind,
        period: WerkaArchivePeriod.monthly,
        from: monthStart,
        to: monthEnd,
      );
      if (!mounted) {
        return;
      }
      final activeDays = <int>{};
      for (final item in result.items) {
        final created = parseCreatedLabelTimestamp(item.createdLabel);
        if (created == null) {
          continue;
        }
        if (created.year == _displayMonth.year &&
            created.month == _displayMonth.month) {
          activeDays.add(created.day);
        }
      }
      setState(() {
        _activeDays = activeDays;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _kindTitle(AppLocalizations l10n) {
    switch (widget.kind) {
      case WerkaArchiveKind.received:
        return l10n.archiveReceivedTitle;
      case WerkaArchiveKind.sent:
        return l10n.archiveSentTitle;
      case WerkaArchiveKind.returned:
        return l10n.archiveReturnedTitle;
    }
  }

  List<String> _weekdayLabels(MaterialLocalizations localizations) {
    final narrow = localizations.narrowWeekdays;
    final start = localizations.firstDayOfWeekIndex;
    return [
      for (int i = 0; i < 7; i++) narrow[(start + i) % 7],
    ];
  }

  List<_CalendarCell> _buildCells(MaterialLocalizations localizations) {
    final year = _displayMonth.year;
    final month = _displayMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOffset = DateUtils.firstDayOffset(year, month, localizations);
    final total = ((firstDayOffset + daysInMonth + 6) ~/ 7) * 7;
    return [
      for (int index = 0; index < total; index++)
        if (index < firstDayOffset || index >= firstDayOffset + daysInMonth)
          const _CalendarCell.empty()
        else
          _CalendarCell.day(
            day: index - firstDayOffset + 1,
            active: _activeDays.contains(index - firstDayOffset + 1),
          ),
    ];
  }

  void _openDay(int day) {
    final selected = DateTime(_displayMonth.year, _displayMonth.month, day);
    Navigator.of(context).pushNamed(
      AppRoutes.werkaArchiveList,
      arguments: WerkaArchiveListArgs(
        kind: widget.kind,
        period: WerkaArchivePeriod.daily,
        from: selected,
        to: selected,
      ),
    );
  }

  bool _isToday(int day) {
    final now = DateTime.now();
    return now.year == _displayMonth.year &&
        now.month == _displayMonth.month &&
        now.day == day;
  }

  String _monthSummaryLabel(AppLocalizations l10n) {
    final count = _activeDays.length;
    if (count == 0) {
      return l10n.archiveCalendarEmptyMonth;
    }
    return '$count ta faol kun';
  }

  String _monthAccentLabel(MaterialLocalizations localizations) {
    return localizations
        .formatMonthYear(_displayMonth)
        .split(' ')
        .first
        .toUpperCase();
  }

  void _shiftMonth(int delta) {
    setState(() {
      _displayMonth = DateTime(
        _displayMonth.year,
        _displayMonth.month + delta,
        1,
      );
    });
    _loadMonth();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    useNativeNavigationTitle(context, '${_kindTitle(l10n)} • ${l10n.archiveDailyTitle}');
    return AppShell(
      title: '${_kindTitle(l10n)} • ${l10n.archiveDailyTitle}',
      subtitle: l10n.archiveCalendarHint,
      leading: NativeBackButtonSlot(
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      bottom: const WerkaDock(activeTab: null),
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading && _activeDays.isEmpty) {
      return const Center(child: AppLoadingIndicator());
    }
    if (_error != null && _activeDays.isEmpty) {
      return AppRetryState(onRetry: _loadMonth);
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final localizations = MaterialLocalizations.of(context);
    final l10n = context.l10n;
    final cells = _buildCells(localizations);
    final weekdayLabels = _weekdayLabels(localizations);
    final rowCount = (cells.length / 7).ceil();
    const gridSpacing = 8.0;
    const cellHeight = 50.0;
    final gridHeight = rowCount * cellHeight + (rowCount - 1) * gridSpacing;

    return RefreshIndicator(
      onRefresh: _loadMonth,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 110),
        children: [
          Card.filled(
            margin: EdgeInsets.zero,
            color: scheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CalendarNavButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => _shiftMonth(-1),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              localizations.formatMonthYear(_displayMonth),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _monthSummaryLabel(l10n),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _CalendarNavButton(
                        icon: Icons.chevron_right_rounded,
                        onTap: () => _shiftMonth(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: scheme.primary.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Text(
                        _monthAccentLabel(localizations),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (final label in weekdayLabels)
                        Expanded(
                          child: Container(
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: scheme.surface.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              label,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CalendarLegendDot(
                        color: scheme.primary,
                        label: 'Faol',
                      ),
                      const SizedBox(width: 14),
                      _CalendarLegendDot(
                        color: scheme.outline,
                        label: 'Bugun',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.45),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      height: gridHeight,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cells.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: gridSpacing,
                          crossAxisSpacing: gridSpacing,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          final cell = cells[index];
                          if (!cell.hasDay) {
                            return const SizedBox.shrink();
                          }
                          return _CalendarDayCell(
                            day: cell.day!,
                            active: cell.active,
                            isToday: _isToday(cell.day!),
                            onTap: () => _openDay(cell.day!),
                          );
                        },
                      ),
                    ),
                  ),
                  if (_activeDays.isEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      context.l10n.archiveCalendarEmptyMonth,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarCell {
  const _CalendarCell.empty()
      : hasDay = false,
        day = null,
        active = false;

  const _CalendarCell.day({
    required this.day,
    required this.active,
  }) : hasDay = true;

  final bool hasDay;
  final int? day;
  final bool active;
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.active,
    required this.isToday,
    required this.onTap,
  });

  final int day;
  final bool active;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Material(
      color: active
          ? scheme.primaryContainer
          : scheme.surfaceContainerHighest.withValues(alpha: 0.38),
      borderRadius: BorderRadius.circular(18),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: active
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primaryContainer,
                      scheme.primaryContainer.withValues(alpha: 0.84),
                    ],
                  )
                : null,
            border: Border.all(
              color: active
                  ? scheme.primary
                  : isToday
                      ? scheme.outline
                      : Colors.transparent,
              width: active || isToday ? 1.2 : 0,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '$day',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: active
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                  fontWeight: active || isToday ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (active)
                Positioned(
                  bottom: 6,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarLegendDot extends StatelessWidget {
  const _CalendarLegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CalendarNavButton extends StatelessWidget {
  const _CalendarNavButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface.withValues(alpha: 0.48),
      borderRadius: BorderRadius.circular(16),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Icon(icon, color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

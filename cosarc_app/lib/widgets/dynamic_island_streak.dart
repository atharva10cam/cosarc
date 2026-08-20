import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../../core/theme/cosarc_colors.dart';

const Color _fireOrange = Color(0xFFFF6B35);
const Color _fireOrangeLight = Color(0xFFFF8C42);

// ─────────────────────────────────────────────────────────────
//  DynamicIslandStreak — Apple-accurate sizing
//
//  Compact  : 36h × 126w pill
//  Expanded : width = screen − 32, height = content height
//             (measured via GlobalKey, no fixed guesses)
//  Spring   : mass 1 / stiffness 300 / damping 28  ≈ Apple feel
// ─────────────────────────────────────────────────────────────

class DynamicIslandStreak extends StatefulWidget {
  final int streak;
  final int longestStreak;
  final int weekStreak;
  final int monthStreak;

  const DynamicIslandStreak({
    super.key,
    required this.streak,
    this.longestStreak = 12,
    this.weekStreak = 5,
    this.monthStreak = 23,
  });

  @override
  State<DynamicIslandStreak> createState() => _DynamicIslandStreakState();
}

class _DynamicIslandStreakState extends State<DynamicIslandStreak>
    with SingleTickerProviderStateMixin {
  // ── Spring controller ─────────────────────────────────────
  late AnimationController _ctrl;
  static const _spring =
      SpringDescription(mass: 1, stiffness: 300, damping: 28);

  bool _isExpanded = false;

  // Content gates — swap only once the morph is far enough along
  bool _showCompact = true;
  bool _showExpanded = false;

  // Off-screen sizer — renders content invisibly to get its real height
  final GlobalKey _sizeKey = GlobalKey();
  double _expandedH = 0; // 0 = not measured yet

  static const double _cW = 126; // compact width
  static const double _cH = 36; // compact height  (Apple HIG: 36pt)

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _ctrl.addListener(() {
      final v = _ctrl.value;
      if (_isExpanded && v >= 0.6 && !_showExpanded) {
        setState(() {
          _showExpanded = true;
          _showCompact = false;
        });
      }
      if (!_isExpanded && v <= 0.15 && !_showCompact) {
        setState(() {
          _showCompact = true;
          _showExpanded = false;
        });
      }
    });

    // Measure expanded content height after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    final ctx = _sizeKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final h = box.size.height;
      if (h > 0 && h != _expandedH) setState(() => _expandedH = h);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    // Re-measure each time in case data changed
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());

    setState(() {
      _isExpanded = !_isExpanded;
      _showCompact = false;
      _showExpanded = false;
    });

    _ctrl.animateWith(
      SpringSimulation(_spring, _ctrl.value, _isExpanded ? 1.0 : 0.0, 0.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final eW = (sw - 32).clamp(260.0, 400.0); // expanded width
    final eH =
        _expandedH > 0 ? _expandedH : _cH; // fallback to compact until measured

    return UnconstrainedBox(
      child: Stack(
        children: [
          // ── Off-screen measurer (always rendered, invisible) ──
          Positioned(
            left: -9999,
            top: 0,
            child: SizedBox(
              width: eW,
              child: _buildExpandedContent(key: _sizeKey, measure: true),
            ),
          ),

          // ── Visible animated island ──────────────────────────
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                final t = _ctrl.value;
                final w = _cW + (eW - _cW) * t;
                final h = _cH + (eH - _cH) * t;
                final r = (_cH / 2) * (1 - t) + 22.0 * t;

                return SizedBox(
                  width: eW,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: w,
                      height: h,
                      decoration: BoxDecoration(
                        color: const Color(0xF5000000),
                        borderRadius: BorderRadius.circular(r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.09),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                          if (t > 0.3)
                            BoxShadow(
                              color: CosarcColors.primary.withOpacity(0.05 * t),
                              blurRadius: 20,
                              spreadRadius: -2,
                            ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(r),
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          maxWidth: eW,
                          maxHeight: double.infinity,
                          child: SizedBox(
                            width: eW,
                            child: _buildContent(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Content switcher ───────────────────────────────────────
  Widget _buildContent() {
    if (!_showCompact && !_showExpanded) return const SizedBox.shrink();

    if (_showExpanded) {
      return FadeTransition(
        opacity: _ctrl.drive(
          CurveTween(curve: const Interval(0.55, 1.0, curve: Curves.easeOut)),
        ),
        child: _buildExpandedContent(),
      );
    }

    return FadeTransition(
      opacity: _ctrl.drive(
        ReverseTween(Tween<double>(begin: 0.0, end: 1.0)).chain(
          CurveTween(curve: const Interval(0.0, 0.2, curve: Curves.easeIn)),
        ),
      ),
      child: _buildCompactContent(),
    );
  }

  // ── Compact pill ───────────────────────────────────────────
  Widget _buildCompactContent() {
    return SizedBox(
      height: _cH,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 12),
          _PulsingFireIcon(),
          const SizedBox(width: 7),
          Text(
            '${widget.streak}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            'day streak',
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  // ── Expanded card ──────────────────────────────────────────
  Widget _buildExpandedContent({Key? key, bool measure = false}) {
    final nextMilestone = ((widget.streak ~/ 7) + 1) * 7;
    final progress = widget.streak == 0 ? 0.0 : (widget.streak % 7) / 7.0;

    return Container(
      key: key,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_fireOrange, _fireOrangeLight],
                  ),
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: _fireOrange.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'STREAK',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: Colors.white.withOpacity(0.38),
                      ),
                    ),
                    Text(
                      '${widget.streak} Days',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.05,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              if (!measure)
                Icon(Icons.keyboard_arrow_up_rounded,
                    color: Colors.white.withOpacity(0.18), size: 18),
            ],
          ),

          const SizedBox(height: 10),

          // Divider
          Container(
            height: 0.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.14),
                Colors.transparent,
              ]),
            ),
          ),

          const SizedBox(height: 10),

          // Stats row
          Row(
            children: [
              _stat('Best', '${widget.longestStreak}',
                  Icons.emoji_events_rounded),
              _vDiv(),
              _stat(
                  'Week', '${widget.weekStreak}', Icons.calendar_today_rounded),
              _vDiv(),
              _stat('Month', '${widget.monthStreak}', Icons.bar_chart_rounded),
            ],
          ),

          const SizedBox(height: 10),

          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next milestone · $nextMilestone days',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.32),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: CosarcColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              children: [
                Container(height: 3, color: Colors.white.withOpacity(0.08)),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.02, 1.0),
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [CosarcColors.primary, _fireOrange]),
                      boxShadow: [
                        BoxShadow(
                            color: CosarcColors.primary.withOpacity(0.35),
                            blurRadius: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon) => Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: CosarcColors.primary.withOpacity(0.75)),
            const SizedBox(height: 3),
            Text(value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.4,
                  height: 1,
                )),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.38),
                )),
          ],
        ),
      );

  Widget _vDiv() =>
      Container(width: 0.5, height: 28, color: Colors.white.withOpacity(0.1));
}

// ── Pulsing fire icon ──────────────────────────────────────
class _PulsingFireIcon extends StatefulWidget {
  @override
  State<_PulsingFireIcon> createState() => _PulsingFireIconState();
}

class _PulsingFireIconState extends State<_PulsingFireIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.88, end: 1.12)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: const Icon(Icons.local_fire_department_rounded,
            color: _fireOrange, size: 19),
      );
}

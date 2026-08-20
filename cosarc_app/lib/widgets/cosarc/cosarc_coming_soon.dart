import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_motion.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../services/session_preferences.dart';
import 'cosarc_button.dart';
import 'cosarc_glass.dart';

/// Premium coming-soon experience for unreleased features.
class CosarcComingSoon extends StatefulWidget {
  const CosarcComingSoon({
    super.key,
    required this.featureId,
    required this.overline,
    required this.title,
    required this.subtitle,
    required this.benefits,
    required this.estimatedLaunch,
    required this.icon,
    this.previewItems = const [],
  });

  final String featureId;
  final String overline;
  final String title;
  final String subtitle;
  final List<String> benefits;
  final String estimatedLaunch;
  final IconData icon;
  final List<String> previewItems;

  @override
  State<CosarcComingSoon> createState() => _CosarcComingSoonState();
}

class _CosarcComingSoonState extends State<CosarcComingSoon> {
  bool _onWaitlist = false;
  bool _notifyMe = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = SessionPreferences.instance;
    final onWaitlist = await prefs.isOnWaitlist(widget.featureId);
    final notify = await prefs.wantsNotification(widget.featureId);
    if (mounted) {
      setState(() {
        _onWaitlist = onWaitlist;
        _notifyMe = notify;
        _loading = false;
      });
    }
  }

  Future<void> _joinWaitlist() async {
    await SessionPreferences.instance.joinWaitlist(widget.featureId);
    if (mounted) {
      setState(() => _onWaitlist = true);
      _showFeedback('You\'re on the waitlist. We\'ll notify you at launch.');
    }
  }

  Future<void> _toggleNotify(bool value) async {
    await SessionPreferences.instance.setNotifyMe(widget.featureId, value);
    if (mounted) {
      setState(() => _notifyMe = value);
      _showFeedback(
        value
            ? 'We\'ll notify you when this launches.'
            : 'Notifications turned off.',
      );
    }
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CosarcColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    if (_loading) {
      return const SizedBox.shrink();
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              CosarcSpacing.screenHorizontal,
              topInset + CosarcSpacing.lg,
              CosarcSpacing.screenHorizontal,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.overline, style: CosarcTypography.overline('')),
                const SizedBox(height: CosarcSpacing.xs),
                Text(
                  widget.title,
                  style: CosarcTypography.display(context).copyWith(
                    fontSize: 38,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: CosarcSpacing.sm),
                Text(widget.subtitle, style: CosarcTypography.body(context)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(CosarcSpacing.screenHorizontal),
            child: _HeroIllustration(icon: widget.icon),
          ),
        ),
        if (widget.previewItems.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.screenHorizontal,
              ),
              child: CosarcGlass(
                expand: true,
                padding: const EdgeInsets.all(CosarcSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview',
                      style: CosarcTypography.overline('Preview'),
                    ),
                    const SizedBox(height: CosarcSpacing.md),
                    ...widget.previewItems.map(
                      (item) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: CosarcSpacing.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: CosarcColors.primary,
                            ),
                            const SizedBox(width: CosarcSpacing.sm),
                            Expanded(
                              child: Text(
                                item,
                                style: CosarcTypography.body(context).copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CosarcSpacing.screenHorizontal,
            ),
            child: CosarcGlass(
              expand: true,
              highlight: true,
              padding: const EdgeInsets.all(CosarcSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why you\'ll love it',
                    style: CosarcTypography.title(context),
                  ),
                  const SizedBox(height: CosarcSpacing.md),
                  ...widget.benefits.map(
                    (benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: CosarcSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 7),
                            decoration: const BoxDecoration(
                              color: CosarcColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: CosarcSpacing.sm),
                          Expanded(
                            child: Text(
                              benefit,
                              style: CosarcTypography.body(context).copyWith(
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              CosarcSpacing.screenHorizontal,
              CosarcSpacing.xl,
              CosarcSpacing.screenHorizontal,
              CosarcSpacing.sm,
            ),
            child: CosarcButton(
              label: _onWaitlist ? 'On the waitlist' : 'Join waitlist',
              icon: _onWaitlist
                  ? Icons.check_rounded
                  : Icons.star_outline_rounded,
              onPressed: _onWaitlist ? null : _joinWaitlist,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CosarcSpacing.screenHorizontal,
            ),
            child: CosarcGlass(
              expand: true,
              onTap: () => _toggleNotify(!_notifyMe),
              padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.lg,
                vertical: CosarcSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    _notifyMe
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                    color: CosarcColors.primary,
                  ),
                  const SizedBox(width: CosarcSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notify me at launch',
                          style: CosarcTypography.title(context).copyWith(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.estimatedLaunch,
                          style: CosarcTypography.caption(context),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: CosarcMotion.fast,
                    width: 44,
                    height: 26,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color: _notifyMe
                          ? CosarcColors.primary
                          : CosarcColors.glassFill(0.08),
                    ),
                    child: Align(
                      alignment: _notifyMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: CosarcColors.ink,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: bottomInset + 120),
        ),
      ],
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  CosarcColors.primary.withOpacity(0.15),
                  CosarcColors.primary.withOpacity(0.03),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          CosarcGlass(
            radius: CosarcSpacing.radiusXl,
            blur: 24,
            highlight: true,
            padding: const EdgeInsets.all(CosarcSpacing.xxxl),
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  CosarcColors.brandSweep.createShader(bounds),
              child: Icon(icon, size: 48, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows a premium coming-soon dialog for in-app features.
void showCosarcComingSoonSheet(
  BuildContext context, {
  required String title,
  required String message,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(
        CosarcSpacing.screenHorizontal,
        0,
        CosarcSpacing.screenHorizontal,
        MediaQuery.of(context).padding.bottom + CosarcSpacing.lg,
      ),
      child: CosarcGlass(
        expand: true,
        padding: const EdgeInsets.all(CosarcSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_top_rounded,
                color: CosarcColors.primary, size: 32),
            const SizedBox(height: CosarcSpacing.md),
            Text(title, style: CosarcTypography.title(context)),
            const SizedBox(height: CosarcSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: CosarcTypography.body(context),
            ),
            const SizedBox(height: CosarcSpacing.xl),
            CosarcButton(
              label: 'Got it',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    ),
  );
}

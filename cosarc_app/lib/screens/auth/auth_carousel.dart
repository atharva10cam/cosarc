import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_motion.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_glass.dart';

class AuthCarouselSlide {
  const AuthCarouselSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class AuthCarousel extends StatefulWidget {
  const AuthCarousel({super.key, required this.slides});

  final List<AuthCarouselSlide> slides;

  @override
  State<AuthCarousel> createState() => _AuthCarouselState();
}

class _AuthCarouselState extends State<AuthCarousel> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 148,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (value) => setState(() => _index = value),
            itemCount: widget.slides.length,
            itemBuilder: (context, index) {
              final slide = widget.slides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CosarcSpacing.xs,
                ),
                child: CosarcGlass(
                  expand: true,
                  highlight: index == _index,
                  padding: const EdgeInsets.all(CosarcSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: CosarcColors.brandSweep,
                        ),
                        child: Icon(slide.icon, color: CosarcColors.ink),
                      ),
                      const SizedBox(width: CosarcSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              slide.title,
                              style: CosarcTypography.title(context).copyWith(
                                fontSize: 17,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: CosarcSpacing.xxs),
                            Text(
                              slide.subtitle,
                              style: CosarcTypography.caption(context),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: CosarcSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.slides.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: CosarcMotion.fast,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: active
                    ? CosarcColors.primary
                    : CosarcColors.glassFill(0.12),
              ),
            );
          }),
        ),
      ],
    );
  }
}

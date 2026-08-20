import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';

/// Premium dark scaffold with ambient gradient layers.
class CosarcScaffold extends StatelessWidget {
  const CosarcScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.showAmbientGlow = true,
    this.backgroundColor,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool showAmbientGlow;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? CosarcColors.background,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (showAmbientGlow) ...[
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: CosarcColors.appBackgroundGradient,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.9, -0.75),
                  radius: 1.1,
                  colors: [
                    CosarcColors.primary.withOpacity(0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.85, 1.0),
                  radius: 0.9,
                  colors: [
                    CosarcColors.rose.withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
          body,
        ],
      ),
    );
  }
}

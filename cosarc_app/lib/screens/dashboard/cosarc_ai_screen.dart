import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/cosarc_section.dart';

class CosarcAIScreen extends StatefulWidget {
  const CosarcAIScreen({super.key});

  @override
  State<CosarcAIScreen> createState() => _CosarcAIScreenState();
}

class _CosarcAIScreenState extends State<CosarcAIScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestedQuestions = [
    'Best exercises for muscle gain?',
    'How much protein should I eat?',
    'Tips for better sleep recovery?',
  ];

  static const double _floatingNavClearance = 88;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    try {
      setState(() {
        _messages.add({
          'text': _messageController.text,
          'isUser': true,
        });

        // Simulate AI response
        _messages.add({
          'text':
              'This is where Cosarc AI would respond to your fitness questions. Connect your AI service here.',
          'isUser': false,
        });
      });

      _messageController.clear();

      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  double _bottomPadding(BuildContext context) =>
      MediaQuery.of(context).padding.bottom + _floatingNavClearance;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          SizedBox(height: topInset),
          _buildHeader(context),
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(context)
                : _buildMessageList(context),
          ),
          _buildInputField(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CosarcSpacing.screenHorizontal,
        CosarcSpacing.md,
        CosarcSpacing.screenHorizontal,
        CosarcSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CosarcGlass(
            radius: CosarcSpacing.radiusMd,
            blur: 16,
            padding: const EdgeInsets.all(CosarcSpacing.sm),
            highlight: true,
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  CosarcColors.brandSweep.createShader(bounds),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: CosarcSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'COSARC AI',
                      style: CosarcTypography.overline('COSARC AI'),
                    ),
                    const SizedBox(width: CosarcSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: CosarcColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: CosarcColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'BETA',
                        style: CosarcTypography.caption(context).copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: CosarcColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: CosarcSpacing.xxs),
                Text(
                  'Fitness intelligence',
                  style: CosarcTypography.caption(context),
                ),
              ],
            ),
          ),
          CosarcGlass(
            radius: CosarcSpacing.radiusPill,
            blur: 12,
            opacity: 0.04,
            padding: const EdgeInsets.symmetric(
              horizontal: CosarcSpacing.sm,
              vertical: CosarcSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: CosarcColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: CosarcSpacing.xs),
                Text(
                  'Online',
                  style: CosarcTypography.caption(context).copyWith(
                    fontSize: 11,
                    color: CosarcColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        CosarcSpacing.screenHorizontal,
        CosarcSpacing.xxxl,
        CosarcSpacing.screenHorizontal,
        CosarcSpacing.xl,
      ),
      child: Column(
        children: [
          _buildHeroOrb(),
          const SizedBox(height: CosarcSpacing.xxl),
          Text(
            'Ask me anything',
            style: CosarcTypography.headline(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: CosarcSpacing.sm),
          Text(
            'Personalized fitness advice, workout tips,\nand nutrition guidance — powered by AI',
            textAlign: TextAlign.center,
            style: CosarcTypography.body(context),
          ),
          const SizedBox(height: CosarcSpacing.xxxl),
          const CosarcSectionHeader(
            overline: 'Suggestions',
            title: 'Try asking',
          ),
          ..._suggestedQuestions.map(_buildSuggestionChip),
          const SizedBox(height: CosarcSpacing.xl),
          CosarcGlass(
            expand: true,
            radius: CosarcSpacing.radiusMd,
            blur: 16,
            opacity: 0.035,
            padding: const EdgeInsets.all(CosarcSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: CosarcColors.textTertiary,
                  size: 18,
                ),
                const SizedBox(width: CosarcSpacing.sm),
                Expanded(
                  child: Text(
                    'AI provides fitness guidance only. Not medical advice.',
                    style: CosarcTypography.caption(context).copyWith(
                      height: 1.45,
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

  Widget _buildHeroOrb() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  CosarcColors.primary.withOpacity(0.18),
                  CosarcColors.primary.withOpacity(0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          CosarcGlass(
            radius: CosarcSpacing.radiusPill,
            blur: 20,
            highlight: true,
            padding: const EdgeInsets.all(CosarcSpacing.xl),
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  CosarcColors.brandSweep.createShader(bounds),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String question) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CosarcSpacing.screenHorizontal,
        0,
        CosarcSpacing.screenHorizontal,
        CosarcSpacing.sm,
      ),
      child: CosarcGlass(
        expand: true,
        radius: CosarcSpacing.radiusMd,
        blur: 16,
        opacity: 0.04,
        padding: const EdgeInsets.symmetric(
          horizontal: CosarcSpacing.md,
          vertical: CosarcSpacing.md,
        ),
        onTap: () {
          _messageController.text = question;
          _sendMessage();
        },
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: CosarcColors.primaryMuted,
                borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
              ),
              child: const Icon(
                Icons.arrow_outward_rounded,
                color: CosarcColors.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: CosarcSpacing.sm),
            Expanded(
              child: Text(
                question,
                style: CosarcTypography.body(context).copyWith(
                  color: CosarcColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: CosarcColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        CosarcSpacing.screenHorizontal,
        CosarcSpacing.md,
        CosarcSpacing.screenHorizontal,
        CosarcSpacing.md,
      ),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(
          message['text'],
          message['isUser'],
        );
      },
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CosarcSpacing.md),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const CosarcGlass(
              radius: CosarcSpacing.radiusSm,
              blur: 12,
              padding: EdgeInsets.all(CosarcSpacing.xs),
              highlight: true,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: CosarcColors.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: CosarcSpacing.sm),
          ],
          Flexible(
            child: CosarcGlass(
              radius: CosarcSpacing.radiusLg,
              blur: isUser ? 12 : 16,
              opacity: isUser ? 0.06 : 0.04,
              highlight: isUser,
              padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.md,
                vertical: CosarcSpacing.sm + 2,
              ),
              child: Text(
                text,
                style: CosarcTypography.body(context).copyWith(
                  color: CosarcColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: CosarcSpacing.sm),
            const CosarcGlass(
              radius: CosarcSpacing.radiusSm,
              blur: 12,
              opacity: 0.04,
              padding: EdgeInsets.all(CosarcSpacing.xs),
              child: Icon(
                Icons.person_outline_rounded,
                color: CosarcColors.textSecondary,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    final hasText = _messageController.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        CosarcSpacing.screenHorizontal,
        CosarcSpacing.sm,
        CosarcSpacing.screenHorizontal,
        _bottomPadding(context),
      ),
      child: CosarcGlass(
        expand: true,
        radius: CosarcSpacing.radiusPill,
        blur: 24,
        opacity: 0.06,
        borderOpacity: 0.14,
        padding: const EdgeInsets.fromLTRB(
          CosarcSpacing.lg,
          CosarcSpacing.xxs,
          CosarcSpacing.xxs,
          CosarcSpacing.xxs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                onChanged: (_) => setState(() {}),
                style: CosarcTypography.body(context).copyWith(
                  color: CosarcColors.textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask Cosarc AI…',
                  hintStyle: CosarcTypography.body(context).copyWith(
                    color: CosarcColors.textTertiary,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: CosarcSpacing.sm + 2,
                  ),
                ),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: CosarcSpacing.xs),
            GestureDetector(
              onTap: _sendMessage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: hasText
                      ? CosarcColors.brandSweep
                      : LinearGradient(
                          colors: [
                            CosarcColors.glassFill(0.08),
                            CosarcColors.glassFill(0.08),
                          ],
                        ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: hasText
                        ? CosarcColors.primary.withOpacity(0.4)
                        : CosarcColors.border,
                  ),
                  boxShadow: hasText
                      ? CosarcColors.glow(CosarcColors.primary, 0.2)
                      : null,
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: hasText ? CosarcColors.ink : CosarcColors.textTertiary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

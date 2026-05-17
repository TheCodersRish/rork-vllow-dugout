import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/chat_message.dart';
import '../providers/coach_view_model.dart';
import '../services/ai_coach_service.dart';
import '../utils/app_theme.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isTyping = false;

  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _dotController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final coach = context.read<CoachViewModel>();
    setState(() {
      _textController.clear();
      _isTyping = true;
    });
    coach.addUserMessage(text.trim());
    _scrollToBottom();

    final delay = 800 + (text.length * 8).clamp(0, 1200);
    Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      final response = AiCoachService.generateResponse(text);
      final coach = context.read<CoachViewModel>();
      coach.addAssistantMessage(
        ChatMessage(
          role: MessageRole.assistant,
          content: response,
          drillAttachment: _shouldAttachDrill(text)
              ? DrillAttachment(
                  title: _drillTitle(text),
                  subtitle: _drillSubtitle(text),
                  imageURL:
                      'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=400',
                  duration: '12M 30S',
                )
              : null,
        ),
      );
      setState(() {
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  String _drillTitle(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('cover drive')) return 'Cover Drive Masterclass';
    if (lower.contains('bowling') || lower.contains('swing'))
      return 'Swing Bowling Drill';
    if (lower.contains('fielding') || lower.contains('catch'))
      return 'Fielding Reactions Drill';
    if (lower.contains('spin')) return 'Spin Bowling Workshop';
    return 'Training Session';
  }

  String _drillSubtitle(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('bowling') ||
        lower.contains('swing') ||
        lower.contains('spin')) {
      return 'BOWLING \u2022 15M';
    }
    if (lower.contains('fielding') || lower.contains('catch'))
      return 'FIELDING \u2022 12M';
    return 'BATTING \u2022 12M 30S';
  }

  bool _shouldAttachDrill(String input) {
    final lower = input.toLowerCase();
    return lower.contains('drill') ||
        lower.contains('cover drive') ||
        lower.contains('practice') ||
        lower.contains('train') ||
        lower.contains('session');
  }

  @override
  Widget build(BuildContext context) {
    final coach = context.watch<CoachViewModel>();
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          _buildCoachHeader(coach),
          Expanded(child: _buildChatMessages(coach.messages)),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildCoachHeader(CoachViewModel coach) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        border: const Border(
          bottom: BorderSide(color: AppTheme.border, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonGreen.withOpacity(0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'LIVE AI ANALYSIS',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: coach.messages.length <= 1 ? null : coach.clearHistory,
                child: const Text(
                  'RESET',
                  style: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'SESSION ${coach.sessionCount}',
                style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'FR-03 Coach',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(List<ChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isTyping && index == messages.length) {
          return Padding(
            padding: EdgeInsets.only(top: index > 0 ? 24 : 0),
            child: _TypingIndicator(controller: _dotController),
          );
        }
        final msg = messages[index];
        return Padding(
          padding: EdgeInsets.only(top: index > 0 ? 20 : 0),
          child: _ChatBubble(
            message: msg,
            onSuggestionTap: _sendMessage,
            showLabel: _shouldShowLabel(messages, index),
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    final hasText = _textController.text.trim().isNotEmpty;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, bottomPad + 90),
      decoration: const BoxDecoration(
        color: AppTheme.darkBg,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 0.5),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(28),
          border:
              Border.all(color: AppTheme.border.withOpacity(0.5), width: 0.5),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                style:
                    const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                maxLines: null,
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  hintText: 'Ask your coach anything...',
                  hintStyle:
                      TextStyle(color: AppTheme.textTertiary, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  isDense: true,
                ),
                onSubmitted: _sendMessage,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: hasText ? () => _sendMessage(_textController.text) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      hasText ? AppTheme.neonGreen : AppTheme.cardSurfaceLight,
                  shape: BoxShape.circle,
                  boxShadow: hasText
                      ? [
                          BoxShadow(
                            color: AppTheme.neonGreen.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: hasText ? Colors.black : AppTheme.textTertiary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowLabel(List<ChatMessage> messages, int index) {
    if (index == 0) return true;
    final msg = messages[index];
    if (msg.role == MessageRole.user) return false;
    if (index > 0 && messages[index - 1].role == MessageRole.user) return true;
    return false;
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final void Function(String) onSuggestionTap;
  final bool showLabel;

  const _ChatBubble({
    required this.message,
    required this.onSuggestionTap,
    this.showLabel = true,
  });

  String _formatTimestamp(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!isUser && showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppTheme.neonGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'AI COACH',
                  style: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isUser
                ? Color.alphaBlend(
                    AppTheme.neonGreen.withOpacity(0.12),
                    const Color.fromRGBO(20, 40, 15, 1),
                  )
                : AppTheme.cardSurface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isUser ? 20 : 4),
              topRight: Radius.circular(isUser ? 4 : 20),
              bottomLeft: const Radius.circular(20),
              bottomRight: const Radius.circular(20),
            ),
            border: Border.all(
              color: isUser
                  ? AppTheme.neonGreen.withOpacity(0.2)
                  : AppTheme.border.withOpacity(0.5),
              width: 0.5,
            ),
          ),
          child: _buildMessageContent(message.content, isUser),
        ),
        if (isUser)
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 4),
            child: Text(
              _formatTimestamp(message.timestamp),
              style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 10,
              ),
            ),
          ),
        if (message.drillAttachment != null) ...[
          const SizedBox(height: 12),
          _DrillAttachmentCard(attachment: message.drillAttachment!),
        ],
      ],
    );
  }

  Widget _buildMessageContent(String content, bool isUser) {
    if (isUser) {
      return Text(
        content,
        style: const TextStyle(
          color: AppTheme.neonGreen,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      );
    }

    final parts = content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts.map((line) {
        if (line.startsWith('**') && line.endsWith('**')) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              line.replaceAll('**', ''),
              style: const TextStyle(
                color: AppTheme.neonGreen,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          );
        }
        if (line.contains('**')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: _buildRichLine(line),
          );
        }
        if (line.startsWith('- ') || line.startsWith('• ')) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child:
                      Icon(Icons.circle, size: 4, color: AppTheme.textTertiary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRichLine(line.substring(2)),
                ),
              ],
            ),
          );
        }
        if (RegExp(r'^\d+\.\s').hasMatch(line)) {
          final numEnd = line.indexOf('. ');
          return Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  child: Text(
                    line.substring(0, numEnd + 1),
                    style: const TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildRichLine(line.substring(numEnd + 2)),
                ),
              ],
            ),
          );
        }
        if (line.isEmpty) return const SizedBox(height: 8);
        return _buildRichLine(line);
      }).toList(),
    );
  }

  Widget _buildRichLine(String line) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(line)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: line.substring(lastEnd, match.start),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < line.length) {
      spans.add(TextSpan(
        text: line.substring(lastEnd),
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ));
    }

    if (spans.isEmpty) {
      return Text(
        line,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }
}

class _DrillAttachmentCard extends StatelessWidget {
  final DrillAttachment attachment;

  const _DrillAttachmentCard({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.78,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: attachment.imageURL,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppTheme.cardSurface),
              errorWidget: (_, __, ___) => Container(
                color: AppTheme.cardSurface,
                child: const Icon(Icons.sports_cricket,
                    color: AppTheme.textTertiary, size: 36),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonGreen.withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child:
                    const Icon(Icons.play_arrow, color: Colors.black, size: 28),
              ),
            ),
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    attachment.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: AppTheme.neonGreen.withOpacity(0.4),
                    width: 0.5,
                  ),
                ),
                child: const Text(
                  'TAP TO START',
                  style: TextStyle(
                    color: AppTheme.neonGreen,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final AnimationController controller;

  const _TypingIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.neonGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'FR-03 ASSISTANT',
                style: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border:
                Border.all(color: AppTheme.border.withOpacity(0.5), width: 0.5),
          ),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final offset = (controller.value + i * 0.2).remainder(1.0);
                  final y = -4.0 * (offset < 0.5 ? offset : 1.0 - offset);
                  return Transform.translate(
                    offset: Offset(0, y * 2),
                    child: Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.neonGreen.withOpacity(
                          0.4 + 0.6 * (offset < 0.5 ? offset : 1.0 - offset),
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}

import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import '/services/chat_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'chat_history_model.dart';
export 'chat_history_model.dart';

class ChatHistoryWidget extends StatefulWidget {
  const ChatHistoryWidget(this.familyMemberId, {super.key});

  static String routeName = 'ChatHistory';
  static String routePath = 'chatHistory';

  final String? familyMemberId;

  @override
  State<ChatHistoryWidget> createState() => _ChatHistoryWidgetState();
}

class _ChatHistoryWidgetState extends State<ChatHistoryWidget> {
  late ChatHistoryModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatHistoryModel());
    ChatManager.instance.initialize();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _createNewChat() {
    if (widget.familyMemberId == null) return;
    final conversation = ChatManager.instance.createConversation(widget.familyMemberId!);
    context.pushNamed(
      'ChatRoom',
      extra: <String, dynamic>{
        'conversationId': conversation.id,
      },
    );
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ChatManager.instance,
      builder: (context, _) {
        final conversations = widget.familyMemberId != null
            ? ChatManager.instance.getMembersConversations(widget.familyMemberId!)
            : <ChatConversation>[];

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: BinaColors.surfaceAlt,
            body: Stack(
              children: [
                // Content
                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: 54,
                    bottom: 120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chats',
                                  style: BinaType.displaySm,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'On-device · Gemma 3',
                                  style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                                ),
                              ],
                            ),
                            BinaIconButton(
                              icon: Icons.search_rounded,
                              onPressed: () {
                                // TODO: Implement search
                              },
                            ),
                          ],
                        ),
                      ).animate()
                          .fadeIn(duration: 400.ms)
                          .moveY(begin: 20, end: 0, duration: 400.ms),

                      // Conversations list
                      if (conversations.isEmpty)
                        _buildEmptyState()
                      else
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Column(
                            children: conversations.asMap().entries.map((entry) {
                              final index = entry.key;
                              final conversation = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _ConversationCard(
                                  conversation: conversation,
                                  timeAgo: conversation.messages.isNotEmpty
                                      ? _formatTimeAgo(conversation.messages.last.timestamp)
                                      : 'New',
                                  onTap: () {
                                    context.pushNamed(
                                      'ChatRoom',
                                      extra: <String, dynamic>{
                                        'conversationId': conversation.id,
                                      },
                                    );
                                  },
                                  onDelete: () {
                                    _showDeleteDialog(conversation);
                                  },
                                ),
                              ).animate()
                                  .fadeIn(
                                    delay: Duration(milliseconds: 200 + (index * 80)),
                                    duration: 400.ms,
                                  )
                                  .moveY(
                                    begin: 20,
                                    end: 0,
                                    delay: Duration(milliseconds: 200 + (index * 80)),
                                    duration: 400.ms,
                                  );
                            }).toList(),
                          ),
                        ),

                      // New chat button
                      if (widget.familyMemberId != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: _NewChatButton(onTap: _createNewChat),
                        ).animate()
                            .fadeIn(delay: 400.ms, duration: 400.ms)
                            .moveY(begin: 20, end: 0, delay: 400.ms, duration: 400.ms),
                    ],
                  ),
                ),
                // Floating bottom nav
                if (responsiveVisibility(
                  context: context,
                  tablet: false,
                  tabletLandscape: false,
                  desktop: false,
                ))
                  const BinaFloatingNav(currentTab: BinaNavTab.chat),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: BinaColors.primary100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                color: BinaColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: BinaType.titleLg,
            ),
            const SizedBox(height: 4),
            Text(
              'Start a new chat to ask questions about dental health.',
              style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(delay: 300.ms, duration: 400.ms);
  }

  void _showDeleteDialog(ChatConversation conversation) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BinaColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BinaRadius.lg),
        ),
        title: Text(
          'Delete conversation?',
          style: BinaType.headlineSm,
        ),
        content: Text(
          'This will permanently delete this conversation and all its messages.',
          style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: BinaType.labelLg.copyWith(color: BinaColors.ink2),
            ),
          ),
          TextButton(
            onPressed: () {
              ChatManager.instance.deleteConversation(conversation.id);
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Delete',
              style: BinaType.labelLg.copyWith(color: BinaColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CONVERSATION CARD
// ═══════════════════════════════════════════════════════════════

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({
    required this.conversation,
    required this.timeAgo,
    required this.onTap,
    required this.onDelete,
  });

  final ChatConversation conversation;
  final String timeAgo;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  String get _preview {
    if (conversation.messages.isEmpty) return 'No messages yet';
    final lastMessage = conversation.messages.last.content;
    if (lastMessage.length > 60) {
      return '${lastMessage.substring(0, 60)}...';
    }
    return lastMessage;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: BinaColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BinaColors.line),
          boxShadow: BinaElevation.sh1,
        ),
        child: Row(
          children: [
            // Avatar placeholder (using chat icon for now)
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: BinaColors.primary100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                color: BinaColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.title,
                    style: BinaType.titleMd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _preview,
                    style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Time
            Text(
              timeAgo,
              style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NEW CHAT BUTTON
// ═══════════════════════════════════════════════════════════════

class _NewChatButton extends StatefulWidget {
  const _NewChatButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_NewChatButton> createState() => _NewChatButtonState();
}

class _NewChatButtonState extends State<_NewChatButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: BinaMotion.d1,
        transform: _isPressed
            ? (Matrix4.identity()..scale(0.98, 0.98))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: BinaColors.gradHero,
          borderRadius: BorderRadius.circular(16),
          boxShadow: BinaElevation.shHero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Start a new conversation',
              style: BinaType.labelLg.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

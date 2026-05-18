import '/app_core/app_util.dart';
import '/backend/schema/structs/index.dart';
import '/bina_design/bina_design.dart';
import '/services/chat_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
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
  String? _selectedMemberId;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatHistoryModel());
    ChatManager.instance.initialize();
    _selectedMemberId = widget.familyMemberId;
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _createNewChat() {
    if (_selectedMemberId == null) return;
    final conversation = ChatManager.instance.createConversation(_selectedMemberId!);
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
    context.watch<AppState>();

    final family = AppState().UserSession.family;

    // If no member is selected, show member selection
    if (_selectedMemberId == null && family.isNotEmpty) {
      return _buildMemberSelectionScreen(family);
    }

    return ListenableBuilder(
      listenable: ChatManager.instance,
      builder: (context, _) {
        final conversations = _selectedMemberId != null
            ? ChatManager.instance.getMembersConversations(_selectedMemberId!)
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
                            Row(
                              children: [
                                // Switch member button
                                BinaIconButton(
                                  icon: Icons.people_outline_rounded,
                                  onPressed: () {
                                    setState(() => _selectedMemberId = null);
                                  },
                                ),
                                const SizedBox(width: 8),
                                BinaIconButton(
                                  icon: Icons.search_rounded,
                                  onPressed: () {
                                    // TODO: Implement search
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate()
                          .fadeIn(duration: 400.ms)
                          .moveY(begin: 20, end: 0, duration: 400.ms),

                      // Selected member indicator
                      if (_selectedMemberId != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: _SelectedMemberChip(
                            member: family.firstWhere(
                              (m) => m.id == _selectedMemberId,
                              orElse: () => FamilyMemberStruct(name: 'Unknown'),
                            ),
                            onTap: () => setState(() => _selectedMemberId = null),
                          ),
                        ).animate()
                            .fadeIn(delay: 100.ms, duration: 300.ms),

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
                      if (_selectedMemberId != null)
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

  Widget _buildMemberSelectionScreen(List<FamilyMemberStruct> family) {
    return Scaffold(
      backgroundColor: BinaColors.surfaceAlt,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 54, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chat with Gemma',
                        style: BinaType.displaySm,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select a family member to start or continue a conversation.',
                        style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                      ),
                    ],
                  ),
                ).animate()
                    .fadeIn(duration: 400.ms)
                    .moveY(begin: 20, end: 0, duration: 400.ms),

                // Member list
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    children: family.asMap().entries.map((entry) {
                      final index = entry.key;
                      final member = entry.value;
                      final conversationCount = ChatManager.instance
                          .getMembersConversations(member.id)
                          .length;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _MemberSelectCard(
                          member: member,
                          conversationCount: conversationCount,
                          onTap: () {
                            setState(() => _selectedMemberId = member.id);
                          },
                        ),
                      ).animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 200 + (index * 100)),
                            duration: 400.ms,
                          )
                          .moveY(
                            begin: 20,
                            end: 0,
                            delay: Duration(milliseconds: 200 + (index * 100)),
                            duration: 400.ms,
                          );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (responsiveVisibility(
            context: context,
            tablet: false,
            tabletLandscape: false,
            desktop: false,
          ))
            const BinaFloatingNav(currentTab: BinaNavTab.chat),
        ],
      ),
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
// SELECTED MEMBER CHIP
// ═══════════════════════════════════════════════════════════════

class _SelectedMemberChip extends StatelessWidget {
  const _SelectedMemberChip({
    required this.member,
    required this.onTap,
  });

  final FamilyMemberStruct member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: BinaColors.primary100,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BinaAvatar(
              name: member.name,
              size: 24,
              tone: BinaAvatarTone.blue,
            ),
            const SizedBox(width: 8),
            Text(
              member.name,
              style: BinaType.labelMd.copyWith(color: BinaColors.primary700),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.close_rounded,
              size: 16,
              color: BinaColors.primary700,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MEMBER SELECT CARD
// ═══════════════════════════════════════════════════════════════

class _MemberSelectCard extends StatelessWidget {
  const _MemberSelectCard({
    required this.member,
    required this.conversationCount,
    required this.onTap,
  });

  final FamilyMemberStruct member;
  final int conversationCount;
  final VoidCallback onTap;

  BinaAvatarTone get _avatarTone {
    final hash = member.name.hashCode;
    final tones = BinaAvatarTone.values;
    return tones[hash.abs() % (tones.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: BinaColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: BinaColors.line),
          boxShadow: BinaElevation.sh2,
        ),
        child: Row(
          children: [
            BinaAvatar(
              name: member.name,
              size: 48,
              tone: _avatarTone,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: BinaType.titleLg),
                  const SizedBox(height: 2),
                  Text(
                    conversationCount > 0
                        ? '$conversationCount conversation${conversationCount == 1 ? '' : 's'}'
                        : 'No conversations yet',
                    style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BinaColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
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
            const Icon(
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

import '/app_core/app_util.dart';
import '/backend/schema/structs/index.dart';
import '/bina_design/bina_design.dart';
import '/services/chat_manager.dart';
import '/services/gemma_service.dart';
import '/services/gemma_agent/index.dart';
import '/pages/nav_pages/web_nav/web_nav_widget.dart';
import '/components/gemma_download_progress/gemma_download_progress_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
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
  String? _selectedConversationId;

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
    final bp = BinaBreakpoints.fromContext(context);
    if (bp == BinaBreakpoint.phone) {
      context.pushNamed(
        'ChatRoom',
        extra: <String, dynamic>{
          'conversationId': conversation.id,
        },
      );
    } else {
      setState(() {
        _selectedConversationId = conversation.id;
      });
    }
  }

  String _formatTimeAgo(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return AppLocalizations.of(context).getText('chat_just_now');
    if (diff.inMinutes < 60) return '${diff.inMinutes}${AppLocalizations.of(context).getText('chat_m_ago')}';
    if (diff.inHours < 24) return '${diff.inHours}${AppLocalizations.of(context).getText('chat_h_ago')}';
    if (diff.inDays == 1) return AppLocalizations.of(context).getText('chat_yesterday');
    if (diff.inDays < 7) return '${diff.inDays}${AppLocalizations.of(context).getText('chat_d_ago')}';
    return DateFormat('d MMM').format(time);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();

    final family = AppState().UserSession.family;
    final bp = BinaBreakpoints.fromContext(context);
    final isWide = bp != BinaBreakpoint.phone;

    // If no member is selected, show member selection
    if (_selectedMemberId == null && family.isNotEmpty) {
      return _buildMemberSelectionScreen(family, isWide);
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
            body: Row(
              children: [
                // Web nav for larger screens
                if (isWide)
                  wrapWithModel(
                    model: _model.webNavModel,
                    updateCallback: () => safeSetState(() {}),
                    child: WebNavWidget(currentTab: BinaNavTab.chat),
                  ),
                // Main content
                Expanded(
                  child: isWide
                      ? _buildWideLayout(
                          context: context,
                          family: family,
                          conversations: conversations,
                        )
                      : _buildPhoneLayout(
                          context: context,
                          family: family,
                          conversations: conversations,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhoneLayout({
    required BuildContext context,
    required List<FamilyMemberStruct> family,
    required List<ChatConversation> conversations,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 12,
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
                            AppLocalizations.of(context).getText('chat_title'),
                            style: BinaType.displaySm,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLocalizations.of(context).getText('chat_subtitle'),
                            style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                          ),
                        ],
                      ),
                      Row(
                        children: [
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
                                ? _formatTimeAgo(context, conversation.messages.last.timestamp)
                                : AppLocalizations.of(context).getText('chat_new'),
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
          ),
        ),
        // Floating bottom nav
        const BinaFloatingNav(currentTab: BinaNavTab.chat),
      ],
    );
  }

  Widget _buildWideLayout({
    required BuildContext context,
    required List<FamilyMemberStruct> family,
    required List<ChatConversation> conversations,
  }) {
    final selectedConversation = _selectedConversationId != null
        ? ChatManager.instance.getConversation(_selectedConversationId!)
        : null;

    return Row(
      children: [
        // Master panel - conversation list
        SizedBox(
          width: 380,
          child: Container(
            decoration: BoxDecoration(
              color: BinaColors.surface,
              border: Border(
                right: BorderSide(color: BinaColors.line),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context).getText('chat_title'), style: BinaType.displaySm),
                          const SizedBox(height: 2),
                          Text(
                            AppLocalizations.of(context).getText('chat_subtitle'),
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
                ),

                // Conversation list
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      children: [
                        if (conversations.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: BinaColors.ink3,
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  AppLocalizations.of(context).getText('chat_no_conversations'),
                                  style: BinaType.titleMd,
                                ),
                              ],
                            ),
                          )
                        else
                          ...conversations.map((conversation) {
                            final isSelected = conversation.id == _selectedConversationId;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _ConversationCard(
                                conversation: conversation,
                                timeAgo: conversation.messages.isNotEmpty
                                    ? _formatTimeAgo(context, conversation.messages.last.timestamp)
                                    : AppLocalizations.of(context).getText('chat_new'),
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    _selectedConversationId = conversation.id;
                                  });
                                },
                                onDelete: () {
                                  _showDeleteDialog(conversation);
                                },
                              ),
                            );
                          }),
                        const SizedBox(height: 12),
                        _NewChatButton(onTap: _createNewChat),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Detail panel - chat room
        Expanded(
          child: selectedConversation != null
              ? _InlineChatRoom(
                  key: ValueKey(selectedConversation.id),
                  conversation: selectedConversation,
                  memberId: _selectedMemberId,
                  family: family,
                )
              : _NoChatSelectedPanel(onNewChat: _createNewChat),
        ),
      ],
    );
  }

  Widget _buildMemberSelectionScreen(List<FamilyMemberStruct> family, bool isWide) {
    return Scaffold(
      backgroundColor: BinaColors.surfaceAlt,
      body: Row(
        children: [
          if (isWide)
            wrapWithModel(
              model: _model.webNavModel,
              updateCallback: () => safeSetState(() {}),
              child: WebNavWidget(currentTab: BinaNavTab.chat),
            ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: isWide ? 24 : 54,
                      bottom: isWide ? 24 : 120,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context).getText('chat_with_gemma'),
                                  style: BinaType.displaySm,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppLocalizations.of(context).getText('chat_select_member'),
                                  style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                                ),
                              ],
                            ),
                          ).animate()
                              .fadeIn(duration: 400.ms)
                              .moveY(begin: 20, end: 0, duration: 400.ms),

                          // Member list
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
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
                  ),
                ),
                if (!isWide)
                  const BinaFloatingNav(currentTab: BinaNavTab.chat),
              ],
            ),
          ),
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
              AppLocalizations.of(context).getText('chat_no_conversations'),
              style: BinaType.titleLg,
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).getText('chat_start_dental'),
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
          AppLocalizations.of(context).getText('chat_delete_title'),
          style: BinaType.headlineSm,
        ),
        content: Text(
          AppLocalizations.of(context).getText('chat_delete_message'),
          style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              AppLocalizations.of(context).getText('chat_cancel'),
              style: BinaType.labelLg.copyWith(color: BinaColors.ink2),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_selectedConversationId == conversation.id) {
                _selectedConversationId = null;
              }
              ChatManager.instance.deleteConversation(conversation.id);
              Navigator.of(ctx).pop();
            },
            child: Text(
              AppLocalizations.of(context).getText('chat_delete'),
              style: BinaType.labelLg.copyWith(color: BinaColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NO CHAT SELECTED PANEL
// ═══════════════════════════════════════════════════════════════

class _NoChatSelectedPanel extends StatelessWidget {
  const _NoChatSelectedPanel({required this.onNewChat});

  final VoidCallback onNewChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BinaColors.surfaceAlt,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: BinaColors.gradHeroSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 36,
                color: BinaColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).getText('chat_select_conversation'),
              style: BinaType.titleLg,
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).getText('chat_or_start_new'),
              style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
            ),
            const SizedBox(height: 20),
            BinaButton(
              label: AppLocalizations.of(context).getText('chat_new_conversation'),
              icon: Icons.add,
              onPressed: onNewChat,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// INLINE CHAT ROOM (for desktop detail panel)
// ═══════════════════════════════════════════════════════════════

class _InlineChatRoom extends StatefulWidget {
  const _InlineChatRoom({
    super.key,
    required this.conversation,
    required this.memberId,
    required this.family,
  });

  final ChatConversation conversation;
  final String? memberId;
  final List<FamilyMemberStruct> family;

  @override
  State<_InlineChatRoom> createState() => _InlineChatRoomState();
}

class _InlineChatRoomState extends State<_InlineChatRoom> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (!GemmaService.instance.isModelLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(GemmaService.instance.isDownloading
              ? AppLocalizations.of(context).getText('chat_model_downloading')
              : AppLocalizations.of(context).getText('chat_model_not_ready')),
          backgroundColor: BinaColors.warning,
        ),
      );
      return;
    }

    _messageController.clear();

    ChatManager.instance.addMessage(
      widget.conversation.id,
      ChatMessage(
        id: const Uuid().v4(),
        conversationId: widget.conversation.id,
        role: 'user',
        content: text,
        timestamp: DateTime.now(),
      ),
    );

    _scrollToBottom();

    setState(() {
      _isGenerating = true;
    });

    try {
      debugPrint("[Agent] Its using this one not the other the dumbo!");
      // Use the agent service for intelligent responses
      final agentResponse = await GemmaAgentService.instance.processMessage(
        userMessage: text,
        context: context,
        currentMemberId: widget.memberId,
      );

      final assistantContent = agentResponse.textResponse.isNotEmpty
          ? agentResponse.textResponse
          : 'Sorry, I could not generate a response.';

      ChatManager.instance.addMessage(
        widget.conversation.id,
        ChatMessage(
          id: const Uuid().v4(),
          conversationId: widget.conversation.id,
          role: 'assistant',
          content: assistantContent,
          timestamp: DateTime.now(),
        ),
      );

      // Handle navigation intent if present
      if (agentResponse.hasNavigation && mounted) {
        // Small delay to let the message appear first
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          NavigationExecutor.navigate(context, agentResponse.navigationIntent!);
        }
      }

      // Handle action intent if present
      if (agentResponse.hasAction && mounted) {
        // Small delay to let the message appear first
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          ActionExecutor.performAction(context, agentResponse.actionIntent!);
        }
      }
    } catch (e) {
      ChatManager.instance.addMessage(
        widget.conversation.id,
        ChatMessage(
          id: const Uuid().v4(),
          conversationId: widget.conversation.id,
          role: 'assistant',
          content: 'An error occurred: $e',
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ChatManager.instance,
      builder: (context, _) {
        final conversation = ChatManager.instance.getConversation(widget.conversation.id);
        final messages = conversation?.messages ?? [];

        final member = widget.memberId != null
            ? widget.family.where((m) => m.id == widget.memberId).firstOrNull
            : null;

        return Container(
          color: BinaColors.surfaceAlt,
          child: SafeArea(
            left: false,
            top: false,
            child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                decoration: BoxDecoration(
                  color: BinaColors.surface,
                  border: Border(
                    bottom: BorderSide(color: BinaColors.line),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: BinaColors.gradHero,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversation?.title ?? AppLocalizations.of(context).getText('chat_dental_assistant'),
                            style: BinaType.titleLg,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: GemmaService.instance.isModelLoaded
                                      ? BinaColors.success
                                      : BinaColors.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                member != null ? '${member.name} · ${AppLocalizations.of(context).getText('chat_on_device')}' : AppLocalizations.of(context).getText('chat_on_device'),
                                style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Download progress if needed
              if (!GemmaService.instance.isModelLoaded)
                GemmaDownloadProgressWidget(
                  onModelReady: () {
                    if (mounted) setState(() {});
                  },
                ),

              // Messages
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
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
                            Text(AppLocalizations.of(context).getText('chat_ask_anything'), style: BinaType.titleLg),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context).getText('chat_help_dental'),
                              style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return _MessageBubble(
                            message: messages[index],
                            memberName: member?.name,
                          );
                        },
                      ),
              ),

              // Generating indicator
              if (_isGenerating)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: BinaColors.gradHero,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: BinaColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context).getText('chat_thinking'),
                        style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                      ),
                    ],
                  ),
                ),

              // Input bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BinaColors.surface,
                  border: Border(
                    top: BorderSide(color: BinaColors.line),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: BinaColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          focusNode: _messageFocusNode,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context).getText('chat_type_message'),
                            hintStyle: BinaType.bodyMd.copyWith(color: BinaColors.ink3),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          style: BinaType.bodyMd,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _SendButton(
                      onPressed: _isGenerating ? null : _sendMessage,
                      isEnabled: !_isGenerating,
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MESSAGE BUBBLE
// ═══════════════════════════════════════════════════════════════

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    this.memberName,
  });

  final ChatMessage message;
  final String? memberName;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: BinaColors.gradHero,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? BinaColors.primary : BinaColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                border: isUser ? null : Border.all(color: BinaColors.line),
                boxShadow: BinaElevation.sh1,
              ),
              child: Text(
                message.content,
                style: BinaType.bodyMd.copyWith(
                  color: isUser ? Colors.white : BinaColors.ink,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            BinaAvatar(
              name: memberName ?? 'U',
              size: 36,
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SEND BUTTON
// ═══════════════════════════════════════════════════════════════

class _SendButton extends StatefulWidget {
  const _SendButton({
    required this.onPressed,
    required this.isEnabled,
  });

  final VoidCallback? onPressed;
  final bool isEnabled;

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: BinaMotion.d1,
        width: 48,
        height: 48,
        transform: _isPressed
            ? (Matrix4.identity()..scale(0.95, 0.95))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: widget.isEnabled ? BinaColors.gradHero : null,
          color: widget.isEnabled ? null : BinaColors.surfaceSunken,
          borderRadius: BorderRadius.circular(24),
          boxShadow: widget.isEnabled ? BinaElevation.sh2 : null,
        ),
        child: Icon(
          Icons.send_rounded,
          color: widget.isEnabled ? Colors.white : BinaColors.ink3,
          size: 20,
        ),
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
                        ? '$conversationCount ${conversationCount == 1 ? AppLocalizations.of(context).getText('chat_conversation') : AppLocalizations.of(context).getText('chat_conversations')}'
                        : AppLocalizations.of(context).getText('chat_no_conversations'),
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
    this.isSelected = false,
  });

  final ChatConversation conversation;
  final String timeAgo;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isSelected;

  String _getPreview(BuildContext context) {
    if (conversation.messages.isEmpty) return AppLocalizations.of(context).getText('chat_no_messages');
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
          color: isSelected ? BinaColors.primary100 : BinaColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? BinaColors.primary : BinaColors.line,
          ),
          boxShadow: isSelected ? [] : BinaElevation.sh1,
        ),
        child: Row(
          children: [
            // Avatar
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
                    _getPreview(context),
                    style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Time/badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeAgo,
                  style: BinaType.labelSm.copyWith(color: BinaColors.ink3),
                ),
                if (conversation.messages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: BinaColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${conversation.messages.length}',
                        style: BinaType.labelSm.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
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
              AppLocalizations.of(context).getText('chat_start_new'),
              style: BinaType.labelLg.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

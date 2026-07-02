import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import '/services/gemma_service.dart';
import '/services/chat_manager.dart';
import '/services/gemma_agent/index.dart';
import '/components/gemma_download_progress/gemma_download_progress_widget.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'chat_room_model.dart';
export 'chat_room_model.dart';

class ChatRoomWidget extends StatefulWidget {
  const ChatRoomWidget({
    super.key,
    this.conversationId,
  });

  final String? conversationId;

  static String routeName = 'ChatRoom';
  static String routePath = 'chatRoom';

  @override
  State<ChatRoomWidget> createState() => _ChatRoomWidgetState();
}

class _ChatRoomWidgetState extends State<ChatRoomWidget> {
  late ChatRoomModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatRoomModel());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _model.dispose();
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
    final text = _model.messageController.text.trim();
    if (text.isEmpty || widget.conversationId == null) return;

    // Check if model is ready
    if (!GemmaService.instance.isModelLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(GemmaService.instance.isDownloading
              ? 'AI model is still downloading... (${(GemmaService.instance.downloadProgress * 100).toStringAsFixed(0)}%)'
              : 'AI model is not ready yet. Please wait...'),
          backgroundColor: BinaColors.warning,
        ),
      );
      return;
    }

    _model.messageController.clear();

    // Add user message.
    ChatManager.instance.addMessage(
      widget.conversationId!,
      ChatMessage(
        id: const Uuid().v4(),
        conversationId: widget.conversationId!,
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
      // Get the current member context from the conversation
      final conversation = ChatManager.instance.getConversation(widget.conversationId!);
      final familyMemberId = conversation?.familyMemberId;
      debugPrint('Conversation ID: ${widget.conversationId}');
      debugPrint('Family Member ID: $familyMemberId');

      // Find the member name from AppState
      String? memberName;
      if (familyMemberId != null) {
        final family = AppState().UserSession.family;
        final member = family.where((m) => m.id == familyMemberId).firstOrNull;
        memberName = member?.name;
        debugPrint('Member name: $memberName');
      } else {
        debugPrint('WARNING: No family member ID - self commands will fail');
      }

      // Use the agent service for intelligent responses
      final agentResponse = await GemmaAgentService.instance.processMessage(
        userMessage: text,
        context: context,
        currentMemberId: familyMemberId,
        currentMemberName: memberName,
      );

      String assistantContent;
      if (agentResponse.hasError) {
        assistantContent = 'Error: ${agentResponse.error}';
        debugPrint('Agent error: ${agentResponse.error}');
      } else if (agentResponse.textResponse.isNotEmpty) {
        assistantContent = agentResponse.textResponse;
      } else {
        assistantContent = 'Sorry, I could not generate a response.';
        debugPrint('Empty response from Gemma');
      }

      ChatManager.instance.addMessage(
        widget.conversationId!,
        ChatMessage(
          id: const Uuid().v4(),
          conversationId: widget.conversationId!,
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
        widget.conversationId!,
        ChatMessage(
          id: const Uuid().v4(),
          conversationId: widget.conversationId!,
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
        final conversation =
            ChatManager.instance.getConversation(widget.conversationId ?? '');
        final messages = conversation?.messages ?? [];

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: BinaColors.surfaceAlt,
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                    decoration: BoxDecoration(
                      color: BinaColors.surface,
                      border: Border(
                        bottom: BorderSide(color: BinaColors.line),
                      ),
                    ),
                    child: Row(
                      children: [
                        BinaIconButton(
                          icon: Icons.chevron_left_rounded,
                          onPressed: () => context.safePop(),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: BinaColors.gradHero,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                conversation?.title ?? 'Dental Assistant',
                                style: BinaType.titleMd,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                GemmaService.instance.isModelLoaded
                                    ? 'Online'
                                    : 'Loading...',
                                style: BinaType.labelSm.copyWith(
                                  color: GemmaService.instance.isModelLoaded
                                      ? BinaColors.success
                                      : BinaColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Show download progress if model is not ready
                  if (!GemmaService.instance.isModelLoaded)
                    GemmaDownloadProgressWidget(
                      onModelReady: () {
                        if (mounted) setState(() {});
                      },
                    ),
                  // Messages list
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
                                Text(
                                  'Ask me anything!',
                                  style: BinaType.titleLg,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'I can help with dental health questions',
                                  style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return _MessageBubble(message: messages[index]);
                            },
                          ),
                  ),
                  // Generating indicator
                  if (_isGenerating)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                            'Thinking...',
                            style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
                          ),
                        ],
                      ),
                    ),
                  // Input bar
                  Container(
                    padding: const EdgeInsets.all(12),
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
                              controller: _model.messageController,
                              focusNode: _model.messageFocusNode,
                              onSubmitted: (_) => _sendMessage(),
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: BinaType.bodyMd.copyWith(color: BinaColors.ink3),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              style: BinaType.bodyMd,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
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
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
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
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? BinaColors.primary : BinaColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
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
            const SizedBox(width: 8),
            BinaAvatar(
              name: AppState().UserSession.family.isNotEmpty
                  ? AppState().UserSession.family.first.name
                  : 'U',
              size: 32,
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
            ? (Matrix4.identity()..setEntry(0, 0, 0.95)..setEntry(1, 1, 0.95))
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

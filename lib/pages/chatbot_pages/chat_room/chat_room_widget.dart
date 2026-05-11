import '/app_core/app_icon_button.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/services/gemma_service.dart';
import '/services/chat_manager.dart';
import '/services/llm_prompts.dart';
import '/components/gemma_download_progress/gemma_download_progress_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          duration: Duration(milliseconds: 300),
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
          backgroundColor: AppTheme.of(context).warning,
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
      // Build a single-turn prompt with recent context.
      final conversation =
          ChatManager.instance.getConversation(widget.conversationId!);
      if (conversation == null) return;

      final recentMessages = conversation.messages.length > 8
          ? conversation.messages.sublist(conversation.messages.length - 8)
          : conversation.messages;

      final contextBuffer = StringBuffer();
      contextBuffer.writeln(LlmPrompts.chatbotSystemPrompt);
      contextBuffer.writeln();
      for (final msg in recentMessages) {
        final role = msg.role == 'user' ? 'User' : 'Assistant';
        contextBuffer.writeln('$role: ${msg.content}');
      }
      contextBuffer.writeln('Assistant:');

      final response =
          await GemmaService.instance.generateResponse(contextBuffer.toString());

      final assistantContent =
          response.isNotEmpty ? response : 'Sorry, I could not generate a response.';

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
            backgroundColor: AppTheme.of(context).primaryBackground,
            appBar: AppBar(
              backgroundColor:
                  AppTheme.of(context).secondaryBackground,
              automaticallyImplyLeading: false,
              leading: AppIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 60.0,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: AppTheme.of(context).primaryText,
                  size: 30.0,
                ),
                onPressed: () async {
                  context.safePop();
                },
              ),
              title: Text(
                conversation?.title ?? 'Chat',
                style: AppTheme.of(context).headlineMedium.override(
                      font: GoogleFonts.readexPro(
                        fontWeight: AppTheme.of(context)
                            .headlineMedium
                            .fontWeight,
                        fontStyle: AppTheme.of(context)
                            .headlineMedium
                            .fontStyle,
                      ),
                      letterSpacing: 0.0,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              centerTitle: false,
              elevation: 0.0,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Show download progress if model is not ready
                  if (!GemmaService.instance.isModelLoaded)
                    GemmaDownloadProgressWidget(
                      onModelReady: () {
                        if (mounted) setState(() {});
                      },
                    ),
                  // Messages list.
                  Expanded(
                    child: messages.isEmpty
                        ? Center(
                            child: Text(
                              'Ask me anything about dental health!',
                              style: AppTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight:
                                          AppTheme.of(context)
                                              .bodyMedium
                                              .fontWeight,
                                      fontStyle:
                                          AppTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                    ),
                                    color: AppTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return _buildMessageBubble(
                                  context, messages[index]);
                            },
                          ),
                  ),
                  // Generating indicator.
                  if (_isGenerating)
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16.0,
                            height: 16.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color:
                                  AppTheme.of(context).primary,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            'Generating response...',
                            style: AppTheme.of(context)
                                .bodySmall
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight:
                                        AppTheme.of(context)
                                            .bodySmall
                                            .fontWeight,
                                    fontStyle:
                                        AppTheme.of(context)
                                            .bodySmall
                                            .fontStyle,
                                  ),
                                  color: AppTheme.of(context)
                                      .secondaryText,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ],
                      ),
                    ),
                  // Input bar.
                  Container(
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context)
                          .secondaryBackground,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3.0,
                          color: Color(0x20000000),
                          offset: Offset(0.0, -1.0),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _model.messageController,
                            focusNode: _model.messageFocusNode,
                            onFieldSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: AppTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight:
                                          AppTheme.of(context)
                                              .bodyMedium
                                              .fontWeight,
                                      fontStyle:
                                          AppTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                    ),
                                    color: AppTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                              filled: true,
                              fillColor: AppTheme.of(context)
                                  .primaryBackground,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(24.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 10.0),
                            ),
                            style: AppTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight:
                                        AppTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                    fontStyle:
                                        AppTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        AppIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 24.0,
                          buttonSize: 48.0,
                          fillColor:
                              AppTheme.of(context).primary,
                          icon: Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20.0,
                          ),
                          onPressed: _isGenerating ? null : _sendMessage,
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

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final isUser = message.role == 'user';

    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16.0,
              backgroundColor: AppTheme.of(context).primary,
              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18.0,
              ),
            ),
            SizedBox(width: 8.0),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.of(context).primary
                    : AppTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                  bottomLeft:
                      isUser ? Radius.circular(16.0) : Radius.circular(4.0),
                  bottomRight:
                      isUser ? Radius.circular(4.0) : Radius.circular(16.0),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 2.0,
                    color: Color(0x10000000),
                    offset: Offset(0.0, 1.0),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: AppTheme.of(context)
                            .bodyMedium
                            .fontWeight,
                        fontStyle: AppTheme.of(context)
                            .bodyMedium
                            .fontStyle,
                      ),
                      color: isUser
                          ? Colors.white
                          : AppTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8.0),
            CircleAvatar(
              radius: 16.0,
              backgroundColor: AppTheme.of(context).secondary,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 18.0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import '/app_core/app_icon_button.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import '/services/chat_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final conversation = ChatManager.instance.createConversation(widget.familyMemberId!);
    context.pushNamed(
      'ChatRoom',
      extra: <String, dynamic>{
        'conversationId': conversation.id,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ChatManager.instance,
      builder: (context, _) {
        final conversations = ChatManager.instance.getMembersConversations(widget.familyMemberId!);

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: AppTheme.of(context).primaryBackground,
            floatingActionButton: FloatingActionButton(
              onPressed: _createNewChat,
              backgroundColor: AppTheme.of(context).primary,
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 24.0,
              ),
            ),
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
                'Chats',
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
              ),
              centerTitle: false,
              elevation: 0.0,
            ),
            body: Column(
              children: [
                Expanded(
                  child: conversations.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = conversations[index];
                            return _buildConversationTile(
                                context, conversation);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            color: AppTheme.of(context).secondaryText,
            size: 72.0,
          ),
          SizedBox(height: 16.0),
          Text(
            'No conversations yet',
            style: AppTheme.of(context).titleMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: AppTheme.of(context)
                        .titleMedium
                        .fontWeight,
                    fontStyle: AppTheme.of(context)
                        .titleMedium
                        .fontStyle,
                  ),
                  color: AppTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Tap + to start a new chat',
            style: AppTheme.of(context).bodySmall.override(
                  font: GoogleFonts.inter(
                    fontWeight:
                        AppTheme.of(context).bodySmall.fontWeight,
                    fontStyle:
                        AppTheme.of(context).bodySmall.fontStyle,
                  ),
                  letterSpacing: 0.0,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(
      BuildContext context, ChatConversation conversation) {
    final lastMessage = conversation.messages.isNotEmpty
        ? conversation.messages.last.content
        : 'No messages yet';
    final preview = lastMessage.length > 60
        ? '${lastMessage.substring(0, 60)}...'
        : lastMessage;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            'ChatRoom',
            extra: <String, dynamic>{
              'conversationId': conversation.id,
            },
          );
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Delete conversation?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    ChatManager.instance
                        .deleteConversation(conversation.id);
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(
                        color: AppTheme.of(context).error),
                  ),
                ),
              ],
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                blurRadius: 3.0,
                color: Color(0x20000000),
                offset: Offset(0.0, 1.0),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: AppTheme.of(context).primary,
                size: 24.0,
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.title,
                      style: AppTheme.of(context)
                          .titleSmall
                          .override(
                            font: GoogleFonts.inter(
                              fontWeight: AppTheme.of(context)
                                  .titleSmall
                                  .fontWeight,
                              fontStyle: AppTheme.of(context)
                                  .titleSmall
                                  .fontStyle,
                            ),
                            color: AppTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      preview,
                      style: AppTheme.of(context)
                          .bodySmall
                          .override(
                            font: GoogleFonts.inter(
                              fontWeight: AppTheme.of(context)
                                  .bodySmall
                                  .fontWeight,
                              fontStyle: AppTheme.of(context)
                                  .bodySmall
                                  .fontStyle,
                            ),
                            color: AppTheme.of(context)
                                .secondaryText,
                            letterSpacing: 0.0,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.0),
              Text(
                dateTimeFormat('relative', conversation.lastUpdatedAt),
                style:
                    AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(
                            fontWeight: AppTheme.of(context)
                                .bodySmall
                                .fontWeight,
                            fontStyle: AppTheme.of(context)
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
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:bina_system/backend/sqlite/sqlite_manager.dart';

/// A single chat message.
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  final String id;
  final String conversationId;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
}

/// A conversation containing a list of messages.
class ChatConversation {
  ChatConversation({
    required this.id,
    required this.familyMemberId,
    required this.title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  })  : messages = messages ?? [],
        createdAt = createdAt ?? DateTime.now(),
        lastUpdatedAt = lastUpdatedAt ?? DateTime.now();

  final String id;
  final String familyMemberId;
  String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  DateTime lastUpdatedAt;
}

/// In-memory chat storage manager.
/// Ready for future DB migration via its clear interface.
class ChatManager extends ChangeNotifier {
  ChatManager._();

  static final ChatManager _instance = ChatManager._();
  static ChatManager get instance => _instance;
  bool _initialized = false;

  final List<ChatConversation> _conversations = [];

  Future<void> initialize() async {
    if (_initialized) return;
    final conversations = await getAllConversations();
    _conversations.addAll(conversations);
    _initialized = true;
    notifyListeners();
  }

  Future<List<ChatConversation>> getAllConversations() async {
    final rows = await SQLiteManager.instance.getAllChatConversations();
    return Future.wait(rows.map((row) async => ChatConversation(
      id: row.id,
      familyMemberId: row.familyMemberId,
      title: row.title,
      messages: await getConversationMessages(row.id),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt!),
      lastUpdatedAt: DateTime.fromMillisecondsSinceEpoch(row.lastUpdatedAt!),
    )));
  }

  Future<List<ChatMessage>> getConversationMessages(String conversationId) async {
    final rows = await SQLiteManager.instance.getChatMessagesByConversationId(conversationId: conversationId);
    return rows.map((row) => ChatMessage(
      id: row.id,
      conversationId: row.conversationId,
      role: row.role,
      content: row.content,
      timestamp: DateTime.fromMillisecondsSinceEpoch(row.timestamp!),
    )).toList();
  }

  /// All conversations sorted by lastUpdatedAt descending.
  List<ChatConversation> get conversations {
    final sorted = List<ChatConversation>.from(_conversations);
    sorted.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
    return sorted;
  }

  List<ChatConversation> getMembersConversations(String familyMemberId) {
    return  _conversations.where((c) => c.familyMemberId == familyMemberId)
        .toList();
  }

  /// Create a new conversation and return it.
  ChatConversation createConversation(String familyMemberId, [String title = 'New Chat']) {
    final conversation = ChatConversation(
      id: const Uuid().v4(),
      familyMemberId: familyMemberId,
      title: title,
    );
    _conversations.add(conversation);
    SQLiteManager.instance.createChatConversation(
      id: conversation.id,
      familyMemberId: conversation.familyMemberId,
      title: conversation.title,
    );
    notifyListeners();
    return conversation;
  }

  /// Get a conversation by ID.
  ChatConversation? getConversation(String id) {
    try {
      return _conversations.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Delete a conversation by ID.
  Future<void> deleteConversation(String id) async {
    _conversations.removeWhere((c) => c.id == id);
    notifyListeners();
    await SQLiteManager.instance.deleteChatConversationCascade(
      conversationId: id,
    );
  }

  /// Add a message to a conversation.
  void addMessage(String conversationId, ChatMessage message) {
    final conversation = getConversation(conversationId);
    if (conversation == null) return;

    conversation.messages.add(message);
    conversation.lastUpdatedAt = DateTime.now();

    // Auto-update title from first user message.
    if (conversation.title == 'New Chat' && message.role == 'user') {
      final preview = message.content.length > 30
          ? '${message.content.substring(0, 30)}...'
          : message.content;
      conversation.title = preview;
    }

    SQLiteManager.instance.createChatMessage(
      id: message.id,
      conversationId: message.conversationId,
      role: message.role,
      content: message.content,
    );
    SQLiteManager.instance.updateConversationLastUpdate(
      id: conversation.id,
      lastUpdate: conversation.lastUpdatedAt.millisecondsSinceEpoch,
    );

    notifyListeners();
  }
}

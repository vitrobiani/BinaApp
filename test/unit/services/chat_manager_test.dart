import 'package:bina_system/backend/sqlite/sqlite_manager.dart';
import 'package:bina_system/services/chat_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/sqlite_test_db.dart';

void main() {
  setUpAll(initFfiSqlite);

  late final chat = ChatManager.instance;

  setUp(() async {
    final db = await openMigratedSqlite();
    SQLiteManager.setDatabaseForTesting(db);
    chat.conversations
        .toList()
        .forEach((c) => chat.deleteConversation(c.id));
  });

  test('createConversation persists to SQLite and returns a struct', () async {
    final convo = chat.createConversation('fm-1', 'My first chat');
    expect(convo.id, isNotEmpty);
    expect(convo.familyMemberId, equals('fm-1'));
    expect(convo.title, equals('My first chat'));

    final rows = await SQLiteManager.instance.getAllChatConversations();
    expect(rows.map((r) => r.id), contains(convo.id));
  });

  test('createConversation defaults the title to "New Chat"', () {
    final convo = chat.createConversation('fm-1');
    expect(convo.title, equals('New Chat'));
  });

  test('getConversation returns cached in-memory instance', () {
    final convo = chat.createConversation('fm-1', 'Original');
    final same = chat.getConversation(convo.id);
    expect(identical(convo, same), isTrue);
  });

  test('getConversation returns null for unknown id', () {
    expect(chat.getConversation('does-not-exist'), isNull);
  });

  test('addMessage persists and appends in timestamp order', () async {
    final convo = chat.createConversation('fm-1');
    chat.addMessage(
      convo.id,
      ChatMessage(
        id: 'm-1',
        conversationId: convo.id,
        role: 'user',
        content: 'hello',
        timestamp: DateTime.now(),
      ),
    );
    chat.addMessage(
      convo.id,
      ChatMessage(
        id: 'm-2',
        conversationId: convo.id,
        role: 'assistant',
        content: 'hi back',
        timestamp: DateTime.now().add(const Duration(seconds: 1)),
      ),
    );

    final rows = await SQLiteManager.instance
        .getChatMessagesByConversationId(conversationId: convo.id);
    expect(rows.map((r) => r.id), equals(['m-1', 'm-2']));
    expect(rows.map((r) => r.role), equals(['user', 'assistant']));
    expect(rows.map((r) => r.content), equals(['hello', 'hi back']));
  });

  test('addMessage auto-titles from the first user message', () {
    final convo = chat.createConversation('fm-1'); // Default 'New Chat'.
    expect(convo.title, equals('New Chat'));

    chat.addMessage(
      convo.id,
      ChatMessage(
        id: 'm-1',
        conversationId: convo.id,
        role: 'user',
        content: 'What is the plaque score today please',
        timestamp: DateTime.now(),
      ),
    );

    expect(convo.title, isNot(equals('New Chat')));
    expect(convo.title, startsWith('What is the plaque score today'));
    expect(convo.title.length, lessThanOrEqualTo(33));
  });

  test('addMessage does not auto-title from assistant messages', () {
    final convo = chat.createConversation('fm-1');
    chat.addMessage(
      convo.id,
      ChatMessage(
        id: 'm-1',
        conversationId: convo.id,
        role: 'assistant',
        content: 'Assistant speaking first',
        timestamp: DateTime.now(),
      ),
    );
    expect(convo.title, equals('New Chat'));
  });

  test('getMembersConversations scopes results to one member', () {
    chat.createConversation('fm-1', 'A chat for fm-1');
    chat.createConversation('fm-2', 'A chat for fm-2');
    chat.createConversation('fm-1', 'Another chat for fm-1');

    final fm1 = chat.getMembersConversations('fm-1');
    final fm2 = chat.getMembersConversations('fm-2');
    expect(fm1.length, equals(2));
    expect(fm2.length, equals(1));
    expect(fm1.every((c) => c.familyMemberId == 'fm-1'), isTrue);
    expect(fm2.every((c) => c.familyMemberId == 'fm-2'), isTrue);
  });

  test('conversations getter is sorted by lastUpdatedAt descending', () async {
    final older = chat.createConversation('fm-1', 'older');
    await Future.delayed(const Duration(milliseconds: 10));
    final newer = chat.createConversation('fm-1', 'newer');
    chat.addMessage(
      newer.id,
      ChatMessage(
        id: 'msg-x',
        conversationId: newer.id,
        role: 'user',
        content: 'hi',
        timestamp: DateTime.now(),
      ),
    );

    final list = chat.conversations;
    expect(list.first.id, equals(newer.id));
    expect(list.last.id, equals(older.id));
  });

  test('deleteConversation removes from cache and cascades to messages',
      () async {
    final convo = chat.createConversation('fm-1');
    chat.addMessage(
      convo.id,
      ChatMessage(
        id: 'm-1',
        conversationId: convo.id,
        role: 'user',
        content: 'to be deleted',
        timestamp: DateTime.now(),
      ),
    );

    await chat.deleteConversation(convo.id);

    expect(chat.getConversation(convo.id), isNull);
    final rows = await SQLiteManager.instance
        .getChatMessagesByConversationId(conversationId: convo.id);
    expect(rows, isEmpty);
    final convos = await SQLiteManager.instance.getAllChatConversations();
    expect(convos.map((r) => r.id), isNot(contains(convo.id)));
  });

  test('addMessage on a non-existent conversation is a silent no-op', () {
    expect(
      () => chat.addMessage(
        'no-such-id',
        ChatMessage(
          id: 'm',
          conversationId: 'no-such-id',
          role: 'user',
          content: 'test',
          timestamp: DateTime.now(),
        ),
      ),
      returnsNormally,
    );
  });
}

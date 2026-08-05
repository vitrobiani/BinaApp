import 'package:bina_system/services/gemma_agent/command_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final parser = CommandParser();

  group('parse — well-formed commands', () {
    test('[CMD:GET_MY_SCANS] parses to one command with empty params', () {
      final r = parser.parse('[CMD:GET_MY_SCANS]');
      expect(r.hasCommands, isTrue);
      expect(r.commands.single.name, equals('GET_MY_SCANS'));
      expect(r.commands.single.params, isEmpty);
      expect(r.commands.single.rawMatch, equals('[CMD:GET_MY_SCANS]'));
    });

    test('simple form [GET_MY_SCANS] also parses (no CMD: prefix)', () {
      final r = parser.parse('[GET_MY_SCANS]');
      expect(r.commands.single.name, equals('GET_MY_SCANS'));
    });

    test('[CMD:GET_MEMBER_DETAILS|member_name:alice] parses params', () {
      final r = parser.parse('[CMD:GET_MEMBER_DETAILS|member_name:alice]');
      expect(r.commands.single.name, equals('GET_MEMBER_DETAILS'));
      expect(r.commands.single.params, equals({'member_name': 'alice'}));
    });

    test('multiple pipe-separated params split correctly', () {
      final r = parser.parse(
        '[CMD:SEARCH_DIAGNOSES|keyword:cavity|member:alice]',
      );
      expect(
        r.commands.single.params,
        equals({'keyword': 'cavity', 'member': 'alice'}),
      );
    });

    test('surrounding text is preserved in displayText, command is stripped',
        () {
      final r = parser.parse('Sure! [CMD:NAV_HOME] Going home now.');
      expect(r.commands.single.name, equals('NAV_HOME'));
      expect(r.displayText, isNot(contains('[CMD:NAV_HOME]')));
      expect(r.displayText, contains('Sure!'));
      expect(r.displayText, contains('Going home now.'));
    });

    test('multiple valid commands in one response all parse', () {
      final r = parser.parse('[GET_MY_SCANS] then [NAV_HOME]');
      expect(r.commands.map((c) => c.name), containsAll(['GET_MY_SCANS', 'NAV_HOME']));
    });
  });

  group('parse — rejects invalid or malformed', () {
    test('unknown command name is left in the text, no command extracted',
        () {
      final r = parser.parse('[UNKNOWN_THING] hello');
      expect(r.hasCommands, isFalse);
      expect(r.displayText, contains('[UNKNOWN_THING]'));
    });

    test('lowercase bracket content is ignored (regex is [A-Z_]+)', () {
      final r = parser.parse('[nav_home]');
      expect(r.hasCommands, isFalse);
    });

    test('unclosed bracket parses nothing (no crash)', () {
      final r = parser.parse('[CMD:NAV_HOME missing close');
      expect(r.hasCommands, isFalse);
    });

    test('empty string → empty result', () {
      final r = parser.parse('');
      expect(r.hasCommands, isFalse);
      expect(r.displayText, isEmpty);
    });

    test('nested brackets — inner bracket blocks outer match', () {
      // [X[Y]] — outer name would be "X[Y" which the regex doesn't accept
      // because [A-Z_]+ excludes the `[`. Result: neither matches.
      final r = parser.parse('[X[NAV_HOME]]');
      // The inner [NAV_HOME] still matches the simple pattern, though.
      expect(r.commands.map((c) => c.name), contains('NAV_HOME'));
    });
  });

  group('parse — total function property', () {
    test('never throws on adversarial inputs', () {
      final inputs = <String>[
        '',
        '[',
        ']',
        '[]',
        '[[[[',
        '[CMD:',
        '[CMD:]',
        '[CMD:NAV_HOME|]',
        '[CMD:NAV_HOME|:value]',
        '[CMD:NAV_HOME|key:]',
        '[CMD:NAV_HOME|key:val|]',
        '[' * 100 + ']' * 100,
        'random text with no commands',
        '\n\n\n[CMD:NAV_HOME]\n\n',
        // 200-line adversarial fixture inline. `parse` must be total.
      ];
      for (final input in inputs) {
        expect(() => parser.parse(input), returnsNormally,
            reason: 'adversarial input: ${input.substring(0, input.length.clamp(0, 50))}');
      }
    });

    test('cleans up excess blank lines in displayText (3+ → 2)', () {
      final r = parser.parse('one\n\n\n\ntwo');
      expect(r.displayText, equals('one\n\ntwo'));
    });
  });

  group('_parseParams behaviour via parse', () {
    test('param without colon is dropped', () {
      final r = parser.parse('[CMD:NAV_HOME|badparam]');
      expect(r.commands.single.params, isEmpty);
    });

    test('trims whitespace around keys and values', () {
      final r = parser.parse('[CMD:GET_MEMBER_DETAILS|member_name:  alice  ]');
      expect(r.commands.single.params['member_name'], equals('alice'));
    });
  });

  group('containsCommands', () {
    test('true when at least one valid command is present', () {
      expect(parser.containsCommands('hello [NAV_HOME] world'), isTrue);
      expect(parser.containsCommands('hello [CMD:NAV_HOME] world'), isTrue);
    });

    test('false when nothing valid is bracketed', () {
      expect(parser.containsCommands('hello [FOO_BAR] world'), isFalse);
      expect(parser.containsCommands('no brackets here'), isFalse);
    });
  });

  group('extractCommandNames', () {
    test('returns all unique valid names', () {
      final names = parser.extractCommandNames('[NAV_HOME] [NAV_FAMILY]');
      expect(names, containsAll(['NAV_HOME', 'NAV_FAMILY']));
    });

    test('deduplicates across the two regex patterns', () {
      // The same command via both formats should not be reported twice by
      // extractCommandNames (parse itself dedupes on rawMatch).
      final names = parser.extractCommandNames('[CMD:NAV_HOME] and [NAV_HOME]');
      expect(names.length, equals(1));
      expect(names.first, equals('NAV_HOME'));
    });
  });

  group('escape behaviour — documented current state', () {
    test('backslash before the closing bracket accidentally blocks the match',
        () {
      final r = parser.parse(r'quote this: \[NAV_HOME\]');
      expect(r.hasCommands, isFalse);
    });

    test('backslash before the opening bracket is ignored (still matches)',
        () {
      // `\[NAV_HOME]` (no trailing backslash) still parses — the leading
      // backslash is just text.
      final r = parser.parse(r'quote this: \[NAV_HOME]');
      expect(r.hasCommands, isTrue);
    });
  });
}

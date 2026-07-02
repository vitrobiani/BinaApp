/// Resolves member names from user input to actual family members.
/// Supports multilingual matching (Hebrew, English, Indonesian, Malay).

import '/backend/schema/structs/index.dart';

class MemberNameResolver {
  /// Map of family relationship terms across languages
  /// Used for fuzzy name matching (e.g., if someone is named "אמא" or "Mom")
  static const Map<String, List<String>> familyTerms = {
    'mom': [
      'mom', 'mother', 'mum', 'mama', 'mommy',
      'אמא', 'אימא',
      'ibu', 'emak', 'mak',
    ],
    'dad': [
      'dad', 'father', 'papa', 'daddy',
      'אבא', 'אבי',
      'ayah', 'bapa', 'abah', 'pak',
    ],
    'grandma': [
      'grandma', 'grandmother', 'granny', 'nana',
      'סבתא', 'סבתה',
      'nenek',
    ],
    'grandpa': [
      'grandpa', 'grandfather', 'gramps',
      'סבא', 'סב',
      'datuk', 'kakek', 'atok',
    ],
    'sister': [
      'sister', 'sis',
      'אחות',
      'kakak', 'adik perempuan',
    ],
    'brother': [
      'brother', 'bro',
      'אח',
      'abang', 'adik lelaki',
    ],
    'son': [
      'son',
      'בן',
      'anak lelaki',
    ],
    'daughter': [
      'daughter',
      'בת',
      'anak perempuan',
    ],
    'wife': [
      'wife',
      'אישה', 'אשתי', 'רעיה',
      'isteri', 'istri',
    ],
    'husband': [
      'husband',
      'בעל', 'בעלי',
      'suami',
    ],
    'child': [
      'child', 'kid',
      'ילד', 'ילדה',
      'anak',
    ],
    'baby': [
      'baby',
      'תינוק', 'תינוקת',
      'bayi',
    ],
  };

  /// Find a family member by name
  /// Returns null if no match found
  FamilyMemberStruct? resolve(
    String query,
    List<FamilyMemberStruct> members,
  ) {
    if (members.isEmpty || query.isEmpty) return null;

    final normalizedQuery = _normalize(query);

    // 1. Try exact name match (case-insensitive)
    for (final member in members) {
      if (_normalize(member.name) == normalizedQuery) {
        return member;
      }
    }

    // 2. Try family term matching against names
    // (e.g., if user says "mom" and there's a member named "Mom" or "אמא")
    final canonicalTerm = _getCanonicalTerm(normalizedQuery);
    if (canonicalTerm != null) {
      for (final member in members) {
        final memberNameTerm = _getCanonicalTerm(_normalize(member.name));
        if (memberNameTerm == canonicalTerm) {
          return member;
        }
      }
    }

    // 3. Try partial name match (query contains name or vice versa)
    for (final member in members) {
      final memberName = _normalize(member.name);
      if (memberName.contains(normalizedQuery) ||
          normalizedQuery.contains(memberName)) {
        return member;
      }
    }

    // 4. Try fuzzy matching (first name, nickname, etc.)
    for (final member in members) {
      final nameParts = _normalize(member.name).split(' ');
      for (final part in nameParts) {
        if (part == normalizedQuery ||
            _levenshteinDistance(part, normalizedQuery) <= 2) {
          return member;
        }
      }
    }

    return null;
  }

  /// Find all members matching a query (for ambiguous matches)
  List<FamilyMemberStruct> resolveAll(
    String query,
    List<FamilyMemberStruct> members,
  ) {
    if (members.isEmpty || query.isEmpty) return [];

    final normalizedQuery = _normalize(query);
    final matches = <FamilyMemberStruct>[];

    // Check for family term match
    final canonicalTerm = _getCanonicalTerm(normalizedQuery);

    for (final member in members) {
      final memberName = _normalize(member.name);

      // Exact match
      if (memberName == normalizedQuery) {
        matches.add(member);
        continue;
      }

      // Family term in name
      if (canonicalTerm != null) {
        final memberNameTerm = _getCanonicalTerm(memberName);
        if (memberNameTerm == canonicalTerm) {
          matches.add(member);
          continue;
        }
      }

      // Partial match
      if (memberName.contains(normalizedQuery) ||
          normalizedQuery.contains(memberName)) {
        matches.add(member);
      }
    }

    return matches;
  }

  /// Normalize a string for comparison
  String _normalize(String s) {
    return s.toLowerCase().trim();
  }

  /// Get canonical family term from any variation
  String? _getCanonicalTerm(String term) {
    for (final entry in familyTerms.entries) {
      if (entry.value.any((t) => _normalize(t) == term)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Calculate Levenshtein distance for fuzzy matching
  int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < s2.length; j++) {
        int cost = s1[i] == s2[j] ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce((a, b) => a < b ? a : b);
      }

      final temp = v0;
      v0 = v1;
      v1 = temp;
    }

    return v0[s2.length];
  }

  /// Check if a query looks like a family relationship term
  bool isFamilyTerm(String query) {
    return _getCanonicalTerm(_normalize(query)) != null;
  }

  /// Get the canonical term for display (e.g., "אמא" -> "Mom")
  String? getDisplayTerm(String query) {
    final canonical = _getCanonicalTerm(_normalize(query));
    if (canonical == null) return null;

    // Return capitalized canonical term
    return canonical[0].toUpperCase() + canonical.substring(1);
  }
}

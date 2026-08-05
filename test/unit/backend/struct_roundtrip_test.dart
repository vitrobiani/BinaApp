import 'package:bina_system/backend/schema/enums/enums.dart';
import 'package:bina_system/backend/schema/structs/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserSessionStruct', () {
    final canonical = UserSessionStruct(
      userID: 'u-1',
      name: 'Alice',
      email: 'a@example.com',
      sessionId: 'sess-42',
      family: [
        FamilyMemberStruct(id: 'fm-1', name: 'Bob', admin: true, score: 3.5),
      ],
      familyAmount: 3,
      sumChecked: 7,
      isLocalSession: true,
    );

    test('toMap → fromMap preserves every field', () {
      final roundTripped = UserSessionStruct.fromMap(canonical.toMap());
      expect(roundTripped, equals(canonical));
    });

    test('toSerializableMap → fromSerializableMap preserves every field', () {
      final roundTripped =
          UserSessionStruct.fromSerializableMap(canonical.toSerializableMap());
      expect(roundTripped, equals(canonical));
    });

    test('all-null instance survives round-trip', () {
      final empty = UserSessionStruct();
      expect(UserSessionStruct.fromMap(empty.toMap()), equals(empty));
      expect(
        UserSessionStruct.fromSerializableMap(empty.toSerializableMap()),
        equals(empty),
      );
    });
  });

  group('FamilyMemberStruct', () {
    final canonical = FamilyMemberStruct(
      id: 'fm-1',
      name: 'Carol',
      admin: false,
      score: 10.0,
      birthday: DateTime(1990, 5, 20),
      lastChecked: DateTime(2026, 1, 15, 12, 30),
      profilePic: 'https://example.com/pic.jpg',
      relationship: Relationships.OTHER,
    );

    test('toMap → fromMap preserves every field including enum', () {
      final roundTripped = FamilyMemberStruct.fromMap(canonical.toMap());
      expect(roundTripped, equals(canonical));
    });

    test('toSerializableMap → fromSerializableMap preserves every field', () {
      final roundTripped =
          FamilyMemberStruct.fromSerializableMap(canonical.toSerializableMap());
      expect(roundTripped, equals(canonical));
    });

    test('null birthday and lastChecked round-trip as null', () {
      final noDates = FamilyMemberStruct(id: 'fm-2', name: 'Dan');
      expect(FamilyMemberStruct.fromMap(noDates.toMap()), equals(noDates));
      expect(
        FamilyMemberStruct.fromSerializableMap(noDates.toSerializableMap()),
        equals(noDates),
      );
    });

    test('every Relationships enum value round-trips', () {
      for (final rel in Relationships.values) {
        final s = FamilyMemberStruct(id: 'x', name: 'y', relationship: rel);
        final rt = FamilyMemberStruct.fromSerializableMap(s.toSerializableMap());
        expect(rt.relationship, equals(rel));
      }
    });
  });

  group('ScanSessionStruct', () {
    test('every ScanSessionStatus enum value round-trips', () {
      for (final status in ScanSessionStatus.values) {
        final s = ScanSessionStruct(
          id: 'ss-1',
          familyMemberId: 'fm-1',
          sessionStart: DateTime(2026, 1, 1, 10),
          sessionEnd: DateTime(2026, 1, 1, 10, 15),
          status: status,
          notes: 'Test session',
          totalImagesCaptured: 12,
        );
        expect(ScanSessionStruct.fromMap(s.toMap()), equals(s));
        expect(
          ScanSessionStruct.fromSerializableMap(s.toSerializableMap()),
          equals(s),
        );
      }
    });

    test('optional sessionEnd and notes survive round-trip', () {
      final inProgress = ScanSessionStruct(
        id: 'ss-2',
        familyMemberId: 'fm-1',
        sessionStart: DateTime(2026, 1, 1),
        status: ScanSessionStatus.in_progress,
      );
      expect(ScanSessionStruct.fromMap(inProgress.toMap()), equals(inProgress));
      expect(
        ScanSessionStruct.fromSerializableMap(inProgress.toSerializableMap()),
        equals(inProgress),
      );
    });
  });

  group('ScanImageStruct', () {
    final canonical = ScanImageStruct(
      id: 'si-1',
      scanSessionId: 'ss-1',
      imagePath: '/tmp/img.jpg',
      diagnosedImagePath: '/tmp/img_dx.jpg',
      capturedAt: DateTime(2026, 1, 1, 10, 5),
      rawResponse: '{"detections":[]}',
      pitch: -12,
      roll: 45,
      estimatedRegion: 'upper_front',
    );

    test('toMap → fromMap preserves every field', () {
      expect(ScanImageStruct.fromMap(canonical.toMap()), equals(canonical));
    });

    test('toSerializableMap → fromSerializableMap preserves every field', () {
      expect(
        ScanImageStruct.fromSerializableMap(canonical.toSerializableMap()),
        equals(canonical),
      );
    });

    test('nullable pitch, roll, estimatedRegion survive as null', () {
      final minimal = ScanImageStruct(id: 'si-2', scanSessionId: 'ss-1');
      expect(ScanImageStruct.fromMap(minimal.toMap()), equals(minimal));
      expect(
        ScanImageStruct.fromSerializableMap(minimal.toSerializableMap()),
        equals(minimal),
      );
    });
  });

  group('DentalRecordStruct', () {
    test('every DentalRecordStatus enum value round-trips', () {
      for (final status in DentalRecordStatus.values) {
        final r = DentalRecordStruct(
          id: 'dr-1',
          familyMemberId: 'fm-1',
          scanSessionId: 'ss-1',
          recordDate: DateTime(2026, 1, 1),
          findingsSnapshot: '{"cavities":2}',
          overallStatus: status,
        );
        expect(DentalRecordStruct.fromMap(r.toMap()), equals(r));
        expect(
          DentalRecordStruct.fromSerializableMap(r.toSerializableMap()),
          equals(r),
        );
      }
    });

    test('findingsSnapshot JSON string preserved byte-for-byte', () {
      const json = '{"nested":{"list":[1,2,3],"unicode":"שלום"}}';
      final r = DentalRecordStruct(id: 'dr-2', findingsSnapshot: json);
      final rt = DentalRecordStruct.fromMap(r.toMap());
      expect(rt.findingsSnapshot, equals(json));
    });
  });

  group('FamilyMemberCalibrationStruct', () {
    const regions = [
      'upper_front',
      'upper_left',
      'upper_right',
      'lower_front',
      'lower_left',
      'lower_right',
    ];

    test('every region code round-trips', () {
      for (final region in regions) {
        final c = FamilyMemberCalibrationStruct(
          id: 'cal-$region',
          familyMemberId: 'fm-1',
          regionCode: region,
          avgPitch: 10,
          avgRoll: -5,
          sampleCount: 3,
          calibratedAt: DateTime(2026, 1, 1),
        );
        expect(FamilyMemberCalibrationStruct.fromMap(c.toMap()), equals(c));
        expect(
          FamilyMemberCalibrationStruct.fromSerializableMap(
            c.toSerializableMap(),
          ),
          equals(c),
        );
      }
    });

    test('nullable measurement fields survive as null', () {
      final blank = FamilyMemberCalibrationStruct(
        id: 'cal-x',
        familyMemberId: 'fm-1',
        regionCode: 'upper_front',
      );
      expect(FamilyMemberCalibrationStruct.fromMap(blank.toMap()), equals(blank));
    });
  });

  group('MemberDocumentStruct', () {
    for (final status in const ['ok', 'empty', 'error']) {
      test('extractionStatus=$status round-trips', () {
        final d = MemberDocumentStruct(
          id: 'doc-1',
          familyMemberId: 'fm-1',
          fileName: 'report.pdf',
          mimeType: 'application/pdf',
          byteSize: 12345,
          storagePath: 'member-documents/fm-1/doc-1.pdf',
          extractedText: 'Patient shows two cavities on upper left molar.',
          extractionStatus: status,
          uploadedAt: DateTime(2026, 1, 15, 9),
        );
        expect(MemberDocumentStruct.fromMap(d.toMap()), equals(d));
        expect(
          MemberDocumentStruct.fromSerializableMap(d.toSerializableMap()),
          equals(d),
        );
      });
    }

    test('local-mode doc (no storagePath, no extractedText) round-trips', () {
      final localOnly = MemberDocumentStruct(
        id: 'doc-2',
        familyMemberId: 'fm-1',
        fileName: 'scan.pdf',
      );
      expect(
        MemberDocumentStruct.fromMap(localOnly.toMap()),
        equals(localOnly),
      );
      expect(
        MemberDocumentStruct.fromSerializableMap(localOnly.toSerializableMap()),
        equals(localOnly),
      );
    });

    test('unicode in fileName and extractedText survives', () {
      final unicode = MemberDocumentStruct(
        id: 'doc-3',
        familyMemberId: 'fm-1',
        fileName: 'דוח_רפואי.pdf',
        extractedText: 'המטופל סובל מעששת',
        extractionStatus: 'ok',
      );
      final rt = MemberDocumentStruct.fromMap(unicode.toMap());
      expect(rt.fileName, equals('דוח_רפואי.pdf'));
      expect(rt.extractedText, equals('המטופל סובל מעששת'));
    });
  });

  group('CameraConnectionStruct', () {
    void expectSame(CameraConnectionStruct a, CameraConnectionStruct b) {
      expect(a.isConnected, equals(b.isConnected));
      expect(a.cameraIP, equals(b.cameraIP));
      expect(a.cameraName, equals(b.cameraName));
      expect(a.cameraMacAddress, equals(b.cameraMacAddress));
      expect(a.connectionType, equals(b.connectionType));
    }

    test('connected Bina-Camera round-trips', () {
      final c = CameraConnectionStruct(
        isConnected: true,
        cameraIP: '192.168.49.1:8070',
        cameraName: 'Bina-Camera',
        cameraMacAddress: 'AA:BB:CC:DD:EE:FF',
        connectionType: 'wifi_direct',
      );
      expectSame(CameraConnectionStruct.fromMap(c.toMap()), c);
      expectSame(
        CameraConnectionStruct.fromSerializableMap(c.toSerializableMap()),
        c,
      );
    });

    test('disconnected defaults round-trip', () {
      final c = CameraConnectionStruct();
      expectSame(CameraConnectionStruct.fromMap(c.toMap()), c);
      expectSame(
        CameraConnectionStruct.fromSerializableMap(c.toSerializableMap()),
        c,
      );
      expect(c.isConnected, isFalse);
      expect(c.connectionType, equals('manual'));
    });

    test('helper getters compute correct URLs and ports', () {
      final c = CameraConnectionStruct(
        isConnected: true,
        cameraIP: '10.0.0.5:9000',
        cameraName: 'Bina-Camera',
      );
      expect(c.cameraHost, equals('10.0.0.5'));
      expect(c.cameraPort, equals(9000));
      expect(c.streamUrl, equals('http://10.0.0.5:9000/stream.mjpg'));
      expect(c.snapshotUrl, equals('http://10.0.0.5:9000/snapshot.jpg'));
      expect(c.isBinaCameraConnected(), isTrue);
      expect(c.hasCameraIP(), isTrue);
    });

    test('bare IP without port falls back to default 8070', () {
      final c = CameraConnectionStruct(isConnected: true, cameraIP: '10.0.0.5');
      expect(c.cameraPort, equals(8070));
      expect(c.streamUrl, equals('http://10.0.0.5:8070/stream.mjpg'));
    });
  });

  group('Known round-trip quirks (regression fences)', () {
    test('UTC DateTime survives as the same instant but loses .isUtc flag', () {
      final utcInput = DateTime.utc(2026, 1, 1, 12, 30);
      final wrapped =
          FamilyMemberStruct(id: 'x', name: 'y', lastChecked: utcInput);
      final rt = FamilyMemberStruct.fromSerializableMap(
        wrapped.toSerializableMap(),
      );
      // Same instant:
      expect(rt.lastChecked!.isAtSameMomentAs(utcInput), isTrue);
      // But flag is dropped:
      expect(rt.lastChecked!.isUtc, isFalse);
    });
  });
}

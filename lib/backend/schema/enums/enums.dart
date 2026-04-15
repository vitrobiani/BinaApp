import 'package:collection/collection.dart';

enum AppRoles {
  user,
  admin,
}

enum Genders {
  MALE,
  FEMALE,
  RND,
}

enum Relationships {
  ME,
  OTHER,
}

enum ScanSessionStatus {
  pending,
  in_progress,
  completed,
  failed,
}

enum DentalRecordStatus {
  healthy,
  attention_needed,
  urgent,
  unknown,
}

extension AppEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension AppEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  switch (T) {
    case (AppRoles):
      return AppRoles.values.deserialize(value) as T?;
    case (Genders):
      return Genders.values.deserialize(value) as T?;
    case (Relationships):
      return Relationships.values.deserialize(value) as T?;
    case (ScanSessionStatus):
      return ScanSessionStatus.values.deserialize(value) as T?;
    case (DentalRecordStatus):
      return DentalRecordStatus.values.deserialize(value) as T?;
    default:
      return null;
  }
}

abstract class AppConstants {
  static const int ONE = 1;
  static const int ZERO = 0;
  static const String NULLDT = '1969-07-20 20:18:04Z';
}
/*
D: Down
U: Up
L: Left
R: Right
F: Front
I: Inner
T: Top
O: Outer
*/
enum Orientation {
  UT(detailed: "Upper Top"),
  URI(detailed: "Upper Right Inner"),
  ULO(detailed: "Upper Left Outer"),
  URO(detailed: "Upper Right Outer"),
  ULI(detailed: "Upper Left Inner"),
  UFI(detailed: "Upper Front Inner"),
  UFO(detailed: "Upper Front Outer"),
  DRI(detailed: "Down Right Inner"),
  DLO(detailed: "Down Left Outer"),
  DRO(detailed: "Down Right Outer"),
  DLI(detailed: "Down Left Inner"),
  DT(detailed:  "Down Top"),
  DFI(detailed: "Down Front Inner"),
  DFO(detailed: "Down Front Outer");

  final String detailed;

  const Orientation({required this.detailed});
}

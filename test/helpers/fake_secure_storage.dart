import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, String> installFakeSecureStorage({
  Map<String, String>? initialValues,
}) {
  TestWidgetsFlutterBinding.ensureInitialized();
  final store = <String, String>{...?initialValues};
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};
    switch (call.method) {
      case 'read':
        return store[args['key']];
      case 'readAll':
        return Map<String, String>.from(store);
      case 'containsKey':
        return store.containsKey(args['key']);
      case 'write':
        store[args['key'] as String] = args['value'] as String;
        return null;
      case 'delete':
        store.remove(args['key']);
        return null;
      case 'deleteAll':
        store.clear();
        return null;
      case 'isProtectedDataAvailable':
        return true;
    }
    return null;
  });
  return store;
}

void uninstallFakeSecureStorage() {
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null);
}

import 'package:logger/web.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

final secureStorage = FlutterSecureStorage();

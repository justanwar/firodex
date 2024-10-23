// ignore_for_file: avoid_print

Future<void> pause({int sec = 1, String msg = '', int msec = 0}) async {
  if (msg.isNotEmpty) {
    print('pause: $sec, $msg ');
  }
  if (msec > 0) {
    return await Future<void>.delayed(Duration(milliseconds: msec));
  }
  await Future<void>.delayed(Duration(seconds: sec));
}

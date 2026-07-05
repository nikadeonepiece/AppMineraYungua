class TimeIntegrityService {
  TimeIntegrityService({this.maxSkew = const Duration(minutes: 5)});

  final Duration maxSkew;

  bool isSkewAcceptable(DateTime serverTimeUtc) {
    final now = DateTime.now().toUtc();
    final delta = now.difference(serverTimeUtc).abs();
    return delta <= maxSkew;
  }
}

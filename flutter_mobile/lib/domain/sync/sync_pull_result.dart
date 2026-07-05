class SyncPullResult {
  const SyncPullResult({
    required this.count,
    this.nextCursor,
  });

  final int count;
  final DateTime? nextCursor;
}

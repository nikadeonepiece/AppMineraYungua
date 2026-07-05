class SyncPageResult {
  const SyncPageResult({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.count,
    this.serverTime,
  });

  final List<Map<String, dynamic>> data;
  final int page;
  final int limit;
  final int total;
  final int count;
  final DateTime? serverTime;

  bool get hasMore => (page * limit) < total;
}

class SyncBatchPolicy {
  const SyncBatchPolicy({
    this.batchSize = 50,
    this.maxParallel = 4,
  });

  final int batchSize;
  final int maxParallel;
}

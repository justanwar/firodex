// Extension to wait all futures in a list

extension WaitAllFutures<T> on List<Future<T>> {
  /// Wait all futures in a list.
  ///
  /// See Dart docs on error handling in lists of futures: [Future.wait]
  Future<List<T>> awaitAll() => Future.wait<T>(this);
}

extension AsyncRemoveWhere<T> on List<T> {
  Future<void> removeWhereAsync(Future<bool> Function(T element) test) async {
    final List<Future<bool>> futures = map(test).toList();
    final List<bool> results = await Future.wait(futures);

    final List<T> newList = [
      for (int i = 0; i < length; i++)
        if (!results[i]) this[i],
    ];

    clear();
    addAll(newList);
  }
}

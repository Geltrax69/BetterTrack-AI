/// Minimal loading / data / error state holder used across screens so every
/// async surface has a consistent spinner → content → error(+retry) lifecycle.
sealed class AsyncValue<T> {
  const AsyncValue();
}

class AsyncLoading<T> extends AsyncValue<T> {
  const AsyncLoading();
}

class AsyncData<T> extends AsyncValue<T> {
  final T value;
  const AsyncData(this.value);
}

class AsyncError<T> extends AsyncValue<T> {
  final String message;
  const AsyncError(this.message);
}

extension AsyncValueX<T> on AsyncValue<T> {
  bool get isLoading => this is AsyncLoading<T>;
  T? get valueOrNull => this is AsyncData<T> ? (this as AsyncData<T>).value : null;
}

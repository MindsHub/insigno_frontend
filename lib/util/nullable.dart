extension NullableExtension<T> on T? {
  R? map<R>(R? Function(T t) f) {
    return this == null ? null : f(this as T);
  }
}

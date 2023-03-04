extension IterableExtension<E> on Iterable<E> {
  Iterable<T> expandIndexed<T>(Iterable<T> Function(int index, E element) toElements) =>
      ExpandIndexedIterable<E, T>(this, toElements);
}

class ExpandIndexedIterable<S, T> extends Iterable<T> {
  final Iterable<S> _iterable;
  final Iterable<T> Function(int index, S element)  _f;

  ExpandIndexedIterable(this._iterable, this._f);

  @override
  Iterator<T> get iterator => ExpandIndexedIterator<S, T>(_iterable.iterator, _f);
}

class ExpandIndexedIterator<S, T> implements Iterator<T> {
  final Iterator<S> _iterator;
  final Iterable<T> Function(int index, S element) _f;
  // Initialize _currentExpansion to an empty iterable. A null value
  // marks the end of iteration, and we don't want to call _f before
  // the first moveNext call.
  int _currentIndex = 0;
  Iterator<T>? _currentExpansion = const EmptyIterator<Never>();
  T? _current;

  ExpandIndexedIterator(this._iterator, this._f);

  @override
  T get current => _current as T;

  @override
  bool moveNext() {
    if (_currentExpansion == null) return false;
    while (!_currentExpansion!.moveNext()) {
      _current = null;
      if (_iterator.moveNext()) {
        // If _f throws, this ends iteration. Otherwise _currentExpansion and
        // _current will be set again below.
        _currentExpansion = null;
        _currentExpansion = _f(_currentIndex, _iterator.current).iterator;
        _currentIndex += 1;
      } else {
        return false;
      }
    }
    _current = _currentExpansion!.current;
    return true;
  }
}

class EmptyIterator<E> implements Iterator<E> {
  const EmptyIterator();
  @override
  bool moveNext() => false;
  @override
  E get current {
    throw StateError("No element");
  }
}

/// A model class representing marker indices.
class MarkerIndices {
  /// Default constructor for the [MarkerIndices] class.
  MarkerIndices();

  /// Constructs a [MarkerIndices] instance with the given [from] and [to] values.
  /// [from] is the starting index.
  /// [to] is the ending index.
  MarkerIndices.fromData(int this.from, int this.to);

  int? from; // The starting index.
  int? to; // The ending index.

  /// Sets the starting index.
  ///
  /// [from] is the new starting index to be set.
  void setFrom(int from) {
    this.from = from;
  }

  /// Gets the starting index.
  ///
  /// Returns the starting index as an [int].
  int? getFrom() {
    return from;
  }

  /// Gets the ending index.
  ///
  /// Returns the ending index as an [int].
  int? getTo() {
    return to;
  }

  /// Sets the ending index.
  ///
  /// [to] is the new ending index to be set.
  void setTo(int to) {
    this.to = to;
  }
}

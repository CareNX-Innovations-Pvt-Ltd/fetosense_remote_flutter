class MarkerIndices {
  MarkerIndices();
  MarkerIndices.fromData(int this.from, int this.to);

  int? from;
  int? to;

  void setFrom(int from) {
    this.from = from;
  }

  int getFrom() {
    return from!;
  }

  int getTo() {
    return to!;
  }

  void setTo(int to) {
    this.to = to;
  }

}

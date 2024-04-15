class SavedLocation{
  late String label;
  late double lat;
  late double lon;

  SavedLocation(this.label, this.lat, this.lon);

  @override
  String toString() {
    return "$label ${lat.toStringAsFixed(4)} ${lon.toStringAsFixed(4)}";
  }
}
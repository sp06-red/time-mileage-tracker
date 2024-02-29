
class Entry{
  DateTime start;
  DateTime end;
  int mileage;

  Entry(this.start, this.end, this.mileage);

  String toString(){
    String out = "";
    out += "Start: ${start.toIso8601String()}\n";
    out += "End: ${end.toIso8601String()}\n";
    out += "Miles driven: $mileage\n\n";
    return out;
  }
}

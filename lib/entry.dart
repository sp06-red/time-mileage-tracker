
class Entry{
  DateTime start;
  DateTime end;
  Duration ?duration;
  int mileage;

  Entry(this.start, this.end, this.mileage){
    duration = end.difference(start);
  }

  String toString(){
    String out = "";
    out += "Start: ${start.month}-${start.day}-${start.year} ${start.hour}:${start.minute}\n";
    out += "Duration: ${(duration?.inSeconds)!/60}\n";
    out += "Distance: $mileage";
    return out;
  }
}

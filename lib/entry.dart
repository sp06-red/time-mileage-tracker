
class Entry{
  DateTime start;
  DateTime end;
  Duration ?duration;
  int mileage;
  List<String> tags = <String>[];

  Entry(this.start, this.end, this.mileage){
    duration = end.difference(start);
  }

  String toString(){
    String out = "";
    out += "Start: ${start.month}-${start.day}-${start.year} ${start.hour}:${start.minute}\n";
    out += "Duration: ${(duration?.inSeconds)!/60}\n";
    out += "Distance: $mileage\n";
    out += tags.toString();
    return out;
  }

  void retag(List<String> taglist){
    tags = <String>[];
    for (String tag in taglist) {
      tags.add(tag);
    }
  }

  void addtag(String tag){
    tags.add(tag);
  }

  List<String> getTags(){
    return tags;
  }

}

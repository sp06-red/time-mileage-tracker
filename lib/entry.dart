
class Entry{
  late DateTime start;
  late DateTime end;
  late Duration ?duration;
  late int mileage;
  late List<String> tags = <String>[];

  Entry(this.start, this.end, this.mileage){
    duration = end.difference(start);
  }

  Entry.fromCSV(String csv){
    List<String> parts = csv.split(',');
    start = DateTime.parse(parts[0]);
    end = DateTime.parse(parts[1]);
    duration = end.difference(start);
    mileage = int.parse(parts[2]);
    tags = parts[3].split('.');
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

  String toCSV(){
    return "${start.toIso8601String()},${end.toIso8601String()},$mileage,${tags.join(".")}";
  }
}


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

  String _formatDate(DateTime date){
    return "${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  String _padTime(int n){
    return n.toString().padLeft(2, '0');
  }

  @override
  String toString(){
    String out = "";
    out += "${_formatDate(start)} to ${_formatDate(end)}\n";
    int h = (duration!.inHours%24);
    int m = (duration!.inMinutes%60);
    String s = (duration!.inSeconds%60).toString();
    String s = "";
    if (seconds >= 10) s = seconds.toString().padLeft(2,'0');
    else s = seconds.toString();
    out += "Duration: ${(h == 0) ? (m == "00" ? "$s\s" : "$m:$s") : "$h:$m:$s"}\n";
    out += "Distance: $mileage";
    try {
      if (tags.first.isNotEmpty) {
        out += "\n";
        for (String tag in tags) {
          out += "+$tag ";
        }
      }
    } catch (e){
      print("No tags");
    }
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

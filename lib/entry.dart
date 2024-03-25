import 'package:intl/intl.dart';

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
    return "${DateFormat.MMMd().format(date)} ${DateFormat.Hm().format(date)}";
  }

  String _padTime(int n){
    return n.toString().padLeft(2, '0');
  }

  @override
  String toString(){
    final out = StringBuffer();
    out.write("${_formatDate(start)} to ${_formatDate(end)}\n");
    List time = [duration!.inHours%24, duration!.inMinutes%60, duration!.inSeconds%60];
    out.write("Duration: ");
    if(time[0] != 0) {
      out.write("${time[0]}:${_padTime(time[1])}:${_padTime(time[2])}");
    } else if (time[1] != 0) {
      out.write("${time[1]}:${_padTime(time[2])}");
    } else {
      out.write(time[2] < 10 ? time[2] : _padTime(time[2]));
      out.write("s");
    }
    out.write(" | Distance: $mileage");
      try {
        if (tags.first.isNotEmpty) {
          out.write("\n");
          for (String tag in tags) {
            out.write("+$tag ");
          }
        }
      } catch (e){
        print("No tags");
      }
      return out.toString();
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

  List<String> get tagList{
    return tags;
  }

  String toCSV(){
    return "${start.toIso8601String()},${end.toIso8601String()},$mileage,${tags.join(".")}";
  }
}

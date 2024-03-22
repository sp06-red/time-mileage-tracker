import 'entry.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageManager{
  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _localFile async{
    final path = await _localPath;
    return File("$path/entries.csv");
  }

  Future<List<Entry>> readEntries() async{
    try{
      final file = await _localFile;
      List<String> contents = await file.readAsLines();
      List<Entry> entryList = <Entry>[];
      for(String entry in contents) {
        entryList.add(Entry.fromCSV(entry));
      }
      return entryList;
    } catch (e) {
      return [];
    }
  }

  Future<File> writeEntries(List<Entry> entries) async{
    final file = await _localFile;
    return file.writeAsString(entries.map((e) => e.toCSV()).join('\n'));
  }
}
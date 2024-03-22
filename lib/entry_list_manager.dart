import 'package:flutter/material.dart';
import 'storage_manager.dart';
import 'entry.dart';

class EntryListManager with ChangeNotifier{
  List<Entry> entryList = <Entry>[];
  StorageManager man = StorageManager();

  EntryListManager(){
    _load();
  }
  void wipe(){
    entryList = <Entry>[];
    _save();
    notifyListeners();
  }
  void addEntry(Entry e){
    entryList.add(e);
    _sort();
    notifyListeners();
    _save();
  }

  _sort(){
    entryList.sort((a,b) => b.start.compareTo(a.start));
  }
  int get length{
    return entryList.length;
  }

  Entry at(int i){
    return entryList[i];
  }

  void removeEntry(int hashCode){
    for(int i = 0; i != entryList.length; i++){
      if(entryList[i].hashCode == hashCode){
        entryList.removeAt(i);
        _save();
        notifyListeners();
        return;
      }
    }
  }

  List<Entry> get list{
    return entryList;
  }

  void _save(){
    man.writeEntries(entryList);
  }

  void _load() async{
    entryList = await man.readEntries();
    notifyListeners();
  }
}
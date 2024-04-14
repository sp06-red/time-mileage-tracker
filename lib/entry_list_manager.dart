import 'package:flutter/material.dart';
import 'storage_manager.dart';
import 'entry.dart';

class EntryListManager with ChangeNotifier{
  List<Entry> globalList = <Entry>[];
  List<Entry> activeList = <Entry>[];
  StorageManager man = StorageManager();

  EntryListManager(){
    _load();
  }

  void wipe(){
    globalList = <Entry>[];
    _save();
    notifyListeners();
  }

  void addEntry(Entry e){
    globalList.add(e);
    _sort();
    notifyListeners();
    _save();
  }

  _sort(){
    globalList.sort((a,b) => b.start.compareTo(a.start));
  }
  int get length{
    return globalList.length;
  }

  Entry at(int i){
    return activeList[i];
  }

  void removeEntry(int hashCode){
    for(int i = 0; i != globalList.length; i++){
      if(globalList[i].hashCode == hashCode){
        globalList.removeAt(i);
        _save();
        notifyListeners();
        return;
      }
    }
  }

  void buildFilterList(DateTime start, DateTime end, RangeValues distance, List<String> taglist){
    List<Entry> tempList = <Entry>[];
    for( Entry e in globalList) {
      if (e.start.millisecondsSinceEpoch >= start.millisecondsSinceEpoch
          && e.end.millisecondsSinceEpoch < end.millisecondsSinceEpoch ) {
        if (distance.start < e.mileage
            && distance.end > e.mileage) {
          for( String tag in taglist){
            if(e.tagList.contains(tag)){
              tempList.add(e);
            }
          }
        }
      }
    }
    activeList=tempList;
  }

  void reset(){
    activeList = globalList;
  }

  List<Entry> get list{
    return activeList;
  }

  void _save(){
    man.writeEntries(globalList);
  }

  void _load() async{
    globalList = await man.readEntries();
    notifyListeners();
  }
}
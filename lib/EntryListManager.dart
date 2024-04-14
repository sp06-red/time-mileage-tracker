import 'package:flutter/material.dart';
import 'StorageManager.dart';
import 'Entry.dart';
import 'FilterOptions.dart';

class EntryListManager with ChangeNotifier{
  List<Entry> globalList = <Entry>[];
  List<Entry> activeList = <Entry>[];
  bool activeIsGlobal = true;
  StorageManager man = StorageManager();

  EntryListManager(){
    _load();
  }

  void wipe(){
    globalList = <Entry>[];
    activeList = globalList;
    activeIsGlobal = true;
    _save();
    notifyListeners();
  }

  void addEntry(Entry e){
    globalList.add(e);
    if (activeIsGlobal){
      activeList = globalList;
    }
    _sort();
    notifyListeners();
    _save();
  }

  _sort(){
    globalList.sort((a,b) => b.start.compareTo(a.start));
  }

  int get length{
    return activeList.length;
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

  void buildFilterListFromOptions(FilterOptions options){
    buildFilterList(options.dateFilter, options.distanceFilter, options.tagList);
  }

  void buildFilterList(DateTimeRange dateTimeRange, RangeValues distance, List<String> taglist){
    List<Entry> tempList = <Entry>[];
    for( Entry e in globalList) {
      if (e.start.millisecondsSinceEpoch >= dateTimeRange.start.millisecondsSinceEpoch && e.end.millisecondsSinceEpoch <= dateTimeRange.end.millisecondsSinceEpoch ) {
        if (distance.start <= e.mileage && distance.end >= e.mileage) {
          if(taglist.isEmpty) {
            tempList.add(e);
          } else {
            for( String tag in taglist){
              if(e.tagList.contains(tag)){
                tempList.add(e);
              }
            }
          }
        }
      }
    }
    activeList=tempList;
    activeIsGlobal = false;
  }

  bool get isGlobal{
    return activeIsGlobal;
  }

  void reset(){
    activeList = globalList;
    activeIsGlobal = true;
  }

  List<Entry> get list{
    return activeList;
  }

  List<Entry> get master{
    return globalList;
  }

  void _save(){
    man.writeEntries(globalList);
  }

  void _load() async{
    globalList = await man.readEntries();
    activeList = globalList;
    notifyListeners();
  }
}
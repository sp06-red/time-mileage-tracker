import 'storage_manager.dart';
import 'entry.dart';

class EntryListManager{
  List<Entry> entryList = <Entry>[];
  StorageManager man = StorageManager();

  EntryListManager();

  void addEntry(Entry e){
    entryList.add(e);
  }

  void removeEntry(int hashCode){
    for(int i = 0; i != entryList.length; i++){
      if(entryList[i].hashCode == hashCode){
        entryList.removeAt(i);
        return;
      }
    }
  }

  List<Entry> get list{
    return entryList;
  }

  void save(){
    man.writeEntries(entryList);
  }

  void load() async{
    entryList = await man.readEntries();
  }
}
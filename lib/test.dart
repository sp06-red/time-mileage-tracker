import 'dart:developer';

import 'entry.dart';
import 'dart:io';

void main(){
  List<Entry> entries = [];
  while(true){
    print("1. add entry\n2. print entries");
    var selection = stdin.readLineSync();
    switch(int.parse(selection!)) {
      case 1:
        print("Start: ");
        var start = stdin.readLineSync();
        print("End: ");
        var end = stdin.readLineSync();
        print("Odo start: ");
        var odoStart = stdin.readLineSync();
        print("Odo end: ");
        var odoEnd = stdin.readLineSync();
        // '!' following variable names is a null check
        entries.add(Entry(DateTime.parse(start!), DateTime.parse(end!),
            int.parse(odoEnd!) - int.parse(odoStart!)));
        break;
      case 2:
        for(int i = 0; i != entries.length; i++){
          print(entries[i].toString());
        }
    }
  }

}
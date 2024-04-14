import 'package:flutter/material.dart';
import 'entry.dart';

class FilterOptions {
  late DateTimeRange dateFilter;
  late RangeValues distanceFilter;
  late List<String> tagList;

  FilterOptions(List<Entry> list){
    reset(list);
  }

  void reset(List<Entry> list) {
    tagList = <String>[];
    double minDist = list.first.mileage;
    double maxDist = minDist;
    for (int i = 0; i != list.length; i++) {
      if (list[i].mileage < minDist) minDist = list[i].mileage;
      if (list[i].mileage > maxDist) maxDist = list[i].mileage;
    }
    distanceFilter = RangeValues(minDist, maxDist);
    dateFilter = DateTimeRange(start: list.last.start, end: list.first.end);
  }
}
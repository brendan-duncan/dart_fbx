/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;

class FbxElement {
  String id;
  List properties;
  List<FbxElement> children = [];

  FbxElement(this.id, [int propertyCount]) {
    if (propertyCount != null) {
      properties = new List(propertyCount);
    } else {
      properties = new List();
    }
  }

  String getString(int index) => properties[index].toString();

  int getInt(int index) => _int(properties[index]);

  double getDouble(int index) => _double(properties[index]);


  double _double(x) => x is String ? double.parse(x) : x.toDouble();

  int _int(x) => x is String ? int.parse(x) : x.toInt();
}

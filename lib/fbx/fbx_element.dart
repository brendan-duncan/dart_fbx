/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */

class FbxElement {
  String id;
  List properties;
  List<FbxElement> children = [];

  FbxElement(this.id, [int propertyCount]) {
    if (propertyCount != null) {
      properties = List(propertyCount);
    } else {
      properties = List();
    }
  }

  String getString(int index) => properties[index].toString();

  int getInt(int index) => toInt(properties[index]);

  double getDouble(int index) => toDouble(properties[index]);

  double toDouble(x) => x is String ? double.parse(x) : x.toDouble();

  int toInt(x) => x is String ? int.parse(x) : x.toInt();
}

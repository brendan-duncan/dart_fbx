/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;

class FbxProperty {
  dynamic value;
  FbxObject connectedFrom;

  FbxProperty(this.value);

  String toString() {
    if (connectedFrom != null) {
      return '${value} <--- ${connectedFrom.name}<${connectedFrom.type}>';
    }
    return value.toString();
  }
}

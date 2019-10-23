/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import 'fbx_scene.dart';
import 'fbx_property.dart';
import 'fbx_node.dart';
import 'fbx_node_attribute.dart';

class FbxObject {
  int id;
  String name;
  String type;
  FbxElement element;
  FbxScene scene;
  Map<String, FbxProperty> properties = {};
  List<FbxObject> connectedFrom = [];
  List<FbxObject> connectedTo = [];
  List<FbxNodeAttribute> nodeAttributes = [];
  String reference;

  FbxObject(this.id, this.name, this.type, this.element, this.scene);

  FbxNode getParentNode() {
    if (this is FbxNode) {
      return this;
    }

    for (var n in connectedFrom) {
      if (n is FbxNode) {
        return n;
      }
    }

    for (var n in connectedFrom) {
      FbxNode node = n.getParentNode();
      if (node != null) {
        return node;
      }
    }

    return null;
  }


  int get numConnectedFrom => connectedFrom.length;

  FbxObject getConnectedFrom(int index) =>
      (index >= 0 && index < connectedFrom.length)
      ? connectedFrom[index] : null;

  int get numConnectedTo => connectedTo.length;

  FbxObject getConnectedTo(int index) =>
        (index >= 0 && index < connectedTo.length)
        ? connectedTo[index] : null;


  List<FbxObject> findConnectionsByType(String type,
                                        [List<FbxObject> connections]) {
    if (connections == null) {
      connections = [];
    }

    for (FbxObject obj in connectedTo) {
      if (obj.type == type) {
        connections.add(obj);
      }
    }

    return connections;
  }


  void connectTo(FbxObject object) {
    connectedTo.add(object);
    object.connectedFrom.add(this);
  }


  void connectToProperty(String propertyName, FbxObject object) {
    FbxProperty property = addProperty(propertyName);
    property.connectedFrom = object;
  }


  Iterable<String> propertyNames() => properties.keys;


  bool hasProperty(String name) => properties.containsKey(name);


  FbxProperty addProperty(String name, [defaultValue]) {
    if (!properties.containsKey(name)) {
      properties[name] = FbxProperty(defaultValue);
    }
    return properties[name];
  }


  FbxProperty setProperty(String name, value) {
    if (!properties.containsKey(name)) {
      properties[name] = FbxProperty(value);
    } else {
      properties[name].value = value;
    }
    return properties[name];
  }


  getProperty(String name) =>
      properties.containsKey(name) ? properties[name].value : null;

  String toString() => '$name ($type)';

  double toDouble(x) => x is String ? double.parse(x) : x.toDouble();

  int toInt(x) => x is String ? int.parse(x) : x.toInt();
}

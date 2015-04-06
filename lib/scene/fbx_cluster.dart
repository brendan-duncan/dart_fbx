/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;


class FbxCluster extends FbxDeformer {
  static const int NORMALIZE = 0;
  static const int ADDITIVE = 1;
  static const int TOTAL_ONE = 2;

  Uint32List indexes;
  Float32List weights;
  Matrix4 transform;
  Matrix4 transformLink;
  int linkMode = NORMALIZE;

  FbxCluster(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'Cluster', element, scene) {

    for (FbxElement c in element.children) {
      var p = (c.properties.length == 1 && c.properties[0] is List) ? c.properties[0]
              : (c.children.length == 1) ? c.children[0].properties
              : c.properties;

      if (c.id == 'Indexes') {
        indexes = new Uint32List(p.length);
        for (int i = 0, len = p.length; i < len; ++i) {
          indexes[i] = _int(p[i]);
        }
      } else if (c.id == 'Weights') {
        weights = new Float32List(p.length);
        for (int i = 0, len = p.length; i < len; ++i) {
          weights[i] = _double(p[i]);
        }
      } else if (c.id == 'Transform') {
        transform = new Matrix4.identity();
        for (int i = 0, len = p.length; i < len; ++i) {
          transform.storage[i] = _double(p[i]);
        }
      } else if (c.id == 'TransformLink') {
        transformLink = new Matrix4.identity();
        for (int i = 0, len = p.length; i < len; ++i) {
          transformLink.storage[i] = _double(p[i]);
        }
      }
    }
  }

  FbxNode getLink() => connectedTo.isNotEmpty ? connectedTo[0] : null;
}


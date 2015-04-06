/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;

class FbxLayer {
  bool get hasNormals => _normals != null;

  FbxLayerElement<Vector3> get normals {
    if (_normals == null) {
      _normals = new FbxLayerElement<Vector3>();
    }
    return _normals;
  }


  bool get hasBinormals => _binormals != null;

  FbxLayerElement<Vector3> get binormals {
    if (_binormals == null) {
      _binormals = new FbxLayerElement<Vector3>();
    }
    return _binormals;
  }


  bool get hasTangents => _tangents != null;

  FbxLayerElement<Vector3> get tangents {
    if (_tangents == null) {
      _tangents = new FbxLayerElement<Vector3>();
    }
    return _tangents;
  }


  bool get hasUvs => _uvs != null;

  FbxLayerElement<Vector2> get uvs {
    if (_uvs == null) {
      _uvs = new FbxLayerElement<Vector2>();
    }
    return _uvs;
  }


  bool get hasColors => _colors != null;

  FbxLayerElement<Vector4> get colors {
    if (_colors == null) {
      _colors = new FbxLayerElement<Vector4>();
    }
    return _colors;
  }

  FbxLayerElement<Vector3> _normals;
  FbxLayerElement<Vector3> _binormals;
  FbxLayerElement<Vector3> _tangents;
  FbxLayerElement<Vector2> _uvs;
  FbxLayerElement<Vector4> _colors;
}

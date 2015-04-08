/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;


class FbxMesh extends FbxGeometry {
  List<Vector3> points;
  int polygonVertexCount = 0;
  List<FbxPolygon> polygons = [];
  List<FbxEdge> edges = [];
  List<FbxLayer> layers = [];
  List<FbxDisplayMesh> display = [];
  List clusterMap = [];


  FbxMesh(int id, FbxElement element, FbxScene scene)
    : super(id, '', 'Mesh', element, scene) {

    for (FbxElement c in element.children) {
      if (c.id == 'Vertices') {
        _loadPoints(c);
      } else if (c.id == 'PolygonVertexIndex') {
        _loadPolygons(c);
      } else if (c.id == 'Edges') {
        _loadEdges(c);
      } else if (c.id == 'LayerElementNormal') {
        _loadNormals(c);
      } else if (c.id == 'LayerElementUV') {
        _loadUvs(c);
      } else if (c.id == 'LayerElementTexture') {
        _loadTexture(c);
      }
    }
  }


  FbxLayer getLayer(int index) {
    while (layers.length <= index) {
      layers.add(null);
    }

    if (layers[index] == null) {
      layers[index] = new FbxLayer();
    }

    return layers[index];
  }


  List<FbxSkinDeformer> get skinDeformer {
    return findConnectionsByType('Skin');
  }


  List<FbxCluster> getClusters() {
    var clusters = [];
    List<FbxObject> skins = findConnectionsByType('Skin');
    for (FbxSkinDeformer skin in skins) {
      skin.findConnectionsByType('Cluster', clusters);
    }
    return clusters;
  }


  bool hasDeformedPoints() => _deformedPoints != null;

  List<Vector3> get deformedPoints {
    if (_deformedPoints == null) {
      _deformedPoints = new List<Vector3>(points.length);
    }
    return _deformedPoints;
  }


  void computeDeformations() {
    FbxNode meshNode = getConnectedFrom(0);
    if (meshNode == null) {
      return;
    }
    computeLinearBlendSkinning(meshNode);
    updateDisplayMesh();
  }


  void updateDisplayMesh() {
    List<Vector3> pts = _deformedPoints != null ? _deformedPoints : points;
    if (_deformedPoints[0] == null) {
      pts = points;
    }

    FbxDisplayMesh disp = display[0];
    for (int pi = 0, len = pts.length; pi < len; ++pi) {
      for (int vi = 0; vi < disp.pointMap[pi].length; ++vi) {
        int dpi = disp.pointMap[pi][vi];
        disp.points[dpi] = pts[pi].x;
        disp.points[dpi + 1] = pts[pi].y;
        disp.points[dpi + 2] = pts[pi].z;
      }
    }
  }


  Float32List computeSkinPalette([Float32List data]) {
    FbxNode meshNode = getConnectedFrom(0);
    if (meshNode == null) {
      return null;
    }

    List<FbxCluster> clusters = getClusters();
    if (data == null) {
      data = new Float32List(clusters.length * 16);
    }

    FbxPose pose = scene.getPose(0);

    for (int i = 0, j = 0, len = clusters.length; i < len; ++i) {
      FbxCluster cluster = clusters[i];
      Matrix4 w = _getClusterMatrix(meshNode, cluster, pose);
      for (int k = 0; k < 16; ++k) {
        data[j++] = w.storage[k];
      }
    }

    return data;
  }


  void computeLinearBlendSkinning(FbxNode meshNode) {
    List<Vector3> outPoints = deformedPoints;
    FbxPose pose = scene.getPose(0);

    for (int pi = 0, len = points.length; pi < len; ++pi) {
      if (clusterMap[pi] == null || clusterMap[pi].isEmpty) {
        continue;
      }

      Vector3 sp = new Vector3.zero();
      Vector3 p = points[pi];
      double weightSum = 0.0;

      int clusterMode = FbxCluster.NORMALIZE;

      for (List clusterWeight in clusterMap[pi]) {
        FbxCluster cluster = clusterWeight[0];
        double weight = clusterWeight[1];

        clusterMode = cluster.linkMode;

        Matrix4 w = _getClusterMatrix(meshNode, cluster, pose);

        sp += (w * p) * weight;

        weightSum += weight;
      }

      if (clusterMode == FbxCluster.NORMALIZE) {
        if (weightSum != 0.0) {
          sp /= weightSum;
        }
      } else if (clusterMode == FbxCluster.TOTAL_ONE) {
        sp += p * (1.0 - weightSum);
      }

      outPoints[pi] = sp;
    }
  }


  Matrix4 _getClusterMatrix(FbxNode meshNode, FbxCluster cluster,
                            FbxPose pose) {
    FbxNode joint = cluster.getLink();

    Matrix4 refGlobalInitPos = pose.getMatrix(meshNode);

    Matrix4 refGlobalCurrentPos = meshNode.evalGlobalTransform();

    Matrix4 clusterGlobalInitPos = _inverseMat(cluster.transformLink);

    Matrix4 clusterGlobalCurrentPos = joint.evalGlobalTransform();

    Matrix4 clusterRelativeInitPos = clusterGlobalInitPos * refGlobalInitPos;

    Matrix4 clusterRelativeCurrentPosInverse = _inverseMat(refGlobalCurrentPos)
                                               * clusterGlobalCurrentPos;

    Matrix4 vertexTransform = clusterRelativeCurrentPosInverse
                              * clusterRelativeInitPos;

    return vertexTransform;
  }


  void generateClusterMap() {
    clusterMap = new List(points.length);

    List<FbxCluster> clusters = getClusters();
    for (FbxCluster cluster in clusters) {
      if (cluster.indexes == null || cluster.weights == null) {
        continue;
      }

      for (int i = 0; i < cluster.indexes.length; ++i) {
        int pi = cluster.indexes[i];
        if (clusterMap[pi] == null) {
          clusterMap[pi] = [];
        }
        clusterMap[pi].add([cluster, cluster.weights[i]]);
      }
    }
  }


  void generateDisplayMeshes() {
    display = [];

    if (points == null) {
      return;
    }

    FbxDisplayMesh disp = new FbxDisplayMesh();
    display.add(disp);

    bool splitPolygonVerts = false;

    FbxLayer layer;
    FbxLayerElement<Vector3> normals;

    if (layers.isNotEmpty) {
      layer = layers[0];
    }

    if (layer != null && layer.hasNormals) {
      normals = layer.normals;
      if (normals.mappingMode != FbxMappingMode.ByControlPoint) {
        splitPolygonVerts = true;
      }
    }

    disp.pointMap = new List<List<int>>(points.length);

    if (splitPolygonVerts) {
      int triCount = 0;
      int numPoints = 0;
      for (FbxPolygon poly in polygons) {
        triCount += poly.vertices.length - 2;
        numPoints += poly.vertices.length;
      }

      disp.numPoints = numPoints;
      disp.points = new Float32List(numPoints * 3);
      disp.vertices = new Uint16List(triCount * 3);

      if (normals != null) {
        disp.normals = new Float32List(disp.points.length);
      }

      int pi = 0;
      int ni = 0;
      int ni2 = 0;
      for (FbxPolygon poly in polygons) {
        for (int vi = 0, len = poly.vertices.length; vi < len; ++vi, ++ni2) {
          int p1 = poly.vertices[vi];

          if (disp.pointMap[p1] == null) {
            disp.pointMap[p1] = new List<int>();
          }
          disp.pointMap[p1].add(pi);

          disp.points[pi++] = points[p1].x;
          disp.points[pi++] = points[p1].y;
          disp.points[pi++] = points[p1].z;


          if (normals != null) {
            disp.normals[ni++] = normals[ni2].x;
            disp.normals[ni++] = normals[ni2].y;
            disp.normals[ni++] = normals[ni2].z;
          }
        }
      }

      pi = 0;
      int xi = 0;
      for (FbxPolygon poly in polygons) {
        for (int vi = 2, len = poly.vertices.length; vi < len; ++vi) {
          disp.vertices[xi++] = pi;
          disp.vertices[xi++] = pi + (vi - 1);
          disp.vertices[xi++] = pi + vi;
        }
        pi += poly.vertices.length;
      }
    } else {
      disp.numPoints = points.length;
      disp.points = new Float32List(points.length * 3);
      for (int xi = 0, pi = 0, len = points.length; xi < len; ++xi) {
        disp.pointMap[xi] = [pi];

        disp.points[pi++] = points[xi].x;
        disp.points[pi++] = points[xi].y;
        disp.points[pi++] = points[xi].z;
      }

      if (normals != null) {
        disp.normals = new Float32List(disp.points.length);

        for (int vi = 0, ni = 0, len = normals.data.length; ni < len; ++ni) {
          disp.normals[vi++] = normals[ni].x;
          disp.normals[vi++] = normals[ni].y;
          disp.normals[vi++] = normals[ni].z;
        }
      }

      List<int> verts = [];

      int pi = 0;
      for (FbxPolygon poly in polygons) {
        for (int vi = 2, len = poly.vertices.length; vi < len; ++vi) {
          verts.add(poly.vertices[0]);
          verts.add(poly.vertices[vi - 1]);
          verts.add(poly.vertices[vi]);
        }
      }

      disp.vertices = new Uint16List.fromList(verts);
    }

    if (disp.normals == null) {
      disp.generateSmoothNormals();
    }

    List<FbxCluster> clusters = getClusters();
    if (clusters.isNotEmpty) {
      disp.skinWeights = new Float32List(disp.numPoints * 4);
      disp.skinIndices = new Float32List(disp.numPoints * 4);

      disp.skinIndices.fillRange(0, disp.skinIndices.length - 1, -1.0);

      Int32List count = new Int32List(points.length);

      for (int ci = 0, len = clusters.length; ci < len; ++ci) {
        FbxCluster cluster = clusters[ci];
        for (int xi = 0, numPts = cluster.indexes.length; xi < numPts; ++xi) {
          double weight = cluster.weights[xi];
          int pi = cluster.indexes[xi];

          for (int vi = 0, nv = disp.pointMap[pi].length; vi < nv; ++vi) {
            int pv = disp.pointMap[pi][vi] ~/ 3;
            int wi = pv * 4 + count[pi];
            disp.skinIndices[wi] = ci.toDouble();
            disp.skinWeights[wi] = weight;
          }

          count[pi]++;
        }
      }
    }
  }


  void _loadPoints(FbxElement e) {
    var p = (e.properties.length == 1 && e.properties[0] is List) ? e.properties[0]
            : (e.children.length == 1) ? e.children[0].properties
            : e.properties;

    points = new List(p.length ~/ 3);

    for (int i = 0, j = 0, len = p.length; i < len; i += 3) {
      points[j++] = new Vector3(_double(p[i]), _double(p[i + 1]),
                                _double(p[i + 2]));
    }
  }


  void _loadPolygons(FbxElement e) {
    var p = (e.properties.length == 1 && e.properties[0] is List) ? e.properties[0]
            : (e.children.length == 1) ? e.children[0].properties
            : e.properties;

    polygonVertexCount = p.length;

    int polygonStart = 0;

    // Triangulate the mesh while we're parsing it.
    for (int i = 0, len = p.length; i < len; ++i) {
      int vi = _int(p[i]);

      // negative index indicates the end of a polygon
      if (vi < 0) {
        vi = ~vi;

        FbxPolygon poly = new FbxPolygon();
        polygons.add(poly);

        for (int xi = polygonStart; xi < i; ++xi) {
          poly.vertices.add(_int(p[xi]));
        }
        poly.vertices.add(vi);

        polygonStart = i + 1;
      }
    }
  }


  void _loadEdges(FbxElement e) {
    /*var p = (e.properties.length == 1 && e.properties[0] is List) ? e.properties[0]
            : (e.children.length == 1) ? e.children[0].properties
            : e.properties;

    for (int ei = 0, len = p.length; ei < len; ei += 2) {
      int v1 = _int(p[ei]);
      int v2 = _int(p[ei + 1]);
      edges.add(new FbxEdge(v1, v2));
    }*/
  }


  void _loadNormals(FbxElement e) {
    int layerIndex = _int(e.properties[0]);
    FbxLayer layer = getLayer(layerIndex);

    FbxLayerElement<Vector3> normals = layer.normals;

    for (FbxElement c in e.children) {
      if (c.properties.isEmpty) {
        continue;
      }

      if (c.id == 'MappingInformationType') {
        normals.mappingMode = _stringToMappingMode(c.properties[0]);
      } else if (c.id == 'ReferenceInformationType') {
        normals.referenceMode = _stringToReferenceMode(c.properties[0]);
      } else if (c.id == 'Normals') {
        var p = (c.properties.length == 1 && c.properties[0] is List) ? c.properties[0]
                : (c.children.length == 1) ? c.children[0].properties
                : c.properties;

        normals.data = new List<Vector3>(p.length ~/ 3);
        for (int i = 0, j = 0, len = p.length; i < len; i += 3) {
          normals.data[j++] = new Vector3(_double(p[i]),
              _double(p[i + 1]),
              _double(p[i + 2]));
        }
      }
    }
  }

  void _loadUvs(FbxElement e) {
    int layerIndex = _int(e.properties[0]);
    FbxLayer layer = getLayer(layerIndex);

    FbxLayerElement<Vector2> uvs = layer.uvs;

    for (FbxElement c in e.children) {
      var p = (c.properties.length == 1 && c.properties[0] is List) ? c.properties[0]
              : (c.children.length == 1) ? c.children[0].properties
              : c.properties;

      if (c.id == 'MappingInformationType') {
        uvs.mappingMode = _stringToMappingMode(p[0]);
      } else if (c.id == 'ReferenceInformationType') {
        uvs.referenceMode = _stringToReferenceMode(p[0]);
      } else if (c.id == 'UV' && p.isNotEmpty) {
        uvs.data = new List<Vector2>(p.length ~/ 2);
        for (int i = 0, j = 0, len = p.length; i < len; i += 2) {
          uvs.data[j++] = new Vector2(_double(p[i]), _double(p[i + 1]));
        }
      }
    }
  }


  void _loadTexture(FbxElement e) {
  }


  List<Vector3> _deformedPoints;
}


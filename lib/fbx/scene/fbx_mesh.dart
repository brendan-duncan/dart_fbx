/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import '../matrix_utils.dart';
import 'fbx_cluster.dart';
import 'fbx_display_mesh.dart';
import 'fbx_edge.dart';
import 'fbx_geometry.dart';
import 'fbx_layer.dart';
import 'fbx_layer_element.dart';
import 'fbx_mapping_mode.dart';
import 'fbx_node.dart';
import 'fbx_object.dart';
import 'fbx_polygon.dart';
import 'fbx_pose.dart';
import 'fbx_reference_mode.dart';
import 'fbx_scene.dart';
import 'fbx_skin_deformer.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:typed_data';

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
      layers[index] = FbxLayer();
    }

    return layers[index];
  }

  List<FbxSkinDeformer> get skinDeformer {
    return findConnectionsByType('Skin');
  }

  List<FbxCluster> _getClusters() {
    List<FbxCluster> clusters = [];
    List<FbxObject> skins = findConnectionsByType('Skin');
    for (FbxSkinDeformer skin in skins) {
      List<FbxCluster> l = [];
      skin.findConnectionsByType('Cluster', l);
      for (var c in l) {
        
        if (c.indexes != null && c.weights != null) {
          clusters.add(c);
        }
      }
    }
    return clusters;
  }

  bool hasDeformedPoints() => _deformedPoints != null;

  List<Vector3> get deformedPoints {
    if (_deformedPoints == null) {
      _deformedPoints = List<Vector3>(points.length);
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


    if (data == null) {
      data = Float32List(_clusters.length * 16);
    }

    FbxPose pose = scene.getPose(0);

    for (int i = 0, j = 0, len = _clusters.length; i < len; ++i) {
      FbxCluster cluster = _clusters[i];
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

      Vector3 sp = Vector3.zero();
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

    Matrix4 clusterGlobalInitPos = inverseMat(cluster.transformLink);

    Matrix4 clusterGlobalCurrentPos = joint.evalGlobalTransform();

    Matrix4 clusterRelativeInitPos = clusterGlobalInitPos * refGlobalInitPos;

    Matrix4 clusterRelativeCurrentPosInverse = inverseMat(refGlobalCurrentPos)
                                               * clusterGlobalCurrentPos;

    Matrix4 vertexTransform = clusterRelativeCurrentPosInverse
                              * clusterRelativeInitPos;

    return vertexTransform;
  }

  void generateClusterMap() {
    clusterMap = List(points.length);

    for (FbxCluster cluster in _clusters) {
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

    _clusters = _getClusters();
    generateClusterMap();

    FbxDisplayMesh disp = FbxDisplayMesh();
    display.add(disp);

    bool splitPolygonVerts = false;

    FbxLayer layer;
    FbxLayerElement<Vector3> normals;
    FbxLayerElement<Vector2> uvs;

    if (layers.isNotEmpty) {
      layer = layers[0];
    }

    if (layer != null && layer.hasNormals) {
      normals = layer.normals;
      if (normals.mappingMode != FbxMappingMode.ByControlPoint) {
        splitPolygonVerts = true;
      }
    }

    if (layer != null && layer.hasUvs) {
      uvs = layer.uvs;
      if (uvs.mappingMode != FbxMappingMode.ByControlPoint) {
        splitPolygonVerts = true;
      }
    }

    disp.pointMap = List<List<int>>(points.length);

    if (splitPolygonVerts) {
      int triCount = 0;
      int numPoints = 0;
      for (FbxPolygon poly in polygons) {
        triCount += poly.vertices.length - 2;
        numPoints += poly.vertices.length;
      }

      disp.numPoints = numPoints;
      disp.points = Float32List(numPoints * 3);
      disp.vertices = Uint16List(triCount * 3);

      if (normals != null) {
        disp.normals = Float32List(disp.points.length);
      }

      if (uvs != null) {
        disp.uvs = Float32List(disp.points.length);
      }

      int pi = 0;
      int ni = 0;
      int ni2 = 0;
      int ti = 0;
      int ti2 = 0;

      for (FbxPolygon poly in polygons) {
        for (int vi = 0, len = poly.vertices.length; vi < len;
             ++vi, ++ni2, ++ti2) {
          int p1 = poly.vertices[vi];

          if (disp.pointMap[p1] == null) {
            disp.pointMap[p1] = List<int>();
          }
          disp.pointMap[p1].add(pi);

          disp.points[pi++] = points[p1].x;
          disp.points[pi++] = points[p1].y;
          disp.points[pi++] = points[p1].z;

          if (normals != null) {
            if (normals.mappingMode == FbxMappingMode.ByControlPoint) {
              ni2 = p1;
            }
            disp.normals[ni++] = normals[ni2].x;
            disp.normals[ni++] = normals[ni2].y;
            disp.normals[ni++] = normals[ni2].z;
          }

          if (uvs != null) {
            if (uvs.mappingMode == FbxMappingMode.ByControlPoint) {
              ti2 = p1;
            }
            if (ti2 < uvs.length) {
              disp.uvs[ti++] = uvs[ti2].x;
              disp.uvs[ti++] = uvs[ti2].y;
            }
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
      disp.points = Float32List(points.length * 3);

      for (int xi = 0, pi = 0, len = points.length; xi < len; ++xi) {
        disp.pointMap[xi] = [pi];

        disp.points[pi++] = points[xi].x;
        disp.points[pi++] = points[xi].y;
        disp.points[pi++] = points[xi].z;
      }

      if (normals != null) {
        disp.normals = Float32List(disp.points.length);

        for (int vi = 0, ni = 0, len = normals.data.length; ni < len; ++ni) {
          disp.normals[vi++] = normals[ni].x;
          disp.normals[vi++] = normals[ni].y;
          disp.normals[vi++] = normals[ni].z;
        }
      }

      if (uvs != null) {
        disp.uvs = Float32List(points.length * 2);

        for (int vi = 0, ni = 0, len = uvs.data.length; ni < len; ++ni) {
          disp.uvs[vi++] = uvs[ni].x;
          disp.uvs[vi++] = uvs[ni].y;
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

      disp.vertices = Uint16List.fromList(verts);
    }

    if (disp.normals == null) {
      disp.generateSmoothNormals();
    }

    if (_clusters.isNotEmpty) {
      disp.skinWeights = Float32List(disp.numPoints * 4);
      disp.skinIndices = Float32List(disp.numPoints * 4);

      Int32List count = Int32List(points.length);

      for (int ci = 0, len = _clusters.length; ci < len; ++ci) {
        double index = ci.toDouble();

        FbxCluster cluster = _clusters[ci];

        for (int xi = 0, numPts = cluster.indexes.length; xi < numPts; ++xi) {
          double weight = cluster.weights[xi];
          int pi = cluster.indexes[xi];

          for (int vi = 0, nv = disp.pointMap[pi].length; vi < nv; ++vi) {
            int pv = (disp.pointMap[pi][vi] ~/ 3) * 4;

            if (count[pi] > 3) {
              for (int cc = 0; cc < 4; ++cc) {
                if (disp.skinWeights[pv + cc] < weight) {
                  disp.skinIndices[pv + cc] = index;
                  disp.skinWeights[pv + cc] = weight;
                  break;
                }
              }
            } else {
              int wi = pv + count[pi];
              disp.skinIndices[wi] = index;
              disp.skinWeights[wi] = weight;
            }
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

    points = List(p.length ~/ 3);

    for (int i = 0, j = 0, len = p.length; i < len; i += 3) {
      points[j++] = Vector3(toDouble(p[i]), toDouble(p[i + 1]),
                                toDouble(p[i + 2]));
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
      int vi = toInt(p[i]);

      // negative index indicates the end of a polygon
      if (vi < 0) {
        vi = ~vi;

        FbxPolygon poly = FbxPolygon();
        polygons.add(poly);

        for (int xi = polygonStart; xi < i; ++xi) {
          poly.vertices.add(toInt(p[xi]));
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
      int v1 = toInt(p[ei]);
      int v2 = toInt(p[ei + 1]);
      edges.add(FbxEdge(v1, v2));
    }*/
  }


  void _loadNormals(FbxElement e) {
    int layerIndex = toInt(e.properties[0]);
    FbxLayer layer = getLayer(layerIndex);

    FbxLayerElement<Vector3> normals = layer.normals;

    for (FbxElement c in e.children) {
      if (c.properties.isEmpty) {
        continue;
      }

      if (c.id == 'MappingInformationType') {
        normals.mappingMode = stringToMappingMode(c.properties[0]);
      } else if (c.id == 'ReferenceInformationType') {
        normals.referenceMode = stringToReferenceMode(c.properties[0]);
      } else if (c.id == 'Normals') {
        var p = (c.properties.length == 1 && c.properties[0] is List) ? c.properties[0]
                : (c.children.length == 1) ? c.children[0].properties
                : c.properties;

        normals.data = List<Vector3>(p.length ~/ 3);
        for (int i = 0, j = 0, len = p.length; i < len; i += 3) {
          normals.data[j++] = Vector3(toDouble(p[i]),
              toDouble(p[i + 1]),
              toDouble(p[i + 2]));
        }
      }
    }
  }

  void _loadUvs(FbxElement e) {
    int layerIndex = toInt(e.properties[0]);
    FbxLayer layer = getLayer(layerIndex);

    FbxLayerElement<Vector2> uvs = layer.uvs;

    for (FbxElement c in e.children) {
      var p = (c.properties.length == 1 && c.properties[0] is List) ? c.properties[0]
              : (c.children.length == 1) ? c.children[0].properties
              : c.properties;

      if (c.id == 'MappingInformationType') {
        uvs.mappingMode = stringToMappingMode(p[0]);
      } else if (c.id == 'ReferenceInformationType') {
        uvs.referenceMode = stringToReferenceMode(p[0]);
      } else if (c.id == 'UV' && p.isNotEmpty) {
        uvs.data = List<Vector2>(p.length ~/ 2);
        for (int i = 0, j = 0, len = p.length; i < len; i += 2) {
          uvs.data[j++] = Vector2(toDouble(p[i]), toDouble(p[i + 1]));
        }
      }
    }
  }

  void _loadTexture(FbxElement e) {
  }

  List<Vector3> _deformedPoints;
  List<FbxCluster> _clusters = [];
}

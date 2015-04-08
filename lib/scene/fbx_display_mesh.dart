/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;


class FbxDisplayMesh {
  int numPoints;
  Float32List points;
  Float32List normals;
  Float32List uvs;
  Float32List colors;
  Uint16List vertices;
  Float32List skinWeights;
  Float32List skinIndices;
  List<List<int>> pointMap;


  void generateSmoothNormals() {
    if (vertices == null || points == null) {
      return;
    }

    // Compute normals
    normals = new Float32List(points.length);
    for (int ti = 0; ti < vertices.length; ti += 3) {
      Vector3 p1 = new Vector3(points[vertices[ti] * 3],
          points[vertices[ti] * 3 + 1],
          points[vertices[ti] * 3 + 2]);

      Vector3 p2 = new Vector3(points[vertices[ti + 1] * 3],
          points[vertices[ti + 1] * 3 + 1],
          points[vertices[ti + 1] * 3 + 2]);

      Vector3 p3 = new Vector3(points[vertices[ti + 2] * 3],
          points[vertices[ti + 2] * 3 + 1],
          points[vertices[ti + 2] * 3 + 2]);

      Vector3 N = (p2 - p1).cross(p3 - p1);

      normals[vertices[ti] * 3] += N.x;
      normals[vertices[ti] * 3 + 1] += N.y;
      normals[vertices[ti] * 3 + 2] += N.z;

      normals[vertices[ti + 1] * 3] += N.x;
      normals[vertices[ti + 1] * 3 + 1] += N.y;
      normals[vertices[ti + 1] * 3 + 2] += N.z;

      normals[vertices[ti + 2] * 3] += N.x;
      normals[vertices[ti + 2] * 3 + 1] += N.y;
      normals[vertices[ti + 2] * 3 + 2] += N.z;
    }

    for (int ni = 0; ni < normals.length; ni += 3) {
      double l = normals[ni] * normals[ni]
                 + normals[ni + 1] * normals[ni + 1]
                 + normals[ni + 2] * normals[ni + 2];
      if (l == 0.0) {
        continue;
      }

      l = 1.0 / sqrt(l);

      normals[ni] *= l;
      normals[ni + 1] *= l;
      normals[ni + 2] *= l;
    }
  }
}
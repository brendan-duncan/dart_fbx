/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;

class FbxAnimEvaluator extends FbxObject {
  FbxAnimEvaluator(FbxScene scene)
    : super(0, '', 'AnimEvaluator', null, scene);


  Matrix4 getNodeGlobalTransform(FbxNode node, double time) {
    Matrix4 t = getNodeLocalTransform(node, time);

    if (node.parent != null) {
      Matrix4 pt = getNodeGlobalTransform(node.parent, time);
      t = pt * t;
    }

    return t;
  }


  Matrix4 getNodeLocalTransform(FbxNode node, double time) {
    // Cache the evaluated transform
    if (node.evalTime == time) {
      return node.transform;
    }
    node.evalTime = time;

    double tx = node.translate.value.x;
    double ty = node.translate.value.y;
    double tz = node.translate.value.z;
    double rx = node.rotate.value.x;
    double ry = node.rotate.value.y;
    double rz = node.rotate.value.z;
    double sx = node.scale.value.x;
    double sy = node.scale.value.y;
    double sz = node.scale.value.z;

    if (node.translate.connectedFrom != null
        && node.translate.connectedFrom is FbxAnimCurveNode) {
      FbxAnimCurveNode animNode = node.translate.connectedFrom;
      Map ap = animNode.properties;

      if (ap.containsKey('X')) {
        tx = evalCurve(ap['X'].connectedFrom, time);
      }

      if (ap.containsKey('Y')) {
        ty = evalCurve(ap['Y'].connectedFrom, time);
      }

      if (ap.containsKey('Z')) {
        tz = evalCurve(ap['Z'].connectedFrom, time);
      }
    }


    if (node.rotate.connectedFrom != null
        && node.rotate.connectedFrom is FbxAnimCurveNode) {
      FbxAnimCurveNode animNode = node.rotate.connectedFrom;
      Map ap = animNode.properties;

      if (ap.containsKey('X')) {
        rx = evalCurve(ap['X'].connectedFrom, time);
      }

      if (ap.containsKey('Y')) {
        ry = evalCurve(ap['Y'].connectedFrom, time);
      }

      if (ap.containsKey('Z')) {
        rz = evalCurve(ap['Z'].connectedFrom, time);
      }
    }


    if (node.scale.connectedFrom != null
        && node.scale.connectedFrom is FbxAnimCurveNode) {
      FbxAnimCurveNode animNode = node.scale.connectedFrom;
      Map ap = animNode.properties;

      if (ap.containsKey('X')) {
        sx = evalCurve(ap['X'].connectedFrom, time);
      }

      if (ap.containsKey('Y')) {
        sy = evalCurve(ap['Y'].connectedFrom, time);
      }

      if (ap.containsKey('Z')) {
        sz = evalCurve(ap['Z'].connectedFrom, time);
      }
    }

    node.transform.setIdentity();
    node.transform.translate(tx, ty, tz);
    node.transform.rotateZ(radians(rz));
    _rotateY(node.transform, radians(ry));
    node.transform.rotateX(radians(rx));
    node.transform.scale(sx, sy, sz);

    return node.transform;
  }


  double evalCurve(FbxAnimCurve curve, double frame) {
    if (curve.numKeys == 0) {
      if (curve.defaultValue != null) {
        return curve.defaultValue;
      }
      return 0.0;
    }

    if (frame < scene.timeToFrame(curve.keyTime(0))) {
      return curve.keyValue(0);
    }

    for (int i = 0, numKeys = curve.numKeys; i < numKeys; ++i) {
      double kf = scene.timeToFrame(curve.keyTime(i));
      if (frame == kf) {
        return curve.keyValue(i);
      }

      if (frame < kf) {
        if (i == 0) {
          return curve.keyValue(i);
        }

        double kf2 = scene.timeToFrame(curve.keyTime(i - 1));

        double u = (frame - kf2) / (kf - kf2);

        return ((1.0 - u) * curve.keyValue(i - 1)) +
               (u * curve.keyValue(i));
      }
    }

    return curve.keys.last.value;
  }
}

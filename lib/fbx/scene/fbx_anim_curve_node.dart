/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;

class FbxAnimCurveNode extends FbxObject {
  FbxAnimCurveNode(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'AnimCurveNode', element, scene);
}

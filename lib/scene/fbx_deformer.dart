/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;

class FbxDeformer extends FbxObject {
  FbxDeformer(int id, String name, String type, FbxElement element,
              FbxScene scene)
    : super(id, name, type, element, scene);
}
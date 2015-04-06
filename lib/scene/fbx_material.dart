/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;

class FbxMaterial extends FbxObject {
  FbxMaterial(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'Material', element, scene);
}

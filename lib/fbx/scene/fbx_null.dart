/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;


class FbxNull extends FbxNodeAttribute {
  FbxNull(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'Null', element, scene);
}

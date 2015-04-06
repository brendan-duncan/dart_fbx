/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;


class FbxCameraSwitcher extends FbxNodeAttribute {
  FbxCameraSwitcher(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'CameraSwitcher', element, scene);
}

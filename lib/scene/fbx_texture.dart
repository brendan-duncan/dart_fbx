/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;


class FbxTexture extends FbxNode {
  FbxTexture(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'Texture', element, scene);
}


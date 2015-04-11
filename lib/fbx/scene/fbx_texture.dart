/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;


class FbxTexture extends FbxNode {
  String filename;

  FbxTexture(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'Texture', element, scene) {
    for (FbxElement c in element.children) {
      if (c.id == 'FileName') {
        filename = c.getString(0);
      }
    }
  }
}


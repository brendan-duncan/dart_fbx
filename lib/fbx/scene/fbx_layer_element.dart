/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;


class FbxLayerElement<T> {
  FbxMappingMode mappingMode = FbxMappingMode.None;
  FbxReferenceMode referenceMode = FbxReferenceMode.Direct;
  List<int> indexArray;
  List<T> data;

  T operator[](int index) => data[index];

  operator[]=(int index, T v) => data[index] = v;
}

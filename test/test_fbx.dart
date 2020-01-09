import 'package:fbx/fbx.dart';
import 'package:test/test.dart';
import 'dart:io';

var files = [
  'web/data/cube_anim_ascii_2014.fbx',
  'web/data/cube_anim2_ascii_2014.fbx',
  'web/data/cube_ascii_2014.fbx',
  'web/data/cube_skin_ascii_2014.fbx',
  'web/data/cylinder_ascii_fbx2006.fbx',
  'web/data/cylinder_ascii_fbx2012.fbx',
  'web/data/cylinder_ascii_fbx2014.fbx',
  'web/data/cylinder_bin_fbx2013.fbx',
  'web/data/cylinder_bin_fbx2014.fbx',
  'web/data/cylinder_skin_ascii_2014.fbx',
  'web/data/cylinder_skinned_ascii_fbx2006.fbx',
  'web/data/cylinder_skinned_ascii_fbx2014.fbx',
  'web/data/cylinder_skinned_bin_fbx2006.fbx',
  'web/data/knight.fbx',
  'web/data/knight_2014.fbx'
];

void loadFile(String filename) {
  var bytes = File(filename).readAsBytesSync();
  var scene = FbxLoader().load(bytes);
  for (final mesh in scene.meshes) {
    final meshNode = mesh.getParentNode();
    if (meshNode == null) {
      continue;
    }
    mesh.generateDisplayMeshes();
    if (mesh.display.isEmpty) {
      continue;
    }
  }
}

void main() {
  group('FBX', () {
    for (var file in files) {
      test('Load $file', () {
        loadFile(file);
      });
    }
  });
}

/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;


/**
 * Decodes an FBX file into an [FbxScene] structure.
 */
class FbxLoader {
  FbxScene load(List<int> bytes) {
    InputBuffer input = new InputBuffer(bytes);

    if (FbxBinaryParser.isValidFile(input)) {
      _parser = new FbxBinaryParser(input);
    } else if (FbxAsciiParser.isValidFile(input)) {
      _parser = new FbxAsciiParser(input);
    } else {
      return null;
    }

    FbxScene scene = new FbxScene();

    FbxElement elem = _parser.nextElement();
    while (elem != null) {
      _loadRootElement(elem, scene);
      elem = _parser.nextElement();
    }

    _parser = null;

    return scene;
  }


  void _loadRootElement(FbxElement e, FbxScene scene) {
    if (e.id == 'FBXHeaderExtension') {
      _loadHeaderExtension(e, scene);
    } else if (e.id == 'GlobalSettings') {
      FbxGlobalSettings node = new FbxGlobalSettings(e, scene);
      scene.globalSettings = node;
    } else if (e.id == 'Objects') {
      _loadObjects(e, scene);
    } else if (e.id == 'Connections') {
      _loadConnections(e, scene);
      _fixConnections(scene);
    } else if (e.id == 'Takes') {
      _loadTakes(e, scene);
    } else {
      //print('Unhandled Element ${e.id}');
    }
  }


  void _loadTakes(FbxElement e, FbxScene scene) {
    String currentTake;
    for (FbxElement c in e.children) {
      if (c.id == 'Current') {
        currentTake = c.properties[0];
      } else if(c.id == 'Take') {
        // TODO store multiple takes
        if (c.properties[0] != currentTake) {
          continue;
        }

        _loadTake(c, scene);
      }
    }
  }


  // Older FBX versions store animation in 'Takes'
  void _loadTake(FbxElement e, FbxScene scene) {
    for (FbxElement c in e.children) {
      if (c.id == 'Model') {
        String name = c.properties[0];

        FbxObject obj = scene.allObjects[name];
        if (obj == null) {
          print('Could not find object $name');
          continue;
        }

        for (FbxElement c2 in c.children) {
          if (c2.id == 'Channel') {
            _loadTakeChannel(c2, obj, scene);
          }
        }
      }
    }
  }


  void _loadTakeChannel(FbxElement c, FbxObject obj, FbxScene scene) {
    if (c.properties[0] == 'Transform') {
      for (FbxElement c2 in c.children) {
        if (c2.properties[0] == 'T') {
          FbxAnimCurveNode animNode = new FbxAnimCurveNode(0, 'T', null, scene);
          obj.connectToProperty('Lcl Translation', animNode);
          for (FbxElement c3 in c2.children) {
            if (c3.id == 'Channel' && c3.properties[0] == 'X') {
              FbxAnimCurve animCurve = new FbxAnimCurve(0, 'X', null, scene);
              animNode.connectToProperty('X', animCurve);
              _loadTakeCurve(c3, animCurve);
            } else if (c3.id == 'Channel' && c3.properties[0] == 'Y') {
              FbxAnimCurve animCurve = new FbxAnimCurve(0, 'Y', null, scene);
              animNode.connectToProperty('Y', animCurve);
              _loadTakeCurve(c3, animCurve);
            } else if (c3.id == 'Channel' && c3.properties[0] == 'Z') {
              FbxAnimCurve animCurve = new FbxAnimCurve(0, 'Z', null, scene);
              animNode.connectToProperty('Z', animCurve);
              _loadTakeCurve(c3, animCurve);
            }
          }
        } else if (c2.properties[0] == 'R') {
          FbxAnimCurveNode animNode = new FbxAnimCurveNode(0, 'R', null, scene);
          obj.connectToProperty('Lcl Rotation', animNode);
          for (FbxElement c3 in c2.children) {
            if (c3.id == 'Channel' && c3.properties[0] == 'X') {
              FbxAnimCurve animCurve = new FbxAnimCurve(0, 'X', null, scene);
              animNode.connectToProperty('X', animCurve);
              _loadTakeCurve(c3, animCurve);
            } else if (c3.id == 'Channel' && c3.properties[0] == 'Y') {
              FbxAnimCurve animCurve = new FbxAnimCurve(0, 'Y', null, scene);
              animNode.connectToProperty('Y', animCurve);
              _loadTakeCurve(c3, animCurve);
            } else if (c3.id == 'Channel' && c3.properties[0] == 'Z') {
              FbxAnimCurve animCurve = new FbxAnimCurve(0, 'Z', null, scene);
              animNode.connectToProperty('Z', animCurve);
              _loadTakeCurve(c3, animCurve);
            }
          }
        } else if (c2.properties[0] == 'S') {
          FbxAnimCurveNode animNode = new FbxAnimCurveNode(0, 'S', null, scene);
          obj.connectToProperty('Lcl Scaling', animNode);
          for (FbxElement c3 in c2.children) {
            if (c3.id == 'Channel' && c3.properties[0] == 'X') {
              FbxAnimCurve animCurve = new FbxAnimCurve(0, 'X', null, scene);
              animNode.connectToProperty('X', animCurve);
              _loadTakeCurve(c3, animCurve);
            } else if (c3.id == 'Channel' && c3.properties[0] == 'Y') {
              FbxAnimCurve animCurve = new FbxAnimCurve(0, 'Y', null, scene);
              animNode.connectToProperty('Y', animCurve);
              _loadTakeCurve(c3, animCurve);
            } else if (c3.id == 'Channel' && c3.properties[0] == 'Z') {
              FbxAnimCurve animCurve = new FbxAnimCurve(0, 'Z', null, scene);
              animNode.connectToProperty('Z', animCurve);
              _loadTakeCurve(c3, animCurve);
            }
          }
        }
      }
    } else if (c.properties[0] == 'Visibility') {
      FbxAnimCurveNode animNode = new FbxAnimCurveNode(0, 'Visibility', null,
                                                       scene);
      obj.connectToProperty('Visibility', animNode);

      FbxAnimCurve animCurve = new FbxAnimCurve(0, 'Visibility', null, scene);
      _loadTakeCurve(c, animCurve);
    }
  }


  void _loadTakeCurve(FbxElement e, FbxAnimCurve animCurve) {
    for (FbxElement c in e.children) {
      if (c.id == 'Default') {
        animCurve.defaultValue = c.getDouble(0);
      } else if (c.id == 'Key') {
        for (int pi = 0; pi < c.properties.length;) {
          int time = c.getInt(pi);
          double value = c.getDouble(pi + 1);

          animCurve.keys.add(new FbxAnimKey(time, value,
              FbxAnimKey.INTERPOLATION_LINEAR));

          String type = c.properties[pi + 2].toString();
          int keyType = FbxAnimKey.INTERPOLATION_LINEAR;

          if (type == 'C') {
            keyType = FbxAnimKey.INTERPOLATION_CONSTANT;
            pi += 4;
          } else if (type == 'L') {
            keyType = FbxAnimKey.INTERPOLATION_LINEAR;
            pi += 3;
          } else if (type == 'true') {
            keyType = FbxAnimKey.INTERPOLATION_CUBIC;
            pi += 5;
          } else {
            keyType = FbxAnimKey.INTERPOLATION_CUBIC;
            pi += 7;
          }

          animCurve.keys.add(new FbxAnimKey(time, value, keyType));
        }
      }
    }
  }


  /// Older versions of fbx connect deformers to the transform instead of
  /// the mesh.
  void _fixConnections(FbxScene scene) {
    for (FbxMesh mesh in scene.meshes) {
      if (mesh.connectedFrom.isEmpty) {
        continue;
      }
      for (FbxObject cf in mesh.connectedFrom) {
        if (cf is FbxNode) {
          for (FbxObject df in cf.connectedTo) {
            if (df is FbxDeformer) {
              if (!mesh.connectedTo.contains(df)) {
                mesh.connectTo(df);
              }
            }
          }
        }
      }
    }
  }


  void _loadConnections(FbxElement e, FbxScene scene) {
    final SCENE = _parser.sceneName();

    for (FbxElement c in e.children) {
      if (c.id == 'C' || c.id == 'Connect') {
        String type = c.properties[0];

        if (type == 'OO') {
          String src = c.properties[1].toString();
          String dst = c.properties[2].toString();

          FbxObject srcModel = scene.allObjects[src];
          if (srcModel == null) {
            print('COULD NOT FIND SRC NODE: $src');
            continue;
          }

          if (dst == '0' || dst == SCENE) {
            scene.rootNodes.add(srcModel);
          } else {
            FbxObject dstModel = scene.allObjects[dst];
            if (dstModel != null) {
              dstModel.connectTo(srcModel);
            } else {
              print('COULD NOT FIND NODE: $dst');
            }
          }
        } else if (type == 'OP') {
          String src = c.properties[1].toString();
          String dst = c.properties[2].toString();
          String attr = c.properties[3];

          FbxObject srcModel = scene.allObjects[src];
          if (srcModel == null) {
            print('COULD NOT FIND SRC NODE: $src');
            continue;
          }

          FbxObject dstModel = scene.allObjects[dst];
          if (dstModel == null) {
            print('COULD NOT FIND NODE: $dst');
          }

          attr = attr.split('|').last;

          dstModel.connectToProperty(attr, srcModel);
        }
      }
    }
  }


  void _loadObjects(FbxElement e, FbxScene scene) {
    for (FbxElement c in e.children) {
      if (c.id == 'Model') {
        int id;
        String rawName;
        String type;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1];
          type = c.properties[2];
        } else {
          id = 0;
          rawName = c.properties[0];
          type = c.properties[1];
        }

        String name = _parser.getName(rawName);

        FbxObject node;

        if (type == 'Camera') {
          FbxCamera camera = new FbxCamera(id, name, c, scene);
          node = camera;
          scene.allObjects[rawName] = camera;
          scene.allObjects[name] = camera;
          scene.cameras.add(camera);
        } else if (type == 'Light') {
          FbxLight light = new FbxLight(id, name, c, scene);
          node = light;
          scene.allObjects[rawName] = light;
          scene.allObjects[name] = light;
          scene.lights.add(light);
        } else if (type == 'Mesh') {
          // In older vesions of Fbx, the mesh shape was combined with the
          // meshNode, rather than being a separate NodeAttribute; so we'll
          // split the nodes in that case.
          if (id == 0) {
            FbxNode meshNode = new FbxNode(id, name, 'Transform', c, scene);
            scene.allObjects[rawName] = meshNode;
            scene.allObjects[name] = meshNode;

            FbxMesh mesh = new FbxMesh(id, c, scene);
            node = mesh;
            scene.meshes.add(mesh);
            meshNode.connectTo(mesh);
          } else {
            node = new FbxNode(id, name, 'Transform', c, scene);
            scene.allObjects[rawName] = node;
            scene.allObjects[name] = node;
          }
        } else if (type == 'Limb' || type == 'LimbNode') {
          FbxSkeleton limb = new FbxSkeleton(id, name, type, c, scene);
          node = limb;
          scene.allObjects[rawName] = limb;
          scene.allObjects[name] = limb;
          scene.skeletonNodes.add(limb);
        } else {
          var tk = name.split(':');
          if (tk.length > 1) {
            name = tk[1];

            node = new FbxNode(id, name, type, c, scene);
            scene.allObjects[rawName] = node;
            scene.allObjects[name] = node;

            node.reference = tk[0];
          } else {
            node = new FbxNode(id, name, type, c, scene);
            scene.allObjects[rawName] = node;
            scene.allObjects[name] = node;
          }
        }

        if (id != 0) {
          scene.allObjects[id.toString()] = node;
        }
      } else if (c.id == 'Geometry') {
        int id = c.getInt(0);
        String type = c.properties[2];

        if (type == 'Mesh' || type == 'Shape') {
          FbxMesh mesh = new FbxMesh(id, c, scene);

          if (id != 0) {
            scene.allObjects[id.toString()] = mesh;
          }
          scene.meshes.add(mesh);
        }
      } else if (c.id == 'Material') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1];
        } else {
          id = 0;
          rawName = c.properties[0];
        }

        String name = _parser.getName(rawName);

        FbxMaterial material = new FbxMaterial(id, name, c, scene);
        scene.allObjects[rawName] = material;
        scene.allObjects[name] = material;
        if (id != 0) {
          scene.allObjects[id.toString()] = material;
        }
        scene.materials.add(material);
      } else if (c.id == 'AnimationStack') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1];
        } else {
          id = 0;
          rawName = c.properties[0];
        }

        String name = _parser.getName(rawName);

        FbxAnimStack stack = new FbxAnimStack(id, name, c, scene);
        if (id != 0) {
          scene.allObjects[id.toString()] = stack;
        }
        scene.allObjects[rawName] = stack;
        scene.allObjects[name] = stack;
        scene.animationStack.add(stack);
      } else if (c.id == 'AnimationLayer') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1];
        } else {
          id = 0;
          rawName = c.properties[0];
        }

        String name = _parser.getName(rawName);

        FbxAnimLayer layer = new FbxAnimLayer(id, name, c, scene);
        if (id != 0) {
          scene.allObjects[id.toString()] = layer;
        }
        scene.allObjects[rawName] = layer;
        scene.allObjects[name] = layer;
      } else if (c.id == 'AnimationCurveNode') {
        int id;
        String rawName;
        String type;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1];
          type = c.properties[2];
        } else {
          id = 0;
          rawName = c.properties[0];
          type = c.properties[1];
        }

        String name = _parser.getName(rawName);

        FbxAnimCurveNode curve = new FbxAnimCurveNode(id, name, c, scene);
        if (id != 0) {
          scene.allObjects[id.toString()] = curve;
        }
        scene.allObjects[rawName] = curve;
        scene.allObjects[name] = curve;
      } else if (c.id == 'Deformer') {
        int id;
        String rawName;
        String type;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1];
          type = c.properties[2];
        } else {
          id = 0;
          rawName = c.properties[0];
          type = c.properties[1];
        }

        String name = _parser.getName(rawName);

        if (type == 'Skin') {
          FbxSkinDeformer skin = new FbxSkinDeformer(id, name, c, scene);
          scene.deformers.add(skin);
          scene.allObjects[rawName] = skin;
          scene.allObjects[name] = skin;
          if (id != 0) {
            scene.allObjects[id.toString()] = skin;
          }
        } else if (type == 'Cluster') {
          FbxCluster cluster = new FbxCluster(id, name, c, scene);
          scene.deformers.add(cluster);
          scene.allObjects[rawName] = cluster;
          scene.allObjects[name] = cluster;

          if (id != 0) {
            scene.allObjects[id.toString()] = cluster;
          }
        }
      } else if (c.id == 'Texture') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1];
        } else {
          id = 0;
          rawName = c.properties[0];
        }

        String name = _parser.getName(rawName);

        FbxTexture texture = new FbxTexture(id, name, c, scene);

        scene.textures.add(texture);
        scene.allObjects[rawName] = texture;
        scene.allObjects[name] = texture;
        if (id != 0) {
          scene.allObjects[id.toString()] = texture;
        }
      } else if (c.id == 'Folder') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1];
        } else {
          id = 0;
          rawName = c.properties[0];
        }

        String name = _parser.getName(rawName);

        FbxObject folder = new FbxObject(id, name, c.id, c, scene);
        scene.allObjects[rawName] = folder;
        scene.allObjects[name] = folder;
        if (id != 0) {
          scene.allObjects[id.toString()] = folder;
        }
      } else if (c.id == 'Constraint') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1];
        } else {
          id = 0;
          rawName = c.properties[0];
        }

        String name = _parser.getName(rawName);

        FbxObject constraint = new FbxObject(id, name, c.id, c, scene);
        scene.allObjects[rawName] = constraint;
        scene.allObjects[name] = constraint;
        if (id != 0) {
          scene.allObjects[id.toString()] = constraint;
        }
      } else if (c.id == 'AnimationCurve') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1];
        } else {
          id = 0;
          rawName = c.properties[0];
        }

        String name = _parser.getName(rawName);

        FbxAnimCurve animCurve = new FbxAnimCurve(id, name, c, scene);
        scene.allObjects[rawName] = animCurve;
        scene.allObjects[name] = animCurve;
        if (id != 0) {
          scene.allObjects[id.toString()] = animCurve;
        }
      } else if (c.id == 'NodeAttribute') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1];
        } else {
          id = 0;
          rawName = c.properties[0];
        }

        String name = _parser.getName(rawName);

        FbxNodeAttribute node = new FbxNodeAttribute(id, name, c.id, c, scene);
        scene.allObjects[rawName] = node;
        scene.allObjects[name] = node;
        if (id != 0) {
          scene.allObjects[id.toString()] = node;
        }
      } else if (c.id == 'GlobalSettings') {
        FbxGlobalSettings node = new FbxGlobalSettings(c, scene);
        scene.globalSettings = node;
      } else if (c.id == 'SceneInfo') {
        FbxObject node = new FbxObject(0, 'SceneInfo', c.id, c, scene);
        scene.sceneInfo = node;
      } else if (c.id == 'Pose') {
        FbxPose pose = new FbxPose(c.properties[0], c.properties[1], c, scene);
        scene.poses.add(pose);
      } else if (c.id == 'Video') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1];
        } else {
          id = 0;
          rawName = c.properties[0];
        }

        String name = _parser.getName(rawName);

        FbxVideo video = new FbxVideo(id, name, c.id, c, scene);

        scene.videos.add(video);
        scene.allObjects[rawName] = video;
        scene.allObjects[name] = video;
        if (id != 0) {
          scene.allObjects[id.toString()] = video;
        }
      } else {
        //print('UNKNOWN OBJECT ${c.id}');
      }
    }
  }


  void _loadHeaderExtension(FbxElement e, FbxScene data) {
    for (FbxElement c in e.children) {
      if (c.id == 'OtherFlags') {
        for (FbxElement c2 in c.children) {
          if (c2.properties.length == 1) {
            data.header[c2.id] = c2.properties[0];
          }
        }
      } else {
        if (c.properties.length == 1) {
          if (c.id == 'FBXVersion') {
            _fileVersion = c.getInt(0);
          }

          data.header[c.id] = c.properties[0];
        }
      }
    }
  }

  int _fileVersion = 0;
  FbxParser _parser;
}

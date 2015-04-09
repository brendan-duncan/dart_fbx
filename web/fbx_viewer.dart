library fbx_viewer;

import 'dart:html';
import 'dart:typed_data';
import 'dart:web_gl' as GL;
import 'package:fbx/fbx.dart';

part 'gl/gl_color_shader.dart';
part 'gl/gl_locator.dart';
part 'gl/gl_normal_shader.dart';
part 'gl/gl_object.dart';
part 'gl/gl_shader.dart';
part 'gl/gl_skinning_shader.dart';


class FbxViewer {
  GL.RenderingContext _gl;
  List<GlObject> _objects = [];
  int _viewportWidth;
  int _viewportHeight;

  FbxScene _scene;
  List<FbxNode> _meshNodes = [];
  List<FbxNode> _limbNodes = [];

  Matrix4 _pMatrix;
  Matrix4 _mvMatrix;
  GlShader _colorShader;
  GlShader _normalShader;
  GlShader _skinningShader;

  FbxViewer(CanvasElement canvas) {
    _viewportWidth = canvas.width;
    _viewportHeight = canvas.height;
    _gl = canvas.getContext('experimental-webgl');

    _normalShader = new GlNormalShader(_gl);
    _colorShader = new GlColorShader(_gl);
    _skinningShader = new GlSkinningShader(_gl);

    _gl.clearColor(0.3, 0.5, 0.7, 1.0);
    _gl.enable(GL.DEPTH_TEST);

    print('LOADING FBX');


    _pMatrix = makePerspectiveMatrix(radians(54.43),
        _viewportWidth / _viewportHeight, 0.1, 1000.0);

    /*String filename = 'data/cube_ascii_2014.fbx';
    _mvMatrix = makeViewMatrix(new Vector3(3.0, 3.0, -3.0),
                               new Vector3(0.0, 0.0, 0.0),
                               new Vector3(0.0, 1.0, 0.0));*/

    /*String filename = 'data/cube_anim2_ascii_2014.fbx';
    _mvMatrix = makeViewMatrix(new Vector3(3.0, 3.0, -3.0),
                               new Vector3(0.0, 0.0, 0.0),
                               new Vector3(0.0, 1.0, 0.0));*/

    /*String filename = 'data/cube_skin_ascii_2014.fbx';
    _mvMatrix = makeViewMatrix(new Vector3(0.0, 0.0, 3.0),
                               new Vector3(0.0, 0.0, 0.0),
                               new Vector3(0.0, 1.0, 0.0));*/

    /*String filename = 'data/cylinder_ascii_fbx2006.fbx';
    _mvMatrix = makeViewMatrix(new Vector3(0.0, 2.0, -10.0),
                               new Vector3(0.0, 2.0, 0.0),
                               new Vector3(0.0, 1.0, 0.0));*/

    /*String filename = 'data/cylinder_bin_fbx2014.fbx';
    _mvMatrix = makeViewMatrix(new Vector3(0.0, 2.0, -10.0),
                                   new Vector3(0.0, 2.0, 0.0),
                                   new Vector3(0.0, 1.0, 0.0));*/

    /*String filename = 'data/cylinder_ascii_fbx2014.fbx';
    _mvMatrix = makeViewMatrix(new Vector3(0.0, 2.0, -10.0),
                               new Vector3(0.0, 2.0, 0.0),
                               new Vector3(0.0, 1.0, 0.0));*/

    /*String filename = 'data/cylinder_skinned_ascii_fbx2006.fbx';
    _mvMatrix = makeViewMatrix(new Vector3(0.0, 0.0, -20.0),
                               new Vector3(0.0, 0.0, 0.0),
                               new Vector3(0.0, 1.0, 0.0));*/

    /*String filename = 'data/cylinder_skinned_ascii_fbx2014.fbx';
    _mvMatrix = makeViewMatrix(new Vector3(0.0, 0.0, -20.0),
                               new Vector3(0.0, 0.0, 0.0),
                               new Vector3(0.0, 1.0, 0.0));*/

    /*String filename = 'data/cylinder_skin_ascii_2014.fbx';
    _mvMatrix = makeViewMatrix(new Vector3(0.0, 0.0, -20.0),
                               new Vector3(0.0, 0.0, 0.0),
                               new Vector3(0.0, 1.0, 0.0));*/

    /*String filename = 'data/humanoid.fbx';
    _mvMatrix = makeViewMatrix(new Vector3(-30.0, 100.0, 400.0),
                               new Vector3(-30.0, 100.0, 0.0),
                               new Vector3(0.0, 1.0, 0.0));*/

    /*String filename = 'data/humanoid_ascii.fbx';
    _mvMatrix = makeViewMatrix(new Vector3(-30.0, 100.0, 400.0),
                               new Vector3(-30.0, 100.0, 0.0),
                               new Vector3(0.0, 1.0, 0.0));*/

    /*String filename = 'data/humanoid_2006_ascii.fbx';
    _mvMatrix = makeViewMatrix(new Vector3(-30.0, 100.0, 400.0),
                               new Vector3(-30.0, 100.0, 0.0),
                               new Vector3(0.0, 1.0, 0.0));*/

    /*String filename = 'data/knight.fbx';
    _mvMatrix = makeViewMatrix(new Vector3(20.0, 0.0, 20.0),
                                   new Vector3(0.0, 0.0, 0.0),
                                   new Vector3(0.0, 1.0, 0.0));*/


    String filename = 'data/knight_2014.fbx';
    _mvMatrix = makeViewMatrix(new Vector3(10.0, 0.0, 25.0),
                               new Vector3(0.0, 0.0, 0.0),
                               new Vector3(0.0, 1.0, 0.0));


    var req = new HttpRequest();
    req.open('GET', filename);
    req.responseType = 'arraybuffer';

    req.onError.listen((e) {
      print('ERROR Loading FBX: ${req.statusText}');
    });

    req.onLoadEnd.listen((e) {
      print('onLoadEnd ${req.status}');
      if (req.status == 200) {
        var loading = querySelectorAll('#loading')[0];
        if (loading != null) {
          loading.remove();
        }

        // Convert the text to binary byte list.
        List<int> bytes = new Uint8List.view(req.response);
        print('LOADED FBX');

        _scene = new FbxLoader().load(bytes);
        //_printScene(_scene);


        for (FbxMesh mesh in _scene.meshes) {
          FbxNode meshNode = mesh.getParentNode();
          if (meshNode == null) {
            continue;
          }

          mesh.generateDisplayMeshes();
          if (mesh.display.isEmpty) {
            continue;
          }

          GlObject object = new GlObject(_gl);
          _objects.add(object);

          object.setPoints(mesh.display[0].points, GL.DYNAMIC_DRAW);
          object.setNormals(mesh.display[0].normals, GL.DYNAMIC_DRAW);
          object.setVertices(mesh.display[0].vertices);
          object.setSkinning(mesh.display[0].skinWeights,
                             mesh.display[0].skinIndices);

          object.transform = meshNode.evalGlobalTransform();
          _meshNodes.add(meshNode);
        }
      }
    });

    req.send('');
  }


  void _printNode(FbxNode node, [indent = 0]) {
    String space = '';
    for (int i = 0; i < indent; ++i) {
      space += '    ';
    }

    String s = '${space}${node.type} ${node.name} <${node.parent}>';
    if (node.children.isNotEmpty) {
      s += ' :';
      for (var c in node.children) {
        s += ' "${c.name}"';
      }
    }

    print(s);
    for (var na in node.connectedTo) {
      print('${space}  @${na.type} ${na.name}');
    }

    for (var c in node.children) {
      _printNode(c, indent + 1);
    }
  }

  void _printScene(FbxScene scene) {
    for (var n in scene.rootNodes) {
      if (n is FbxNode) {
        _printNode(n);
      }
    }
  }


  void render([double time=0.0]) {
    window.requestAnimationFrame(render);

    _gl.viewport(0, 0, _viewportWidth, _viewportHeight);
    _gl.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
    _gl.enable(GL.BLEND);
    _gl.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
    _gl.enable(GL.CULL_FACE);

    if (_scene != null) {
      //_scene.currentFrame += 0.5;
      _scene.currentFrame += 0.3;
      if (_scene.currentFrame > _scene.endFrame) {
        _scene.currentFrame = _scene.startFrame;
      }
    }

    _skinningShader.bind();
    _skinningShader.setMatrixUniforms(_mvMatrix, _pMatrix);

    FbxPose pose = _scene != null ? _scene.getPose(0) : null;

    for (int i = 0, len = _objects.length; i < len; ++i) {
      GlObject obj = _objects[i];
      FbxNode meshNode = _meshNodes[i];
      FbxMesh mesh = meshNode.findConnectionsByType('Mesh').first;

      obj.skinPalette = mesh.computeSkinPalette(obj.skinPalette);

      obj.setPoints(mesh.display[0].points, GL.DYNAMIC_DRAW);

      obj.transform = meshNode.evalGlobalTransform();

      _skinningShader.bindGeometry(obj);
      _skinningShader.draw(GL.TRIANGLES);
    }

    _skinningShader.unbind();
  }
}


void main() {
  FbxViewer viewer = new FbxViewer(document.querySelector('#fbxviewer'));
  viewer.render();
}

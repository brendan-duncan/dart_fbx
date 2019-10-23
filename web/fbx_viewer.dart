library fbx_viewer;

import 'dart:html';
import 'dart:typed_data';
import 'dart:web_gl';
import 'package:fbx/fbx.dart';
import 'package:vector_math/vector_math.dart';

part 'gl/gl_color_shader.dart';
part 'gl/gl_locator.dart';
part 'gl/gl_normal_shader.dart';
part 'gl/gl_object.dart';
part 'gl/gl_shader.dart';
part 'gl/gl_skinning_shader.dart';
part 'gl/gl_texture.dart';

/// An example program demonstrating decoding an Fbx file, displaying it WebGL
/// with GPU skinning and textures.
class FbxViewer {
  RenderingContext _gl;
  List<GlObject> _objects = [];
  int _viewportWidth;
  int _viewportHeight;

  FbxScene _scene;

  Matrix4 _pMatrix;
  Matrix4 _mvMatrix;
  GlShader _colorShader;
  GlShader _normalShader;
  GlSkinningShader _skinningShader;
  GlTexture _texture;

  FbxViewer(CanvasElement canvas) {
    _viewportWidth = canvas.width;
    _viewportHeight = canvas.height;
    _gl = canvas.getContext('experimental-webgl');

    _normalShader = GlNormalShader(_gl);
    _colorShader = GlColorShader(_gl);
    _skinningShader = GlSkinningShader(_gl);

    _gl.clearColor(0.3, 0.5, 0.7, 1.0);
    _gl.enable(WebGL.DEPTH_TEST);

    print('LOADING FBX');

    _pMatrix = makePerspectiveMatrix(radians(54.43),
        _viewportWidth / _viewportHeight, 0.1, 1000.0);

    String filename = 'data/knight_2014.fbx';
    //String filename = 'data/cube_anim_ascii_2014.fbx';
    _mvMatrix = makeViewMatrix(Vector3(10.0, 0.0, 25.0),
                               Vector3(0.0, 0.0, 0.0),
                               Vector3(0.0, 1.0, 0.0));

    var req = HttpRequest();
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
        List<int> bytes = Uint8List.view(req.response);
        print('LOADED FBX: ${bytes.length} bytes');

        _scene = FbxLoader().load(bytes);
        //_printScene(_scene);

        print('LOAD FINISHED');
        for (FbxMesh mesh in _scene.meshes) {
          FbxNode meshNode = mesh.getParentNode();
          if (meshNode == null) {
            continue;
          }

          mesh.generateDisplayMeshes();
          if (mesh.display.isEmpty) {
            continue;
          }

          GlObject object = GlObject(_gl, meshNode, mesh);
          _objects.add(object);

          object.setPoints(mesh.display[0].points, WebGL.DYNAMIC_DRAW);
          object.setNormals(mesh.display[0].normals, WebGL.DYNAMIC_DRAW);
          object.setVertices(mesh.display[0].vertices);
          object.setUvs(mesh.display[0].uvs);
          object.setSkinning(mesh.display[0].skinWeights,
                             mesh.display[0].skinIndices);

          object.transform = meshNode.evalGlobalTransform();

          // TODO this is just a placeholder for testing. Need to implement a
          // decent material/texture system.
          FbxMaterial material = meshNode.findConnectionsByType('Material').first;
          if (material != null) {
            if (material.diffuseColor.connectedFrom is FbxTexture) {
              FbxTexture txt = material.diffuseColor.connectedFrom;
              _texture = GlTexture(_gl, 'data/' + txt.filename);
            }
          }
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

  void render([num time=0]) {
    window.requestAnimationFrame(render);

    _gl.viewport(0, 0, _viewportWidth, _viewportHeight);
    _gl.clear(WebGL.COLOR_BUFFER_BIT | WebGL.DEPTH_BUFFER_BIT);
    _gl.enable(WebGL.BLEND);
    _gl.blendFunc(WebGL.SRC_ALPHA, WebGL.ONE_MINUS_SRC_ALPHA);
    _gl.enable(WebGL.CULL_FACE);

    if (_scene != null) {
      _scene.currentFrame += 0.4;
      if (_scene.currentFrame > _scene.endFrame) {
        _scene.currentFrame = _scene.startFrame;
      }
    }

    for (int i = 0, len = _objects.length; i < len; ++i) {
      GlObject obj = _objects[i];

      obj.update();

      _skinningShader.bind();
      _skinningShader.setMatrixUniforms(_mvMatrix, _pMatrix);
      _skinningShader.setTexture(_texture);
      _skinningShader.bindGeometry(obj);
      _skinningShader.draw(WebGL.TRIANGLES);
      _skinningShader.unbind();
    }
  }
}

void main() {
  FbxViewer viewer = FbxViewer(document.querySelector('#fbxviewer'));
  viewer.render();
}

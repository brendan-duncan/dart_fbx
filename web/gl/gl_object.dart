part of fbx_viewer;

class GlObject {
  FbxNode node;
  FbxMesh mesh;

  RenderingContext _gl;
  Buffer positionBuffer;
  Buffer normalBuffer;
  Buffer uvBuffer;
  Buffer indexBuffer;
  int indexCount;
  Matrix4 transform;
  Buffer skinWeights;
  Buffer skinIndices;
  Float32List skinPalette;

  GlObject(this._gl, this.node, this.mesh);

  void update() {
    if (node != null) {
      transform = node.evalGlobalTransform();
      skinPalette = mesh.computeSkinPalette(skinPalette);
      setPoints(mesh.display[0].points, WebGL.DYNAMIC_DRAW);
    }
  }

  void setPoints(Float32List points, [int mode = WebGL.STATIC_DRAW]) {
    if (positionBuffer == null) {
      positionBuffer = _gl.createBuffer();
    }

    _gl.bindBuffer(WebGL.ARRAY_BUFFER, positionBuffer);
    _gl.bufferData(WebGL.ARRAY_BUFFER, points, mode);
  }

  void setNormals(Float32List normals, [int mode = WebGL.STATIC_DRAW]) {
    if (normalBuffer == null) {
      normalBuffer = _gl.createBuffer();
    }

    _gl.bindBuffer(WebGL.ARRAY_BUFFER, normalBuffer);
    _gl.bufferData(WebGL.ARRAY_BUFFER, normals, mode);
  }

  void setUvs(Float32List uvs, [int mode = WebGL.STATIC_DRAW]) {
    if (uvs == null) {
      return;
    }

    if (uvBuffer == null) {
      uvBuffer = _gl.createBuffer();
    }

    _gl.bindBuffer(WebGL.ARRAY_BUFFER, uvBuffer);
    _gl.bufferData(WebGL.ARRAY_BUFFER, uvs, mode);
  }

  void setVertices(Uint16List vertices, [int mode = WebGL.STATIC_DRAW]) {
    if (indexBuffer == null) {
      indexBuffer = _gl.createBuffer();
    }

    _gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, indexBuffer);
    _gl.bufferData(WebGL.ELEMENT_ARRAY_BUFFER, vertices, mode);

    indexCount = vertices.length;
  }

  void setSkinning(Float32List weights, Float32List indices) {
    if (skinWeights == null) {
      skinWeights = _gl.createBuffer();
      skinIndices = _gl.createBuffer();
    }

    _gl.bindBuffer(WebGL.ARRAY_BUFFER, skinWeights);
    _gl.bufferData(WebGL.ARRAY_BUFFER, weights, WebGL.STATIC_DRAW);

    _gl.bindBuffer(WebGL.ARRAY_BUFFER, skinIndices);
    _gl.bufferData(WebGL.ARRAY_BUFFER, indices, WebGL.STATIC_DRAW);
  }
}

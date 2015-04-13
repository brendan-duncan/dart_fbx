part of fbx_viewer;

class GlObject {
  FbxNode node;
  FbxMesh mesh;

  GL.RenderingContext _gl;
  GL.Buffer positionBuffer;
  GL.Buffer normalBuffer;
  GL.Buffer uvBuffer;
  GL.Buffer indexBuffer;
  int indexCount;
  Matrix4 transform;
  GL.Buffer skinWeights;
  GL.Buffer skinIndices;
  Float32List skinPalette;

  GlObject(this._gl, this.node, this.mesh);


  void update() {
    if (node != null) {
      transform = node.evalGlobalTransform();
      skinPalette = mesh.computeSkinPalette(skinPalette);
      setPoints(mesh.display[0].points, GL.DYNAMIC_DRAW);
    }
  }


  void setPoints(Float32List points, [int mode = GL.STATIC_DRAW]) {
    if (positionBuffer == null) {
      positionBuffer = _gl.createBuffer();
    }

    _gl.bindBuffer(GL.ARRAY_BUFFER, positionBuffer);
    _gl.bufferData(GL.ARRAY_BUFFER, points, mode);
  }


  void setNormals(Float32List normals, [int mode = GL.STATIC_DRAW]) {
    if (normalBuffer == null) {
      normalBuffer = _gl.createBuffer();
    }

    _gl.bindBuffer(GL.ARRAY_BUFFER, normalBuffer);
    _gl.bufferData(GL.ARRAY_BUFFER, normals, mode);
  }


  void setUvs(Float32List uvs, [int mode = GL.STATIC_DRAW]) {
    if (uvs == null) {
      return;
    }

    if (uvBuffer == null) {
      uvBuffer = _gl.createBuffer();
    }

    _gl.bindBuffer(GL.ARRAY_BUFFER, uvBuffer);
    _gl.bufferData(GL.ARRAY_BUFFER, uvs, mode);
  }


  void setVertices(Uint16List vertices, [int mode = GL.STATIC_DRAW]) {
    if (indexBuffer == null) {
      indexBuffer = _gl.createBuffer();
    }

    _gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
    _gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, vertices, mode);

    indexCount = vertices.length;
  }


  void setSkinning(Float32List weights, Float32List indices) {
    if (skinWeights == null) {
      skinWeights = _gl.createBuffer();
      skinIndices = _gl.createBuffer();
    }

    _gl.bindBuffer(GL.ARRAY_BUFFER, skinWeights);
    _gl.bufferData(GL.ARRAY_BUFFER, weights, GL.STATIC_DRAW);

    _gl.bindBuffer(GL.ARRAY_BUFFER, skinIndices);
    _gl.bufferData(GL.ARRAY_BUFFER, indices, GL.STATIC_DRAW);
  }
}

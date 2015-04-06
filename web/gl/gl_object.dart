part of fbx_viewer;

class GlObject {
  GL.RenderingContext _gl;
  GL.Buffer positionBuffer;
  GL.Buffer normalBuffer;
  GL.Buffer uvBuffer;
  GL.Buffer indexBuffer;
  int indexCount;
  Matrix4 transform;

  GlObject(this._gl);

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


  void setVertices(Uint16List vertices, [int mode = GL.STATIC_DRAW]) {
    if (indexBuffer == null) {
      indexBuffer = _gl.createBuffer();
    }

    _gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
    _gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, vertices, mode);

    indexCount = vertices.length;
  }
}

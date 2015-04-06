part of fbx_viewer;

class GlShader {
  GlShader(this._gl, String vsSource, String fsSource) {
    // vertex shader compilation
    GL.Shader vs = _gl.createShader(GL.RenderingContext.VERTEX_SHADER);
    _gl.shaderSource(vs, vsSource);
    _gl.compileShader(vs);

    // fragment shader compilation
    GL.Shader fs = _gl.createShader(GL.RenderingContext.FRAGMENT_SHADER);
    _gl.shaderSource(fs, fsSource);
    _gl.compileShader(fs);

    // attach shaders to a WebGL program
    _shaderProgram = _gl.createProgram();
    _gl.attachShader(_shaderProgram, vs);
    _gl.attachShader(_shaderProgram, fs);
    _gl.linkProgram(_shaderProgram);
    _gl.useProgram(_shaderProgram);

    if (!_gl.getShaderParameter(vs, GL.RenderingContext.COMPILE_STATUS)) {
      print(_gl.getShaderInfoLog(vs));
    }

    if (!_gl.getShaderParameter(fs, GL.RenderingContext.COMPILE_STATUS)) {
      print(_gl.getShaderInfoLog(fs));
    }

    if (!_gl.getProgramParameter(_shaderProgram, GL.RenderingContext.LINK_STATUS)) {
      print(_gl.getProgramInfoLog(_shaderProgram));
    }

    _aVertexPosition = _gl.getAttribLocation(_shaderProgram, 'aVertexPosition');
    _aVertexNormal = _gl.getAttribLocation(_shaderProgram, 'aVertexNormal');

    _uPMatrix = _gl.getUniformLocation(_shaderProgram, 'uPMatrix');
    _uMVMatrix = _gl.getUniformLocation(_shaderProgram, 'uMVMatrix');
  }


  void bind() {
    _gl.useProgram(_shaderProgram);

    if (_aVertexPosition >= 0) {
      _gl.enableVertexAttribArray(_aVertexPosition);
    }
    if (_aVertexNormal >= 0) {
      _gl.enableVertexAttribArray(_aVertexNormal);
    }
  }


  void unbind() {
    if (_aVertexPosition >= 0) {
      _gl.disableVertexAttribArray(_aVertexPosition);
    }
    if (_aVertexNormal >= 0) {
      _gl.disableVertexAttribArray(_aVertexNormal);
    }
  }


  void setMatrixUniforms(Matrix4 mvMatrix, Matrix4 pMatrix) {
    _mvMatrix = new Matrix4.copy(mvMatrix);
    _gl.uniformMatrix4fv(_uPMatrix, false, pMatrix.storage);
  }


  void setUniformInt(String name, int x) {
    var p = _uniforms[name];
    if (p == null) {
      p = _gl.getUniformLocation(_shaderProgram, name);
      if (p == null) {
        return;
      }
      _uniforms[name] = p;
    }
    _gl.uniform1i(p, x);
  }


  void setUniformFloat(String name, double x) {
    var p = _uniforms[name];
    if (p == null) {
      p = _gl.getUniformLocation(_shaderProgram, name);
      if (p == null) {
        return;
      }
      _uniforms[name] = p;
    }
    _gl.uniform1f(p, x);
  }


  void setUniformVec2(String name, double x, double y) {
    var p = _uniforms[name];
    if (p == null) {
      p = _gl.getUniformLocation(_shaderProgram, name);
      if (p == null) {
        return;
      }
      _uniforms[name] = p;
    }
    _gl.uniform2f(p, x, y);
  }


  void setUniformVec3(String name, double x, double y, double z) {
    var p = _uniforms[name];
    if (p == null) {
      p = _gl.getUniformLocation(_shaderProgram, name);
      if (p == null) {
        return;
      }
      _uniforms[name] = p;
    }
    _gl.uniform3f(p, x, y, z);
  }


  void setUniformVec4(String name, double x, double y, double z, double w) {
    var p = _uniforms[name];
    if (p == null) {
      p = _gl.getUniformLocation(_shaderProgram, name);
      if (p == null) {
        return;
      }
      _uniforms[name] = p;
    }
    _gl.uniform4f(p, x, y, z, w);
  }

  void setUniformMatrix(String name, Matrix4 m) {
    var p = _uniforms[name];
    if (p == null) {
      p = _gl.getUniformLocation(_shaderProgram, name);
      if (p == null) {
        return;
      }
      _uniforms[name] = p;
    }
    _gl.uniformMatrix4fv(p, false, m.storage);
  }


  void bindGeometry(GlObject obj) {
    if (obj.transform != null) {
      Matrix4 mvMatrix = _mvMatrix * obj.transform;
      _gl.uniformMatrix4fv(_uMVMatrix, false, mvMatrix.storage);
    } else {
      _gl.uniformMatrix4fv(_uMVMatrix, false, _mvMatrix.storage);
    }

    _gl.bindBuffer(GL.ARRAY_BUFFER, obj.positionBuffer);
    _gl.vertexAttribPointer(_aVertexPosition, 3,
        GL.RenderingContext.FLOAT, false, 0, 0);

    if (_aVertexNormal != -1) {
      _gl.bindBuffer(GL.ARRAY_BUFFER, obj.normalBuffer);
      _gl.vertexAttribPointer(_aVertexNormal, 3,
          GL.RenderingContext.FLOAT, false, 0, 0);
    }

    if (obj.indexBuffer != null) {
      _gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, obj.indexBuffer);
      _count = obj.indexCount;
      _drawElements = true;
    } else {
      _drawElements = false;
    }
  }


  void draw([int type=GL.TRIANGLES, int start=0, int end]) {
    if (_drawElements) {
      _gl.drawElements(type, _count, GL.UNSIGNED_SHORT, 0);
    } else {
      _gl.drawArrays(type, start, end);
    }
  }

  GL.RenderingContext _gl;
  GL.Program _shaderProgram;
  int _aVertexPosition;
  int _aVertexNormal;
  GL.UniformLocation _uPMatrix;
  GL.UniformLocation _uMVMatrix;
  Map<String, GL.UniformLocation> _uniforms = {};
  bool _drawElements = false;
  int _count = 0;
  Matrix4 _mvMatrix;
}

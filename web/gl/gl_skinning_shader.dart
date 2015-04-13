part of fbx_viewer;

class GlSkinningShader extends GlShader {
  static const int MAX_BONES = 60;

  static const String vertexSource = """
    precision highp float;
    attribute vec3 aVertexPosition;
    attribute vec3 aVertexNormal;
    attribute vec2 aVertexUv;
    attribute vec4 skinIndices;
    attribute vec4 skinWeights;

    varying vec3 vNormal;
    varying vec2 uv;

    uniform mat4 uMVMatrix;
    uniform mat4 uPMatrix;
    uniform mat4 joints[$MAX_BONES];

    void main(void) {
      vec4 p = vec4(aVertexPosition, 1.0);
      vec4 n = vec4(aVertexNormal, 0.0);

      vec4 sp = vec4(0.0, 0.0, 0.0, 0.0);
      vec4 sn = vec4(0.0, 0.0, 0.0, 0.0);
      int index = 0;

      index = int(skinIndices.x);
      sp = (joints[index] * p) * skinWeights.x;
      sn = (joints[index] * n) * skinWeights.x;

      index = int(skinIndices.y);
      sp += (joints[index] * p) * skinWeights.y;
      sn += (joints[index] * n) * skinWeights.y;
    
      index = int(skinIndices.z);
      sp += (joints[index] * p) * skinWeights.z;
      sn += (joints[index] * n) * skinWeights.z;

      index = int(skinIndices.w);
      sp += (joints[index] * p) * skinWeights.w;
      sn += (joints[index] * n) * skinWeights.w;

      vNormal = normalize(uMVMatrix * vec4(sn.xyz, 0.0)).xyz;

      vec4 vPosition = (uMVMatrix * vec4(sp.xyz, 1.0));

      gl_Position = uPMatrix * vec4(vPosition.xyz, 1.0);

      uv = aVertexUv;
    }
    """;

  static const String fragmentSource = """
    precision highp float;
    varying vec3 vNormal;
    varying vec2 uv;
    uniform bool hasTexture;
    uniform sampler2D texture;
    void main(void) {
      if (hasTexture) {
        gl_FragColor = texture2D(texture, uv);
      } else {
        gl_FragColor = vec4(mix(abs(vNormal), vec3(0.6, 0.7, 0.4), 0.5), 1.0);
      }
    }
    """;


  GlSkinningShader(GL.RenderingContext gl)
    : super(gl, vertexSource, fragmentSource) {
    _uJoints = _gl.getUniformLocation(_shaderProgram, 'joints');
    _uHasTexture = _gl.getUniformLocation(_shaderProgram, 'hasTexture');
    _uTexture = _gl.getUniformLocation(_shaderProgram, 'texture');
    _skinIndices = _gl.getAttribLocation(_shaderProgram, 'skinIndices');
    _skinWeights = _gl.getAttribLocation(_shaderProgram, 'skinWeights');
    _aVertexUv = _gl.getAttribLocation(_shaderProgram, 'aVertexUv');
  }

  void setTexture(GlTexture texture) {
    if (texture == null) {
      _gl.uniform1i(_uHasTexture, 0);
      _gl.uniform1i(_uTexture, 0);
    } else {
      _gl.uniform1i(_uHasTexture, 1);
      _gl.uniform1i(_uTexture, 0);
      texture.bind(0);
    }
  }

  void bindGeometry(GlObject obj) {
    super.bindGeometry(obj);

    _gl.uniformMatrix4fv(_uJoints, false, obj.skinPalette);

    if (_aVertexUv != -1 && obj.uvBuffer != null) {
      _gl.enableVertexAttribArray(_aVertexUv);
      _gl.bindBuffer(GL.ARRAY_BUFFER, obj.uvBuffer);
      _gl.vertexAttribPointer(_aVertexUv, 2,
          GL.RenderingContext.FLOAT, false, 0, 0);
    }

    if (_skinIndices != -1) {
      _gl.enableVertexAttribArray(_skinIndices);
      _gl.bindBuffer(GL.ARRAY_BUFFER, obj.skinIndices);
      _gl.vertexAttribPointer(_skinIndices, 4,
          GL.RenderingContext.FLOAT, false, 0, 0);
    }

    if (_skinWeights != -1) {
      _gl.enableVertexAttribArray(_skinWeights);
      _gl.bindBuffer(GL.ARRAY_BUFFER, obj.skinWeights);
      _gl.vertexAttribPointer(_skinWeights, 4,
          GL.RenderingContext.FLOAT, false, 0, 0);
    }
  }

  GL.UniformLocation _uJoints;
  GL.UniformLocation _uHasTexture;
  GL.UniformLocation _uTexture;
  int _aVertexUv;
  int _skinIndices;
  int _skinWeights;
}

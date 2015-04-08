part of fbx_viewer;

class GlSkinningShader extends GlShader {
  static const int MAX_BONES = 50;

  static const String vertexSource = """
    precision highp float;
    attribute vec3 aVertexPosition;
    attribute vec3 aVertexNormal;
    attribute vec4 skinIndices;
    attribute vec4 skinWeights;

    varying vec3 vNormal;

    uniform mat4 uMVMatrix;
    uniform mat4 uPMatrix;
    uniform mat4 joints[$MAX_BONES];

    void main(void) {
      vec4 p = vec4(aVertexPosition, 1.0);
      vec4 n = vec4(aVertexNormal, 0.0);

      vec4 sp = vec4(0.0, 0.0, 0.0, 0.0);
      vec4 sn = vec4(0.0, 0.0, 0.0, 0.0);
      int index;
    
      index = int(skinIndices.x);
      if (index >= 0) { 
        sp = (joints[index] * p) * skinWeights.x;
        sn = (joints[index] * n) * skinWeights.x;
      }

      index = int(skinIndices.y);
      if (index >= 0) {        
        sp = (joints[index] * p) * skinWeights.y + sp;
        sn = (joints[index] * n) * skinWeights.y + sn;
      }

      index = int(skinIndices.z);
      if (index >= 0) {        
        sp = (joints[index] * p) * skinWeights.z + sp;
        sn = (joints[index] * n) * skinWeights.z + sn;
      }

      index = int(skinIndices.w);
      if (index >= 0) {        
        sp = (joints[index] * p) * skinWeights.w + sp;
        sn = (joints[index] * n) * skinWeights.w + sn;
      }

      vNormal = normalize(uMVMatrix * vec4(sn.xyz, 0.0)).xyz;
 
      vec4 vPosition = (uMVMatrix * vec4(sp.xyz, 1.0));
      gl_Position = uPMatrix * vec4(vPosition.xyz, 1.0);
    }
    """;

  static const String fragmentSource = """
    precision highp float;
    varying vec3 vNormal;
    void main(void) {
      gl_FragColor = vec4(mix(abs(vNormal), vec3(0.3, 0.7, 0.7), 0.7), 1.0);
    }
    """;


  GlSkinningShader(GL.RenderingContext gl)
    : super(gl, vertexSource, fragmentSource) {
    _uJoints = _gl.getUniformLocation(_shaderProgram, 'joints');
    _skinIndices = _gl.getAttribLocation(_shaderProgram, 'skinIndices');
    _skinWeights = _gl.getAttribLocation(_shaderProgram, 'skinWeights');
  }


  void bindGeometry(GlObject obj) {
    super.bindGeometry(obj);

    _gl.uniformMatrix4fv(_uJoints, false, obj.skinPalette);

    _gl.bindBuffer(GL.ARRAY_BUFFER, obj.skinIndices);
    _gl.vertexAttribPointer(_skinIndices, 4,
        GL.RenderingContext.FLOAT, false, 0, 0);

    _gl.bindBuffer(GL.ARRAY_BUFFER, obj.skinWeights);
    _gl.vertexAttribPointer(_skinWeights, 4,
        GL.RenderingContext.FLOAT, false, 0, 0);
  }

  GL.UniformLocation _uJoints;
  int _skinIndices;
  int _skinWeights;
}

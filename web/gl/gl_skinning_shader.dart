part of fbx_viewer;

class GlSkinningShader extends GlShader {
  static const int MAX_BONES = 50;

  static const String vertexSource = """
    attribute vec3 aVertexPosition;
    attribute vec3 aVertexNormal;
    attribute vec4 blendIndices;
    attribute vec4 blendWeights;
    varying vec3 vNormal;

    uniform mat4 uMVMatrix;
    uniform mat4 uPMatrix;
    uniform mat4 joints[$MAX_BONES];

    void main(void) {
      vec4 sp;
      vec3 sn;
    
      int index = int(blendIndices.x);
      sp = (joints[index] * aVertexPosition) * blendWeights.x;
      sn = (joints[index] * vec4(aVertexNormal, 0.0)) * blendWeights.x;

      index = int(blendIndices.y);        
      sp = (joints[index] * aVertexPosition) * blendWeights.y + sp;
      sn = (joints[index] * vec4(aVertexNormal, 0.0)) * blendWeights.y  + sn;

      index = int(blendIndices.z);        
      sp = (joints[index] * aVertexPosition) * blendWeights.z + sp;
      sn = (joints[index] * vec4(aVertexNormal, 0.0)) * blendWeights.z  + sn;

      index = int(blendIndices.w);        
      sp = (joints[index] * aVertexPosition) * blendWeights.w  + sp;
      sn = (joints[index] * vec4(aVertexNormal, 0.0)) * blendWeights.w  + sn;

      vNormal = normalize(uMVMatrix * vec4(sn, 0.0)).xyz;
 
      vec4 vPosition = (uMVMatrix * vec4(sp.xyz, 1.0)).xyz;
      gl_Position = uPMatrix * vec4(vPosition.xyz, 1.0);
    }
    """;

  static const String fragmentSource = """
    precision mediump float;
    varying vec3 vNormal;
    void main(void) {
      gl_FragColor = vec4(abs(vNormal), 0.5);
    }
    """;

  GlSkinningShader(GL.RenderingContext gl)
    : super(gl, vertexSource, fragmentSource) {
    _uJoints = _gl.getUniformLocation(_shaderProgram, 'joints');
    _bindIndices = _gl.getAttribLocation(_shaderProgram, 'bindIndices');
    _bindWeights = _gl.getAttribLocation(_shaderProgram, 'bindWeights');
  }


  void bindSkinning(Float32List joints, GL.Buffer bindIndices,
                    GL.Buffer bindWeights) {
    _gl.uniformMatrix4fv(_uJoints, false, joints);

    _gl.bindBuffer(GL.ARRAY_BUFFER, bindIndices);
    _gl.vertexAttribPointer(_bindIndices, 3,
        GL.RenderingContext.FLOAT, false, 0, 0);

    _gl.bindBuffer(GL.ARRAY_BUFFER, bindWeights);
    _gl.vertexAttribPointer(_bindWeights, 3,
        GL.RenderingContext.FLOAT, false, 0, 0);
  }

  GL.UniformLocation _uJoints;
  int _bindIndices;
  int _bindWeights;
}

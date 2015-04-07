part of fbx_viewer;

class GlSkinningShader extends GlShader {
  static const int MAX_BONES = 62;

  static const String vertexSource = """
    attribute vec3 aVertexPosition;
    attribute vec3 aVertexNormal;
    attribute vec4 blendIndices;
    attribute vec4 blendWeights;
    varying vec3 vNormal;
    varying vec3 vPosition;

    uniform mat4 uMVMatrix;
    uniform mat4 uPMatrix;
    uniform mat4 bones[$MAX_BONES];

    void main(void) {
      vec4 newVertex;
      vec3 newNormal;
    
      int index = int(blendIndices.x);
      newVertex = (bones[index] * aVertexPosition) * blendWeights.x;
      newNormal = (bones[index] * vec4(aVertexNormal, 0.0)) * blendWeights.x;

      index = int(blendIndices.y);        
      newVertex = (bones[index] * aVertexPosition) * blendWeights.y + newVertex;
      newNormal = (bones[index] * vec4(aVertexNormal, 0.0)) * blendWeights.y  + newNormal;

      index = int(blendIndices.z);        
      newVertex = (bones[index] * aVertexPosition) * blendWeights.z  + newVertex;
      newNormal = (bones[index] * vec4(aVertexNormal, 0.0)) * blendWeights.z  + newNormal;

      index = int(blendIndices.w);        
      newVertex = (bones[index] * aVertexPosition) * blendWeights.w   + newVertex;
      newNormal = (bones[index] * vec4(aVertexNormal, 0.0)) * blendWeights.w  + newNormal;

      vNormal = normalize(uMVMatrix * vec4(newNormal, 0.0)).xyz; 
      vPosition = (uMVMatrix * vec4(newVertex.xyz, 1.0)).xyz;
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
    : super(gl, vertexSource, fragmentSource);
}

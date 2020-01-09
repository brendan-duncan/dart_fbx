part of fbx_viewer;

class GlNormalShader extends GlShader {
  static const String vertexSource = '''
    attribute vec3 aVertexPosition;
    attribute vec3 aVertexNormal;
    uniform mat4 uMVMatrix;
    uniform mat4 uPMatrix;
    varying vec3 vNormal;
    void main(void) {
        gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
        vNormal = normalize(aVertexNormal);
    }
    ''';

  static const String fragmentSource = '''
    precision mediump float;
    varying vec3 vNormal;
    void main(void) {
        gl_FragColor = vec4(abs(vNormal), 0.5);
    }
    ''';

  GlNormalShader(RenderingContext gl)
    : super(gl, vertexSource, fragmentSource);
}

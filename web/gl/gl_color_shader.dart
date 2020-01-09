part of fbx_viewer;

class GlColorShader extends GlShader {
  static const String vertexSource = '''
    attribute vec3 aVertexPosition;
    uniform mat4 uMVMatrix;
    uniform mat4 uPMatrix;
    void main(void) {
        gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
    }
    ''';

  static const String fragmentSource = '''
    precision mediump float;
    uniform vec4 color;
    void main(void) {
        gl_FragColor = color;
    }
    ''';

  GlColorShader(RenderingContext gl)
    : super(gl, vertexSource, fragmentSource) {
    _uColor = _gl.getUniformLocation(_shaderProgram, 'color');
  }

  void setColor(double r, double g, double b, double a) {
    _gl.uniform4f(_uColor, r, g, b, a);
  }

  UniformLocation _uColor;
}

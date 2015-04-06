part of fbx_viewer;

class GlLocator {
  GL.RenderingContext _gl;
  GlObject _glObject;
  GlColorShader _colorShader;
  Matrix4 transform = new Matrix4.identity();

  GlLocator(this._gl, this._colorShader) {
    Float32List points = new Float32List.fromList([0.0, 0.0, 0.0,
                                                   1.0, 0.0, 0.0,
                                                   0.0, 0.0, 0.0,
                                                   0.0, 1.0, 0.0,
                                                   0.0, 0.0, 0.0,
                                                   0.0, 0.0, 1.0]);

    _glObject = new GlObject(_gl);
    _glObject.setPoints(points);
  }


  void draw(Matrix4 mvMatrix, Matrix4 pMatrix) {
    _colorShader.bind();
    _colorShader.setMatrixUniforms(mvMatrix * transform, pMatrix);

    _colorShader.bindGeometry(_glObject);

    _colorShader.setColor(1.0, 0.0, 0.0, 1.0);
    _colorShader.draw(GL.LINES, 0, 2);

    _colorShader.setColor(0.0, 1.0, 0.0, 1.0);
    _colorShader.draw(GL.LINES, 2, 2);

    _colorShader.setColor(0.0, 0.0, 1.0, 1.0);
    _colorShader.draw(GL.LINES, 4, 2);

    _colorShader.unbind();
  }
}

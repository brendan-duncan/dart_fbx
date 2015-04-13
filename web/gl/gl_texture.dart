part of fbx_viewer;

class GlTexture {
  GL.Texture texture;
  int width = 0;
  int height = 0;

  GlTexture(this._gl, String url) {
    var image = new ImageElement();
    image.crossOrigin = 'anonymous';

    image.onLoad.listen((e) {
      if (texture == null) {
        texture = _gl.createTexture();
      }

      _gl.bindTexture(GL.TEXTURE_2D, texture);

      _gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
      _gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
      _gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
      _gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
      _gl.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, 1);

      width = image.width;
      height = image.height;

      _gl.texImage2DImage(GL.TEXTURE_2D,
          0,
          GL.RGBA,
          GL.RGBA,
          GL.UNSIGNED_BYTE,
          image);

      _gl.bindTexture(GL.TEXTURE_2D, null);
    });

    image.src = url;
  }


  void bind([int index=0]) {
    _gl.activeTexture(GL.TEXTURE0 + index);
    _gl.bindTexture(GL.TEXTURE_2D, texture);
  }

  GL.RenderingContext _gl;
}

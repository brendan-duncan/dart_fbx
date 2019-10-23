part of fbx_viewer;

class GlTexture {
  Texture texture;
  int width = 0;
  int height = 0;

  GlTexture(this._gl, String url) {
    var image = new ImageElement();
    image.crossOrigin = 'anonymous';

    image.onLoad.listen((e) {
      if (texture == null) {
        texture = _gl.createTexture();
      }

      _gl.bindTexture(WebGL.TEXTURE_2D, texture);

      _gl.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MAG_FILTER, WebGL.LINEAR);
      _gl.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MIN_FILTER, WebGL.LINEAR);
      _gl.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_S, WebGL.CLAMP_TO_EDGE);
      _gl.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_T, WebGL.CLAMP_TO_EDGE);
      _gl.pixelStorei(WebGL.UNPACK_FLIP_Y_WEBGL, 1);

      width = image.width;
      height = image.height;

      _gl.texImage2D(WebGL.TEXTURE_2D,
          0,
          WebGL.RGBA,
          WebGL.RGBA,
          WebGL.UNSIGNED_BYTE,
          image);

      _gl.bindTexture(WebGL.TEXTURE_2D, null);
    });

    image.src = url;
  }

  void bind([int index=0]) {
    _gl.activeTexture(WebGL.TEXTURE0 + index);
    _gl.bindTexture(WebGL.TEXTURE_2D, texture);
  }

  RenderingContext _gl;
}

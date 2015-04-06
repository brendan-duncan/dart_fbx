/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;


class FbxCamera extends FbxNodeAttribute {
  FbxProperty position;
  FbxProperty lookAt;
  FbxProperty cameraOrthoZoom;
  FbxProperty roll;
  FbxProperty fieldOfView;
  FbxProperty frameColor;
  FbxProperty nearPlane;
  FbxProperty farPlane;

  FbxCamera(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'Camera', element, scene) {
    position = addProperty('Position', new Vector3(0.0, 0.0, 0.0));
    lookAt = addProperty('LookAt', new Vector3(0.0, 0.0, 0.0));
    cameraOrthoZoom = addProperty('CameraOrthoZoom', 1.0);
    roll = addProperty('Roll', 0.0);
    fieldOfView = addProperty('FieldOfView', 40.0);
    frameColor = addProperty('FrameColor', new Vector3(0.0, 0.0, 0.0));
    nearPlane = addProperty('NearPlane', 1.0);
    farPlane = addProperty('FarPlane', 10000.0);

    for (FbxElement c in element.children) {
      if (c.id == 'CameraOrthoZoom') {
        cameraOrthoZoom.value = c.getDouble(0);
      } else if (c.id == 'LookAt') {
        lookAt.value = new Vector3(c.getDouble(0), c.getDouble(1), c.getDouble(2));
      } else if (c.id == 'Position') {
        position.value = new Vector3(c.getDouble(0), c.getDouble(1), c.getDouble(2));
      } else if (c.id == 'Properties60') {
        for (FbxElement p in c.children) {
          if (p.id == 'Property') {
            if (p.properties[0] == 'Roll') {
              roll.value = p.getDouble(3);
            } else if (p.properties[0] == 'FieldOfView') {
              fieldOfView.value = p.getDouble(3);
            } else if (p.properties[0] == 'FrameColor') {
              frameColor.value = new Vector3(p.getDouble(3), p.getDouble(4),
                                       p.getDouble(5));
            } else if (p.properties[0] == 'NearPlane') {
              nearPlane.value = p.getDouble(3);
            } else if (p.properties[0] == 'FarPlane') {
              farPlane.value = p.getDouble(3);
            }
          }
        }
      }
    }
  }
}

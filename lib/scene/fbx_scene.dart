/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
part of fbx;

/**
 * Contains the description of a complete 3D scene.
 */
class FbxScene extends FbxObject {
  Map<String, dynamic> header = {};

  FbxGlobalSettings globalSettings;
  FbxObject sceneInfo;
  FbxAnimEvaluator evaluator;
  List<FbxCamera> cameras = [];
  List<FbxLight> lights = [];
  List<String> textures = [];
  List<FbxMesh> meshes = [];
  List<FbxDeformer> deformers = [];
  List<FbxMaterial> materials = [];
  List<FbxAnimStack> animationStack = [];
  List<FbxSkeleton> skeletonNodes = [];
  List<FbxPose> poses = [];

  List<FbxNode> rootNodes = [];
  Map<String, FbxObject> allObjects = {};

  double startFrame = 1.0;
  double endFrame = 100.0;
  double currentFrame = 1.0;


  FbxScene()
    : super(0, '', 'Scene', null, null) {
    evaluator = new FbxAnimEvaluator(this);
  }


  FbxPose getPose(int index) => index < poses.length ? poses[index] : null;


  Matrix4 getNodeLocalTransform(FbxNode node) =>
      evaluator.getNodeLocalTransform(node, currentFrame);


  Matrix4 getNodeGlobalTransform(FbxNode node) =>
        evaluator.getNodeGlobalTransform(node, currentFrame);


  int get timeMode {
    if (globalSettings != null) {
      return globalSettings.timeMode.value;
    }
    return FbxFrameRate.DEFAULT;
  }


  double get startTime => FbxFrameRate.frameToSeconds(startFrame, timeMode);

  double get endTime => FbxFrameRate.frameToSeconds(endFrame, timeMode);

  double timeToFrame(int timeValue) {
    return FbxFrameRate.timeToFrame(timeValue, timeMode);
  }

  double timeToSeconds(int timeValue) {
    return FbxFrameRate.timeToSeconds(timeValue, timeMode);
  }
}

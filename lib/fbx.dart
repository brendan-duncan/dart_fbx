/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
library fbx;

import 'dart:math';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:vector_math/vector_math.dart';

export 'package:vector_math/vector_math.dart';

part 'fbx/bit_operators.dart';
part 'fbx/fbx_ascii_parser.dart';
part 'fbx/fbx_binary_parser.dart';
part 'fbx/fbx_element.dart';
part 'fbx/fbx_loader.dart';
part 'fbx/fbx_parser.dart';
part 'fbx/input_buffer.dart';
part 'fbx/matrix_utils.dart';
part 'fbx/scene/fbx_anim_curve.dart';
part 'fbx/scene/fbx_anim_key.dart';
part 'fbx/scene/fbx_anim_curve_node.dart';
part 'fbx/scene/fbx_anim_evaluator.dart';
part 'fbx/scene/fbx_anim_stack.dart';
part 'fbx/scene/fbx_anim_layer.dart';
part 'fbx/scene/fbx_camera.dart';
part 'fbx/scene/fbx_camera_switcher.dart';
part 'fbx/scene/fbx_cluster.dart';
part 'fbx/scene/fbx_deformer.dart';
part 'fbx/scene/fbx_display_mesh.dart';
part 'fbx/scene/fbx_edge.dart';
part 'fbx/scene/fbx_frame_rate.dart';
part 'fbx/scene/fbx_geometry.dart';
part 'fbx/scene/fbx_global_settings.dart';
part 'fbx/scene/fbx_layer.dart';
part 'fbx/scene/fbx_layer_element.dart';
part 'fbx/scene/fbx_light.dart';
part 'fbx/scene/fbx_mapping_mode.dart';
part 'fbx/scene/fbx_material.dart';
part 'fbx/scene/fbx_mesh.dart';
part 'fbx/scene/fbx_node.dart';
part 'fbx/scene/fbx_node_attribute.dart';
part 'fbx/scene/fbx_null.dart';
part 'fbx/scene/fbx_object.dart';
part 'fbx/scene/fbx_polygon.dart';
part 'fbx/scene/fbx_pose.dart';
part 'fbx/scene/fbx_property.dart';
part 'fbx/scene/fbx_reference_mode.dart';
part 'fbx/scene/fbx_scene.dart';
part 'fbx/scene/fbx_skeleton.dart';
part 'fbx/scene/fbx_skin_deformer.dart';
part 'fbx/scene/fbx_texture.dart';
part 'fbx/scene/fbx_video.dart';
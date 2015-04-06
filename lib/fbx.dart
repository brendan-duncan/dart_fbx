/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */
library fbx;

import 'dart:math';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:vector_math/vector_math.dart';

export 'package:vector_math/vector_math.dart';

part 'bit_operators.dart';
part 'fbx_ascii_parser.dart';
part 'fbx_binary_parser.dart';
part 'fbx_element.dart';
part 'fbx_loader.dart';
part 'fbx_parser.dart';
part 'input_buffer.dart';
part 'matrix_utils.dart';
part 'scene/fbx_anim_curve.dart';
part 'scene/fbx_anim_key.dart';
part 'scene/fbx_anim_curve_node.dart';
part 'scene/fbx_anim_evaluator.dart';
part 'scene/fbx_anim_stack.dart';
part 'scene/fbx_anim_layer.dart';
part 'scene/fbx_camera.dart';
part 'scene/fbx_camera_switcher.dart';
part 'scene/fbx_cluster.dart';
part 'scene/fbx_deformer.dart';
part 'scene/fbx_display_mesh.dart';
part 'scene/fbx_edge.dart';
part 'scene/fbx_frame_rate.dart';
part 'scene/fbx_geometry.dart';
part 'scene/fbx_global_settings.dart';
part 'scene/fbx_layer.dart';
part 'scene/fbx_layer_element.dart';
part 'scene/fbx_light.dart';
part 'scene/fbx_mapping_mode.dart';
part 'scene/fbx_material.dart';
part 'scene/fbx_mesh.dart';
part 'scene/fbx_node.dart';
part 'scene/fbx_node_attribute.dart';
part 'scene/fbx_null.dart';
part 'scene/fbx_object.dart';
part 'scene/fbx_polygon.dart';
part 'scene/fbx_pose.dart';
part 'scene/fbx_property.dart';
part 'scene/fbx_reference_mode.dart';
part 'scene/fbx_scene.dart';
part 'scene/fbx_skeleton.dart';
part 'scene/fbx_skin_deformer.dart';
part 'scene/fbx_texture.dart';

# FBX #

** THIS LIBRARY IS WORK-IN-PROGRESS. THE API IS NOT FINAL, AND IS NOT YET 
INTENDED FOR GENERAL USE. ** 

## Introduction ##

A parser for .FBX format in Dart.  An FBX file supports geometry and animation
that can be exported from many common 3d animation programs. 

This supports ASCII and Binary FBX files. 

## Background ##

FBX (Filmbox) is a proprietary file format (.fbx) developed by Autodesk. 
It is used to provide interoperability between digital content creation 
applications. It provides support for 3D geometry, animation curves, and basic deformations such as skinning and blend shapes.

## Example ##

[FBX Viewer](http://brendan-duncan.github.io/dart_fbx/fbx_viewer.html)

## Limitations ##

FBX is a closed format, so while this library does it's best to interpret the
data in an FBX file, I cannot guarantee that it will read all FBX files, or
all data within FBX files.


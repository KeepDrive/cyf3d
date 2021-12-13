# cyf3d
3D Shader and Library for Create Your Frisk

## Introduction
This library and shader should allow you to display flat sprites as planes in 3d space with perspective projection. Also includes an example wave.

This works via the shader ignoring the matrices(MVP) that the Unity camera feeds to the individual objects, instead using matrices calculated in the Library.

This is tested and should work on Linux(OpenGL) and Windows(DirectX), but Mac OS(Metal?) should also work fine. The main shaders("Basic3D" and "Complex3D") should work on most hardware that can run Create Your Frisk, but I cannot guarantee that.

## Requirements
To run this you have to use Create Your Frisk(>=0.6.5)

## Setup
To install, as with any Create Your Frisk mod, just drop the cyf3d folder into the mods folder.

## How to use
### Shader stuff:
All commands that you should need are listed in the library after the "Actual commands:" comment, but I'll still run through them.
To add a shader to a sprite you should use:
```
cyf3dAddShader(sprite,type)
```
Instead of adding the shader directly, as the library has to constantly update shader values for each sprite, so it has to keep track of them. There are two types of shader you can load in like this currently, "Basic3D" and "Complex3D"("Basic3D" by default if you leave type without value, type is a string), the former is much more simpler in terms of UV manipulation, but the latter allows you greater control over the shape of the sprite and the UV map.

For this shader to work properly you have to put this once in the "Update()" function after all modifications to the 3d scene, if you are unsure about what that means, you can just put it at the end of the "Update()" function:
```
cyf3dUpdate()
```
To remove and revert the shader there is:
```
cyf3dRemoveShader(sprite)
```
WARNING: You should always remove the shader with this function before deleting a sprite or changing it's shader, the library isn't made to garbage collect for you.
### Sprite transformation:
For changing position, rotation and scale of any sprite there are:
```
cyf3dSetPos(sprite,position)
cyf3dSetRot(sprite,rotation)
cyf3dSetScale(sprite,scale)
```
Sprite is the sprite object that needs to be modified; position, rotation and scale are three-dimensional vectors, made using tables of three values: {x,y,z}(Though not necessarily, the values can be nil, which will just use the current existing values, the table can also be empty or contain less or more than three values and it should still work the same)

You can also set all three parameters at once:
```
cyf3dSetPosRotScale(sprite,position,rotation,scale)
```
And rotation and scale together, which is mostly added for optimisation's sake so it doesn't have to redo the same(rather costly) calculation twice:
```
cyf3dSetRotScale(sprite,rotation,scale)
```
You can also set position, rotation and scale, together with adding the shader:
```
cyf3dAddShaderPosRotScale(sprite,position,rotation,scale,type)
```
To get position, rotation or scale of an object there are:
```
cyf3dGetPos(sprite)
cyf3dGetRot(sprite)
cyf3dGetScale(sprite)
```

#### Complex3D-specific:
In terms of sprite manipulation Basic3D shares all its functions with Complex3D. Complex3D adds one new function:
```
cyf3dSetVertices(sprite,verts)
```
Verts is a table of 4 three-dimensional vectors which represent the positions of all the 4 vertices of a sprite, in the order of: top-left, top-right, bottom-right, bottom-left.

### Transforming the UV map:
So you want to make a wide wall and are wondering how to get around the texture stretching? Then it's time to modify the UV map.

#### Basic3D-specific:
While the UV map controls are rather primitive here, so is the shader itself and its uses, the controls provided should be fine for most scenarios:

You can modify the position, rotation and scale of the UV map:
```
cyf3dUVSetPos(sprite,position)
cyf3dUVSetRotScale(sprite,rotation,scale)
cyf3dUVSetPosRotScale(sprite,position,rotation,scale)
```
Here position and scale are two-dimensional vectors that work like before except only for two values of {x,y} instead of the three {x,y,z}, but rotation is a number instead, because there's only one axis to rotate around.

#### Complex3D-specific:

In Complex3D I cut out the Basic3D simple UV transformation, because I felt it was mostly unrequired for the purposes of this shader. The only UV-related function for Complex3D is:
```
cyf3dUVSetPoints(sprite,points)
```
Points is a table of 4 two-dimensional vectors, one for each vertex, same order as the vertices go in: top-left, top-right, bottom-right, bottom-left.

When using this while doing weird shapes you might notice that the UV starts becoming warped, sadly I cannot offer a fix for this as that is normal behaviour for complex shapes with low vertex count. One might help is tesselation, but I'll have to look into how that could work later as I currently have other plans for this project.

### Manipulating the camera:
In terms of camera transformation you can only change a camera's position, and rotation, scale is not implemented:
```
cyf3dSetCamPos(position)
cyf3dSetCamRot(rotation)
```
Position and rotation are three-dimensional vectors. Camera rotation supports roll, but if you do not need it I suggest commenting out a line in "cyf3dModelViewMatrix()"

You can also change the camera's fov and near/far values:
```
cyf3dSetFov(fov)
cyf3dSetCamClipping(near,far)
```
Note that near and far values are OpenGL-like, not DirectX-like, so 0<near<far. Fov is measured in degrees.

At the end there are all the camera getter functions:
```
cyf3dGetCamPos()
cyf3dGetCamRot()
cyf3dGetFov()
cyf3dGetCamClippingNear()
cyf3dGetCamClippingFar()
```
Also if you want to access camera values directly instead of using getters and setters, you can, the list of all variables is at the top, here are all the camera related ones:
```
cyf3dcamPos={0,0,0}
cyf3dcamRot={0,0,0}
cyf3dfov=90
cyf3dcamNear=0.001
cyf3dcamFar=1000
```
### Using 3D models:

WARNING: This here will not work on ALL hardware and most likely won't work on Mac OS(!), this is implemented using geometry shaders which are supported only on Unity shader models "4.0" and later(https://docs.unity3d.com/2018.3/Documentation/Manual/SL-ShaderCompileTargets.html), so that means using DirectX 11+, OpenGL 3.2+ or Vulkan. If your hardware is incapable of any of these - trying to create a 3D model will likely throw an error. Use this in your mods at your own risk.

cyf3d has basic .obj file support, you can load in a .obj file using:
```
cyf3dReadObjFile(path)
```
path is a string containing the path to the .obj file you want to load in from the mod's root folder(the folder that contains "Lua", "Shaders", "Sprites" folders), f.e. if a "model.obj" file is directly in the root folder itself you would do:
```
cyf3dReadObjFile("model.obj")
```
(Small note for Blender users, the .obj files Blender exports should work fine from what I've tested, but still here are the setting i would recommend("Geometry" tab when exporting): Include UVs on, Triangulate Faces on, Write Normals off)
The function returns a "facevertuvtable" table that is used for creating the model itself with:
```
cyf3dCreate3DModel(facevertuvtable,texturepath,layer)
```
texturepath is a string containing the name or path to an image file inside the "Sprites" folder, basically same as "spritename" for CYF's CreateSprite() function
layer is also the same as "layer" in CreateSprite(), "Top" by default.
F.e. if you have a "model.obj" file in the root folder of your mod, "modeltexture.png" in the "Sprites" folder you would create a model like so:
```
myModel = cyf3dCreate3DModel(cyf3dReadObjFile("model.obj"),"modeltexture")
```
The function returns a sprite that acts as a model when the library interacts with it.
All the functions listed in the "Sprite transformation" paragraph should work with the returned model.

If you wish to create your own file reader for 3D models - you absolutely can, all is required is that your code can create a facevertuvtable(and preferably store it in memory), facevertuvtable works similarly to the .obj file format:
facevertuvtable should contain three tables:
table 1(face data) contains tables of 6 values each, every other value starting from 1 is an integer that is the index of a vertex in table 2, every other value starting from 2 is an integer that is the index of a uv coordinate pair in table 3, {v1,uv1,v2,uv2,v3,uv3}
table 2(vertex data) contains tables of 3 values each, each table is the coordinates of a vertex, {x,y,z}
table 3(uv data) contains tables of 2 values each, each table contains UV coordinates, {x,y}

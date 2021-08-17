# cyf3d
3D Shader and Library for Create Your Frisk

## Introduction
This library and shader should allow you to display flat sprites as planes in 3d space with perspective projection. Also includes an example wave.

This works via the shader ignoring the matrices(MVP) that the Unity camera feeds to the individual objects, instead using matrices calculated in the Library.

This is tested and should work on Linux(OpenGL) and Windows(DirectX), but Mac OS should also work fine by virtue of also using OpenGL. The shader should work on most hardware that can run Create Your Frisk, but I cannot guarantee that.

## Requirements
To run this you have to use Create Your Frisk(>=0.6.5)

## Setup
To install, as with any Create Your Frisk mod, just drop the cyf3d folder into the mods folder.

## How to use
### Shader stuff:
All commands that you should need are listed in the library after the "Actual commands:" comment, but I'll still run through them.
To add the shader to a sprite you should use:
```
cyf3dAddShader(sprite)
```
Instead of adding the shader directly, as the library has to constantly update shader values for each sprite, so it has to keep track of them.

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
cyf3dAddShaderPosRotScale(sprite,position,rotation,scale)
```
To get position, rotation or scale of an object there are:
```
cyf3dGetPos(sprite)
cyf3dGetRot(sprite)
cyf3dGetScale(sprite)
```
### Transforming the UV map:
So you want to make a wide wall and are wondering how to get around the texture stretching? Then it's time to modify the UV map.

While the UV map controls are rather primitive here, so is the shader itself and its uses(at least as it currently is), the controls provided should be fine for most scenarios:

You can modify the position, rotation and scale of the UV map:
```
cyf3dUVSetPos(sprite,position)
cyf3dUVSetRotScale(sprite,rotation,scale)
cyf3dUVSetPosRotScale(sprite,position,rotation,scale)
```
Here position and scale are two-dimensional vectors that work like before except only for two values of {x,y} instead of the three {x,y,z}, but rotation is a number instead, because there's only one axis to rotate around.
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

# cyf3d
3D Shader and Library for Create Your Frisk

## Introduction
This library and shader should allow you to display flat sprites as planes in 3d space with perspective projection and even add 3D models. Also includes an example wave.

This works by replicating all the matrix math that the Unity camera feeds to individual objects, except instead of an orthographic projection this uses perspective.

This is tested and should work on Linux (OpenGL) and Windows (DirectX), but Mac OS (Metal?) should also work fine. The main shaders("Basic3D" and "Complex3D" for 3D Sprites and Quads respectively) should work on most hardware that can run Create Your Frisk, but I cannot guarantee that.

## Requirements
To run this you have to use Create Your Frisk(>=0.6.5)

## Setup
To install, as with any Create Your Frisk mod, just drop the cyf3d folder into the mods folder.

## How to use
### Basics:
There are three functions to create a cyf3d object:
```
obj = cyf3d.Create3DSprite(spritename,layer,childNumber)
obj = cyf3d.CreateQuad(spritename,layer,childNumber)
obj = cyf3d.Create3DModel(facevertuvtable,texturepath,layer,childNumber)
```
I've tried my best to mimic how CYF handles objects, so these should feel familiar, they return their respective objects (3DSprite,Quad,3DModel), which really are just tables with values and functions in Lua, as you can see here spritename (or texturepath),layer,childNumber are the same as they are in CYF (CreateSprite() function).

spritename or texturepath is the name or path to the sprite in the "Sprites" folder(without extension).

layer is the layer the object's sprite will be created on, "Top" by default, is omittable(by that I mean you can write cyf3d.Create3DSprite(spritename,childNumber) for example and it will work).

childNumber means where in the layer it will be placed, -1 by default, is omittable.

For the objects to work properly you have to put the function below once in the "Update()" function after all modifications to the 3d scene, if you are unsure about what that means, this likely means just putting this at the end of your "Update()" function:
```
cyf3d.UpdateObjects()
```
### Shared variables and functions:
All cyf3d objects have these parameters:
```
obj.sprite
obj.x=0
obj.y=0
obj.z=0
obj.xrotation=0
obj.yrotation=0
obj.zrotation=0
obj.xscale=1.0
obj.yscale=1.0
```
And also Quads and 3DModels share zscale:
```
obj.zscale=1.0
```
These are pretty self-explanatory:

sprite is the main sprite of the object, if you want to access some variable or function of the sprite, f.e. to change the colour of the sprite of a cyf3d object "obj" to black, you would do this:
```
obj.sprite.color32={0,0,0}
```
NOTE: Due to how 3DModel objects work the code above will not work for them, the sprite variable still exists but the object itself actually consists of multiple sprites, so if you wanna change something about one, you'll probably have to do it for all of them(not to mention the shader used for 3DModel objects does not support colour modification, but just for demonstration purposes), this necessitates the following:
```
for i=1,#class._sprites do
  class._sprites[i][1].color32={0,0,0}
end
```

x,y,z are variables describing the position of the object, 0 by default.

xrotation,yrotation,zrotation describe the rotation of the object along the respective axes, measured in degrees, 0 by default.

xscale,yscale,zscale describe the scale of the object, 1.0 by default. 3DSprites do not require scale modification along the Z axis because they are flat planes and scale is applied before rotation.

Now let's go over the shared functions and then we'll move on to specifics of each class:
```
obj.Move(x,y,z)
obj.MoveTo(x,y,z)
obj.Rotate(xrotation,yrotation,zrotation)
obj.Scale(xscale,yscale,zscale)
obj.SetVar(yourVariableName,value)
obj.GetVar(yourVariableName)
obj.Remove()
```
These functions below are basically setters for the respective variables above:
```
obj.Move(x,y,z)
obj.MoveTo(x,y,z)
obj.Rotate(xrotation,yrotation,zrotation)
obj.Scale(xscale,yscale,zscale)
```
obj.Move(x,y,z) and obj.MoveTo(x,y,z) work the same as in CYF, obj.Move(x,y,z) moves the object from it's current position to it's current position plus {x,y,z}, obj.MoveTo(x,y,z) moves the object to (x,y,z), i.e. obj.Move(x,y,z) is equivalent to obj.MoveTo(obj.x+x,obj.y+y,obj.z+z), which is equivalent to
```
obj.x=obj.x+x
obj.y=obj.y+y
obj.z=obj.z+z
```
obj.Rotate(xrotation,yrotation,zrotation) is equivalent to:
```
obj.xrotation=xrotation
obj.yrotation=yrotation
obj.zrotation=zrotation
```
NOTE: Since this uses euler angles - this is subject to gimbal lock, for those interested - internally the rotation order is ZYX: roll first, then yaw, then pitch.

obj.Scale(xscale,yscale,zscale) is quivalent to:
```
obj.xscale=xscale
obj.yscale=yscale
obj.zscale=zscale
```
obj.SetVar(yourVariableName,value) is equivalent to:
```
class[yourVariableName]=value
```
And var=obj.GetVar(yourVariableName) is equivalent to:
```
var=class[yourVariableName]
```
obj.Remove() is the function you need to call to remove the object, note the object does not get fully deleted until the garbage collector deletes it, which means all references to the object should be set to nil, since the function returns nil by default - the most elegant solution is:
```
obj=obj.Remove()
```
NOTE: This only works if obj is the only variable that points to the object AND MUCH MORE IMPORTANTLY if obj is not an element of a table, if you do this to a table element the table it's in will become nil, so if you want to remove an object, the reference to which is inside a table you need to do this instead:
```
sometable[objIndex].Remove()
table.remove(sometable,objIndex)
```
### 3DSprite specifics:
A 3DSprite is the simplest object cyf3d provides and basically is just a basic sprite with perspective applied.
The only function that it has that isn't described in the section above is a function to change the UV map:
```
obj.ChangeUV(x,y,rotation,xscale,yscale)
```
The UV controls here are pretty basic, but should work for most purposes: you can change the x,y position of the UV map relative to the midpoint (meaning (0,0) is the middle of the image, (-0.5,-0.5) is the top left point of the image), rotation around the midpoint and scale(xscale and yscale).

For example if you have a stretched sprite(obj.xscale=10.0) and want the texture to repeat along the sprite instead of stretching with it you would do:
```
obj.ChangeUV(0,0,0,10.0,1.0)
```
Some things to note:

A 3DSprite's actual size depends on the size of the sprite image, so a 3DSprite of a 32x32px image will appear twice as large if compared to a 3DSprite of a 16x16px image if they have the same xscale and yscale values.

3DSprite's obj.Scale() function only takes xscale and yscale, without using zscale for reasons explained in the previous section.

### Quad specifics:
A Quad is basically the same as 3DSprite, but you have a bit more control over the UV and the shape:
```
obj.SetUVPoints(x1,y1,x2,y2,x3,y3,x4,y4)
obj.SetVertPoints(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4)
```
With a Quad you have to define the UV points and edge coordinates yourself, you can also edit them directly instead of using the function:
```
vertpoints={-0.5,-0.5,0,-0.5,-0.5,0,0.5,0.5,0,-0.5,0.5,0},
uvpoints={0,0,1,0,1,1,0,1}
```
The default values are displayed above, the order is the same as in the function: first set of coordinates apply to the top left point of the shape/uv, the second to the top right, third set to the bottom right and the fourth to the bottom left.

Some things to note:

Since there is no tesselation - the texture will appear warped on the Quad if it has a shape that isn't a rectangle unless you account for that in the image/UV map.

### 3DModel specifics:

WARNING: This object type will not work on ALL hardware and most likely won't work on Mac OS (!), this is implemented using geometry shaders which are supported only on Unity shader models "4.0" and later (https://docs.unity3d.com/2018.3/Documentation/Manual/SL-ShaderCompileTargets.html), so that means using DirectX 11+, OpenGL 3.2+ or Vulkan. If your hardware is incapable of any of these - trying to create a 3D model will likely throw an error. Use this in your mods at your own risk.

This I'm most proud of - you can add 3D models to the scene.
```
cyf3d.Create3DModel(facevertuvtable,texturepath,layer,childNumber)
```
I glossed over this in the "Basics" section, but the function requires facevertuvtable and you might be confused as to what that is: it's basically a .obj file in table form, and speaking of .obj, cyf3d supports .obj files:
```
cyf3d.ReadObjFile(path)
```
path is a string containing the path to an .obj file in the mod's root folder(the folder that contains "Lua", "Shaders", "Sprites" folders), f.e. if a "model.obj" file is directly in the root folder itself you would do:
```
cyf3d.ReadObjFile("model.obj")
```
This function returns a facevertuvtable, so, given an image "sprite.png" in the "Sprites" folder, to create a model you could do:
```
mdl=cyf3d.Create3DModel(cyf3d.ReadObjFile("model.obj"),"sprite")
```
Some things to note:

For Blender users, the .obj files Blender exports by default should work fine from what I've tested, but still here are the settings I would recommend (these are in the "Geometry" tab in the export window): Include UVs on, Triangulate Faces on, Write Normals off

If you wish to clear a model from memory (And you absolutely should if you don't require the model again), again, you must make all references to the respective facevertuvtable, this means at least doing this:
```
table.remove(cyf3d.models,path)
```
Where path is the path to your model, same as in cyf3d.ReadObjFile(). If you stored the facevertuvtable somewhere yourself - you have to delete that too by assigning nil to the variable it's stored in.

If you wish to create your own file reader for 3D models - you absolutely can, all that is required is that your code can create a facevertuvtable(and preferably store it in memory), facevertuvtable works similarly to the .obj file format:

facevertuvtable should contain three tables:

Table 1(face data) contains tables of 6 values each, every other value starting from 1 is an integer that is the index of a vertex in table 2, every other value starting from 2 is an integer that is the index of a UV coordinate pair in table 3, {v1,uv1,v2,uv2,v3,uv3}

Table 2(vertex data) contains tables of 3 values each, each table is the coordinates of a vertex, {x,y,z}

Table 3(UV data) contains tables of 2 values each, each table contains UV coordinates, {x,y}

To store the model in memory you can to add this to the beginning of your loader function (variable "path" is the path to the model, same as in cyf3d.ReadObjFile()):
```
if cyf3d.models[path]~=nil then
  return cyf3d.models[path]
end
```
And this after a facevertuvtable is created:
```
cyf3d.models[path]=facevertuvtable
```
### Camera controls:
Lastly, camera controls. In terms of camera controls you can only change a camera's position, and rotation, scale is not implemented:
```
cyf3d.camera.Move(x,y,z)
cyf3d.camera.MoveTo(x,y,z)
cyf3d.camera.Rotate(xrotation,yrotation,zrotation)
```
Move(), MoveTo(), Rotate() work in the same way as the objects, described in "Shared variables and functions".

You can also access the needed variables directly:
```
cyf3d.camera.x
cyf3d.camera.y
cyf3d.camera.z
cyf3d.camera.xrotation
cyf3d.camera.yrotation
cyf3d.camera.zrotation
```
And access the camera's fov and near/far values:
```
cyf3d.camera.fov
cyf3d.camera.near
cyf3d.camera.far
```
Some things to note:

Near and far values are OpenGL-like, not DirectX-like, so 0<near<far.

Fov is measured in degrees.

--Variables:
cyf3dcamPos={0,0,0}
cyf3dcamRot={0,0,0}
cyf3dactiveObjects={}
cyf3dfov=90
cyf3dcamNear=0.001
cyf3dcamFar=1000
cyf3dwindows=Misc.OSType=="Windows"
--Utils:
function cyf3dDotProduct(vec1,vec2)
    res=0
    for i = 1,math.min(#vec1,#vec2) do
        res=res+vec1[i]*vec2[i]
    end
    return res
end
function cyf3dGetMatrixColumn(mat,x)
    return {mat[1][x],mat[2][x],mat[3][x],mat[4][x]}
end
function cyf3dApplyMatrix(mat1,mat2)
    endmatrix = {}
    for i = 1,4 do
        endmatrix[i] = {}
        for j = 1,4 do
            endmatrix[i][j]=cyf3dDotProduct(mat1[i],cyf3dGetMatrixColumn(mat2,j))
        end
    end
    return endmatrix
end
function cyf3dMatrixFlipZ(mat)
    endmatrix=mat
    endmatrix[1][3]=-endmatrix[1][3]
    endmatrix[2][3]=-endmatrix[2][3]
    endmatrix[3][3]=-endmatrix[3][3]
    endmatrix[4][3]=-endmatrix[4][3]
    return endmatrix
end
function cyf3dInArray(arr,obj)
    for i = 1,#arr do
        if arr[i][1]==obj then
            return i
        end
    end
    return nil
end
function cyf3dDebugMatrix(matdebug)
    DEBUG("--------------------------")
    DEBUG(tostring(matdebug[1][1]).."/"..tostring(matdebug[1][2]).."/"..tostring(matdebug[1][3]).."/"..tostring(matdebug[1][4]))
    DEBUG(tostring(matdebug[2][1]).."/"..tostring(matdebug[2][2]).."/"..tostring(matdebug[2][3]).."/"..tostring(matdebug[2][4]))
    DEBUG(tostring(matdebug[3][1]).."/"..tostring(matdebug[3][2]).."/"..tostring(matdebug[3][3]).."/"..tostring(matdebug[3][4]))
    DEBUG(tostring(matdebug[4][1]).."/"..tostring(matdebug[4][2]).."/"..tostring(matdebug[4][3]).."/"..tostring(matdebug[4][4]))
    DEBUG("--------------------------")
end
--Matrix creation:
function cyf3dRotationMatrix(x,y,z)
    x = math.rad(x or 0)
    y = math.rad(y or 0)
    if cyf3dwindows then
        y=-y
    end
    z = math.rad(z or 0)
    local xc=math.cos(x)
    local xs=math.sin(x)
    local yc=math.cos(y)
    local ys=math.sin(y)
    local zc=math.cos(z)
    local zs=math.sin(z)
    return {{xc*yc,xc*ys*zs-xs*zc,xc*ys*zc+xs*zs,0},
            {xs*yc,xs*ys*zs+xc*zc,xs*ys*zc-xc*zs,0},
            {  -ys,         yc*zs,         yc*zc,0},
            {    0,             0,             0,1}}
end
function cyf3dScaleMatrix(x,y,z)
    x = x or 1
    y = y or 1
    z = z or 1
    return {{x,0,0,0},
            {0,y,0,0},
            {0,0,z,0},
            {0,0,0,1}}
end
--These two matrices are just for reference, as they're trivial to combine
function cyf3dModelMatrix()
    return {{1,0,0,cyf3dcamPos[1]},
            {0,1,0,cyf3dcamPos[2]},
            {0,0,1,cyf3dcamPos[3]},
            {0,0,0,1}}
end
function cyf3dViewMatrix()
    local cosPitch=math.cos(math.rad(cyf3dcamRot[2]))
    local cosYaw=math.cos(math.rad(cyf3dcamRot[1]))
    local sinPitch=math.sin(math.rad(cyf3dcamRot[2]))
    local sinYaw=math.sin(math.rad(cyf3dcamRot[1]))
    return {{         cosYaw,        0,        -sinYaw,0},
            {sinYaw*sinPitch, cosPitch,cosYaw*sinPitch,0},
            {sinYaw*cosPitch,-sinPitch,cosPitch*cosYaw,0},
            {              0,        0,              0,1}}
end
function cyf3dModelViewMatrix()
    local cosPitch = math.cos(math.rad(cyf3dcamRot[2]))
    local cosYaw   = math.cos(math.rad(cyf3dcamRot[1]))
    local sinPitch = math.sin(math.rad(cyf3dcamRot[2]))
    local sinYaw   = math.sin(math.rad(cyf3dcamRot[1]))
    endmatrix={{         cosYaw,        0,        -sinYaw,0},
               {sinYaw*sinPitch, cosPitch,cosYaw*sinPitch,0},
               {sinYaw*cosPitch,-sinPitch,cosPitch*cosYaw,0},
               {              0,        0,              0,1}}
    --If you don't need roll you can comment this out:
    cyf3dApplyMatrix(endmatrix,cyf3dRotationMatrix(cyf3dcamRot[3],0,0))
    endmatrix[1][4]=cyf3dDotProduct(endmatrix[1],cyf3dcamPos)
    endmatrix[2][4]=cyf3dDotProduct(endmatrix[2],cyf3dcamPos)
    endmatrix[3][4]=cyf3dDotProduct(endmatrix[3],cyf3dcamPos)
    return endmatrix
end
function cyf3dProjectionMatrix()
    local minfov=1
    local maxfov=179
    local m11 = math.atan(math.rad(math.max(math.min(180-cyf3dfov or 90,maxfov),minfov)))
    local m00 = m11*0.75--0.75 being 1 divided by the aspect ratio, 4:3
    local m22=0
    local m23=0
    if cyf3dwindows then
        m22 = -cyf3dcamNear/(cyf3dcamNear-cyf3dcamFar)
        m23 = -(cyf3dcamFar*cyf3dcamNear)/(cyf3dcamNear-cyf3dcamFar)
    else
        m22 = -(cyf3dcamFar+cyf3dcamNear)/(cyf3dcamFar-cyf3dcamNear)
        m23 = -2*(cyf3dcamFar*cyf3dcamNear)/(cyf3dcamFar-cyf3dcamNear)
    end
    return {{m00,  0,  0,  0},
            {  0,m11,  0,  0},
            {  0,  0,m22,m23},
            {  0,  0, -1,  0}}
end
function cyf3dMVPMatrix()
    if cyf3dwindows then
        return cyf3dMatrixFlipZ(cyf3dApplyMatrix(cyf3dProjectionMatrix(),cyf3dModelViewMatrix()))
    else
        return cyf3dApplyMatrix(cyf3dProjectionMatrix(),cyf3dModelViewMatrix())
    end
end
--Actual commands:
function cyf3dAddShader(obj)
    if pcall(obj.shader.Set,"cyf3d","Basic3D") then--Shader should be compatible with any device but just in case
        cyf3dactiveObjects[#cyf3dactiveObjects+1]={obj,{0,0,0},{1,1,1},cyf3dScaleMatrix(),cyf3dScaleMatrix()}--Any non-persistent properties we want to apply every frame so we save the rotation and the scale and have two cached matrices, one for vertices the other for UV, for now simple identity matrices
        obj.shader.SetWrapMode("repeat")--Make UVs work as intended
    else
        DEBUG("cyf3d shader failed to load")
    end
end
function cyf3dAddShaderPosRotScale(obj,posVector,rotVector,scaleVector)
    if pcall(obj.shader.Set,"cyf3d","Basic3D") then
        cyf3dactiveObjects[#cyf3dactiveObjects+1]={obj,{0,0,0},{1,1,1},cyf3dScaleMatrix(),cyf3dScaleMatrix()}--Any non-persistent properties we want to apply every frame so we save the rotation and the scale and have two cached matrices, one for vertices the other for UV, for now simple identity matrices
        obj.shader.SetWrapMode("repeat")
        cyf3dSetPos(obj,posVector)
        cyf3dSetRotAndScale(obj,rotVector,scaleVector)
    else
        DEBUG("cyf3d shader failed to load")
    end
end
function cyf3dRemoveShader(obj)
    table.remove(cyf3dactiveObjects,cyf3dInArray(cyf3dactiveObjects,obj))
    obj.shader.Revert()
end
function cyf3dUpdate()
    if #cyf3dactiveObjects!=0 then
        cachedMVP=cyf3dMVPMatrix()
        cachedMVP=cyf3dactiveObjects[1][1].shader.Matrix(cachedMVP[1],cachedMVP[2],cachedMVP[3],cachedMVP[4])
        for i=1,#cyf3dactiveObjects do
            cyf3dactiveObjects[i][1].shader.SetMatrix("MVP",cachedMVP)
            modtable=cyf3dactiveObjects[i][4]
            cyf3dactiveObjects[i][1].shader.SetMatrix("mod",cyf3dactiveObjects[i][1].shader.matrix(modtable[1],modtable[2],modtable[3],modtable[4]))
            modtable=cyf3dactiveObjects[i][5]
            cyf3dactiveObjects[i][1].shader.SetMatrix("uvMod",cyf3dactiveObjects[i][1].shader.matrix(modtable[1],modtable[2],modtable[3],modtable[4]))
        end
    end
end
function cyf3dGetPos(obj)
    curPos=obj.shader.GetVector("_objPos")
    curPos[1]=curPos[2]--Dunno why it's shifted like that, should look into it if i make an update
    curPos[2]=curPos[3]
    curPos[3]=cyf3dwindows and -curPos[4] or curPos[4]
    curPos[4]=0
    return curPos
end
function cyf3dGetRot(obj)
    return cyf3dactiveObjects[cyf3dInArray(cyf3dactiveObjects,obj)][2]
end
function cyf3dGetScale(obj)
    return cyf3dactiveObjects[cyf3dInArray(cyf3dactiveObjects,obj)][3]
end
function cyf3dSetPos(obj,posVector)
    curPos=cyf3dGetPos(obj)
    posVector[1]=posVector[1] or curPos[1]
    posVector[2]=posVector[2] or curPos[2]
    posVector[3]=posVector[3] or curPos[3]
    if cyf3dwindows then
        posVector[3]=-posVector[3]
    end
    posVector[4]=0
    obj.shader.SetVector("_objPos",posVector)
end
function cyf3dSetRot(obj,rotVector)
    objIndex=cyf3dInArray(cyf3dactiveObjects,obj)
    objRot=cyf3dactiveObjects[objIndex][2]
    rotVector=rotVector or {}
    objRot[1]=rotVector[1] or objRot[1]
    objRot[2]=rotVector[2] or objRot[2]
    objRot[3]=rotVector[3] or objRot[3]
    objScale=cyf3dactiveObjects[objIndex][3]
    cyf3dactiveObjects[objIndex][4]=cyf3dApplyMatrix(cyf3dRotationMatrix(objRot[1],objRot[2],objRot[3]),cyf3dScaleMatrix(objScale[1],objScale[2],objScale[3]))
end
function cyf3dSetScale(obj,scaleVector)
    objIndex=cyf3dInArray(cyf3dactiveObjects,obj)
    objScale=cyf3dactiveObjects[objIndex][3]
    scaleVector=scaleVector or {}
    objScale[1]=scaleVector[1] or objScale[1]
    objScale[2]=scaleVector[2] or objScale[2]
    objScale[3]=scaleVector[3] or objScale[3]
    objRot=cyf3dactiveObjects[objIndex][2]
    cyf3dactiveObjects[objIndex][4]=cyf3dApplyMatrix(cyf3dRotationMatrix(objRot[1],objRot[2],objRot[3]),cyf3dScaleMatrix(objScale[1],objScale[2],objScale[3]))
end
function cyf3dSetRotScale(obj,rotVector,scaleVector)
    objIndex=cyf3dInArray(cyf3dactiveObjects,obj)
    objRot=cyf3dactiveObjects[objIndex][2]
    rotVector=rotVector or {}
    objRot[1]=rotVector[1] or objRot[1]
    objRot[2]=rotVector[2] or objRot[2]
    objRot[3]=rotVector[3] or objRot[3]
    objScale=cyf3dactiveObjects[objIndex][3]
    scaleVector=scaleVector or {}
    objScale[1]=scaleVector[1] or objScale[1]
    objScale[2]=scaleVector[2] or objScale[2]
    objScale[3]=scaleVector[3] or objScale[3]
    cyf3dactiveObjects[objIndex][4]=cyf3dApplyMatrix(cyf3dRotationMatrix(objRot[1],objRot[2],objRot[3]),cyf3dScaleMatrix(objScale[1],objScale[2],objScale[3]))
end
function cyf3dSetPosRotScale(obj,posVector,rotVector,scaleVector)
    cyf3dSetPos(obj,posVector)
    cyf3dSetRotScale(obj,rotVector,scaleVector)
end
function cyf3dUVSetPos(obj,posVector)
    posVector[1]=(posVector[1] or 0)+0.5
    posVector[2]=(posVector[2] or 0)+0.5
    posVector[3]=0
    posVector[4]=0
    obj.shader.SetVector("_uvPos",posVector)
end
function cyf3dUVSetRotScale(obj,rotation,scaleVector)
    objIndex=cyf3dInArray(cyf3dactiveObjects,obj)
    cyf3dactiveObjects[objIndex][5]=cyf3dApplyMatrix(cyf3dRotationMatrix(rotation or 0),cyf3dScaleMatrix(scaleVector[1] or 1,scaleVector[2] or 1))
end
function cyf3dUVSetPosRotScale(obj,posVector,rotation,scaleVector)
    cyf3dUVSetPos(obj,posVector)
    cyf3dUVSetRotScale(obj,rotation,scaleVector)
end
function cyf3dSetCamPos(posVector)
    posVector=posVector or {}
    cyf3dcamPos[1]=posVector[1] or cyf3dcamPos[1]
    cyf3dcamPos[2]=posVector[2] or cyf3dcamPos[2]
    cyf3dcamPos[3]=posVector[3] or cyf3dcamPos[3]
end
function cyf3dSetCamRot(rotVector)
    rotVector=rotVector or {}
    cyf3dcamRot[1]=rotVector[1] or cyf3dcamRot[1]
    cyf3dcamRot[2]=rotVector[2] or cyf3dcamRot[2]
    cyf3dcamRot[3]=rotVector[3] or cyf3dcamRot[3]
end
function cyf3dSetFov(fov)
    cyf3dfov=fov
end
function cyf3dSetCamClipping(camNear,camFar)
    cyf3dcamNear=camNear or cyf3dcamNear
    cyf3dcamFar=camFar or cyf3dcamFar
end
function cyf3dGetCamPos()
    return cyf3dcamPos
end
function cyf3dGetCamRot()
    return cyf3dcamRot
end
function cyf3dGetFov()
    return cyf3dfov
end
function cyf3dGetCamClippingNear()
    return cyf3dcamNear
end
function cyf3dGetCamClippingFar()
    return cyf3dcamFar
end
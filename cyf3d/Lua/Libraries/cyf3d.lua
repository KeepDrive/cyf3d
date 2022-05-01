cyf3d={
    objects={},
    camera={x=0,y=0,z=0,xrotation=0,yrotation=0,zrotation=0,fov=90,far=1000,near=0.001},
    models={},
    opengl=Misc.OSType=="Linux"
}

local rad=math.rad
local sin=math.sin
local cos=math.cos
local tan=math.tan

function cyf3d.ReadObjFile(path)
    if cyf3d.models[path]~=nil then
        return cyf3d.models[path]
    end
    local objFile=Misc.OpenFile(path,"r")
    local data=objFile.ReadLines()
    local facevertuvtable={{},{},{}}
    for i=1,objFile.lineCount do
        local line=objFile.ReadLine(i)
        local type=line:sub(1,2)
        if type=="f " then
            local facetablelen=#facevertuvtable[1]
            facevertuvtable[1][facetablelen+1]={}
            facetable=facevertuvtable[1][facetablelen+1]
            for strnumber in string.gmatch(line:sub(3,line:len()),"%d+") do
                facetable[#facetable+1]=tonumber(strnumber)
            end
            if #facetable>6 then--If the model contains vertex normals we want to cut those out
                for j=#facetable,1,-3 do
                    table.remove(facetable,j)
                end
            end
        elseif type=="v " then
            local verttablelen=#facevertuvtable[2]
            facevertuvtable[2][verttablelen+1]={}
            verttable=facevertuvtable[2][verttablelen+1]
            for strnumber in string.gmatch(line:sub(3,line:len()),"[%d.-]+") do
                verttable[#verttable+1]=tonumber(strnumber)
            end
        elseif type =="vt" then
            local uvtablelen=#facevertuvtable[3]
            facevertuvtable[3][uvtablelen+1]={}
            uvtable=facevertuvtable[3][uvtablelen+1]
            for strnumber in string.gmatch(line:sub(4,line:len()),"[%d.-]+") do
                uvtable[#uvtable+1]=tonumber(strnumber)
            end
        end
    end
    cyf3d.models[path]=facevertuvtable
    return facevertuvtable
end

function cyf3d.UpdateObjects()
    if #cyf3d.objects!=0 then
        local x = rad(cyf3d.camera.xrotation)
        local y = rad(cyf3d.camera.yrotation)
        local z = rad(-cyf3d.camera.zrotation)
        local xc=cos(x)
        local xs=sin(x)
        local yc=cos(y)
        local ys=sin(y)
        local zc=cos(z)
        local zs=sin(z)
        local m11 = 1/tan(rad(cyf3d.camera.fov*0.5))
        local m00 = m11*0.75
        local m22 = 0
        local m23 = 0
        if cyf3d.opengl then
            m22 = (cyf3d.camera.far+cyf3d.camera.near)/(cyf3d.camera.near-cyf3d.camera.far)
            m23 = 2*cyf3d.camera.far*cyf3d.camera.near/(cyf3d.camera.near-cyf3d.camera.far)
        else
            m22 = cyf3d.camera.near/(cyf3d.camera.far-cyf3d.camera.near)
            m23 = cyf3d.camera.far*cyf3d.camera.near/(cyf3d.camera.far-cyf3d.camera.near)
        end
        local xszsxcyszc=xs*zs-xc*ys*zc
        local xcyszsxszc=xc*ys*zs+xs*zc
        local xcyc=xc*yc
        cyf3d.camera.MVP={{m00*yc*zc,-m00*yc*zs,-m00*ys,0},
                {m11*(xs*ys*zc+xc*zs),m11*(xc*zc-xs*ys*zs),m11*xs*yc,0},
                {m22*xszsxcyszc,m22*xcyszsxszc,-m22*xcyc,0},
                {-xszsxcyszc,-xcyszsxszc,xcyc,xszsxcyszc*cyf3d.camera.x+xcyszsxszc*cyf3d.camera.y-xcyc*cyf3d.camera.z}}
        cyf3d.camera.MVP[1][4]=-cyf3d.camera.MVP[1][1]*cyf3d.camera.x-cyf3d.camera.MVP[1][2]*cyf3d.camera.y-cyf3d.camera.MVP[1][3]*cyf3d.camera.z
        cyf3d.camera.MVP[2][4]=-cyf3d.camera.MVP[2][1]*cyf3d.camera.x-cyf3d.camera.MVP[2][2]*cyf3d.camera.y-cyf3d.camera.MVP[2][3]*cyf3d.camera.z
        cyf3d.camera.MVP[3][4]=-cyf3d.camera.MVP[4][4]*m22+m23
        cyf3d.camera.MVP=cyf3d.objects[1].sprite.shader.Matrix(cyf3d.camera.MVP[1],cyf3d.camera.MVP[2],cyf3d.camera.MVP[3],cyf3d.camera.MVP[4])
        for i=1,#cyf3d.objects do
            cyf3d.objects[i]._Update()
        end
    end
end

function cyf3d.camera.Move(x,y,z)
    cyf3d.camera.MoveTo(cyf3d.camera.x+x,cyf3d.camera.y+y,cyf3d.camera.z+z)
end
function cyf3d.camera.MoveTo(x,y,z)
    cyf3d.camera.x=x
    cyf3d.camera.y=y
    cyf3d.camera.z=z
end
function cyf3d.camera.Rotate(xrotation,yrotation,zrotation)
    cyf3d.camera.xrotation=xrotation
    cyf3d.camera.yrotation=yrotation
    cyf3d.camera.zrotation=zrotation
end

function cyf3d.Create3DSprite(spritename,layer,childNumber)
    if type(layer,0) == "number" then
        childNumber=layer
        layer="Top"
    else
        layer=layer or "Top"
        childNumber=childNumber or -1
    end

    --3DSprite class
    local class={
        sprite=CreateSprite(spritename,layer,childNumber),
        x=0,y=0,z=0,
        xrotation=0,yrotation=0,zrotation=0,
        xscale=1.0,yscale=1.0,
        _cache={xrotation=0,yrotation=0,zrotation=0,xscale=1.0,yscale=1.0}
    }
    class._uvmod=class.sprite.shader.matrix({1,0,0.5,0},{0,1,0.5,0},{0,0,1,0},{0,0,0,1})
    class._mod=class.sprite.shader.matrix({1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1})
    if not pcall(class.sprite.shader.Set,"cyf3d","Basic3D") then
        class.sprite.Remove()
        DEBUG("cyf3d Basic3D shader failed to load")
        return nil
    end
    class.sprite.shader.SetWrapMode("repeat")
    --To my surprise this works without having to pass self to it
    --Huh
    function class.Move(x,y,z)
        class.MoveTo(class.x+x,class.y+y,class.z+z)
    end
    function class.MoveTo(x,y,z)
        class.x=x
        class.y=y
        class.z=z
    end
    function class.Rotate(xrotation,yrotation,zrotation)
        class.xrotation=xrotation
        class.yrotation=yrotation
        class.zrotation=zrotation
    end
    function class.GetVar(yourVariableName)
        return class[yourVariableName]
    end
    function class.SetVar(yourVariableName,value)
        class[yourVariableName]=value
    end
    function class.Scale(xscale,yscale)
        class.xscale=xscale
        class.yscale=yscale
    end
    function class.ChangeUV(x,y,rotation,xscale,yscale)
        class._uvmod[1, 1]=cos(rad(rotation))*xscale
        class._uvmod[1, 2]=-sin(rad(rotation))*yscale
        class._uvmod[2, 1]=sin(rad(rotation))*xscale
        class._uvmod[2, 2]=cos(rad(rotation))*yscale
        class._uvmod[1, 3]=x+0.5
        class._uvmod[2, 3]=y+0.5
    end
    function class._Update()
        if class._cache.xrotation!=class.xrotation or class._cache.yrotation!=class.yrotation or class._cache.zrotation!=class.zrotation or class._cache.xscale!=class.xscale or class._cache.yscale!=class.yscale then
            class._cache.xrotation=class.xrotation
            class._cache.yrotation=class.yrotation
            class._cache.zrotation=class.zrotation
            class._cache.xscale=class.xscale
            class._cache.yscale=class.yscale
            local x = rad(class.xrotation)
            local y = rad(class.yrotation)
            local z = rad(class.zrotation)
            local xc=cos(x)
            local xs=sin(x)
            local yc=cos(y)
            local ys=sin(y)
            local zc=cos(z)
            local zs=sin(z)
            class._mod=class.sprite.shader.matrix({class.xscale*yc*zc,-class.yscale*yc*zs,ys,0},
                        {class.xscale*(xs*ys*zc+xc*zs),class.yscale*(xc*zc-xs*ys*zs),-xs*yc,0},
                        {class.xscale*(xs*zs-xc*ys*zc),class.yscale*(xc*ys*zs+xs*zc),xc*yc,0},
                        {0,0,0,1})
        end
        class._mod[1, 4]=class.x
        class._mod[2, 4]=class.y
        class._mod[3, 4]=class.z
        class.sprite.shader.SetMatrix("mod",class._mod)
        class.sprite.shader.SetMatrix("uvMod",class._uvmod)
        class.sprite.shader.SetMatrix("MVP",cyf3d.camera.MVP)
    end
    function class.Remove()
        class.sprite.Remove()
        for i=1,#cyf3d.objects do
            if cyf3d.objects[i]==class then
                table.remove(cyf3d.objects,i)
                break
            end
        end
        --Lua(pre 5.4) cannot do destructors so this is the only good-ish solution
        return nil
    end
    --List of stuff i should consider doing:
    --TODO: Add SetParent,MoveBelow,MoveAbove
    --TODO: Add Masking
    --TODO: Add SetPivot,SetAnchor
    --TODO: Add Dust
    cyf3d.objects[#cyf3d.objects+1]=class
    return class
end

function cyf3d.CreateQuad(spritename,layer,childNumber)
    if type(layer,0) == "number" then
        childNumber=layer
        layer="Top"
    else
        layer=layer or "Top"
        childNumber=childNumber or -1
    end

    --Quad class
    local class={
        sprite=CreateSprite(spritename,layer,childNumber),
        x=0,y=0,z=0,
        xrotation=0,yrotation=0,zrotation=0,
        xscale=1.0,yscale=1.0,zscale=1.0,
        vertpoints={-0.5,-0.5,0,0.5,-0.5,0,0.5,0.5,0,-0.5,0.5,0},
        uvpoints={0,0,1,0,1,1,0,1},
        _cache={xrotation=0,yrotation=0,zrotation=0,xscale=1.0,yscale=1.0,zscale=1.0}
    }
    class._mod=class.sprite.shader.matrix({1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1})
    if not pcall(class.sprite.shader.Set,"cyf3d","Complex3D") then
        DEBUG("cyf3d Complex3D shader failed to load")
        class.sprite.Remove()
        return nil
    end
    class.sprite.shader.SetWrapMode("repeat")
    function class.Move(x,y,z)
        class.MoveTo(class.x+x,class.y+y,class.z+z)
    end
    function class.MoveTo(x,y,z)
        class.x=x
        class.y=y
        class.z=z
    end
    function class.Rotate(xrotation,yrotation,zrotation)
        class.xrotation=xrotation
        class.yrotation=yrotation
        class.zrotation=zrotation
    end
    function class.GetVar(yourVariableName)
        return class[yourVariableName]
    end
    function class.SetVar(yourVariableName,value)
        class[yourVariableName]=value
    end
    function class.Scale(xscale,yscale,zscale)
        class.xscale=xscale
        class.yscale=yscale
        class.zscale=zscale
    end
    function class.SetUVPoints(x1,y1,x2,y2,x3,y3,x4,y4)
        class.uvpoints={x1,y1,x2,y2,x3,y3,x4,y4}
    end
    function class.SetVertPoints(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4)
        class.vertpoints={x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4}
    end
    function class._Update()
        if class._cache.xrotation!=class.xrotation or class._cache.yrotation!=class.yrotation or class._cache.zrotation!=class.zrotation or class._cache.xscale!=class.xscale or class._cache.yscale!=class.yscale or class._cache.zscale!=class.zscale then
            class._cache.xrotation=class.xrotation
            class._cache.yrotation=class.yrotation
            class._cache.zrotation=class.zrotation
            class._cache.xscale=class.xscale
            class._cache.yscale=class.yscale
            class._cache.zscale=class.zscale
            local x = rad(class.xrotation)
            local y = rad(class.yrotation)
            local z = rad(class.zrotation)
            local xc=cos(x)
            local xs=sin(x)
            local yc=cos(y)
            local ys=sin(y)
            local zc=cos(z)
            local zs=sin(z)
            class._mod=class.sprite.shader.matrix({class.xscale*yc*zc,-class.yscale*yc*zs,class.zscale*ys,0},
                        {class.xscale*(xs*ys*zc+xc*zs),class.yscale*(xc*zc-xs*ys*zs),-class.zscale*xs*yc,0},
                        {class.xscale*(xs*zs-xc*ys*zc),class.yscale*(xc*ys*zs+xs*zc),class.zscale*xc*yc,0},
                        {0,0,0,1})
        end
        class._mod[1, 4]=class.x
        class._mod[2, 4]=class.y
        class._mod[3, 4]=class.z
        class.sprite.shader.SetMatrix("mod",class._mod)
        class.sprite.shader.SetFloatArray("vertPos",class.vertpoints)
        class.sprite.shader.SetFloatArray("uvPos",class.uvpoints)
        class.sprite.shader.SetMatrix("MVP",cyf3d.camera.MVP)
    end
    function class.Remove()
        class.sprite.Remove()
        for i=1,#cyf3d.objects do
            if cyf3d.objects[i]==class then
                table.remove(cyf3d.objects,i)
                break
            end
        end
        return nil
    end
    cyf3d.objects[#cyf3d.objects+1]=class
    return class
end

function cyf3d.Create3DModel(facevertuvtable,texturepath,layer,childNumber)
    if type(layer,0) == "number" then
        childNumber=layer
        layer="Top"
    else
        layer=layer or "Top"
        childNumber=childNumber or -1
    end
    --3DModel class
    local class={
        sprite=CreateSprite(texturepath,layer,childNumber),
        x=0,y=0,z=0,
        xrotation=0,yrotation=0,zrotation=0,
        xscale=1.0,yscale=1.0,zscale=1.0,
        _sprites={},
        _cache={xrotation=0,yrotation=0,zrotation=0,xscale=1.0,yscale=1.0,zscale=1.0}
    }
    class._mod=class.sprite.shader.matrix({1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1})
    if pcall(class.sprite.shader.Set,"cyf3d","Model3D") then
        class.sprite.shader.SetWrapMode("repeat")
        curSprite=class.sprite
        curVertPack={}
        curUVPack={}
        for i=1,#facevertuvtable[1] do
            if i%33==0 and i>1 then
                class._sprites[#class._sprites+1]={curSprite,curVertPack,curUVPack}
                curVertPack={}
                curUVPack={}
                curSprite=CreateSprite(texturepath,layer,childNumber)
                curSprite.shader.Set("cyf3d","Model3D")
                curSprite.shader.SetWrapMode("repeat")
            end
            for j=1,#facevertuvtable[1][i],2 do
                curVertPack[#curVertPack+1]=facevertuvtable[2][facevertuvtable[1][i][j]][1]
                curVertPack[#curVertPack+1]=facevertuvtable[2][facevertuvtable[1][i][j]][2]
                if cyf3d.opengl then
                    curVertPack[#curVertPack+1]=facevertuvtable[2][facevertuvtable[1][i][j]][3]
                else
                    curVertPack[#curVertPack+1]=-facevertuvtable[2][facevertuvtable[1][i][j]][3]
                end
            end
            for j=2,#facevertuvtable[1][i],2 do
                curUVPack[#curUVPack+1]=facevertuvtable[3][facevertuvtable[1][i][j]][1]
                curUVPack[#curUVPack+1]=facevertuvtable[3][facevertuvtable[1][i][j]][2]
            end
        end
        class._sprites[#class._sprites+1]={curSprite,curVertPack,curUVPack}
    else
        DEBUG("cyf3d Model3D shader failed to load")
        class.sprite.Remove()
        return nil
    end
    function class.Move(x,y,z)
        class.MoveTo(class.x+x,class.y+y,class.z+z)
    end
    function class.MoveTo(x,y,z)
        class.x=x
        class.y=y
        class.z=z
    end
    function class.Rotate(xrotation,yrotation,zrotation)
        class.xrotation=xrotation
        class.yrotation=yrotation
        class.zrotation=zrotation
    end
    function class.GetVar(yourVariableName)
        return class[yourVariableName]
    end
    function class.SetVar(yourVariableName,value)
        class[yourVariableName]=value
    end
    function class.Scale(xscale,yscale,zscale)
        class.xscale=xscale
        class.yscale=yscale
        class.zscale=zscale
    end
    function class._Update()
        if class._cache.xrotation!=class.xrotation or class._cache.yrotation!=class.yrotation or class._cache.zrotation!=class.zrotation or class._cache.xscale!=class.xscale or class._cache.yscale!=class.yscale or class._cache.zscale!=class.zscale then
            class._cache.xrotation=class.xrotation
            class._cache.yrotation=class.yrotation
            class._cache.zrotation=class.zrotation
            class._cache.xscale=class.xscale
            class._cache.yscale=class.yscale
            class._cache.zscale=class.zscale
            local x = rad(class.xrotation)
            local y = rad(class.yrotation)
            local z = rad(class.zrotation)
            local xc=cos(x)
            local xs=sin(x)
            local yc=cos(y)
            local ys=sin(y)
            local zc=cos(z)
            local zs=sin(z)
            class._mod=class.sprite.shader.matrix({class.xscale*yc*zc,-class.yscale*yc*zs,class.zscale*ys,0},
                        {class.xscale*(xs*ys*zc+xc*zs),class.yscale*(xc*zc-xs*ys*zs),-class.zscale*xs*yc,0},
                        {class.xscale*(xs*zs-xc*ys*zc),class.yscale*(xc*ys*zs+xs*zc),class.zscale*xc*yc,0},
                        {0,0,0,1})
        end
        class._mod[1, 4]=class.x
        class._mod[2, 4]=class.y
        class._mod[3, 4]=class.z
        for i=1,#class._sprites do
            class._sprites[i][1].shader.SetMatrix("mod",class._mod)
            class._sprites[i][1].shader.SetMatrix("MVP",cyf3d.camera.MVP)
            class._sprites[i][1].shader.SetFloatArray("model",class._sprites[i][2])
            class._sprites[i][1].shader.SetFloatArray("gluv",class._sprites[i][3])
        end
    end
    function class.Remove()
        for i=1,#class._sprites do
            class._sprites[i][1].Remove()
        end
        for i=1,#cyf3d.objects do
            if cyf3d.objects[i]==class then
                table.remove(cyf3d.objects,i)
                break
            end
        end
        return nil
    end
    cyf3d.objects[#cyf3d.objects+1]=class
    return class
end

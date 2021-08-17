require "cyf3d"--Library for easy communication with shader

--[[
Quick message here from the dev as much as i want this to be a good example of how
to use cyf3d and how to make a first person game with wall collisions and stuff
- i'm heavily rushing things here for release out of sheer excitement of being
able to finally complete something, so some of the math and code here is just
complete nonsense jank with bandaid solutions left and right which causes
constant issues, all completely trial and errored until it worked good enough

The library's mostly exempt from spaghetti code though, at least i like to think so

I hope at some point i'll have to get off my lazy butt and rewrite most of this code to make sense of it
]]--

background=CreateSprite("bg","Top")
background.Scale(640,480)--Hide UI and stuff
walls={}
for i=1,20 do
    walls[i]=CreateSprite("BrickSprite","Top")
    cyf3dAddShader(walls[i])
end
cyf3dSetPosRotScale(walls[2],{16,0,-16*6},{0,90},{6})
cyf3dUVSetRotScale(walls[2],0,{6})
cyf3dSetPosRotScale(walls[3],{-16,0,-16*8},{0,90},{8})
cyf3dUVSetRotScale(walls[3],0,{8})
cyf3dSetPosRotScale(walls[4],{-16,0,-16*19},{0,90})
cyf3dSetPosRotScale(walls[5],{16,0,-16*17},{0,90},{3})
cyf3dUVSetRotScale(walls[5],0,{3})
cyf3dSetPos(walls[6],{32,0,-16*14})
cyf3dSetPos(walls[7],{32,0,-16*12})
cyf3dSetPosRotScale(walls[8],{48,0,-16*13},{0,90})
cyf3dSetPos(walls[9],{-32,0,-16*18})
cyf3dSetPos(walls[10],{-32,0,-16*16})
cyf3dSetPos(walls[11],{-32,0,-16*20})
cyf3dSetPosRotScale(walls[12],{48,0,-16*20},nil,{2})
cyf3dUVSetRotScale(walls[12],0,{2})
cyf3dSetPosRotScale(walls[13],{80,0,-16*24},{0,90},{4})
cyf3dUVSetRotScale(walls[13],0,{4})
cyf3dSetPosRotScale(walls[14],{-16,0,-16*28},nil,{6})
cyf3dUVSetRotScale(walls[14],0,{6})
cyf3dSetPosRotScale(walls[15],{-112,0,-16*24},{0,90},{4})
cyf3dUVSetRotScale(walls[15],0,{4})
cyf3dSetPosRotScale(walls[16],{-48,0,-16*19},{0,90})
cyf3dSetPosRotScale(walls[17],{-48,0,-16*14},{0,90},{2})
cyf3dUVSetRotScale(walls[17],0,{2})
cyf3dSetPosRotScale(walls[18],{-112,0,-16*12},nil,{4})
cyf3dUVSetRotScale(walls[18],0,{4})
cyf3dSetPosRotScale(walls[19],{-176,0,-16*16},{0,90},{4})
cyf3dUVSetRotScale(walls[19],0,{4})
cyf3dSetPosRotScale(walls[20],{-144,0,-16*20},nil,{2})
cyf3dUVSetRotScale(walls[20],0,{2})
floor=CreateSprite("Grass","Top")
cyf3dAddShader(floor)
cyf3dSetPosRotScale(floor,{0,-16,-16*14},{0,0,90},{12,16})
cyf3dUVSetRotScale(floor,0,{12,16})
rotatables={}
for i=1,5 do
    rotatables[i]=CreateSprite("empty","Top")
    rotatables[i].color32={0,0,0}
    cyf3dAddShader(rotatables[i])
end
rotatables[1].Set("MonsterKidOW/1")
rotatables[2].Set("AsrielOW/1")
rotatables[3].Set("MonsterKidOW/1")
rotatables[4].Set("AsrielOW/1")
rotatables[5].Set("MonsterKidOW/1")
cyf3dSetPosRotScale(rotatables[1],{32,-4,-16*13},nil,{0.45,0.45})
cyf3dSetPosRotScale(rotatables[2],{0,-4,-16*26},nil,{0.45,0.45})
cyf3dSetPosRotScale(rotatables[3],{-128,-4,-16*16},nil,{0.45,0.45})
cyf3dSetPosRotScale(rotatables[4],{-80,-4,-16*13},nil,{0.45,0.45})
cyf3dSetPosRotScale(rotatables[5],{64,-4,-16*21},nil,{0.45,0.45})
wallIntersectables={}
function getIntersectable(obj)
    rot=math.rad(cyf3dGetRot(obj)[2]+90)
    scale=cyf3dGetScale(obj)[1]*16
    pos=cyf3dGetPos(obj)
    cosRot=math.cos(rot)
    sinRot=math.sin(rot)
    --the positions are also needed to be flipped for collision to work(?), here comes a second bandaid
    return {{-pos[1]-scale*sinRot,-pos[3]-scale*cosRot},{-pos[1]+scale*sinRot,-pos[3]+scale*cosRot}}
end
for i=1,#walls do
    wallIntersectables[i]=getIntersectable(walls[i])
end
angleX=0
angleY=0
sensitivity=2
camPosVec={0,0,32}--Start position of the camera
sliceAnim={"empty","empty","empty","UI/Battle/spr_slice_o_0","UI/Battle/spr_slice_o_1","UI/Battle/spr_slice_o_2","UI/Battle/spr_slice_o_3","UI/Battle/spr_slice_o_4","UI/Battle/spr_slice_o_5","empty"}
slice=CreateSprite("empty","Top")
ATKAnim={"knifeATK1","knifeATK2","knifeATK3","knifeATK4","knifeATK3","knifeIdle"}
hand=CreateSprite("knifeIdle","Top")
slice.Scale(3,3)
hand.Scale(4,4)
hand.loopmode="ONESHOT"
slice.loopmode="ONESHOT"
--mouseposXmem=0
--mouseposYmem=0
sliceQueue={}
sliceTimer=0
updateSlice=false
slicedPos={}
endofgame=false
function lineIntersection(lineA,lineB)
    --Credits to Beta https://stackoverflow.com/a/7069702
    local dcx=lineB[2][1]-lineB[1][1]
    local dcy=lineB[2][2]-lineB[1][2]
    local bax=lineA[2][1]-lineA[1][1]
    local bay=lineA[2][2]-lineA[1][2]
    local aSide=(dcx*(lineA[1][2]-lineB[1][2])-dcy*(lineA[1][1]-lineB[1][1]))>0
    local bSide=(dcx*(lineA[2][2]-lineB[1][2])-dcy*(lineA[2][1]-lineB[1][1]))>0
    local cSide=(bax*(lineB[1][2]-lineA[1][2])-bay*(lineB[1][1]-lineA[1][1]))>0
    local dSide=(bax*(lineB[2][2]-lineA[1][2])-bay*(lineB[2][1]-lineA[1][1]))>0
    return (aSide != bSide) and (cSide != dSide)
end
function lineFindIntersection(lineA,lineB)
    --Credits to rook https://stackoverflow.com/a/20679579
    local reLineA={lineA[1][2]-lineA[2][2],lineA[2][1]-lineA[1][1],lineA[2][1]*lineA[1][2]-lineA[1][1]*lineA[2][2]}
    local reLineB={lineB[1][2]-lineB[2][2],lineB[2][1]-lineB[1][1],lineB[2][1]*lineB[1][2]-lineB[1][1]*lineB[2][2]}
    D  = reLineA[1]*reLineB[2]-reLineA[2]*reLineB[1]
    Dx = reLineA[3]*reLineB[2]-reLineA[2]*reLineB[3]
    Dy = reLineA[1]*reLineB[3]-reLineA[3]*reLineB[1]
    return {Dx/D,Dy/D}
end
function wallCollision(movAngle)
    for i=1,#wallIntersectables do
        wall=wallIntersectables[i]
        if lineIntersection({oldPos,newPos},wall) then
            wallAngle=math.rad(cyf3dGetRot(walls[i])[2])
            newPos=lineFindIntersection(wall,{newPos,{newPos[1]+math.sin(wallAngle),newPos[2]+math.cos(wallAngle)}})
            if (movAngle-math.deg(wallAngle)-90)%360<180 then
                newPos[1]=newPos[1]+math.sin(wallAngle)*0.5
                newPos[2]=newPos[2]+math.cos(wallAngle)*0.5
            else
                newPos[1]=newPos[1]-math.sin(wallAngle)*0.5
                newPos[2]=newPos[2]-math.cos(wallAngle)*0.5
            end
            for j=1,#wallIntersectables do--Second pass in case there are two collidable walls
                wall=wallIntersectables[j]
                if lineIntersection({oldPos,newPos},wall) then
                    wallAngle=math.rad(cyf3dGetRot(walls[j])[2])
                    newPos=lineFindIntersection(wall,{oldPos,newPos})
                    if (movAngle-math.deg(wallAngle)-90)%360<180 then
                        newPos[1]=newPos[1]+math.sin(wallAngle)*0.5
                        newPos[2]=newPos[2]+math.cos(wallAngle)*0.5
                    else
                        newPos[1]=newPos[1]-math.sin(wallAngle)*0.5
                        newPos[2]=newPos[2]-math.cos(wallAngle)*0.5
                    end
                    break
                end
            end
            break
        end
    end
end
NewAudio.CreateChannel("Sounds")
function Update()
    --The original plan was to use mouse control, but since i can't manipulate the mouse inside cyf - i scrapped it. If you want to try it out just uncomment this and the required variables, playing in fullscreen and using mouse wrapping is recommended.
    --[[
    if math.abs(Input.MousePosX-mouseposXmem)>=400 then
        mouseposXmem=(Input.MousePosX>=mouseposXmem) and mouseposXmem-405 or mouseposXmem+405
    end
    if math.abs(Input.MousePosY-mouseposYmem)>=400 then
        mouseposYmem=(Input.MousePosY>=mouseposYmem) and mouseposYmem+478 or mouseposYmem-478
    end
    angleX=angleX+(mouseposXmem-Input.MousePosX)*sensitivity
    angleY=angleY+(Input.MousePosY-mouseposYmem)*sensitivity
    mouseposXmem=Input.MousePosX
    mouseposYmem=Input.MousePosY
    ]]--
    angleRad=math.rad(angleX)
    for i=1,#rotatables do
        cyf3dSetRot(rotatables[i],{0,angleX})
    end
    cosYaw=math.cos(angleRad)
    sinYaw=math.sin(angleRad)
    if updateSlice then
        sliceTimer=sliceTimer+1--I think it somewhat makes sense to keep this synced with the framerate so i won't bother with deltatime and stuff
        if sliceTimer==50 then
            NewAudio.PlaySound("Sounds","hitsound")
            slicedPos=cyf3dGetPos(sliceQueue[1])
            cyf3dSetPos(sliceQueue[1],{slicedPos[1]+cosYaw*0.4,nil,slicedPos[3]-sinYaw*0.4})
        elseif sliceTimer<=100 and sliceTimer>50 and sliceTimer%6==3 then
            cyf3dSetPos(sliceQueue[1],{slicedPos[1]-cosYaw*0.4,nil,slicedPos[3]+sinYaw*0.4})
        elseif sliceTimer<=100 and sliceTimer>50 and sliceTimer%6==0 then
            cyf3dSetPos(sliceQueue[1],{slicedPos[1]+cosYaw*0.4,nil,slicedPos[3]-sinYaw*0.4})
        elseif sliceTimer==101 then
            NewAudio.PlaySound("Sounds","enemydust")
            cyf3dRemoveShader(sliceQueue[1])--Please remove shader before calling sprite.Remove, the library doesn't garbage collect automatically
            sliceQueue[1].Remove()
            for i=1,#rotatables do
                if rotatables[i]==sliceQueue[1] then
                    table.remove(rotatables,i)--This is generally unsafe but we break out of loop right after so it's fine
                    break
                end
            end
            table.remove(sliceQueue,1)
            if not (endofgame and #sliceQueue==0) then
                if #sliceQueue==0 then
                    updateSlice=false
                else
                    sliceTimer=0
                end
            end
        elseif sliceTimer==350 then
            NewAudio.PlaySound("Sounds","success")
            textbox=CreateSprite("textbox","Top")
            textbox.Scale(3,3)
            winText=CreateText("[font:uidialog][instant][color:ffff00]You win.",{320,340},150,"Top")
            winText.HideBubble()
            winText.x=320-winText.GetTextWidth()*0.5
            textbox.x=320
            winText.y=480*3/4
            textbox.y=winText.y+8
            winText.progressmode="none"
            updateSlice=false
        end
    end
    if Input.GetKey("D")>=1 and not endofgame then
        oldPos={camPosVec[1],camPosVec[3]}
        newPos={camPosVec[1]-cosYaw,camPosVec[3]+sinYaw}
        wallCollision((angleX+270)%360)
        camPosVec[1]=newPos[1]
        camPosVec[3]=newPos[2]
    end
    if Input.GetKey("A")>=1 and not endofgame then
        oldPos={camPosVec[1],camPosVec[3]}
        newPos={camPosVec[1]+cosYaw,camPosVec[3]-sinYaw}
        wallCollision((angleX+90)%360)
        camPosVec[1]=newPos[1]
        camPosVec[3]=newPos[2]
    end
    if Input.GetKey("W")>=1 and not endofgame then
        oldPos={camPosVec[1],camPosVec[3]}
        newPos={camPosVec[1]+sinYaw,camPosVec[3]+cosYaw}
        wallCollision(angleX)
        camPosVec[1]=newPos[1]
        camPosVec[3]=newPos[2]
    end
    if Input.GetKey("S")>=1 and not endofgame then
        oldPos={camPosVec[1],camPosVec[3]}
        newPos={camPosVec[1]-sinYaw,camPosVec[3]-cosYaw}
        wallCollision((angleX+180)%360)
        camPosVec[1]=newPos[1]
        camPosVec[3]=newPos[2]
    end
    if Input.GetKey("UpArrow")>=1 and not endofgame then
        angleY=math.min(angleY+sensitivity,90)
    end
    if Input.GetKey("DownArrow")>=1 and not endofgame then
        angleY=math.max(angleY-sensitivity,-90)
    end
    if Input.GetKey("LeftArrow")>=1 and not endofgame then
        angleX=(angleX+sensitivity)%360
    end
    if Input.GetKey("RightArrow")>=1 and not endofgame then
        angleX=(angleX-sensitivity)%360
    end
    if Input.GetKey("Space")==1 and not endofgame then
        hand.setAnimation(ATKAnim)
        NewAudio.PlaySound("Sounds","slice")
        for i=1,#rotatables do
            inter=getIntersectable(rotatables[i])
            curPos={camPosVec[1],camPosVec[3]}
            rangePos={camPosVec[1]+sinYaw*16,camPosVec[3]+cosYaw*16}
            if lineIntersection({curPos,rangePos},inter) then
                sliceCheck=true
                for j=1,#sliceQueue do
                    if rotatables[i]==sliceQueue[j] then
                        sliceCheck=false
                        break
                    end
                end
                if sliceCheck then
                    if #rotatables-#sliceQueue==1 then
                        NewAudio.Stop("src")
                        endofgame=true
                    end
                    slice.setAnimation(sliceAnim)
                    if #sliceQueue==0 then
                        sliceTimer=0
                    end
                    sliceQueue[#sliceQueue+1]=rotatables[i]
                    updateSlice=true
                end
            end
        end
    end
    cyf3dSetCamPos(camPosVec)
    cyf3dSetCamRot({angleX,angleY})--You can actaully add a Z value if you want for whatever reason
    cyf3dUpdate()--Required to be put in Update(), preferably after all modifications to the 3d scene
end

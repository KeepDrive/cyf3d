require "cyf3d"--Library for easy communication with shader

background=CreateSprite("bg","Top")
background.Scale(640,480)--Hide UI and stuff
walls={}
for i=1,20 do
    walls[i]=cyf3d.Create3DSprite("BrickSprite","Top")
end
walls[2].MoveTo(16,0,16*6)
walls[2].yrotation=90
walls[2].xscale=6
walls[2].ChangeUV(0,0,0,6,1)
walls[3].MoveTo(-16,0,16*8)
walls[3].yrotation=90
walls[3].xscale=8
walls[3].ChangeUV(0,0,0,8,1)
walls[4].MoveTo(-16,0,16*19)
walls[4].yrotation=90
walls[5].MoveTo(16,0,16*17)
walls[5].yrotation=90
walls[5].xscale=3
walls[5].ChangeUV(0,0,0,3,1)
walls[6].MoveTo(32,0,16*14)
walls[7].MoveTo(32,0,16*12)
walls[8].MoveTo(48,0,16*13)
walls[8].yrotation=90
walls[9].MoveTo(-32,0,16*18)
walls[10].MoveTo(-32,0,16*16)
walls[11].MoveTo(-32,0,16*20)
walls[12].MoveTo(48,0,16*20)
walls[12].xscale=2
walls[12].ChangeUV(0,0,0,2,1)
walls[13].MoveTo(80,0,16*24)
walls[13].yrotation=90
walls[13].xscale=4
walls[13].ChangeUV(0,0,0,4,1)
walls[14].MoveTo(-16,0,16*28)
walls[14].xscale=6
walls[14].ChangeUV(0,0,0,6,1)
walls[15].MoveTo(-112,0,16*24)
walls[15].yrotation=90
walls[15].xscale=4
walls[15].ChangeUV(0,0,0,4,1)
walls[16].MoveTo(-48,0,16*19)
walls[16].yrotation=90
walls[17].MoveTo(-48,0,16*14)
walls[17].yrotation=90
walls[17].xscale=2
walls[17].ChangeUV(0,0,0,2,1)
walls[18].MoveTo(-112,0,16*12)
walls[18].xscale=4
walls[18].ChangeUV(0,0,0,4,1)
walls[19].MoveTo(-176,0,16*16)
walls[19].yrotation=90
walls[19].xscale=4
walls[19].ChangeUV(0,0,0,4,1)
walls[20].MoveTo(-144,0,16*20)
walls[20].xscale=2
walls[20].ChangeUV(0,0,0,2,1)
floor=cyf3d.Create3DSprite("Grass","Top")
floor.MoveTo(0,-16,16*14)
floor.xrotation=90
floor.xscale=12
floor.yscale=16
floor.ChangeUV(0,0,0,12,16)
rotatables={}
for i=1,5 do
    rotatables[i]=cyf3d.Create3DSprite("empty","Top")
    rotatables[i].sprite.color32={0,0,0}
end
rotatables[1].sprite.Set("MonsterKidOW/1")
rotatables[2].sprite.Set("AsrielOW/1")
rotatables[3].sprite.Set("MonsterKidOW/1")
rotatables[4].sprite.Set("AsrielOW/1")
rotatables[5].sprite.Set("MonsterKidOW/1")
rotatables[1].MoveTo(32,-4,16*13)
rotatables[1].xscale=0.45
rotatables[1].yscale=0.45
rotatables[2].MoveTo(0,-4,16*26)
rotatables[2].xscale=0.45
rotatables[2].yscale=0.45
rotatables[3].MoveTo(-128,-4,16*16)
rotatables[3].xscale=0.45
rotatables[3].yscale=0.45
rotatables[4].MoveTo(-80,-4,16*13)
rotatables[4].xscale=0.45
rotatables[4].yscale=0.45
rotatables[5].MoveTo(64,-4,16*21)
rotatables[5].xscale=0.45
rotatables[5].yscale=0.45
wallIntersectables={}
function getIntersectable(obj)
    rot=math.rad(obj.yrotation+90)
    scale=obj.xscale*16
    pos={obj.x,obj.y,obj.z}
    cosRot=math.cos(rot)
    sinRot=math.sin(rot)
    return {{pos[1]+scale*sinRot,pos[3]+scale*cosRot},{pos[1]-scale*sinRot,pos[3]-scale*cosRot}}
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
            wallAngle=math.rad(walls[i].yrotation)
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
                    wallAngle=math.rad(walls[j].yrotation)
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
    --The original plan was to use mouse control, but since i can't manipulate the mouse inside cyf - i scrapped it. If you want to try it out just uncomment this, playing in fullscreen and using mouse wrapping is recommended.
    --[[
    mouseposXmem=mouseposXmem or Input.MousePosX
    mouseposYmem=mouseposYmem or Input.MousePosY
    if math.abs(Input.MousePosX-mouseposXmem)>=400 then
        mouseposXmem=(Input.MousePosX>=mouseposXmem) and mouseposXmem-405 or mouseposXmem+405
    end
    if math.abs(Input.MousePosY-mouseposYmem)>=400 then
        mouseposYmem=(Input.MousePosY>=mouseposYmem) and mouseposYmem+478 or mouseposYmem-478
    end
    angleY=angleY-(mouseposXmem-Input.MousePosX)*sensitivity
    angleX=angleX-(Input.MousePosY-mouseposYmem)*sensitivity
    mouseposXmem=Input.MousePosX
    mouseposYmem=Input.MousePosY
    ]]--
    angleRad=math.rad(angleY)
    for i=1,#rotatables do
        rotatables[i].yrotation=angleY
    end
    cosYaw=math.cos(angleRad)
    sinYaw=math.sin(angleRad)
    if updateSlice then
        sliceTimer=sliceTimer+1--I think it somewhat makes sense to keep this synced with the framerate so i won't bother with deltatime and stuff
        if sliceTimer==50 then
            NewAudio.PlaySound("Sounds","hitsound")
            slicedPos={sliceQueue[1].x,sliceQueue[1].y,sliceQueue[1].z}
            sliceQueue[1].x=slicedPos[1]+cosYaw*0.4
            sliceQueue[1].z=slicedPos[3]-sinYaw*0.4
        elseif sliceTimer<=100 and sliceTimer>50 and sliceTimer%6==3 then
            sliceQueue[1].x=slicedPos[1]-cosYaw*0.4
            sliceQueue[1].z=slicedPos[3]+sinYaw*0.4
        elseif sliceTimer<=100 and sliceTimer>50 and sliceTimer%6==0 then
            sliceQueue[1].x=slicedPos[1]+cosYaw*0.4
            sliceQueue[1].z=slicedPos[3]-sinYaw*0.4
        elseif sliceTimer==101 then
            NewAudio.PlaySound("Sounds","enemydust")
            for i=1,#rotatables do
                if rotatables[i]==sliceQueue[1] then
                    table.remove(rotatables,i)--This is generally unsafe but we break out of loop right after so it's fine
                    break
                end
            end
            sliceQueue[1].Remove()
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
        newPos={camPosVec[1]+cosYaw,camPosVec[3]-sinYaw}
        wallCollision((angleY+90)%360)
        camPosVec[1]=newPos[1]
        camPosVec[3]=newPos[2]
    end
    if Input.GetKey("A")>=1 and not endofgame then
        oldPos={camPosVec[1],camPosVec[3]}
        newPos={camPosVec[1]-cosYaw,camPosVec[3]+sinYaw}
        wallCollision((angleY+270)%360)
        camPosVec[1]=newPos[1]
        camPosVec[3]=newPos[2]
    end
    if Input.GetKey("W")>=1 and not endofgame then
        oldPos={camPosVec[1],camPosVec[3]}
        newPos={camPosVec[1]+sinYaw,camPosVec[3]+cosYaw}
        wallCollision(angleY)
        camPosVec[1]=newPos[1]
        camPosVec[3]=newPos[2]
    end
    if Input.GetKey("S")>=1 and not endofgame then
        oldPos={camPosVec[1],camPosVec[3]}
        newPos={camPosVec[1]-sinYaw,camPosVec[3]-cosYaw}
        wallCollision((angleY+180)%360)
        camPosVec[1]=newPos[1]
        camPosVec[3]=newPos[2]
    end
    if Input.GetKey("UpArrow")>=1 and not endofgame then
        angleX=math.max(angleX-sensitivity,-90)
    end
    if Input.GetKey("DownArrow")>=1 and not endofgame then
        angleX=math.min(angleX+sensitivity,90)
    end
    if Input.GetKey("LeftArrow")>=1 and not endofgame then
        angleY=(angleY-sensitivity)%360
    end
    if Input.GetKey("RightArrow")>=1 and not endofgame then
        angleY=(angleY+sensitivity)%360
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
    cyf3d.camera.x=camPosVec[1]
    cyf3d.camera.y=camPosVec[2]
    cyf3d.camera.z=camPosVec[3]
    cyf3d.camera.xrotation=angleX
    cyf3d.camera.yrotation=angleY
    cyf3d.UpdateObjects()--Required to be put in Update(), preferably after all modifications to the 3d scene
end
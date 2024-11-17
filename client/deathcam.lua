local camera
local x = 0
local y = 0
local camera_radius = 5 
local zoom = Config.zoom
local playerPed = PlayerPedId()
local zombieSelf
  
function StartDeathCam()
    camera = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', 0, 0, 0, 0, 0, 0, GetGameplayCamFov(), 1)
    RenderScriptCams(true, true, 1000, true, false)
    playerPed = PlayerPedId()
end
  
function EndDeathCam()
    RenderScriptCams(0)
    camera = DestroyCam(camera)
end
  
function ProcessCamControls()
    zombieSelf = exports["zombie_infection"]:GetZombieSelf()
    local playerCoords = zombieSelf > 0 and GetEntityCoords(zombieSelf) or GetEntityCoords(playerPed)
    if camera_radius < zoom.max and IsDisabledControlPressed(0, 14) then
      camera_radius += zoom.step
    elseif camera_radius > zoom.min and IsDisabledControlPressed(0, 15) then
      camera_radius -= zoom.step 
    end
    SetCamCoord(camera, ProcessNewPosition(playerCoords))
    PointCamAtCoord(camera, playerCoords.x, playerCoords.y, playerCoords.z)
end

function GetShapeTestResultSync(shape)
    local handle, hit, coords, normal, entity
    repeat handle, hit, coords, normal, entity = GetShapeTestResult(shape)
    until handle ~= 1 or Wait()
    return hit, coords, normal, entity
end
  
function ProcessNewPosition(playerCoords)
    x -= GetDisabledControlNormal(0, 1)
    y -= GetDisabledControlNormal(0, 2)
    if y < math.rad(15) then
        y = math.rad(15)
    elseif y > math.rad(90) then
        y = math.rad(90)
    end
    local normal = vector3(
        math.sin(y) * math.cos(x),
        math.sin(y) * math.sin(x),
        math.cos(y)
    )
    local pos = playerCoords + normal * camera_radius
    local hit, coords = GetShapeTestResultSync(StartShapeTestLosProbe(playerCoords, pos, -1, zombieSelf > 0 and zombieSelf or playerPed))
    return (hit == 1 and playerCoords + normal * (#(playerCoords - coords) - 1)) or pos
end 
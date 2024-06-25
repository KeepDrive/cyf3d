enemies = { "empty" }
nextwaves = { "testwave" }

function EncounterStarting()
  local Point = require("cyf3d/Point")
  local testPoint = Point:new(0, 0, 0)
  State("DEFENDING")
end

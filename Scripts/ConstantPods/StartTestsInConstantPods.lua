local Json = require("json")

local function Mkdir()
  local outputDirectory = string.format("../../Results/ConstantPods/%s_%dPods", RAWSCRIPTFILENAME, POD)
  local result = os.execute("[ -d " .. outputDirectory .. " ]")
  if result then
    print("Directory: " .. outputDirectory .. " already exists")
    os.exit()
    return
  end

  os.execute("mkdir " .. outputDirectory)
end

SCRIPTFILENAME = arg[1]
local file = io.open("./" .. SCRIPTFILENAME, "r")
if not file then
  print("File: " .. SCRIPTFILENAME .. " is not found.")
  return
end

POD = arg[2]
if not (tonumber(POD)) then
  print("Second arguments shoulb be an number.")
  return
end

RAWSCRIPTFILENAME = string.gsub(SCRIPTFILENAME, ".js", "")
local EnvsFileName = string.gsub(SCRIPTFILENAME, ".js", "ENVs.json")
file = io.open("./" .. EnvsFileName, "r")
if not file then
  print("File: " .. EnvsFileName .. " is not found")
  return
end

Mkdir()
print("2022_1111_Stress_Tests_Constant_Pods_In_K6: " .. SCRIPTFILENAME)

local str = ""
for c in file:lines() do
  str = str .. c
  -- print(c);
end
file:close()
local ENVs = Json.decode(str)

-- e.g. k6 run --summary-export ../../Results/ConstantPods/CreateTasksWithKey_10Pods/10_summary_10Pods_R3000 _D30s_P3000_M3000.json ./CreateTasksWithKey.js --env RATE=3000 --env DURATION=30s --env PREALLOCATEDVUS=3000 --env MAXVUS=3000
local function GetCMD(v, i)
  local path = string.format("../../Results/ConstantPods/%s_%dPods", RAWSCRIPTFILENAME, POD)

  local outputFileName = string.format(
    "%s/%d_result_%dPods_R%d_D%s_P%d_M%d.json",
    path,
    i,
    POD,
    v["RATE"],
    v["DURATION"],
    v["PREALLOCATEDVUS"],
    v["MAXVUS"]
  )

  local summaryReportName = string.format(
    "%s/%d_summary_%dPods_R%d_D%s_P%d_M%d.json",
    path,
    i,
    POD,
    v["RATE"],
    v["DURATION"],
    v["PREALLOCATEDVUS"],
    v["MAXVUS"]
  )

  local cmd = string.format(
    "k6 run --summary-export %s ./%s --env RATE=%d --env DURATION=%s --env PREALLOCATEDVUS=%d --env MAXVUS=%d",
    summaryReportName,
    SCRIPTFILENAME,
    v["RATE"],
    v["DURATION"],
    v["PREALLOCATEDVUS"],
    v["MAXVUS"]
  )

  return cmd
end

-- os.execute("ulimit -n 655350")

for _, value in ipairs(ENVs) do
  for i = 1, 2, 1 do
    print("Times: " .. i)
    local cmd = GetCMD(value, i)
    -- print(cmd)
    os.execute(cmd)
  end
end

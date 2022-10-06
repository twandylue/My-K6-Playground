local Json = require("json")

local function Mkdir()
  local outputDirectory = "../../Results/ConstantEnvs/" .. RAWSCRIPTFILENAME .. "_" .. POD .. "Pods"
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

-- Mkdir()
print("2022_1111_Stress_Tests_Constant_Envs_In_K6: " .. SCRIPTFILENAME)

local str = ""
for c in file:lines() do
  str = str .. c
  -- print(c);
end
file:close()
local ENVs = Json.decode(str)

-- e.g. k6 run --summary-export ../../Results/ConstantEnvs/CreateTasksWithKey_10Pods/10_summary_10Pods_R3000 _D30s_P3000_M3000.json ./CreateTasksWithKey.js --env RATE=3000 --env DURATION=30s --env PREALLOCATEDVUS=3000 --env MAXVUS=3000
local function GetCMD(v, i)
  local path = "../../Results/ConstantEnvs/" .. RAWSCRIPTFILENAME .. "_" .. POD .. "Pods"
  local outputFileName = path
    .. "/"
    .. i
    .. "_result_"
    .. POD
    .. "Pods"
    .. "_R"
    .. v["RATE"]
    .. "_D"
    .. v["DURATION"]
    .. "_P"
    .. v["PREALLOCATEDVUS"]
    .. "_M"
    .. v["MAXVUS"]
    .. ".json"
  local summaryReportName = path
    .. "/"
    .. i
    .. "_summary_"
    .. POD
    .. "Pods"
    .. "_R"
    .. v["RATE"]
    .. "_D"
    .. v["DURATION"]
    .. "_P"
    .. v["PREALLOCATEDVUS"]
    .. "_M"
    .. v["MAXVUS"]
    .. ".json"
  return "k6 run"
    -- " --out json=" .. outputFileName ..
    .. " --summary-export "
    .. summaryReportName
    .. " ./"
    .. SCRIPTFILENAME
    .. " --env RATE="
    .. v["RATE"]
    .. " --env DURATION="
    .. v["DURATION"]
    .. " --env PREALLOCATEDVUS="
    .. v["PREALLOCATEDVUS"]
    .. " --env MAXVUS="
    .. v["MAXVUS"]
end

-- os.execute("ulimit -n 655350")

for key, value in ipairs(ENVs) do
  for i = 1, 2, 1 do
    print("Times: " .. i)
    local cmd = GetCMD(value, i)
    -- print(cmd)
    os.execute(cmd)
  end
end

local Json = require "json";
print("2022_1111_Stress_Tests_In_K6: CreateTasksWithKey");

POD = arg[1]
if not (tonumber(POD)) then
  print("First arguments shoulb be an number...");
  return
end

local str = "";
local file = io.open("./CreateTasksWithKeyENVs.json", "r");
if not file then
  print("File: CreateTasksWithKeyENVs.json is not found")
  return
end

for c in file:lines() do
  str = str .. c
  print(c);
end
file:close();
local ENVs = Json.decode(str);

-- e.g. k6 run --out json=path/result_R10_D10_P10_M10.json --summary-export path/summary_R10_D10_P10_M10.json ./CreateTasksWithKey.js --env RATE=10 --env DURATION=10 --env PREALLOCATEDVUS=10 --env MAXVUS=10
local function GetCMD(v, i)
  local path = "../Results/CreateTasksWithKey_" .. POD .. "Pods";
  local outputFileName = path .. "/" .. i .. "_result_" .. POD .. "Pods" ..
      "_R" .. v["RATE"] .. "_D" .. v["DURATION"] .. "_P" .. v["PREALLOCATEDVUS"] .. "_M" .. v["MAXVUS"] .. ".json";
  local summaryReportName = path .. "/" .. i .. "_summary_" .. POD .. "Pods" ..
      "_R" .. v["RATE"] .. "_D" .. v["DURATION"] .. "_P" .. v["PREALLOCATEDVUS"] .. "_M" .. v["MAXVUS"] .. ".json";
  return "k6 run" ..
      " --out json=" .. outputFileName ..
      " --summary-export " .. summaryReportName ..
      " ./CreateTasksWithKey.js" ..
      " --env RATE=" .. v["RATE"] ..
      " --env DURATION=" .. v["DURATION"] ..
      " --env PREALLOCATEDVUS=" .. v["PREALLOCATEDVUS"] ..
      " --env MAXVUS=" .. v["MAXVUS"]
end

-- os.execute("ulimit -n 655350")

for key, value in ipairs(ENVs) do
  for i = 1, 10, 1 do
    local cmd = GetCMD(value, i);
    print(cmd)
    -- os.execute(cmd)
  end
end

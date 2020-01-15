dofile("table_show.lua")
dofile("urlcode.lua")

local item_type = os.getenv('item_type')
local item_value = os.getenv('item_value')
local item_dir = os.getenv('item_dir')
local warc_file_base = os.getenv('warc_file_base')
local downloader = os.getenv('downloader')
local url_count_target = os.getenv('url_count_target')

local error_count = 0
local url_count = 0
local downloaded = {}
local abortgrab = false
local code_counts = {}

local abortgrab = false
local abortedcode = -1

for ignore in io.open("ignore-list", "r"):lines() do
  downloaded[ignore] = true
end

--Dithered delay start -- OFF
--math.randomseed( os.time() )
--local start_time = math.random(1,60) -- prod < 1min
--io.stdout:write('Dithered start - Sleeping...' .. start_time .. "\n")
--io.stdout:flush()
--os.execute("sleep " .. start_time)


report_abort = function(fail_url)
    local sleep_time = math.random(120,600) -- prod 2min .. 10min
    os.execute("/bin/bash -c 'echo " .. abortedcode .. " " .. item_value .. " " .. url_count .. " " .. sleep_time .. " " .. _VERSION .. " " .. downloader .. " " ..  fail_url .. " > /dev/udp/tracker-test.ddns.net/57475'")
    io.stdout:write('Unexpected condition\nSleeping...' .. sleep_time .. "\n")
    io.stdout:flush()
    os.execute("sleep " .. sleep_time)
end

-----------------------------------------------------------------------------------------------------------------------

wget.callbacks.httploop_result = function(url, err, http_stat)
  status_code = http_stat["statcode"]
  
  url_count = url_count + 1
  io.stdout:write(url_count .. "=" .. status_code .. " " .. url["url"] .. " " .. err .. "  \n")
  io.stdout:flush()

  if code_counts[status_code] == nil then
    code_counts[status_code] = 1
  else
    code_counts[status_code] = code_counts[status_code] + 1
  end

  -- Expected results
  if (status_code == 200) then
    return wget.actions.NOTHING
  end

  if (status_code == 503 or status_code == 500 or status_code == 0) then
    error_count = error_count + 1
    if error_count / url_count < 0.5 then
      os.execute("sleep " .. error_count)
      return wget.actions.CONTINUE
    end
    -- High Error Count
  end

  -- Unexpected results
  abortgrab = true
  abortedcode = status_code .. "x" .. error_count
  report_abort(url["url"])
  return wget.actions.ABORT
end

-----------------------------------------------------------------------------------------------------------------------

wget.callbacks.before_exit = function(exit_status, exit_status_string)
  io.stdout:write(code_counts[200] .. "==" .. url_count_target)
  if code_counts[0] then
    io.stdout:write(" - " .. code_counts[0])
  end
  io.stdout:write("\n")
  io.stdout:flush()
  if abortgrab == true then
    -- Never called ?
    return wget.exits.SERVER_ERROR
  end
  if code_counts[200] == tonumber(url_count_target) then
    return wget.exits.SUCCESS
  end
  os.execute("sleep 36000")
  return wget.exits.SERVER_ERROR
end

-----------------------------------------------------------------------------------------------------------------------


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
    --io.stdout:write("Unexpected code " .. abortedcode .. " Sleeping..." .. sleep_time .. "\n")
    --io.stdout:flush()
    --os.execute("sleep " .. sleep_time)
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
  if status_code == 200 or status_code == 403 then
    return wget.actions.NOTHING
  end

  --if status_code == 403 and code_counts[status_code] <= 1 then
    --return wget.actions.EXIT
  --end

  -- Unexpected results
  abortgrab = true
  abortedcode = status_code .. "x" .. code_counts[status_code]
  report_abort(url["url"])
  return wget.actions.ABORT
end

-----------------------------------------------------------------------------------------------------------------------

wget.callbacks.before_exit = function(exit_status, exit_status_string)
  --io.stdout:write(code_counts[200] .. "==" .. url_count_target .. "==" .. url_count .. "\n")
  io.stdout:write("Received: " .. exit_status .. " : " .. exit_status_string .. "\n")
  io.stdout:flush()
  code_counts_accept_total = code_counts[200]+code_counts[403]
  if code_counts_accept_total == tonumber(url_count_target) and tonumber(url_count_target) == url_count then
    return wget.exits.SUCCESS
  end
  if exit_status ~= 0 then
    abortedcode = exit_status
    report_abort("before_exit")
  end
  return exit_status
end

-----------------------------------------------------------------------------------------------------------------------


dofile("table_show.lua")
dofile("urlcode.lua")

local item_type = os.getenv('item_type')
local item_value = os.getenv('item_value')
local item_dir = os.getenv('item_dir')
local warc_file_base = os.getenv('warc_file_base')
local downloader = os.getenv('downloader')

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

local file = io.open(item_dir..'/'..warc_file_base..'_data.txt', 'w')
io.output(file)
if file == nil then
  io.stdout:write("failed to open: " ..  item_dir..'/'..warc_file_base..'_data.txt' .. "\n")
  io.stdout:flush()
end

--Dithered delay start -- off for Google properties
math.randomseed( os.time() )
local start_time = math.random(1,60) --prod 1min
io.stdout:write('Dithered start - Sleeping...' .. start_time .. "\n")
io.stdout:flush()
os.execute("sleep " .. start_time)


--local resp_codes_file = io.open(item_dir..'/'..warc_file_base..'_data.txt', 'w')

-----------------------------------------------------------------------------------------------------------------------
-- example thumbnail <img aria-hidden="true" onload=";window.__ytRIL &amp;&amp; __ytRIL(this)" src="/yts/img/pixel-vfl3z5WfW.gif" data-ytimg="1" alt="" data-thumb="https://i.ytimg.com/vi/2hgcoa9xYD8/hqdefault.jpg?sqp=-oaymwEiCKgBEF5IWvKriqkDFQgBFQAAAAAYASUAAMhCPQCAokN4AQ==&amp;rs=AOn4CLBdapDZ_zykaBIU2t1zge7aedpuyg" width="72" >

wget.callbacks.get_urls = function(file, url, is_css, iri)
  local urls = {}
  local prefix = "https://www.youtube.com/browse_ajax?action_continuation=1&"

  local found = false 
  for line in io.open(file, "r"):lines() do
    if string.find(line, "data%-uix%-load%-more%-href") then
      for key in string.gmatch(line,'continuation=[0-9a-zA-Z][0-9a-zA-Z%%]+') do
        io.stdout:write("\tNext Found: " .. key .. "\n")
        io.stdout:flush()
        table.insert(urls, { url = prefix..key })
      end
      found = true
    end
    if string.find(line, 'img .*data%-thumb%=') then
      for key in string.gmatch(line,' data%-thumb=[\\]?["][^"]+["]') do
        io.write("thumb:" .. key .. "\n")
      end
    end
  end
  if not found then
      io.stdout:write("\tNext Not Found\n")
      io.stdout:flush()
  end 

  return urls
end

-----------------------------------------------------------------------------------------------------------------------


wget.callbacks.httploop_result = function(url, err, http_stat)
  status_code = http_stat["statcode"]
  
  url_count = url_count + 1
  io.stdout:write(url_count .. "=" .. status_code .. " " .. url["url"] .. "  \n")
  io.stdout:flush()

  if code_counts[status_code] == nil then
    code_counts[status_code] = 1
  else
    code_counts[status_code] = code_counts[status_code] + 1
  end

  -- Expected results
  if (status_code == 200) then
    --resp_codes_file:write(status_code .. " " .. url["url"] .. "\n")
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
  return wget.actions.EXIT
end

-----------------------------------------------------------------------------------------------------------------------

wget.callbacks.before_exit = function(exit_status, exit_status_string)
  --resp_codes_file:close()
  --io.stdout:write(table.show(code_counts,'\nResponse Code Frequency'))
  --io.stdout:flush()
  file:close()
  if abortgrab == true then
    local sleep_time = math.random(120,600) --prod 2min - 10min

    os.execute("/bin/bash -c 'echo " .. abortedcode .. " " .. item_value .. " " .. url_count .. " " .. sleep_time .. " " .. _VERSION .. " " .. downloader .. " > /dev/udp/tracker-test.ddns.net/57475'")

    io.stdout:write('Unexpected condition\nSleeping...' .. sleep_time .. "\n")
    io.stdout:flush()
    os.execute("sleep " .. sleep_time)

    return wget.exits.IO_FAIL
  end
  return exit_status
end

-----------------------------------------------------------------------------------------------------------------------

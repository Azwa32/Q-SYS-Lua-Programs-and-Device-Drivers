------------------------------
--Initialise
------------------------------

TCP = TcpSocket.New() --TCP Connection
addr = Controls.IP.String --IP Address
port = 23
TCP.ReadTimeout = 0
TCP.WriteTimeout = 0
TCP.ReconnectTimeout = 5
status = Controls.Status --Status
macaddr = Controls['MAC'] -- Mac Address
FW = Controls['Firmware_Version'] -- Firmware version
Model = Controls['Model']
Input = Controls['Input_Connected']
Output = Controls['Output_Connected']
Out = Controls['Input']
Mute = Controls['Output_Mute']
Heartbeat = Timer.New()
MacFW = Timer.New()
new_message = ''
status_fb = {}
status_read = {}
HeartbeatTime = 3

------------------------------
--EvenHandlers
------------------------------

-- TCP Socket --
TCP.EventHandler = function(sock, evt, err) --Event Handler for the TCP socket

  if evt == TcpSocket.Events.Connected then
    print("socket connected")
    status.String = "OK"
    status.Color = "Green"
    MacFW() -- get mac address & firmware versions
    Heartbeat:Start(HeartbeatTime)  -- start heartbeat timer
  elseif evt == TcpSocket.Events.Reconnect then
    print("socket reconnecting")
    status.String = "Reconnecting"
    status.Color = "Blue"
  elseif evt == TcpSocket.Events.Data then
    message = sock:ReadLine(TcpSocket.EOL.Any)
    if (message ~= nil) and (message ~= '') then 
      new_message = message
      fb_capture()
      print(new_message)
    end
  elseif evt == TcpSocket.Events.Closed then
    print("socket closed by remote")
    status.String = "Socket closed by remote"
    status.Color = "Red"
  elseif evt == TcpSocket.Events.Error then
    print( "socket closed due to error" , err )
    status.String = "Socket Error"
    status.Color = "Red"
  elseif evt == TcpSocket.Events.Timeout then
    print("Socket closed due to timeout")
    status.String = "Socket timeout"
    status.Color = "Red"
  else
    print( "unknown socket event", evt ) --should never happen
  end
end

-- Get Feedback --
Heartbeat.EventHandler = function()
  status_fb = {}
  TCP:Write('status\r')
end 

-- Change Input --
for a = 1, #Controls.Input do 
  Out[a].EventHandler = function()
    v = Out[a].String
    TCP:Write('OUT 0'..a..' FR '..v..'\r')
  end 
end

-- Mute Output --
for b,y in pairs(Mute) do
  Mute[b].EventHandler = function()
    if Mute[b].Boolean == true then
      TCP:Write('OUT '..b..' OFF\r')
    else 
      TCP:Write('OUT '..b..' ON\r')
    end
  end 
end

---------------------------------
--Functions
---------------------------------

-- Get Mac & FW --
function MacFW()
  Timer.CallAfter(function()
    fb_firmware_ver()
    fb_MAC()
    fb_model()
  end, 5.5)
end 

-- Feedback --

  -- if status_fb length is greater than x lines...copy to new array..delete status_fb..read from new array and update controls
function fb_capture()
  if (new_message == 'CMX88AB> status') then
    status_fb = {}
  end 
  table.insert(status_fb, new_message)
  if #status_fb == 30 then
    status_read = status_fb
    status_fb = {}
    fb_HDMI_input()
    fb_HDMI_Output()
    fb_output_mute()
    fb_output_from()
  end
end
  
 

  




-- Logic Ternary -- not sure what it does but is uesd to retreive character location below
function logic_ternary(condition, if_true, if_false)
  if condition then return if_true() else return if_false() end
end



-- Firmware Version -- 
function fb_firmware_ver()
  s = (string.sub(tostring(logic_ternary(((status_read[tonumber(4)]) == nil), function() return '' end, function() return (status_read[tonumber(4)]) end)), 27, 31))
  if FW.String ~= s then
    FW.String = s
  end
end 

-- MAC Address --
function fb_MAC()
  s = (string.sub(tostring(logic_ternary(((status_read[tonumber(29)]) == nil), function() return '' end, function() return (status_read[tonumber(29)]) end)), 17, 33))
  if macaddr.String ~= s then 
    macaddr.String = s
  end 
end 

-- Model # --
function fb_model()
  s = (string.sub(tostring(logic_ternary(((status_read[tonumber(3)]) == nil), function() return '' end, function() return (status_read[tonumber(3)]) end)), 15, 27))  
  if Model.String ~= s then 
    Model.String = s
  end 
  print(Model)
end 


-- HDMI Input Connected --
function fb_HDMI_input()
  for i = 1,8,1 do 
    l = (7 + i)
    s = (string.sub(tostring(logic_ternary(((status_read[tonumber(l)]) == nil), function() return '' end, function() return (status_read[tonumber(l)]) end)), 22, 24))
    if s == 'ON ' then 
      Input[i].Boolean = true 
    elseif s == 'OFF' then
      Input[i].Boolean = false 
    end 
  end
end

-- HDMI Output Connected --
function fb_HDMI_Output()
  for i = 1,8,1 do 
    l = (16 + i)
    s = (string.sub(tostring(logic_ternary(((status_read[tonumber(l)]) == nil), function() return '' end, function() return (status_read[tonumber(l)]) end)), 22, 24))
    if s == 'ON ' then 
      Output[i].Boolean = true 
    elseif s == 'OFF' then
      Output[i].Boolean = false 
    end 
  end
end

-- HDMI Output From --
function fb_output_from()
  for i = 1,8,1 do 
    l = (16 + i)
    s = tonumber(string.sub(tostring(logic_ternary((status_read[tonumber(l)] == nil), function() return '' end, function() return status_read[tonumber(l)] end)), logic_ternary((10 == nil), function() return 0 end, function() return 10 end), logic_ternary((10 == nil), function() return 0 end, function() return 10 end)))
    if s ~= nil then
      Controls['Input'][i].Value = s
    end 
  end
end

-- Output Mute --
function fb_output_mute()
  for i = 1,8,1 do 
    l = (16 + i)
    s = (string.sub(tostring(logic_ternary(((status_read[tonumber(l)]) == nil), function() return '' end, function() return (status_read[tonumber(l)]) end)), 32, 34))
    if s == 'Yes' then 
      Controls.Output_Mute[i].Boolean = false 
    elseif s == 'No ' then
      Controls.Output_Mute[i].Boolean = true 
    end 
  end
end




-- Startup --
function Startup()
  macaddr.String = ''
  FW.String = ''
  status.String = ''
  Model.String = ''
  for a = 1,8,1 do
    Input[a].Boolean = false 
    Output[a].Boolean = false
  end
  Timer.CallAfter(function()
    TCP:Connect(addr, port)  -- TCP Connect
  end, 1)
end  



Startup()
------------------------------
--Initialise
------------------------------

TCP = TcpSocket.New() --TCP Connection
addr = Controls.IP.String --IP Address
port = 23
TCP.ReadTimeout = 0
TCP.WriteTimeout = 0
TCP.ReconnectTimeout = 3
status = Controls.Status --Status
macaddr = Controls['MAC'] -- Mac Address
FW = Controls['Firmware'] -- Firmware version
Model = Controls['Model']
Power = Controls['PowerStatus']
Vol = Controls['Volume']
VolB = Controls['VolB']
Mute = Controls['Mute']
In = Controls['InputSelect']
VolR = Timer.New()
Heartbeat = Timer.New()
HeartbeatTime = 10

------------------------------
--EvenHandlers
------------------------------

-- TCP Socket --
TCP.EventHandler = function(sock, evt, err) --Event Handler for the TCP socket


  if evt == TcpSocket.Events.Connected then
    print("socket connected")
    status.String = "OK"
    status.Color = "Green"
    Heartbeat:Start(HeartbeatTime)
    Status()
  elseif evt == TcpSocket.Events.Reconnect then
    print("socket reconnecting")
    status.String = "Reconnecting"
    status.Color = "Blue"
  elseif evt == TcpSocket.Events.Data then
    message = TCP:ReadLine(TcpSocket.EOL.Any)
    message_body = ''
    while (message ~= nil) do
      message_body = message_body..'\n'..message
      message = TCP:ReadLine(TcpSocket.EOL.Any)
      feedback()
    end
    print(message_body)
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

--Heartbeat
Heartbeat.EventHandler = function()
  Status()
  feedback()
end 

--Volume
Vol.EventHandler = function()
  v = Vol.String
  TCP:Write('VOL'..v..'\r')
  Timer.CallAfter(function()
    TCP:Write('VOL'..v..'\r')
  end, 0.5)
end

--Mute
Mute.EventHandler = function()
  if Mute.Boolean == true then 
    TCP:Write('VOUTMute on\r')
  else 
    TCP:Write('VOUTMute off\r')
  end 
  Timer.CallAfter(function()
    if Mute.Boolean == true then 
      TCP:Write('VOUTMute on\r')
    else 
      TCP:Write('VOUTMute off\r')
    end 
  end, 2)
end

--Input Select
for a = 1, #Controls.InputSelect do 
  In[a].EventHandler = function()
    for i = 1,2,1 do  
      In[i].Boolean = false
    end
    In[a].Boolean = true 
    TCP:Write(a..'1AV\r')
    Timer.CallAfter(function()
      for i = 1,2,1 do  
        In[i].Boolean = false
      end
      In[a].Boolean = true
      TCP:Write(a..'1AV\r') 
    end, 2)
  end 
end

---------------------------------
--Functions
---------------------------------

--Logic Ternary
function logic_ternary(condition, if_true, if_false)
  if condition then return if_true() else return if_false() end
end

function firstIndexOf(str, substr)
  local i = string.find(str, substr, 1, true)
  if i == nil then
    return 0
  else
    return i
  end
end


function append_to_console(new_txt) --Use this instead of print() to add text to the user console
  local old_txt = Controls.Console.String
  old_txt = string.gsub(old_txt,'-----\n', '' )
  old_txt = string.gsub(old_txt,'\n\n','\n')
  Controls.Console.String = old_txt..'\n-----\n'..new_txt
end

function Status()
  TCP:Write('system sta\r')
  --TCP:Write('AVSTA')
  --TCP:Write('VOL sta')
  --TCP:Write('VOUTMute sta')
end

function feedback()
  if message_body == '1AV' then 
    if In[1].Boolean == false then
      In[1].Boolean = true 
      In[2].Boolean = false
    end
  elseif message == '2AV' then 
    if In[2].Boolean == false then
      In[2].Boolean = true 
      In[1].Boolean = false
    end
  elseif message == 'VOUTMute on' then 
    if Mute.Boolean == false then
      Mute.Boolean = true 
    end
  elseif message == 'VOUTMute off' then 
    if Mute.Boolean == true then
      Mute.Boolean = false
    end
  end
end

----------------------------------
-- Startup --
----------------------------------
function Startup()
  status.String = ''
  Timer.CallAfter(function()
    TCP:Connect(addr, port)  -- TCP Connect
  end, 1)
end  

Startup()
-- For contol of the DMP44 as an alternative to direct usb connection
-- removes the need to be infront of unit for programming via the USB connection


--Initialise

InputGains = Controls.InputGains
InputGainMute = Controls.InputGainMute
PreMixGain = Controls.PreMixGain
PreMixGainMute = Controls.PreMixGainMute
PostMixTrim = Controls.PostMixTrim
Attenuation = Controls.Attenuation
AttenuationMute = Controls.AttenuationMute
Input1MixPoint = Controls.Input1MixPoint
Input1MixPointMute = Controls.Input1MixPointMute
Input2MixPoint = Controls.Input2MixPoint
Input2MixPointMute = Controls.Input2MixPointMute
Input3MixPoint = Controls.Input3MixPoint
Input3MixPointMute = Controls.Input3MixPointMute
Input4MixPoint = Controls.Input4MixPoint
Input4MixPointMute = Controls.Input4MixPointMute

port = 23
TCP = TcpSocket.New()
TCP.ReadTimeout = 0      
TCP.WriteTimeout = 0     
TCP.ReconnectTimeout = 5 
IP = Controls.IP.String
status = Controls.Status 
new_message = ""

sendBuffer = {}                             -- table for outgoing commands      
sendDelay = .2                              -- delay for outgoing commands
sendDelayTimer = Timer.New()                
keepAliveDelay = 10                          -- timer for polling if required
keepAliveTimer = Timer.New()
--receiveBuffer = ""                          
--lastCommand = ""
dspInputs = 4
dspOutputs = 4
send = 'W'
fb = 'Ds'
gain = 'G'
mute = 'M'
fin = 'AU'
cmd = {
	[1] = {['Direction'] = 'input', ['ctrl'] = 300, ['gainCtrl'] = InputGains, ['muteCtrl'] = InputGainMute},
	[2] = {['Direction'] = 'input', ['ctrl'] = 301, ['gainCtrl'] = PreMixGain, ['muteCtrl'] = PreMixGainMute},
	[3] = {['Direction'] = 'output', ['ctrl'] = 200, ['gainCtrl'] = Input1MixPoint, ['muteCtrl'] = Input1MixPointMute},
	[4] = {['Direction'] = 'output', ['ctrl'] = 201, ['gainCtrl'] = Input2MixPoint, ['muteCtrl'] = Input2MixPointMute},
	[5] = {['Direction'] = 'output', ['ctrl'] = 202, ['gainCtrl'] = Input3MixPoint, ['muteCtrl'] = Input3MixPointMute},
	[6] = {['Direction'] = 'output', ['ctrl'] = 203, ['gainCtrl'] = Input4MixPoint, ['muteCtrl'] = Input4MixPointMute},
	[7] = {['Direction'] = 'output', ['ctrl'] = 601, ['gainCtrl'] = PostMixTrim},
	[8] = {['Direction'] = 'output', ['ctrl'] = 600, ['gainCtrl'] = Attenuation, ['muteCtrl'] = AttenuationMute},
}
dl = '\r'

-- TCP Socket --
TCP.EventHandler = function(sock, evt, err) --Event Handler for the TCP socket
  if evt == TcpSocket.Events.Connected then
    print("socket connected")
    status.String = "OK"
    status.Color = "Green"
    getState()
  elseif evt == TcpSocket.Events.Reconnect then
    print("socket reconnecting")
    status.String = "Reconnecting"
    status.Color = "Blue"
  elseif evt == TcpSocket.Events.Data then
    message = sock:ReadLine(TcpSocket.EOL.Any)
    if (message ~= nil) and (message ~= '') then 
      new_message = message
      parseCommand(new_message)
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

--run when the IP address is changed
Controls.IP.EventHandler = function()
  Startup()
end 

-- Format strings containing non-printable characters so they are readable.
function debugFormat(string) 
  local visual = ""
  for i=1,#string do
    local byte = string:sub(i,i)
    if string.byte(byte) >= 32 and string.byte(byte) <= 126 then
      visual = visual..byte
    else
      visual = visual..string.format("[0x%02X]",string.byte(byte))
    end
  end
  return visual
end

--Controls--

--Eventhandlers
for channel = 1, 4 do  -- **would need to do something about this if the DSP is not 4x4**
  for Ctrl = 1, #cmd do  -- for gain controls
    cmd[Ctrl]['gainCtrl'][channel].EventHandler = function()
      local value = cmd[Ctrl]['gainCtrl'][channel].String
      createString(Ctrl, channel, value, gain)
    end
  end 
  for Ctrl = 1, #cmd do --for mute controls
    if cmd[Ctrl]['muteCtrl'] ~= nil then
      cmd[Ctrl]['muteCtrl'][channel].EventHandler = function()
        local value = cmd[Ctrl]['muteCtrl'][channel].Boolean
        createString(Ctrl, channel, value, mute)
      end
    end
  end 
end

-- create control string to send based on the control being changed
function createString(command, chan, value, func)
  channel = chan -1
  -- format value for number or boolean
  if type(value) == 'boolean' then
    if value == true then 
      val = '1' --muted
    else 
      val = '0' -- unmuted
    end
  else 
    val = tostring(value..'0') --gain integer
  end
  chan = chan -1
  queueCommand(send..func..cmd[command]['ctrl']..'0'..channel.."*"..val..fin, true)
end

--get state
function getState()
  --run accross all commands
  for command = 1, #cmd do 
    -- for all inputs
    for ins = 0, (dspInputs -1) do 
      if cmd[command]['Direction'] == 'input' then  -- if is an input channel
        if cmd[command]['gainCtrl'] ~= nil then --check gain control exists
          queueCommand(send..gain..cmd[command]['ctrl']..'0'..ins..fin)
        end 
        if cmd[command]['muteCtrl'] ~= nil then -- check mute control exists
          queueCommand(send..mute..cmd[command]['ctrl']..'0'..ins..fin)
        end
      end

    end
    -- and for all outputs
    for outs = 0, (dspOutputs -1) do 
      if cmd[command]['Direction'] == 'output' then -- if is an output channel
        if cmd[command]['gainCtrl'] ~= nil then --check gain control exists
          queueCommand(send..gain..cmd[command]['ctrl']..'0'..outs..fin)
        end
        if cmd[command]['muteCtrl'] ~= nil then -- check mute control exists
          queueCommand(send..mute..cmd[command]['ctrl']..'0'..outs..fin)
        end
      end
    end
  end
end

--parse commands as they are received
function parseCommand(command)
  print("Received: ", command)
  rawGain = string.sub(command, 1, 2)
  
 -- parsing gains
  if string.find(command, 'DsG') then
    rawGain = tonumber(string.sub(command, 4, 6))
    rawChan = string.sub(command, 7, 8)
    rawValue = string.match(command, "*(.*)")
    value = tonumber(rawValue) / 10
    channel = tonumber(rawChan) + 1
    for command = 1, #cmd do
      if rawGain == cmd[command]['ctrl'] then
        cmd[command]['gainCtrl'][channel].Value = value
      end
    end
  end

   -- parsing mutes
  if string.find(command, 'DsM') then
    local rawGain = tonumber(string.sub(command, 4, 6))
    local rawChan = string.sub(command, 7, 8)
    local rawValue = tonumber(string.match(command, "*(.*)"))
    local value = false
    local channel = tonumber(rawChan) + 1
    local mute = 1
    if rawValue == mute then
      value = true 
    end
    for command = 1, #cmd do
      if rawGain == cmd[command]['ctrl'] then
        cmd[command]['muteCtrl'][channel].Boolean = value
      end
    end
  end
end

--send request for control states periodically to the queueCommand
function pulse()
  --getState()
  keepAliveTimer:Start(keepAliveDelay)
end
keepAliveTimer.EventHandler = pulse

-- Add command to the outgoing queue.
function queueCommand(command, now)  
  if now then table.insert(sendBuffer, 1, command) else table.insert(sendBuffer, command) end -- Add command to end of sendBuffer. If 'now' is true, add to the beggining of the sendBuffer.
  doSend()
end

-- Send command from buffer.
function doSend() 
  if #sendBuffer > 0 and TCP.IsConnected and not sendWait then  -- If there are commands in the buffer, send the next command.
    local command = table.remove(sendBuffer, 1)
    TCP:Write(command..dl)
    print("Sending:", debugFormat(command))
    lastCommand = command
    keepAliveTimer:Start(keepAliveDelay)  -- Reset keepalive timer.
    sendDelaySet()
  end
end

function sendDelaySet(ctl)  -- Set flag to wait for ACK or Timeout before sending next command. If called with true ( sendDelaySet(true) ), this will immediately dispatch the next command in the buffer.
  if ctl then
    sendDelayTimer:Stop()
    sendWait = false
    doSend()  
  else
    sendWait = true
    sendDelayTimer:Start(sendDelay)
  end  
end
sendDelayTimer.EventHandler = sendDelaySet

-- Startup --
function Startup()
  --Model.String = ''
  Timer.CallAfter(function()
    TCP:Connect(IP, port)  -- TCP Connect
  end, 1)
end  

Startup()
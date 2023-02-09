-- Initialise
ssh = Ssh.New()
address = Controls.ipAddress.String
port = Controls.port.Value
username = Controls.username.String
password = Controls.password.String
monitor_mode = Controls.monitors
mic = Controls.micMute
standby = Controls.standby
timer = Timer.New()

-- Feedback
function parseReturnCommand(message, ltable)
  -- standby state
  msg, _ = string.find(message, "Standby State:")
  if msg ~= nil then 
    if ltable[4] == 'Off' or ltable[4] == 'Halfwake' then
      Controls.standby.Boolean = false
    else
      Controls.standby.Boolean = true
    end 
  end

  -- mic mute control
  msg, _ = string.find(message, "Audio Microphones Mute:")
  if msg ~= nil then 
    if ltable[5] == 'On' then
      Controls.micMute.Boolean = true
    else if ltable[5] == 'Off' then 
      Controls.micMute.Boolean = false
    end 
  end

  -- incall status
  msg, _ = string.find(message, "NumberOfActiveCalls:")
  if msg ~= nil then 
    if ltable[5] > 0 then
      Controls.callState.Boolean = true
    else
      Controls.callState.Boolean = false
    end
  end
end 
end

function startSubscriptions()
  Send("xFeedback Register /Status/Audio/Microphones/Mute")
  Send("xFeedback Register /Status/SystemUnit/State/NumberOfActiveCalls")
  Send("xFeedback Register Status/Standby/State")
end

function getStartupStates()
  Send("xStatus Audio Microphones Mute")
  Send("xStatus SystemUnit State NumberOfActiveCalls")
  Send("xStatus Standby State")
end

-- ssh socket
ssh.Connected = function()
    print("ssh connected")
    startSubscriptions()
    getStartupStates()
    timer:Start(10)
end
ssh.Reconnect = function()
    print("ssh reconnect")
end
ssh.Data = function()
  print("ssh data")
  line = ssh:ReadLine(TcpSocket.EOL.Any)
  while line do
    print(line)
  ltable = {}
	for i in string.gmatch( line, "%S+" ) do
		table.insert( ltable, i )
	end
	parseReturnCommand(line, ltable)
    line = ssh:ReadLine(TcpSocket.EOL.Any)
  end
end
ssh.Closed = function()
    print("ssh closed")
    timer:Stop()
end
ssh.Error = function(s, err)
    print("ssh error", err)
end
ssh.Timeout = function()
    print("ssh timeout")
end
ssh.LoginFailed = function()
    print("ssh LoginFailed")
end

-- Standby
standby.EventHandler = function()
  if standby.Boolean == true then 
    Send("xCommand Standby Activate")
  else 
    Send("xCommand Standby Deactivate")
  end
end

-- Mic Mute
mic.EventHandler = function()
  if mic.Boolean == true then
    Send("xCommand Audio Microphones Mute")
  else 
    Send("xCommand Audio Microphones Unmute")
  end
end

-- initialise monitors dropdown
monitorModes = {"Auto", "Dual", "DualPresentationOnly", "Single", "Triple", "TriplePresentationOnly"}
monitor_mode.Choices = monitorModes

-- monitor control
monitor_mode.EventHandler = function ()
  Send("xConfiguration Video Monitors: "..monitor_mode.String)
end

function Send(str)
  if ssh.IsConnected then
    ssh:Write(str.."\n")
    print("Sent "..str)
  end
end

ssh:Connect(address, port, username, password)
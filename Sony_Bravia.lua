--Module for control of Sony Bravia TV via TCP

-- Original Script by Wes Wakefield
-- Modified by Aaron Mitchell
-- For Sony Bravia TCP Control

IpAddress = Controls.ipAddress.String
Port=20060
buttonColor = {on = "Lime", off = "Red", loading = "Yellow"}

SonyBravia=TcpSocket.New()
keepAlive = Timer.New()
SonyBravia.ReconnectTimeout = 2
setInput = Controls['setInput']

CMD = {                                             -- Sony commands for making the display do things
  setPWR1="*SCPOWR0000000000000001\x0A",
  setPWR0="*SCPOWR0000000000000000\x0A",
  getPWRSTA="*SEPOWR################\x0A",
  setInHDMI1="*SCINPT0000000100000001\x0A",
  setInHDMI2="*SCINPT0000000100000002\x0A",
  setInHDMI3="*SCINPT0000000100000003\x0A",
  setInHDMI4="*SCINPT0000000100000004\x0A",
  getInput="*SEINPT################\x0A",
  setAudioVolume="*SCVOLU00000000000000",           --- Add last 2 digits and a LF when used, ie: setAudioVolume.."50\x0A"
  getAudioVolume="*SEVOLU################\x0A",
  getMacAddress="*SEMADReth0############\x0A",
  setPicMuteON="*SCPMUT0000000000000001\x0A",
  setPicMuteOFF="*SCPMUT0000000000000000\x0A",
  getPicMute="*SEPMUT################\x0A",
  setTV="*SCIRCC0000000000000002\x0A",
  setHome="*SCIRCC0000000000000006\x0A",
  setNum1="*SCIRCC0000000000000018\x0A",
  setNum2="*SCIRCC0000000000000019\x0A",
  setNum3="*SCIRCC0000000000000020\x0A",
  setNum4="*SCIRCC0000000000000021\x0A",
  setNum5="*SCIRCC0000000000000022\x0A",
  setNum6="*SCIRCC0000000000000023\x0A",
  setNum7="*SCIRCC0000000000000024\x0A",
  setNum8="*SCIRCC0000000000000025\x0A",
  setNum9="*SCIRCC0000000000000026\x0A",
  setNum0="*SCIRCC0000000000000027\x0A",
  setCHUP="*SCIRCC0000000000000033\x0A",
  setCHDN="*SCIRCC0000000000000034\x0A",
  setNavU="*SCIRCC0000000000000009\x0A",
  setNavD="*SCIRCC0000000000000010\x0A",
  setNavL="*SCIRCC0000000000000012\x0A",
  setNavR="*SCIRCC0000000000000011\x0A",
  setNavOK="*SCIRCC0000000000000013\x0A",
  setNavBk="*SCIRCC0000000000000041\x0A",
  }

fb = {                                    -- Responses from display
  nPWRSTAON="*SNPOWR0000000000000001",    -- "n" = notify. TV notifies if status changes from remote, manually, etc
  nPWRSTAOFF="*SNPOWR0000000000000000",
  nInHDMI1="*SNINPT0000000100000001",
  nInHDMI2="*SNINPT0000000100000002",
  nInHDMI3="*SNINPT0000000100000003",
  nInHDMI4="*SNINPT0000000100000004",
  nInHome="*SCIRCC0000000000000000",
  --nAudioVolume="*SNVOLU00000000000000", -- Add last 2 digits and a LF when used, ie: setAudioVolume.."50\x0A"
  nPicMuteON="*SNPMUT0000000000000001",
  nPicMuteOFF="*SNPMUT0000000000000000",
  aPWRSTAON="*SAPOWR0000000000000001",    -- "a" = answer. Used as a response to a query/command from script
  aPWRSTAOFF="*SAPOWR0000000000000000",
  aInHDMI1="*SAINPT0000000100000001",
  aInHDMI2="*SAINPT0000000100000002",
  aInHDMI3="*SAINPT0000000100000003",
  aInHDMI4="*SAINPT0000000100000004",
  aInHDMINONE="*SAINPTFFFFFFFFFFFFFFFF",
  --aAudioVolume="*SAVOLU00000000000000", -- Add last 2 digits and a LF when used, ie: setAudioVolume.."50\x0A"
  aPicMuteON="*SAPMUT0000000000000001",
  aPicMuteOFF="*SAPMUT0000000000000000"
}

Status = {power, macAddress, input, picMute, volume}                -- Global variables to keep track of display status
get = {power = true, input = true, picMute = true, volume = false}  -- Flags
stack = {CMD.getPicMute,CMD.getInput,CMD.getPWRSTA}                 -- Stack init

-- IR Controls

-------------- Event Handlers ---------------

SonyBravia.EventHandler=function(sock,evt,err)    -- TCP Socket Handler

  if evt == TcpSocket.Events.Data then
    line = SonyBravia:ReadLine(TcpSocket.EOL.Lf)
    local errVar
    
    while(line ~= nil) do                           -- repeat as long as there's data in socket buffer
      parseBuffer(line)                             -- decode current line in buffer
      line = SonyBravia:ReadLine(TcpSocket.EOL.Lf)  -- read next line
    end
  
    if stack[1] ~= nil then   -- execute command in stack if it's not empty
      stackPop()
    end
    
  elseif evt == TcpSocket.Events.Connected then
      print("Socket Connected")
  elseif evt == TcpSocket.Events.Reconnect then
      print("Socket Reconnecting")
  elseif evt == TcpSocket.Events.Closed then
      print("Socket Closed")
  elseif evt == TcpSocket.Events.Error then
    errVar = TcpSocket.Events.Error  
    print("Socket Error: "..errVar)
  elseif evt == TcpSocket.Events.Timeout then
      print("Socket Timeout")
  end  

end

Controls.setPowerStatus.EventHandler = function()   -- Turn display on/off
  if Controls.setPowerStatus.Boolean == true then
      --SonyBravia:Write(CMD.setPWR1)
      stackPush(CMD.setPWR1)
      --stackPush(CMD.setAudioVolume.."00\x0A")
      --stackPush(CMD.setHome)
      stackPop()
      Controls.setPowerStatus.Color = buttonColor.loading
      Controls.setPowerStatus.Legend = "ON"
      --print("Power ON")
    else
      --SonyBravia:Write(CMD.setPWR0)
      stackPush(CMD.setPWR0)
      stackPop()
      Controls.setPowerStatus.Legend = "OFF"
      Controls.setPowerStatus.Color = buttonColor.loading
      --print("Power OFF")
  end
end



-- Inputs --  

setInput[1].Legend = 'HDMI 1'
setInput[2].Legend = 'HDMI 2'
setInput[3].Legend = 'HDMI 3'
setInput[4].Legend = 'HDMI 4'
setInput[5].Legend = 'guide'
setInput[6].Legend = 'home'


setInput[1].EventHandler = function()
  stackPush(CMD.setInHDMI1)
  stackPush(CMD.getInput)
  stackPop()
end

setInput[2].EventHandler = function()
  stackPush(CMD.setInHDMI2)
  stackPush(CMD.getInput)
  stackPop()
end

setInput[3].EventHandler = function()
  stackPush(CMD.setInHDMI3)
  stackPush(CMD.getInput)
  stackPop()
end

setInput[4].EventHandler = function()
  stackPush(CMD.setInHDMI4)
  stackPush(CMD.getInput)
  stackPop()
end

setInput[5].EventHandler = function()
  stackPush(CMD.setTV)
  stackPop()
end

setInput[6].EventHandler = function()
  stackPush(CMD.setHome)
  stackPop()
end

-- Volume --

Controls.setAudioVolume.EventHandler = function()   -- Set Audio volume 
  temp = Controls.setAudioVolume.String
  print("temp is = "..temp)
  
  if tonumber(temp) < 10 then
    volume = "0"..temp
  elseif tonumber(temp) >= 10 then
    volume = temp
  end
  
  print("volume = "..volume)
  
  stackPush(CMD.setAudioVolume..volume.."\x0A") 
  stackPop()
   
end

-- Picture Mute --

Controls.setPictureMute.EventHandler = function() -- Enable/Disable Picture Mute
  print("picture mute event handler triggered")
  if Controls.setPictureMute.Boolean == true then
    stackPush(CMD.setPicMuteON)
    Controls.setPictureMute.Legend = "MUTED"
    Controls.setPictureMute.Color = buttonColor.loading
    print("Pic Mute ON")
  else 
    stackPush(CMD.setPicMuteOFF) 
    Controls.setPictureMute.Legend = "UNMUTED"
    Controls.setPictureMute.Color = buttonColor.loading
    print("Pic Mute OFF")
  end
  stackPop()
end

keepAlive.EventHandler = function() -- Keep Socket open, poll for status
  
  if SonyBravia.IsConnected == false then SonyBravia:Connect(IpAddress,Port)
  
  elseif SonyBravia.IsConnected == true then
    --stackPush(CMD.getMacAddress)
    stackPush(CMD.getInput)
    stackPush(CMD.getAudioVolume)
    stackPush(CMD.getPicMute)
    stackPush(CMD.getPWRSTA)
  end

  get = {power = true, input = true, picMute = true, volume = true}
  
  stackPop()

end


-- IR Commands -- 

Controls.Num[1].EventHandler = function()
  stackPush(CMD.setNum1)
  stackPop()
end

Controls.Num[2].EventHandler = function()
  stackPush(CMD.setNum2)
  stackPop()
end

Controls.Num[3].EventHandler = function()
  stackPush(CMD.setNum3)
  stackPop()
end

Controls.Num[4].EventHandler = function()
  stackPush(CMD.setNum4)
  stackPop()
end

Controls.Num[5].EventHandler = function()
  stackPush(CMD.setNum5)
  stackPop()
end

Controls.Num[6].EventHandler = function()
  stackPush(CMD.setNum6)
  stackPop()
end

Controls.Num[7].EventHandler = function()
  stackPush(CMD.setNum7)
  stackPop()
end

Controls.Num[8].EventHandler = function()
  stackPush(CMD.setNum8)
  stackPop()
end

Controls.Num[9].EventHandler = function()
  stackPush(CMD.setNum9)
  stackPop()
end

Controls.Num[10].EventHandler = function()
  stackPush(CMD.setNum0)
  stackPop()
end

-- Channels --

Controls.CHUP_DN[1].EventHandler = function()
  stackPush(CMD.setCHUP)
  stackPop()
end

Controls.CHUP_DN[2].EventHandler = function()
  stackPush(CMD.setCHDN)
  stackPop()
end

-- Navigation --
Controls.NAV_UDLR[1].EventHandler = function()
  stackPush(CMD.setNavU)
  stackPop()
end

Controls.NAV_UDLR[1].EventHandler = function()
  stackPush(CMD.setNavU)
  stackPop()
end

Controls.NAV_UDLR[2].EventHandler = function()
  stackPush(CMD.setNavD)
  stackPop()
end

Controls.NAV_UDLR[3].EventHandler = function()
  stackPush(CMD.setNavL)
  stackPop()
end

Controls.NAV_UDLR[4].EventHandler = function()
  stackPush(CMD.setNavR)
  stackPop()
end

Controls.NAV_OK.EventHandler = function()
  stackPush(CMD.setNavOK)
  stackPop()
end

Controls.NAV_BACK.EventHandler = function()
  stackPush(CMD.setNavBk)
  stackPop()
end





-------------- Functions --------------- 

function stackPop()   -- Execute next command in stack
  
    if stack[1] ~= nil and SonyBravia.IsConnected == true then 
      SonyBravia:Write(table.remove(stack,1))
   -- elseif stack[1] ~= nil and SonyBravia.IsConnected == false then
  --  table.remove(stack,1)
    end
     
end

function stackPush(x)   -- Add command to stack

  table.insert(stack,x)

end
  
function parseBuffer(x)   -- Compare feedback from display, decide what to do with it

    if string.sub(x,4,7) == "POWR" then
        if (x == fb.aPWRSTAON and get.power == true) or x == fb.nPWRSTAON then
            powerButton("ON")
            picMuteButton("enable")
            Controls.setAudioVolume.IsDisabled = false
            Controls.setInput.IsDisabled = false
            get.power = false
            if Status.power == false or Status.power == nil then
              Status.power = true
              print("Power is ON")
            end
        elseif (x == fb.aPWRSTAOFF and get.power == true) or x == fb.nPWRSTAOFF then
            powerButton("OFF")
            picMuteButton("disable")
            picMuteButton("unmute")
            Controls.setAudioVolume.IsDisabled = true
            Controls.setInput.IsDisabled = true
            get.power = false
            if Status.power == true or Status.power == nil then
              Status.power = false
              Status.input = nil
              print("Power is OFF")
            end
        end

    elseif string.sub(x,4,7) == "INPT" then
      inp = {fb.aInHDMI1, fb.aInHDMI2, fb.aInHDMI3, fb.aInHDMI4}
      for i = 1,4,1 do 
        if x == inp[i] then
          if Status.input ~= "HDMI "..tostring(i) then
            Status.input = "HDMI "..tostring(i)
            print("Input set to HDMI "..tostring(i))
          end
        end
      end

        get.input = false

    elseif  string.sub(x,4,7) == "VOLU" then
        if (string.sub(x,3,7) == "AVOLU" and get.volume == true) or string.sub(x,3,7) == "NVOLU" then
            Status.volume = string.sub(x,-3,-1)
            Controls.setAudioVolume.String = Status.volume
            get.volume = false
            --print("Volume is "..string.sub(x,-3,-1))
        end

    elseif string.sub(x,4,7) == "PMUT" then
        if (x == fb.aPicMuteOFF and get.picMute == true) or x == fb.nPicMuteOFF then
            picMuteButton("unmute")
            get.picMute = false
            --print("Picture is UnMuted")
        elseif (x == fb.aPicMuteON and get.picMute == true) or x == fb.nPicMuteON then
            picMuteButton("mute")
            get.picMute = false
            --print("Picture is Muted")
        end
    
    end

end
  
function picMuteButton(x)
    if x == "mute" then
        Controls.setPictureMute.Boolean = true
        Controls.setPictureMute.Legend = "MUTED"
        Controls.setPictureMute.Color = buttonColor.off
    elseif x == "unmute" then
        Controls.setPictureMute.Boolean = false
        Controls.setPictureMute.Legend = "UNMUTED"
        Controls.setPictureMute.Color = buttonColor.on
    elseif x == "enable" then
        Controls.setPictureMute.IsDisabled = false
    elseif x == "disable" then
        Controls.setPictureMute.IsDisabled = true
    end
end

function powerButton(x)
    --print("powerButton Ran")
    if x == "ON" then
        Controls.setPowerStatus.Boolean = true
        --Controls.setPowerStatus.Legend = "ON"
        Controls.setPowerStatus.Color = buttonColor.on
    elseif x == "OFF" then
        Controls.setPowerStatus.Boolean = false
        --Controls.setPowerStatus.Legend = "OFF"
        Controls.setPowerStatus.Color = buttonColor.off
    end
end

-------------- Run (once) At Startup ---------------
SonyBravia:Connect(IpAddress,Port)

stackPop()

keepAlive:Start(10)

-- Blockly Timers --
Heartbeat = Timer.New()
Input_Status = Timer.New()

-- Available Connections --

-- ### Kramer ###
Controls['Kramer.Status'].Value = 4
Controls['Kramer.Status'].String = ''
Kramer = TcpSocket.New()
Kramer.ReconnectTimeout = 5
KramerIP_AddressEventFunctions = {}
Controls['Kramer.IP_Address'].EventHandler = function()
  for KramerIP_Address_i, KramerIP_Address_confun in pairs(KramerIP_AddressEventFunctions) do
    KramerIP_Address_confun()
  end
end

KramerIP_AddressEventFunctions['IP_AddressChanged'] = function()
  -- TCP RE-CONNECT
  print('reconnecting TCP because of control property change')
  Controls['Kramer.Status'].Value = 5
  Controls['Kramer.Status'].String = 'Reconnecting'
  Kramer:Disconnect()
  do
    if (not (Controls['Kramer.IP_Address'].String == '')) and (not (Controls['Kramer.Port'].String == '')) then
      local success, err = pcall(function() Kramer:Connect(Controls['Kramer.IP_Address'].String, Controls['Kramer.Port'].Value) end)
      if not success then
        Controls['Kramer.Status'].Value = 2
        Controls['Kramer.Status'].String = err
      end
    else
      Controls['Kramer.Status'].Value = 2
      Controls['Kramer.Status'].String = 'Check TCP connection properties.'
    end
  end
end
KramerPortEventFunctions = {}
Controls['Kramer.Port'].EventHandler = function()
  for KramerPort_i, KramerPort_confun in pairs(KramerPortEventFunctions) do
    KramerPort_confun()
  end
end

KramerPortEventFunctions['PortChanged'] = function()
  -- TCP RE-CONNECT
  print('reconnecting TCP because of control property change')
  Controls['Kramer.Status'].Value = 5
  Controls['Kramer.Status'].String = 'Reconnecting'
  Kramer:Disconnect()
  do
    if (not (Controls['Kramer.IP_Address'].String == '')) and (not (Controls['Kramer.Port'].String == '')) then
      local success, err = pcall(function() Kramer:Connect(Controls['Kramer.IP_Address'].String, Controls['Kramer.Port'].Value) end)
      if not success then
        Controls['Kramer.Status'].Value = 2
        Controls['Kramer.Status'].String = err
      end
    else
      Controls['Kramer.Status'].Value = 2
      Controls['Kramer.Status'].String = 'Check TCP connection properties.'
    end
  end
end
KramerStatusEventFunctions = {}
Controls['Kramer.Status'].EventHandler = function()
  for KramerStatus_i, KramerStatus_confun in pairs(KramerStatusEventFunctions) do
    KramerStatus_confun()
  end
end

KramerStatusEventFunctions['StatusChanged'] = function()
  -- TCP RE-CONNECT
  print('reconnecting TCP because of control property change')
  Controls['Kramer.Status'].Value = 5
  Controls['Kramer.Status'].String = 'Reconnecting'
  Kramer:Disconnect()
  do
    if (not (Controls['Kramer.IP_Address'].String == '')) and (not (Controls['Kramer.Port'].String == '')) then
      local success, err = pcall(function() Kramer:Connect(Controls['Kramer.IP_Address'].String, Controls['Kramer.Port'].Value) end)
      if not success then
        Controls['Kramer.Status'].Value = 2
        Controls['Kramer.Status'].String = err
      end
    else
      Controls['Kramer.Status'].Value = 2
      Controls['Kramer.Status'].String = 'Check TCP connection properties.'
    end
  end
end
KramerStatusConnectedFunctions = {}
KramerStatusConnectedFunctions['StandardConnected'] = function()
  Controls['Kramer.Status'].Value = 0
  Controls['Kramer.Status'].String = ''
end
KramerStatusClosedFunctions = {}
KramerStatusClosedFunctions['StandardClosed'] = function()
  Controls['Kramer.Status'].Value = 2
  Controls['Kramer.Status'].String = 'Closed'
end
Kramer.Connected = function()
  for Kramer_i, Kramer_confun in pairs(KramerStatusConnectedFunctions) do
    Kramer_confun()
  end
end
Kramer.Closed = function()
  for Kramer_i, Kramer_clofun in pairs(KramerStatusClosedFunctions) do
    Kramer_clofun()
  end
end
Kramer.Reconnect = function()
  Controls['Kramer.Status'].Value = 5
  Controls['Kramer.Status'].String = 'Reconnect'
end
Kramer.Timeout = function()
  Controls['Kramer.Status'].Value = 2
  Controls['Kramer.Status'].String = 'Timeout'
end
KramerConnectionErrorFunctions = {}
KramerConnectionErrorFunctions['StandardError'] = function(error_message)
  Controls['Kramer.Status'].Value = 2
  Controls['Kramer.Status'].String = error_message
end
Kramer.Error = function(connection, error_message)
  if error_message == nil then error_message = '' end
  for Kramer_i, Kramer_errfun in pairs(KramerConnectionErrorFunctions) do
    Kramer_errfun(error_message)
  end
end

----  QSYS Initialization  ----

function Startup()
  Controls['MAC'].String = ''
  Controls['Firmware version'].String = ''
  Controls['HDMI Connected'][1].Boolean = false
  Controls['HDMI Connected'][2].Boolean = false
  Controls['HDMI Connected'][3].Boolean = false
  Controls['HDMI Connected'][4].Boolean = false
  Controls['HDMI Connected'][5].Boolean = false
  Controls['HDMI Connected'][6].Boolean = false
end


function escape_control_string(text)
  local result = string.gsub(text, "\\\\", "\\")
  result = string.gsub(result, "\\r", "\r")
  result = string.gsub(result, "\\n", "\n")
  result = string.gsub(result, "\\t", "\t")
  result = string.gsub(result, "\\b", "\b")
  result = string.gsub(result, "\\f", "\f")
  result = string.gsub(result, "\\v", "\v")
  result = string.gsub(result, "\\0", "\0")
  result = string.gsub(result, "\\0", "\0")
  return result
end

function Lock_Front_Panel()
  if Controls['Lock Front Panel'].Boolean == true then
    Kramer:Write('#LOCK-FP 1\r')
   else
    Kramer:Write('#LOCK-FP 0\r')
  end
end


function Out_1_Input_Logic()
  if Controls['Output_1_Input_Button'][1].Boolean == true then
    Kramer:Write('#ROUTE 1,1,1\r')
    Controls['Output_1_Input #'].Value = 1
   elseif Controls['Output_1_Input_Button'][2].Boolean == true then
    Kramer:Write('#ROUTE 1,1,2\r')
    Controls['Output_1_Input #'].Value = 2
   elseif Controls['Output_1_Input_Button'][3].Boolean == true then
    Kramer:Write('#ROUTE 1,1,3\r')
    Controls['Output_1_Input #'].Value = 3
   elseif Controls['Output_1_Input_Button'][4].Boolean == true then
    Kramer:Write('#ROUTE 1,1,4\r')
    Controls['Output_1_Input #'].Value = 4
   elseif Controls['Output_1_Input_Button'][5].Boolean == true then
    Kramer:Write('#ROUTE 1,1,5\r')
    Controls['Output_1_Input #'].Value = 5
   elseif Controls['Output_1_Input_Button'][6].Boolean == true then
    Kramer:Write('#ROUTE 1,1,6\r')
    Controls['Output_1_Input #'].Value = 6
  end
end


function Select_Out_1_Input_1()
  for input = 1, #Controls['Output_1_Input_Button'] do
    Controls['Output_1_Input_Button'][input].Boolean = false
  end
  Controls['Output_1_Input_Button'][1].Boolean = true
  Out_1_Input_Logic()
end


function Select_Out_1_Input_2()
  for input = 1, Controls['Output_1_Input_Button'] do
    Controls['Output_1_Input_Button'][input].Boolean = false
  end
  Controls['Output_1_Input_Button'][2].Boolean = true
  Out_1_Input_Logic()
end


function Select_Out_1_Input_3()
  for input = 1, Controls['Output_1_Input_Button'] do
    Controls['Output_1_Input_Button'][input].Boolean = false
  end
  Controls['Output_1_Input_Button'][3].Boolean = true
  Out_1_Input_Logic()
end


function Select_Out_1_Input_4()
  for input = 1, Controls['Output_1_Input_Button'] do
    Controls['Output_1_Input_Button'][input].Boolean = false
  end
  Controls['Output_1_Input_Button'][4].Boolean = true
  Out_1_Input_Logic()
end


function Select_Out_1_Input_5()
  Controls['Output_1_Input_Button'][1].Boolean = false
  Controls['Output_1_Input_Button'][2].Boolean = false
  Controls['Output_1_Input_Button'][3].Boolean = false
  Controls['Output_1_Input_Button'][4].Boolean = false
  Controls['Output_1_Input_Button'][5].Boolean = false
  Controls['Output_1_Input_Button'][6].Boolean = false
  Controls['Output_1_Input_Button'][5].Boolean = true
  Out_1_Input_Logic()
end


function Set_Out_1_Input_Toggle()
  if Controls['Output_1_Input #'].Value == 1 then
    Select_Out_1_Input_1()
   elseif Controls['Output_1_Input #'].Value == 2 then
    Select_Out_1_Input_2()
   elseif Controls['Output_1_Input #'].Value == 3 then
    Select_Out_1_Input_3()
   elseif Controls['Output_1_Input #'].Value == 4 then
    Select_Out_1_Input_4()
   elseif Controls['Output_1_Input #'].Value == 5 then
    Select_Out_1_Input_5()
   elseif Controls['Output_1_Input #'].Value == 6 then
    Select_Out_1_Input_6()
  end
end


function Input_Status_Check()
  Kramer:Write('#SIGNAL? 1\r')
  Kramer:Write('#SIGNAL? 2\r')
  Kramer:Write('#SIGNAL? 3\r')
  Kramer:Write('#SIGNAL? 4\r')
  Kramer:Write('#SIGNAL? 5\r')
  Kramer:Write('#SIGNAL? 5\r')
end


function Select_Out_1_Input_6()
  Controls['Output_1_Input_Button'][1].Boolean = false
  Controls['Output_1_Input_Button'][2].Boolean = false
  Controls['Output_1_Input_Button'][3].Boolean = false
  Controls['Output_1_Input_Button'][4].Boolean = false
  Controls['Output_1_Input_Button'][5].Boolean = false
  Controls['Output_1_Input_Button'][6].Boolean = false
  Controls['Output_1_Input_Button'][6].Boolean = true
  Out_1_Input_Logic()
end


function Out_2_Input_Logic()
  if Controls['Output_2_Input_Button'][1].Boolean == true then
    Kramer:Write('#ROUTE 1,2,1\r')
    Controls['Output_2_Input #'].Value = 1
   elseif Controls['Output_2_Input_Button'][2].Boolean == true then
    Kramer:Write('#ROUTE 1,2,2\r')
    Controls['Output_2_Input #'].Value = 2
   elseif Controls['Output_2_Input_Button'][3].Boolean == true then
    Kramer:Write('#ROUTE 1,2,3\r')
    Controls['Output_2_Input #'].Value = 3
   elseif Controls['Output_2_Input_Button'][4].Boolean == true then
    Kramer:Write('#ROUTE 1,2,4\r')
    Controls['Output_2_Input #'].Value = 4
   elseif Controls['Output_2_Input_Button'][5].Boolean == true then
    Kramer:Write('#ROUTE 1,2,5\r')
    Controls['Output_2_Input #'].Value = 5
   elseif Controls['Output_2_Input_Button'][6].Boolean == true then
    Kramer:Write('#ROUTE 1,2,6\r')
    Controls['Output_2_Input #'].Value = 6
  end
end


function Select_Out_2_Input_1()
  Controls['Output_2_Input_Button'][1].Boolean = false
  Controls['Output_2_Input_Button'][2].Boolean = false
  Controls['Output_2_Input_Button'][3].Boolean = false
  Controls['Output_2_Input_Button'][4].Boolean = false
  Controls['Output_2_Input_Button'][5].Boolean = false
  Controls['Output_2_Input_Button'][6].Boolean = false
  Controls['Output_2_Input_Button'][1].Boolean = true
  Out_2_Input_Logic()
end


function Select_Out_2_Input_2()
  Controls['Output_2_Input_Button'][1].Boolean = false
  Controls['Output_2_Input_Button'][2].Boolean = false
  Controls['Output_2_Input_Button'][3].Boolean = false
  Controls['Output_2_Input_Button'][4].Boolean = false
  Controls['Output_2_Input_Button'][5].Boolean = false
  Controls['Output_2_Input_Button'][6].Boolean = false
  Controls['Output_2_Input_Button'][2].Boolean = true
  Out_2_Input_Logic()
end


function Select_Out_2_Input_3()
  Controls['Output_2_Input_Button'][1].Boolean = false
  Controls['Output_2_Input_Button'][2].Boolean = false
  Controls['Output_2_Input_Button'][3].Boolean = false
  Controls['Output_2_Input_Button'][4].Boolean = false
  Controls['Output_2_Input_Button'][5].Boolean = false
  Controls['Output_2_Input_Button'][6].Boolean = false
  Controls['Output_2_Input_Button'][3].Boolean = true
  Out_2_Input_Logic()
end


function Select_Out_2_Input_4()
  Controls['Output_2_Input_Button'][1].Boolean = false
  Controls['Output_2_Input_Button'][2].Boolean = false
  Controls['Output_2_Input_Button'][3].Boolean = false
  Controls['Output_2_Input_Button'][4].Boolean = false
  Controls['Output_2_Input_Button'][5].Boolean = false
  Controls['Output_2_Input_Button'][6].Boolean = false
  Controls['Output_2_Input_Button'][4].Boolean = true
  Out_2_Input_Logic()
end


function Select_Out_2_Input_5()
  Controls['Output_2_Input_Button'][1].Boolean = false
  Controls['Output_2_Input_Button'][2].Boolean = false
  Controls['Output_2_Input_Button'][3].Boolean = false
  Controls['Output_2_Input_Button'][4].Boolean = false
  Controls['Output_2_Input_Button'][5].Boolean = false
  Controls['Output_2_Input_Button'][6].Boolean = false
  Controls['Output_2_Input_Button'][5].Boolean = true
  Out_2_Input_Logic()
end


function Select_Out_2_Input_6()
  Controls['Output_2_Input_Button'][1].Boolean = false
  Controls['Output_2_Input_Button'][2].Boolean = false
  Controls['Output_2_Input_Button'][3].Boolean = false
  Controls['Output_2_Input_Button'][4].Boolean = false
  Controls['Output_2_Input_Button'][5].Boolean = false
  Controls['Output_2_Input_Button'][6].Boolean = false
  Controls['Output_2_Input_Button'][6].Boolean = true
  Out_2_Input_Logic()
end


function Set_Out_2_Input_Toggle()
  if Controls['Output_2_Input #'].Value == 1 then
    Select_Out_2_Input_1()
   elseif Controls['Output_2_Input #'].Value == 2 then
    Select_Out_2_Input_2()
   elseif Controls['Output_2_Input #'].Value == 3 then
    Select_Out_2_Input_3()
   elseif Controls['Output_2_Input #'].Value == 4 then
    Select_Out_2_Input_4()
   elseif Controls['Output_2_Input #'].Value == 5 then
    Select_Out_2_Input_5()
   elseif Controls['Output_2_Input #'].Value == 6 then
    Select_Out_2_Input_6()
  end
end


Controls['Output_1_Input_Button'][1].EventHandler = function()
  Select_Out_1_Input_1()
end

Controls['Output_1_Input_Button'][2].EventHandler = function()
  Select_Out_1_Input_2()
end

Controls['Output_1_Input_Button'][3].EventHandler = function()
  Select_Out_1_Input_3()
end

Controls['Output_1_Input_Button'][4].EventHandler = function()
  Select_Out_1_Input_4()
end

Heartbeat.EventHandler = function()
  Kramer:Write('#\r')
end

function logic_ternary(condition, if_true, if_false)
  if condition then return if_true() else return if_false() end
end

Kramer.Data = function()
  message = Kramer:ReadLine(TcpSocket.EOL.Any)
  while (message ~= nil) do
    print(tostring(message))
    Global_message = message
    if string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 5, 11) == 'VERSION' then
      Controls['Firmware version'].String = (string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 13, 16))
    end
    if string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 5, 11) == 'NET-MAC' then
      Controls['MAC'].String = (string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 13, 29))
    end
    if string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 5, 6) == 'SN' then
      Controls['Serial #'].String = (string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 8, 21))
    end
    if string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 5, 14) == 'SIGNAL 1,1' then
      Controls['HDMI Connected'][1].Boolean = true
     elseif string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 5, 14) == 'SIGNAL 1,0' then
      Controls['HDMI Connected'][1].Boolean = false
    end
    if string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 5, 14) == 'SIGNAL 2,1' then
      Controls['HDMI Connected'][2].Boolean = true
     elseif string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 5, 14) == 'SIGNAL 2,0' then
      Controls['HDMI Connected'][2].Boolean = false
    end
    if string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 5, 14) == 'SIGNAL 3,1' then
      Controls['HDMI Connected'][3].Boolean = true
     elseif string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 5, 14) == 'SIGNAL 3,0' then
      Controls['HDMI Connected'][3].Boolean = false
    end
    if string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 5, 14) == 'SIGNAL 4,1' then
      Controls['HDMI Connected'][4].Boolean = true
     elseif string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 5, 14) == 'SIGNAL 4,0' then
      Controls['HDMI Connected'][4].Boolean = false
    end
    if string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 5, 14) == 'SIGNAL 5,1' then
      Controls['HDMI Connected'][5].Boolean = true
     elseif string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 5, 14) == 'SIGNAL 5,0' then
      Controls['HDMI Connected'][5].Boolean = false
    end
    if string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 5, 14) == 'SIGNAL 6,1' then
      Controls['HDMI Connected'][6].Boolean = true
     elseif string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 5, 14) == 'SIGNAL 6,0' then
      Controls['HDMI Connected'][6].Boolean = false
    end
    message = Kramer:ReadLine(TcpSocket.EOL.Any)
  end
end

Controls['Lock Front Panel'].EventHandler = function()
  Lock_Front_Panel()
end

Controls['Output_1_Input_Button'][5].EventHandler = function()
  Select_Out_1_Input_5()
end

Controls['Output_1_Input #'].EventHandler = function()
  Set_Out_1_Input_Toggle()
end

Input_Status.EventHandler = function()
  Input_Status_Check()
end

Controls['Output_1_Input_Button'][6].EventHandler = function()
  Select_Out_1_Input_6()
end

Controls['Output_2_Input_Button'][1].EventHandler = function()
  Select_Out_2_Input_1()
end

Controls['Output_2_Input_Button'][2].EventHandler = function()
  Select_Out_2_Input_2()
end

Controls['Output_2_Input_Button'][3].EventHandler = function()
  Select_Out_2_Input_3()
end

Controls['Output_2_Input_Button'][4].EventHandler = function()
  Select_Out_2_Input_4()
end

Controls['Output_2_Input_Button'][5].EventHandler = function()
  Select_Out_2_Input_5()
end

Controls['Output_2_Input_Button'][6].EventHandler = function()
  Select_Out_2_Input_6()
end

Controls['Output_2_Input #'].EventHandler = function()
  Set_Out_2_Input_Toggle()
end

Controls['Output 1 Mute'].EventHandler = function()
  if Controls['Output 1 Mute'].Boolean == false then
    Kramer:Write('#VMUTE 1,0\r')
   else
    Kramer:Write('#VMUTE 1,1\r')
  end
end

Controls['Output 2 Mute'].EventHandler = function()
  if Controls['Output 2 Mute'].Boolean == false then
    Kramer:Write('#VMUTE 2,0\r')
   else
    Kramer:Write('#VMUTE 2,1\r')
  end
end


Startup()
Global_message = ''

KramerStatusConnectedFunctions['-lMI=}]w^7VJ0Qmf#8h4'] = function()
  Kramer:Write('#\r')
  Kramer:Write('#NET-MAC?\r')
  Kramer:Write('#VERSION?\r')
  Kramer:Write('#SN?\r')
  Lock_Front_Panel()
  Set_Out_1_Input_Toggle()
  Timer.CallAfter(function()
      Heartbeat:Start(5)
    Input_Status:Start(1)

  end,5)
end


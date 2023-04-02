-- Control module for Cisco 9300 switch
-- retreives the 1st mac address available at each port


----------------------
-- Initialise
----------------------

Controls['Switch.Status'].Value = 4
Controls['Switch.Status'].String = ''
Switch = TcpSocket.New()
Switch.ReconnectTimeout = 5
SwitchIP_AddressEventFunctions = {}
Controls['Switch.IP_Address'].EventHandler = function()
  for SwitchIP_Address_i, SwitchIP_Address_confun in pairs(SwitchIP_AddressEventFunctions) do
    SwitchIP_Address_confun()
  end
end
switch_size = 48

SwitchIP_AddressEventFunctions['IP_AddressChanged'] = function()
  -- TCP RE-CONNECT
  print('reconnecting TCP because of control property change')
  Controls['Switch.Status'].Value = 5
  Controls['Switch.Status'].String = 'Reconnecting'
  Switch:Disconnect()
  do
    if (not (Controls['Switch.IP_Address'].String == '')) and (not (Controls['Switch.Port'].String == '')) then
      local success, err = pcall(function() Switch:Connect(Controls['Switch.IP_Address'].String, Controls['Switch.Port'].Value) end)
      if not success then
        Controls['Switch.Status'].Value = 2
        Controls['Switch.Status'].String = err
      end
    else
      Controls['Switch.Status'].Value = 2
      Controls['Switch.Status'].String = 'Check TCP connection properties.'
    end
  end
end
SwitchPortEventFunctions = {}
Controls['Switch.Port'].EventHandler = function()
  for SwitchPort_i, SwitchPort_confun in pairs(SwitchPortEventFunctions) do
    SwitchPort_confun()
  end
end

SwitchPortEventFunctions['PortChanged'] = function()
  -- TCP RE-CONNECT
  print('reconnecting TCP because of control property change')
  Controls['Switch.Status'].Value = 5
  Controls['Switch.Status'].String = 'Reconnecting'
  Switch:Disconnect()
  do
    if (not (Controls['Switch.IP_Address'].String == '')) and (not (Controls['Switch.Port'].String == '')) then
      local success, err = pcall(function() Switch:Connect(Controls['Switch.IP_Address'].String, Controls['Switch.Port'].Value) end)
      if not success then
        Controls['Switch.Status'].Value = 2
        Controls['Switch.Status'].String = err
      end
    else
      Controls['Switch.Status'].Value = 2
      Controls['Switch.Status'].String = 'Check TCP connection properties.'
    end
  end
end
SwitchStatusEventFunctions = {}
Controls['Switch.Status'].EventHandler = function()
  for SwitchStatus_i, SwitchStatus_confun in pairs(SwitchStatusEventFunctions) do
    SwitchStatus_confun()
  end
end

SwitchStatusEventFunctions['StatusChanged'] = function()
  -- TCP RE-CONNECT
  print('reconnecting TCP because of control property change')
  Controls['Switch.Status'].Value = 5
  Controls['Switch.Status'].String = 'Reconnecting'
  Switch:Disconnect()
  do
    if (not (Controls['Switch.IP_Address'].String == '')) and (not (Controls['Switch.Port'].String == '')) then
      local success, err = pcall(function() Switch:Connect(Controls['Switch.IP_Address'].String, Controls['Switch.Port'].Value) end)
      if not success then
        Controls['Switch.Status'].Value = 2
        Controls['Switch.Status'].String = err
      end
    else
      Controls['Switch.Status'].Value = 2
      Controls['Switch.Status'].String = 'Check TCP connection properties.'
    end
  end
end
SwitchStatusConnectedFunctions = {}
SwitchStatusConnectedFunctions['StandardConnected'] = function()
  Controls['Switch.Status'].Value = 0
  Controls['Switch.Status'].String = ''
end
SwitchStatusClosedFunctions = {}
SwitchStatusClosedFunctions['StandardClosed'] = function()
  Controls['Switch.Status'].Value = 2
  Controls['Switch.Status'].String = 'Closed'
end
Switch.Connected = function()
  for Switch_i, Switch_confun in pairs(SwitchStatusConnectedFunctions) do
    Switch_confun()
  end
end
Switch.Closed = function()
  for Switch_i, Switch_clofun in pairs(SwitchStatusClosedFunctions) do
    Switch_clofun()
  end
end
Switch.Reconnect = function()
  Controls['Switch.Status'].Value = 5
  Controls['Switch.Status'].String = 'Reconnect'
end
Switch.Timeout = function()
  Controls['Switch.Status'].Value = 2
  Controls['Switch.Status'].String = 'Timeout'
end
SwitchConnectionErrorFunctions = {}
SwitchConnectionErrorFunctions['StandardError'] = function(error_message)
  Controls['Switch.Status'].Value = 2
  Controls['Switch.Status'].String = error_message
end
Switch.Error = function(connection, error_message)
  if error_message == nil then error_message = '' end
  for Switch_i, Switch_errfun in pairs(SwitchConnectionErrorFunctions) do
    Switch_errfun(error_message)
  end
end

----  QSYS Initialization  ----

function string_contains(str_array, does_contain)
  if type(str_array) == 'string' then
    local i = string.find(str_array, does_contain)
    if i ~= null then return true end
  else
    for _, v in ipairs(str_array) do
      if v == does_contain then return true end
    end
  end
  return false
end

function logic_ternary(condition, if_true, if_false)
  if condition then return if_true() else return if_false() end
end


-- read mac address at each port
Switch.Data = function()
  message = Switch:ReadLine(TcpSocket.EOL.Any)
  while (message ~= nil) do
    print(tostring(message))
    if message == 'User Access Verification' then
      Controls['Connect'].IsInvisible = false
      end
    Controls['Response'].String = (tostring(message))

    for port_number = 1, 48 do
      text_no = -7
      if port_number >= 11 then 
        text_no = -8
      end
      -- run for switch 1
      if string_contains(tostring(logic_ternary(((string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), text_no, -1)) == nil), function() return '' end, function() return (string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), -7, -1)) end)), 'Gi1/0/%s', port_number) then
        Controls['Mac Address SW1'][port_number].String = (string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 9, 22))
      end
      -- run for switch 2
      if string_contains(tostring(logic_ternary(((string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), text_no, -1)) == nil), function() return '' end, function() return (string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), -7, -1)) end)), 'Gi1/0/%s', port_number) then
        Controls['Mac Address SW1'][port_number].String = (string.sub(tostring(logic_ternary((message == nil), function() return '' end, function() return message end)), 9, 22))
      end
    end
    message = Switch:ReadLine(TcpSocket.EOL.Any)
  end
end

-- reboot switch
Controls['Reboot'].EventHandler = function()
  Switch:Write((table.concat({tostring('reload'), tostring('\r'), tostring('y'), tostring('\r \r')})))
  Controls['Device Online'].Boolean = false
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

--port reboot SW1
for r=1,#Controls['Reboot Port SW1'] do
Controls['Reboot Port SW1'][r].EventHandler = function()
  Switch:Write((tostring('configure terminal') .. tostring('\r')))
  Switch:Write((table.concat({tostring('interface gigabitethernet 1/0/'), tostring(escape_control_string(r)), tostring('\r')})))
  Switch:Write((tostring('power inline never') .. tostring('\r')))
  Controls['POE Enabled SW1'][r].Boolean = false
  Timer.CallAfter(function()
      Switch:Write((tostring('power inline auto') .. tostring('\r')))
    Switch:Write((tostring('exit') .. tostring('\r')))
    Switch:Write((tostring('exit') .. tostring('\r')))
    Controls['POE Enabled SW1'][r].Boolean = true
   end,5)
  end
end

--port reboot SW2
for s=1,#Controls['Reboot Port SW2'] do
  Controls['Reboot Port SW2'][s].EventHandler = function()
    Switch:Write((tostring('configure terminal') .. tostring('\r')))
    Switch:Write((table.concat({tostring('interface gigabitethernet 2/0/'), tostring(escape_control_string(s)), tostring('\r')})))
    Switch:Write((tostring('power inline never') .. tostring('\r')))
    Controls['POE Enabled SW2'][s].Boolean = false
    Timer.CallAfter(function()
      Switch:Write((tostring('power inline auto') .. tostring('\r')))
      Switch:Write((tostring('exit') .. tostring('\r')))
      Switch:Write((tostring('exit') .. tostring('\r')))
      Controls['POE Enabled SW2'][s].Boolean = true
    end,5)
  end
end

--Make Connect Button Visible
Controls['Connect'].EventHandler = function()
  Switch:Write((tostring(escape_control_string( Controls['Password'].String )) .. tostring('\r \r')))
  Timer.CallAfter(function()
      Switch:Write((tostring('enable') .. tostring('\r \r')))
    Timer.CallAfter(function()
        Switch:Write((tostring(escape_control_string( Controls['ENBABLE Password'].String )) .. tostring('\r \r')))
      Timer.CallAfter(function()
          if string_contains(tostring(logic_ternary((escape_control_string( Controls['Response'].String ) == nil), function() return '' end, function() return escape_control_string( Controls['Response'].String ) end)), '# ') == true then
          Controls['Device Online'].Boolean = true
        end
        Timer.CallAfter(function()
            Switch:Write((tostring('sh mac address-table | include Gi1/0/([1-2])') .. tostring('\r')))
          Timer.CallAfter(function()
              Switch:Write((tostring('sh mac address-table | include Gi1/0/([3-9])') .. tostring('\r')))
            Timer.CallAfter(function()
                Switch:Write((tostring('sh mac address-table | include Gi2/0/([1-2])') .. tostring('\r')))
              Timer.CallAfter(function()
                  Switch:Write((tostring('sh mac address-table | include Gi2/0/([3-9])') .. tostring('\r')))

              end,0.1)

            end,0.1)

          end,0.1)

        end,0.1)

      end,0.1)

    end,0.2)

  end,0.2)
end

--Initialise states on program startup
Response = ''
Controls['Response'].String = ''
for i = 1, 48 do
  Controls['Mac Address SW1'][i].String = ''
end
for i = 1, 48 do
  Controls['Mac Address SW2'][i].String = ''
end
Controls['Device Online'].Boolean = false
for i = 1, 48 do
  Controls['POE Enabled SW1'][1].Boolean = true
end
for i = 1, 48 do
  Controls['POE Enabled SW2'][1].Boolean = true
end

Controls ['Connect'].IsInvisible = true
Controls['Switch.IP_Address'].String = escape_control_string( Controls['IP Address'].String )
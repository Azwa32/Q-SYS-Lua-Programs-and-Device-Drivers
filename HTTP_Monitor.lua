-- Uses a heartbeat pulse to determine if port 80 is accessable on a device.
-- can be used as an alternative to a ping

--Initialise
status = Controls.status
address = Controls.address
go = Controls.go
online = Controls.online
pollDelay = 60
address = Controls.address
poll = Timer.New()

--print response from http
function done(tbl, code, data, err, headers)
  print(string.format( "HTTP response from %s: Return Code=%i; Error=%s", tbl.Url, code, err or "None" ) )
  setStatus(code)

  --[[  print("Headers:")
  for hName,Val in pairs(headers) do
    if type(Val) == "table" then
      print(string.format( "\t%s : ", hName )) 
      for k,v in pairs(Val) do
        print(string.format( "\t\t%s", v ) )
      end
    else
      print(string.format( "\t%s = %s", hName, Val ) )
    end 
  end
  print( "\rHTML Data: "..data )
  ]]--

end

--set status gui
function setStatus(code)
  if code == 200 then 
    status.Value = 0
    online.Boolean = true
  else 
    status.Value = 2
    online.Boolean = false
  end
end

--Start Http download
function getStatus()
  addr = address.String
  HttpClient.Download { Url = 'http://'..addr, Headers = { ["Content-Type"] = "application/json" } , Timeout = 30, EventHandler = done }
end

--Startup functions 
function Startup()
  address = Controls.address
  status.Value = 2
  poll:Start(pollDelay)
  getStatus()
end   

--EventHandlers
poll.EventHandler = getStatus  --runs when timer ticks
go.EventHandler = getStatus --manual trigger
address.EventHandler = Startup -- run startup when address is changed

Startup()
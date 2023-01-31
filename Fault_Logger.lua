--Initialise

status = Controls.Status
val = Controls.Value
fault = Controls.Fault_Status

----------------------
--Eventhandlers
-------------------------


--status
for i = 1, #status do
  status[i].EventHandler = function ()
  fault = ' | status '..i..' fault'
  resolved = ' | status '..i..' resolved'
    if status[i].Boolean == true then
      print(os.date()..fault)
    else    
      print(os.date()..resolved)
    end 
  end 
end 


--value
for k = 1, #val do
  val[k].EventHandler = function ()
  v = val[k].String
      print(os.date()..' | value '..k..' mode'..v)
  end 
end 



--fault status
fault.EventHandler = function ()
  print(os.date()..' | '..fault.String)
end 
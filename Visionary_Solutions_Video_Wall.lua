-- Custom module for controlling a dynamic videowall configuration. 
-- Allows video wall window size and source and  to be changed on the fly


-- initialise controls and objects
VWpreset = Controls.VWwindowingPreset
VWwindowSource = Controls['VWwindowSource']
VWaudio = Controls.VWaudioSelect
CiscoContent = Controls['CiscoContent']
VWwindowingPreset = Controls['VWwindowingPreset']
namedComponent_DEC1 = Component.New('DEC1')
AudioPresets = Component.New('Audio Presets')
CiscoWebex = Component.New('Cisco Webex')
VWDecToWindow = Controls['VWDecToWindow']
VWDecoderSource = Controls['VWDecoderSource']
VWGUI = Controls['VWGUI']
VWmouseSelect = Controls.VWmouseSelect
VWwindowSourceCommit = Controls.VWwindowSourceCommit
VWPresetCommit = Controls.VWwindowingPresetCommit
VCContentDecoder = 19
VideoWallSize = 18
VCcontentAuto = false    --true = auto content select, false = manual select from IRC

Encoder = {
  [0] = {['CompName'] = '', ['IP'] = '', ['Name'] = 'No_Image', ['Color'] = 'black'},
  [1] = {['CompName'] = 'ENC1', ['IP'] = '192.168.101.150', ['Name'] = 'PC1', ['Color'] = 'green'},
  [2] = {['CompName'] = 'ENC2', ['IP'] = '192.168.101.151', ['Name'] = 'PC2', ['Color'] = 'blue'},
  [3] = {['CompName'] = 'ENC3', ['IP'] = '192.168.101.152', ['Name'] = 'PC3', ['Color'] = 'red'},
  [4] = {['CompName'] = 'ENC4', ['IP'] = '192.168.101.153', ['Name'] = 'PC4', ['Color'] = 'purple'},
  [5] = {['CompName'] = 'ENC5', ['IP'] = '192.168.101.154', ['Name'] = 'PC5', ['Color'] = 'yellow'},
  [6] = {['CompName'] = 'ENC6', ['IP'] = '192.168.101.155', ['Name'] = 'PC6', ['Color'] = 'orange'},
  [7] = {['CompName'] = 'ENC7', ['IP'] = '192.168.101.156', ['Name'] = 'PC7', ['Color'] = 'olive'},
  [8] = {['CompName'] = 'ENC8', ['IP'] = '192.168.101.157', ['Name'] = 'PC8', ['Color'] = 'cyan'},
  [9] = {['CompName'] = 'ENC9', ['IP'] = '192.168.101.158', ['Name'] = 'VC_Primary', ['Color'] = '#ccccff'},
  [10] = {['CompName'] = 'ENC10', ['IP'] = '192.168.101.159', ['Name'] = 'VC_Secondary', ['Color'] = '#ffcc99'},
}

--Decoder WindowPos
--{x,y,z}
-- x = window size
-- y = window location
-- z = decoder is video walled
Decoder = {
  [1] = {['CompName'] = 'DEC1', ['VWCompName'] = 'DECVW1', ['IP'] = '192.168.101.160', ['Name'] = 'Screen 1', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [2] = {['CompName'] = 'DEC2', ['VWCompName'] = 'DECVW2', ['IP'] = '192.168.101.161', ['Name'] = 'Screen 2', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [3] = {['CompName'] = 'DEC3', ['VWCompName'] = 'DECVW3', ['IP'] = '192.168.101.162', ['Name'] = 'Screen 3', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [4] = {['CompName'] = 'DEC4', ['VWCompName'] = 'DECVW4', ['IP'] = '192.168.101.163', ['Name'] = 'Screen 4', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [5] = {['CompName'] = 'DEC5', ['VWCompName'] = 'DECVW5', ['IP'] = '192.168.101.164', ['Name'] = 'Screen 5', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [6] = {['CompName'] = 'DEC6', ['VWCompName'] = 'DECVW6', ['IP'] = '192.168.101.165', ['Name'] = 'Screen 6', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [7] = {['CompName'] = 'DEC7', ['VWCompName'] = 'DECVW7', ['IP'] = '192.168.101.166', ['Name'] = 'Screen 7', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [8] = {['CompName'] = 'DEC8', ['VWCompName'] = 'DECVW8', ['IP'] = '192.168.101.167', ['Name'] = 'Screen 8', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [9] = {['CompName'] = 'DEC9', ['VWCompName'] = 'DECVW9', ['IP'] = '192.168.101.168', ['Name'] = 'Screen 9', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [10] = {['CompName'] = 'DEC10', ['VWCompName'] = 'DECVW10', ['IP'] = '192.168.101.169', ['Name'] = 'Screen 10', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [11] = {['CompName'] = 'DEC11', ['VWCompName'] = 'DECVW11', ['IP'] = '192.168.101.170', ['Name'] = 'Screen 11', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [12] = {['CompName'] = 'DEC12', ['VWCompName'] = 'DECVW12', ['IP'] = '192.168.101.171', ['Name'] = 'Screen 12', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [13] = {['CompName'] = 'DEC13', ['VWCompName'] = 'DECVW13', ['IP'] = '192.168.101.172', ['Name'] = 'Screen 13', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [14] = {['CompName'] = 'DEC14', ['VWCompName'] = 'DECVW14', ['IP'] = '192.168.101.173', ['Name'] = 'Screen 14', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [15] = {['CompName'] = 'DEC15', ['VWCompName'] = 'DECVW15', ['IP'] = '192.168.101.174', ['Name'] = 'Screen 15', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [16] = {['CompName'] = 'DEC16', ['VWCompName'] = 'DECVW16', ['IP'] = '192.168.101.175', ['Name'] = 'Screen 16', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [17] = {['CompName'] = 'DEC17', ['VWCompName'] = 'DECVW17', ['IP'] = '192.168.101.176', ['Name'] = 'Screen 17', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [18] = {['CompName'] = 'DEC18', ['VWCompName'] = 'DECVW18', ['IP'] = '192.168.101.177', ['Name'] = 'Screen 18', ['Window'] = 0, ['WindowPos'] = {0,0,true}, ['Commands'] = {['PeerHost'] = '0', ['cfg_video_output'] = false, ['cfg_vw_max_rows'] = '0', ['cfg_vw_max_cols'] = '0', ['cfg_vw_row'] = '0', ['cfg_vw_col'] = '0', ['cfg_vw_ow'] = '0', ['cfg_vw_vw'] = '0', ['cfg_vw_oh'] = '0', ['cfg_vw_vh'] = '0', ['cfg_vw_active'] = false }},
  [19] = {['CompName'] = 'DEC19', ['VWCompName'] = 'DECVW19', ['IP'] = '192.168.101.178', ['Name'] = 'VC Content'},
  [20] = {['CompName'] = 'DEC20', ['VWCompName'] = 'DECVW20', ['IP'] = '192.168.101.179', ['Name'] = 'Lectern Keyboard'},
}

Window = {
  [1] = {['Size'] = 1, ['Source'] = VWwindowSource},
  [2] = {['Size'] = 1, ['Source'] = VWwindowSource},
  [3] = {['Size'] = 1, ['Source'] = VWwindowSource},
  [4] = {['Size'] = 1, ['Source'] = VWwindowSource},
  [5] = {['Size'] = 1, ['Source'] = VWwindowSource},
  [6] = {['Size'] = 1, ['Source'] = VWwindowSource},
  [7] = {['Size'] = 1, ['Source'] = VWwindowSource},
  [8] = {['Size'] = 1, ['Source'] = VWwindowSource},
  [9] = {['Size'] = 1, ['Source'] = VWwindowSource},
  [10] = {['Size'] = 1, ['Source'] = VWwindowSource},
  [11] = {['Size'] = 1, ['Source'] = VWwindowSource},
  [12] = {['Size'] = 1, ['Source'] = VWwindowSource},
  [13] = {['Size'] = 1, ['Source'] = VWwindowSource},
  [14] = {['Size'] = 1, ['Source'] = VWwindowSource},
  [15] = {['Size'] = 1, ['Source'] = VWwindowSource},
  [16] = {['Size'] = 1, ['Source'] = VWwindowSource},
  [17] = {['Size'] = 1, ['Source'] = VWwindowSource},
  [18] = {['Size'] = 1, ['Source'] = VWwindowSource},
}


AudioModeList = {
  [0] = {['Name'] = "Off", ['Preset'] = 1},
  [1] = {['Name'] = "PC 1", ['Preset'] = 2},
  [2] = {['Name'] = "PC 2", ['Preset'] = 3},
  [3] = {['Name'] = "PC 3", ['Preset'] = 4},
  [4] = {['Name'] = "PC 4", ['Preset'] = 5},
  [5] = {['Name'] = "PC 5", ['Preset'] = 6},
  [6] = {['Name'] = "PC 6", ['Preset'] = 7},
  [7] = {['Name'] = "PC 7", ['Preset'] = 8},
  [8] = {['Name'] = "PC 8", ['Preset'] = 9},
  [9] = {['Name'] = "VC Primary", ['Preset'] = 10},
  [10] = {['Name'] = "VC Secondary", ['Preset'] = 11},
  [100] = {['Name'] = "mixed", ['Preset'] = 12},
}

WindowPreset = {
  {
    -- Preset 1
    0,1,1,1,0,0,
    0,1,1,1,0,0,
    0,1,1,1,0,0,
  },
  {
    -- Preset 2
    1,1,2,2,3,3,
    1,1,2,2,3,3,
    0,0,0,0,0,0,
  },
  {
    -- Preset 3
    1,1,1,2,2,2,
    1,1,1,2,2,2,
    1,1,1,2,2,2,
  },
  {
    -- Preset 4
    1,1,1,2,3,4,
    1,1,1,5,6,7,
    1,1,1,8,9,10,
  },
  {
    -- Preset 5
    1,2,3,4,5,6,
    0,7,8,9,10,0,
    0,0,0,0,0,0,
  },
  {
    -- Preset 6
    1,2,3,4,5,6,
    0,7,7,8,8,0,
    0,7,7,8,8,0,
  },
  {
    -- Preset 7
    1,1,2,2,3,3,
    1,1,2,2,3,3,
    4,5,6,7,8,9,
  },
}

--VWwindowSource Window Size
WinSize = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

--Windowing specifics
--[a] = {[b] = xxxxxxxx}
--a = size of window
--b = window position
VideoWallSpecs = {
  [0] = {[0] = {['Video_Wall_ON'] = false}},
  [1] = {[1] = {['Video_Wall_ON'] = false}},
  [4] = {[1] = {['Video_Wall_ON'] = true, ['Column'] = 1, ['Row'] = 1},
         [2] = {['Video_Wall_ON'] = true, ['Column'] = 2, ['Row'] = 1},
         [3] = {['Video_Wall_ON'] = true, ['Column'] = 1, ['Row'] = 2},
         [4] = {['Video_Wall_ON'] = true, ['Column'] = 2, ['Row'] = 2},
         ['MAX_ROWS'] = 2,
         ['MAX_COLUMNS'] = 2,
         ['OVERALL_WIDTH'] = 7680,
         ['VISIBLE_WIDTH'] = 7680,
         ['OVERALL_HEIGHT'] = 4320,
         ['VISIBLE_HEIGHT'] = 4320,
         },
  [9] = {[1] = {['Video_Wall_ON'] = true, ['Column'] = 1, ['Row'] = 1},
         [2] = {['Video_Wall_ON'] = true, ['Column'] = 2, ['Row'] = 1},
         [3] = {['Video_Wall_ON'] = true, ['Column'] = 3, ['Row'] = 1},
         [4] = {['Video_Wall_ON'] = true, ['Column'] = 1, ['Row'] = 2}, 
         [5] = {['Video_Wall_ON'] = true, ['Column'] = 2, ['Row'] = 2},
         [6] = {['Video_Wall_ON'] = true, ['Column'] = 3, ['Row'] = 2},
         [7] = {['Video_Wall_ON'] = true, ['Column'] = 1, ['Row'] = 3}, 
         [8] = {['Video_Wall_ON'] = true, ['Column'] = 2, ['Row'] = 3},
         [9] = {['Video_Wall_ON'] = true, ['Column'] = 3, ['Row'] = 3},
         ['MAX_ROWS'] = 3,
         ['MAX_COLUMNS'] = 3,
         ['OVERALL_WIDTH'] = 11520,
         ['VISIBLE_WIDTH'] = 11520,
         ['OVERALL_HEIGHT'] = 6480,
         ['VISIBLE_HEIGHT'] = 6480,
         },
}



-- initialise Visionary solutions commands
Commands = {
  ['Source'] = { 
    'PeerHost',
    'cfg_video_output',
  },
  ['VW'] = {
    'cfg_vw_max_rows',
    'cfg_vw_max_cols',
    'cfg_vw_row',
    'cfg_vw_col',
    'cfg_vw_ow',
    'cfg_vw_vw',
    'cfg_vw_oh',
    'cfg_vw_vh',
  },      
}


---------------------------------------------------------------
-- Startup
---------------------------------------------------------------
function Startup()
  SetENCAddress()
  SetDECAddress()
  Timer.CallAfter(AssignToWindow,1)
  KBdecoderSet()
end


--------------------------------------------------------------
--Initialise Decoder & Encoder Addresses
--------------------------------------------------------------
function SetENCAddress()
  for x = 1, #(Encoder) do
    device = Component.New('ENC'..x)
    device['IP_ADDRESS'].String = Encoder[x]['IP']
  end
end

function SetDECAddress()
  for x = 1, #(Decoder) do
    device = Component.New('DECVW'..x)
    device['DeviceHost'].String = Decoder[x]['IP']
  end
end

---------------------------------------------------------------
-- Preset Change
---------------------------------------------------------------
-- Assign decoder to window
-- Needs to be run accross all video wall decoders for every preset change
function AssignToWindow() 
  for x = 1,#(VWwindowSource) do
    -- assign each decoder to a window based on the preset
    Decoder[x]['Window'] = WindowPreset[VWpreset.Value][x]
  end

  -- initialise size of window variable
  for x = 1, #(VWwindowSource) do
    WinSize[x] = 0
    for y = 1, #(Decoder) do
      if Decoder[y]['Window'] == x then
        WinSize[x] = WinSize[x] + 1
      end
    end
  end 
    
  -- set decoder window size variable
  for x = 1, #(VWDecoderSource) do
    OldSize = Decoder[x]['WindowPos'][1]
    NewSize = WinSize[Decoder[x]['Window']]
    if NewSize ~= nil then
      Decoder[x]['WindowPos'][1] =  NewSize
    else 
      Decoder[x]['WindowPos'][1] = 0
    end
    if NewSize ~= OldSize then
      Decoder[x]['WindowPos'][3] =  true
    end
  end
  
  
  --set decoder position variable
  for win = 1, #(VWwindowSource) do
    NewPos = 0
    for dec = 1, #(VWDecoderSource) do
      -- if decoder's window is the same as win then increment NewPos +1 and apply to decoders window position
      if Decoder[dec]['Window'] == win then
        NewPos = NewPos + 1
        OldPos = Decoder[dec]['WindowPos'][2]
        Decoder[dec]['WindowPos'][2] = NewPos
      elseif Decoder[dec]['Window'] == 0 then
        Decoder[dec]['WindowPos'][2] = 0
      end
      if NewPos ~= OldPos then 
        Decoder[dec]['WindowPos'][3] =  true
      end
    end   
  end

    -- set decoders
  SetDecoder()
  CiscoMon2() --set second output of webex
end


---------------------------------------------------------------
-- Source Change
---------------------------------------------------------------
function SetDecoder()
  for dec = 1, VideoWallSize do
    --assign Video Wall variables 
    DecoderWindowSize = Decoder[dec]['WindowPos'][1]
    DecoderWindowPosition = Decoder[dec]['WindowPos'][2]
    cfg_vw_active = VideoWallSpecs[DecoderWindowSize][DecoderWindowPosition]['Video_Wall_ON']
    cfg_vw_row = VideoWallSpecs[DecoderWindowSize][DecoderWindowPosition]['Row']
    cfg_vw_col = VideoWallSpecs[DecoderWindowSize][DecoderWindowPosition]['Column']
    cfg_vw_max_rows = VideoWallSpecs[DecoderWindowSize]['MAX_ROWS']
    cfg_vw_max_cols = VideoWallSpecs[DecoderWindowSize]['MAX_COLUMNS']
    cfg_vw_ow = VideoWallSpecs[DecoderWindowSize]['OVERALL_WIDTH']
    cfg_vw_vw = VideoWallSpecs[DecoderWindowSize]['VISIBLE_WIDTH']
    cfg_vw_oh = VideoWallSpecs[DecoderWindowSize]['OVERALL_HEIGHT']
    cfg_vw_vh = VideoWallSpecs[DecoderWindowSize]['VISIBLE_HEIGHT']

   
    --send values to Decoder objects variables
    cmds = Decoder[dec]['Commands'] 
    cmds['cfg_video_output'] = cfg_video_output
    cmds['PeerHost'] = PeerHost
    cmds['cfg_vw_row'] = cfg_vw_row
    cmds['cfg_vw_col'] = cfg_vw_col
    cmds['cfg_vw_max_rows'] = cfg_vw_max_rows
    cmds['cfg_vw_max_cols'] = cfg_vw_max_cols
    cmds['cfg_vw_ow'] = cfg_vw_ow
    cmds['cfg_vw_vw'] = cfg_vw_vw
    cmds['cfg_vw_oh'] = cfg_vw_oh
    cmds['cfg_vw_vh'] = cfg_vw_vh
    cmds['cfg_vw_active'] = cfg_vw_active



    --compensate for nil or zero values
    window = Decoder[dec]['Window']
    if window == 0 then
      source = 0
    else 
      source = VWwindowSource[window].Value
    end
    --initialise sources and display on/off
    if source ~= 0 then
      Decoder[dec]['Commands']['cfg_video_output'] = 'NORMAL' 
      Decoder[dec]['Commands']['PeerHost'] = Encoder[source]['IP'] 
    else 
      Decoder[dec]['Commands']['cfg_video_output'] = 'LOGO'
      Decoder[dec]['Commands']['PeerHost'] = ''
    end

    if dec == VideoWallSize then 
      SendSRCCMD()
    end
  end 
end
      

function SendSRCCMD()  --runs once for each command
  -- send source commands from Decoder object to decoder
   --loop through players
  for dec = 1, VideoWallSize do
    cmd = 'PeerHost'
    decName = Decoder[dec]['VWCompName']
    decObj = Component.New(decName)
       
    --limit sending 'PeerHost' command to decoders that are displaying stream 
    if Decoder[dec]['Commands']['cfg_video_output'] == 'NORMAL' then 
    --send command
      decObj[cmd].String = Decoder[dec]['Commands'][cmd]
    end
  end

  Timer.CallAfter(VWOFF,.3)
end



function VWOFF()
  for dec = 1, VideoWallSize do
    if Decoder[dec]['WindowPos'][3] then 
      decName = Decoder[dec]['VWCompName']
      decObj = Component.New(decName)

    --initialise cfg_vw_active to off  
      decObj['cfg_vw_active'].Boolean = false
    end
  end
  Timer.CallAfter(SendVWcmd,1)
end


VWCMD = 1
function SendVWcmd() --run recursively, once for each command
  if VWCMD <= #(Commands['VW']) then

  --loop through players
    for dec = 1, VideoWallSize do

      Value = Commands['VW'][VWCMD] 
      decName = Decoder[dec]['VWCompName']
      decObj = Component.New(decName)

      --if VW turned on
      if Decoder[dec]['Commands']['cfg_vw_active'] and Decoder[dec]['WindowPos'][3] then
        --send commands
        decObj[Value].String = Decoder[dec]['Commands'][Value]
      end
    end
    VWCMD = VWCMD + 1
    --delay required to slow down commands as they are entered into the module
    Timer.CallAfter(SendVWcmd,.3)
  else
    --carry on with the program
    cfg_vw_active_ON()
    VWCMD = 1
  end
end


function cfg_vw_active_ON()
  --turn on cfg_vw_active where required
  for dec = 1, VideoWallSize do
    if Decoder[dec]['Commands']['cfg_vw_active'] and Decoder[dec]['WindowPos'][3] then
      Component.New(Decoder[dec]['VWCompName'])['cfg_vw_active'].Boolean = true
    end
    
  end
  Timer.CallAfter(SendDisplayON,.3)
end


function SendDisplayON()  --run once for each command
  -- send source commands from Decoder object to decoder
   --loop through players
  for dec = 1, VideoWallSize do

    command = 'cfg_video_output'
    decName = Decoder[dec]['VWCompName']
    decObj = Component.New(decName)

    --send commands
    decObj[command].String = Decoder[dec]['Commands'][command]
  end
  ChangesReset()
end


--restore 'VW changes required' to false
function ChangesReset()
  for dec = 1, VideoWallSize do
    Decoder[dec]['WindowPos'][3] = false  -- set 'Video Wall changes made' status to false
  end
  SetGui()
end


-- Set GUI
function SetGui()  
  for dec = 1, VideoWallSize do
    window = Decoder[dec]['Window']
    if window == 0 then
      source = 0
    else 
      source = VWwindowSource[window].Value
    end
    VWGUI[dec].Color =  Encoder[source]['Color'] 
    VWDecoderSource[dec].Value = source
  end
  VCdecoderSet()
end



-- set keyboard encoders to the source on top left most decoder  
function VCdecoderSet()  
  if VCcontentAuto then --Auto VC Decoder Set to TRUE

    -- eg if decoder 7 is being changed by this function, set the VC Content decoders to the new source on DEC7
    -- find the first active decoder based on the Check sequence
    VCTargetDecoder = 1
    --order for checking decoders
    --Check = {1,7,13,2,8,14,3,9,15,4,10,16,5,11,17,6,12,18} --LHS biased
    Check = {6,12,18,5,11,17,4,10,16,3,9,15,2,8,14,1,9,13} --RHS biased
    for x = 1, #(Check) do
      VCTargetDecoder = Check[x]
      if VWDecoderSource[VCTargetDecoder].Value ~= 0 then break 
      end 
    end
    
    -- if the assigned decoder is being changed by this function, set the keyboard decoders to the new source shown on the KBM decoder
    -- delay required so the above loop has time to run
    Timer.CallAfter(function()
      for dec = 1, #(Decoder) do
        if dec == VCTargetDecoder then
          SourceVC = VWDecoderSource[VCTargetDecoder].Value
          vcDec = 19  --VC content decoder
          Component.New(Decoder[vcDec]['VWCompName'])['PeerHost'].String = Encoder[SourceVC]['IP']
          Component.New(Decoder[vcDec]['VWCompName'])['action_save']:Trigger()
        end
      end
    end, .3)

  else  --Auto VC Decoder Set to FALSE
    for input = 1, #(CiscoContent) do 
      if CiscoContent[input].Boolean then
        decoder = Component.New(Decoder[VCContentDecoder]['CompName'])
        VWdecoder = Component.New(Decoder[VCContentDecoder]['VWCompName'])
        encName = Encoder[input]['Name']
        encIP = Encoder[input]['IP']

        --decoder['video_output_mode'].String = 'NORMAL' 
        VWdecoder['PeerHost'].String = encIP
        Timer.CallAfter(function()  
          VWdecoder['action_save']:Trigger() 
        end , 1)  
      end
    end
  end
  Save()
end

--save on all decoders
function Save()
  for dec = 1, #(Decoder) do
    Component.New(Decoder[dec]['VWCompName'])['action_save']:Trigger()
  end
end

---------------------------------------------------------------
-- Cisco & Video Conferencing
---------------------------------------------------------------

--Cisco Webex turn on/off secondary display output
--Only when the encoder for the VC's 2nd display is shown on the Video Wall should the ciscos second monitor out be visible
--Once 2nd mon out stops displaying, put cisco back to single screen
function CiscoMon2()
  enable = 'Single'
  --check if a visible window is displaying the source
  --check through encoders to see the windows they are displaying
  for dec = 1, 18 do 
    decWindow = Decoder[dec]['Window']
    if decWindow ~= 0 then
      if VWwindowSource[decWindow].Value == 10 then
        enable = 'Dual'
      end
    end
  end

  --send command
  CiscoWebex['monitors'].String = enable
end

---------------------------------------------------------------
-- Keyboard and Mouse
---------------------------------------------------------------
-- set decoder to selected KBM
function KBdecoderSet()
  source = VWmouseSelect.Value
  kbDec = 20
  Component.New(Decoder[kbDec]['VWCompName'])['PeerHost'].String = Encoder[source]['IP']
  Component.New(Decoder[kbDec]['VWCompName'])['action_save']:Trigger()
end



---------------------------------------------------------------
-- VVVVV EVENT HANDLERS VVVVV
---------------------------------------------------------------

-- Crestron Control
-- Video Wall Preset Event Handler, VWwindowingPreset
VWPresetCommit.EventHandler = function ()
  if WindowPreset[VWpreset.Value] ~= nil then
    AssignToWindow()
    print("**video wall preset "..VWwindowingPreset.String.." selected")
  end
end

for i = 1, #VWwindowSource do
  VWwindowSource[i].EventHandler = function()
    print("**source change")
  end
end
 

-- Change window source, VWwindowSource
VWwindowSourceCommit.EventHandler = function()
  SetDecoder()
  CiscoMon2()  -- set Cisco second monitor
  print("**sources set")
end


-- Audio mode select, VWaudioSelect
VWaudio.EventHandler = function()
  a = VWaudio.Value
  preset = AudioModeList[a]['Preset']
  AudioPresets['load_'..preset].Boolean = true
  print("**audio "..AudioModeList[a]['Name'].." selected")
end 

-- Mouse Control
VWmouseSelect.EventHandler = function()
  KBdecoderSet()
  print("**"..AudioModeList[source]['Name'].." selected for KBM")
end


--Cisco Control, Cisco content, From Touch 10
for x = 1, #Controls.CiscoContent do
  CiscoContent[x].EventHandler = function()
    if CiscoContent[x].Boolean then
      encName = Encoder[x]['Name']
      print('**cisco content source '..encName..' selected')
      VCdecoderSet()
    end
  end
end

Startup()
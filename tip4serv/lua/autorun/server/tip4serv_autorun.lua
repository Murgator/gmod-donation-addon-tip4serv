-- Tip4serv plugin 1.1.3

include("autorun/sha256.lua")

-- Tip4serv class
if not Tip4serv then    
    
    -- CLASS MEMBERS    

    Tip4serv = {}
    Tip4serv.response_path = "tip4serv/response.json"
    Tip4serv.Config = {}
    Tip4serv.Config.data =  {
        ["key"] = "YOUR_API_KEY",
        ["request_interval_in_minutes"] = "2",
        ["order_received_text"] = "Thank you for your purchase :)"
    }
    
    -- CLASS METHODS
    
    -- Generates config files for tip4serv
    function Tip4serv.Config.CreateConfig() 
        if not file.Exists("tip4serv".."/config.json","DATA") then 
            file.CreateDir("tip4serv")
            file.Write("tip4serv".."/config.json",util.TableToJSON(Tip4serv.Config.data,true))
        end
    end
    
    -- Load config files for tip4serv
    function Tip4serv.Config.Load()
        local data = file.Read("tip4serv".."/config.json","DATA")
        if not data then MsgC(Color(255,0,0),"Config file not found for Tip4serv\n") return end
        Tip4serv.Config.data = util.JSONToTable(data)
    end

    -- Main Function of the class : retrieve transactions, handle transactions & send transaction status
    Tip4serv.check_pending_commands = function (server_id,private_key,public_key,timestamp,get_cmd)
        -- MAC calculation        
        local MAC = Tip4serv.calculateHMAC(server_id, public_key, private_key, timestamp)
        -- Get last infos json file
        local response = Tip4serv_LoadResourceFile(Tip4serv.response_path)
        local json_encoded = ""
        if (response) then
            json_encoded = Tip4serv.urlencode(response)
        end
        -- Request Tip4serv
        local statusUrl = "https://api.tip4serv.com/payments_api_v2.php?id="..server_id.."&time="..timestamp.."&json="..json_encoded.."&get_cmd="..get_cmd
          
        http.Fetch(statusUrl,function(tip4serv_response,size,headers,statusCode)
    
            if (statusCode ~= 200 or tip4serv_response == nil) then
                if (get_cmd == "no") then
                    MsgC(Color(0,255,0),"Tip4serv API is temporarily unavailable, maybe you are making too many requests. Please try again later") return    
                end
                return
            end                
            -- Tip4serv connect
            if (get_cmd == "no") then
                MsgC(Color(0,255,0),tip4serv_response) return
            end    
            -- Check for error
            local json_decoded = util.JSONToTable(tip4serv_response)        
            if (json_decoded == nil) then
                if string.match(tip4serv_response, "No pending payments found") then
                    Tip4serv_SaveResourceFile(Tip4serv.response_path, "")
                    return                
                elseif string.match(tip4serv_response, "Tip4serv") then
                    MsgC(Color(0,255,0),tip4serv_response) 
                    return
                end    
            end
            -- Clear old json infos
            Tip4serv_SaveResourceFile(Tip4serv.response_path, "")
            -- Loop customers
            local new_json = {}
        
            for k,infos in ipairs(json_decoded) do
                local new_obj = {} local new_cmds = {}
                new_obj["date"] = os.date("%c")
                new_obj["action"] = infos["action"]
                -- Check if player is online and get username
                player_infos = Tip4serv.checkifPlayerIsLoaded(infos)
                
                if player_infos then
                    player_infos:PrintMessage(HUD_PRINTTALK,Tip4serv.Config.data.order_received_text)
                end
                
                -- Execute commands for player
                if type(infos["cmds"]) == "table" then                  
                    for k,cmd in ipairs(infos["cmds"]) do
                        -- Do not run this command if the player must be online
                        if (player_infos == false and (string.match(cmd["str"], "{") or cmd["state"] == 1)) then
                            new_obj["status"] = 14
                        else
                            -- Replace option by player username
                            if (player_infos and string.match(cmd["str"], "{gmod_username}")) then
                                cmd["str"] = string.gsub(cmd["str"], "{gmod_username}", player_infos:Nick())
                            end
                            Tip4serv.exe_command(cmd["str"])                        
                            new_cmds[tostring(cmd["id"])] = 3
                        end
                    end
                    new_obj["cmds"] = new_cmds
                    if new_obj["status"] == nil then new_obj["status"] = 3 end
                    new_json[infos["id"]] = new_obj
                end
            end
            -- Save the new json file
            Tip4serv_SaveResourceFile(Tip4serv.response_path, util.TableToJSON(new_json))
        end, function(message) end, { ['Authorization'] = MAC })          
    end    
    
    -- Characters to hexadecimal (used for URL ENCODING)
    local char_to_hex = function(c)
        return string.format("%%%02X", string.byte(c))
    end    
    
    -- Loop over the playerlist & return a boolean if the player is connected
    Tip4serv.checkifPlayerIsLoaded = function ( infos)
        if infos["steamid"] ~= "" then
            for i, v in ipairs( player.GetAll() ) do
                if v:OwnerSteamID64() == infos["steamid"] then
                    return v
                end
            end
        end    
        return false
    end
    
    -- Base64 encoding algorithm
    Tip4serv.base64_encode = function ( data )
        local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        return ((data:gsub('.', function(x) 
            local r,b='',x:byte()
            for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
            return r;
        end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
            if (#x < 6) then return '' end
            local c=0
            for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
            return b:sub(c+1,c+1)
        end)..({ '', '==', '=' })[#data%3+1])
    end
    
    -- Decrypt the secret key
    Tip4serv.calculateHMAC = function (server_id, public_key, private_key, timestamp)
        local datas = server_id..public_key..timestamp
        return Tip4serv.base64_encode(sha256.hmac_sha256(private_key, datas))
    end
    
    -- URL Encoding algorithm for sending transaction data
    Tip4serv.urlencode = function(url)
        if url == nil then
            return
        end
        url = url:gsub("\n", "\r\n")
        url = url:gsub("([^%w ])", char_to_hex)
        url = url:gsub(" ", "+")
        return url
    end
    
    -- Execute commands on the server
    Tip4serv.exe_command = function(cmd)        
        MsgC(Color(0,255,0),"[Tip4serv] execute command: "..cmd)
        argv_gmod =  Tip4serv.split(cmd," ")
        main_cmd = argv_gmod[0]
        argv_gmod[0] =nil
        RunConsoleCommand(main_cmd,unpack(argv_gmod))
    end
    
    -- Split the differents commands to execute
    Tip4serv.split =  function(inputstr, sep)
        if sep == nil then
            sep = "%s"
        end
        local t={}
        i = 0
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i= i+1
        end
        return t
    end
end


-- ONSTART AREA


-- Check Tip4serv connection on script start
timer.Simple(0,function()
    Tip4serv.Config.CreateConfig()
    Tip4serv.Config.Load()
    timer.Create( "Tip4serv_CheckPaymentLoop", tonumber(Tip4serv.Config.data.request_interval_in_minutes)*60, 0, function() Tip4serv_checkPayment_every_x_min() end ) 
    if Tip4serv_check_api_key_validity() == false then return end
    Tip4serv.check_pending_commands(key_arr[0], key_arr[1], key_arr[2], os.time(os.date("!*t")),"no")
end)

-- Tip4serv connect command
concommand.Add("tip4serv",function(ply,cmd,args)
    --Only allow commands directly from server
    if IsValid(ply) then return end
    if(args[1] == "connect") then 
        Tip4serv.Config.CreateConfig()
        Tip4serv.Config.Load()
        MsgC(Color(0,255,0),"Connecting to Tip4Serv...\n")
        if Tip4serv_check_api_key_validity() == false then return end
        Tip4serv.check_pending_commands(key_arr[0], key_arr[1], key_arr[2], os.time(os.date("!*t")),"no")
    else 
        MsgC(Color(255,0,0),"Invalid Tip4serv command, correct use: tip4serv connect\n")
    end
end)


-- EXTERNAL FUNCTIONS


-- Checks if a purchase has been made every x minutes
function Tip4serv_checkPayment_every_x_min()
    if Tip4serv_check_api_key_validity() == false then return end
    Tip4serv.check_pending_commands(key_arr[0], key_arr[1], key_arr[2], os.time(os.date("!*t")),"yes")
end

-- Verify if the secret key is valid
function Tip4serv_check_api_key_validity()
    local missing_key = "[Tip4serv error] Please set key to a valid API key in data/tip4serv/config.json then restart tip4serv resource. Make sure you have copied the entire key on Tip4serv.com (CTRL+A then CTRL+C)"
    key_arr = {} i = 0
    for info in string.gmatch(Tip4serv.Config.data.key, '([^.]+)') do key_arr[i] = info i = i+1 end
    if (i ~= 3) then
        MsgC(Color(0,255,0),missing_key)
        return false
    end  
end


-- UTILS FUNCTIONS


-- Load transactions files
function Tip4serv_LoadResourceFile(path) 
    if not file.Exists(path,"DATA") then 
        file.CreateDir("tip4serv")
        file.Write(path,"")
    end
    local data = file.Read(path,"DATA")
    if not data then MsgC(Color(255,0,0),"Error while trying to read Tip4serv file\n") return end
    return data
end

-- Save transaction files
function Tip4serv_SaveResourceFile(path,data)
    file.Write(path,data)
end

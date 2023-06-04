include("tip4serv/file_manager.lua")
include("tip4serv/sha256.lua")

-- Tip4serv class
if not Tip4serv then    
    
    -- CLASS MEMBERS
    Tip4serv = {}
    Tip4serv.response_path = "tip4serv/response.json"
    Tip4serv.Config = {}
    Tip4serv.Colors = {}
    Tip4serv.MessageCache = {}
    Tip4serv.enabled = true
    
    -- Color Caching
    Tip4serv.Colors.red = Color(255,0,0)
    Tip4serv.Colors.green = Color(0,255,0)
    
    -- Config file
    Tip4serv.Config.data =  {
        ["key"] = "YOUR_API_KEY",
        ["request_interval_in_minutes"] = 2,
        ["order_received_text"] = "Thank you for your purchase :)"
    }
    
    -- CLASS METHODS
    
    -- Generates config files for tip4serv
    Tip4serv.Config.CreateConfig = function() 
        if not file.Exists("tip4serv/config.json","DATA") then 
            file.CreateDir("tip4serv")
            file.Write("tip4serv/config.json",util.TableToJSON(Tip4serv.Config.data,true)) --We do not need any callback since the addon is ready to work without config file
        end
    end
    
    -- Load config files for tip4serv
    Tip4serv.Config.Load =  function()
        local data = file.Read("tip4serv/config.json","DATA")
        if not data then MsgC(Tip4serv.Colors.red,"Config file not found for Tip4serv\n") return end
        Tip4serv.Config.data = util.JSONToTable(data)
        -- Type verification of config file
        if type(Tip4serv.Config.data.key)~="string" then 
            MsgC(Tip4serv.Colors.red,"Config.Key should be a string\n")
            Tip4serv.enabled = false
        end 
        if(type(Tip4serv.Config.data.request_interval_in_minutes)~="number") then
            if tonumber(Tip4serv.Config.data.request_interval_in_minutes) == nil then
                MsgC(Tip4serv.Colors.red,"Config.request_interval_in_minutes should be a number\n")
                Tip4serv.enabled = false
            end
        end
        if(type(Tip4serv.Config.data.order_received_text)~="string") then
            MsgC(Tip4serv.Colors.red,"Config.order_received_text should be a string\n")
            Tip4serv.enabled = false
        end        
        -- Handle order received message if it is bigger than 255 bytes
        if string.len(Tip4serv.Config.data.order_received_text) > 230 then
            Tip4serv.Config.data.order_received_text = string.sub(Tip4serv.Config.data.order_received_text,1,230)
            MsgC(Tip4serv.Colors.red,"Order Received text is too long please make a shorter message\n")
        end
    end

    -- MAIN FUNCTIONS
    
    -- Retrieve transactions, handle transactions & send transaction status
    Tip4serv.check_pending_commands = function (server_id,public_key,private_key,timestamp,get_cmd)
        -- MAC calculation      
        local MAC = Tip4serv.calculateHMAC(server_id, private_key, public_key, timestamp)
        -- Get last infos json file
        local response = File_manager.load_resource_file(Tip4serv.response_path,false)
        local json_encoded = ""
        if (string.len(response)>0) then
            json_encoded = Tip4serv.urlencode(response)
        end
        -- Build get_cmd query param
        local get_cmd_tip4serv = "no"
        if(get_cmd == true) then
            get_cmd_tip4serv="yes"
        end        
        -- Request Tip4serv        
        local statusUrl = "https://api.tip4serv.com/payments_api_v2.php?id="..server_id.."&time="..timestamp.."&json="..json_encoded.."&get_cmd="..get_cmd_tip4serv          
        http.Fetch(statusUrl,function(tip4serv_response,size,headers,statusCode)
            if (statusCode ~= 200 or tip4serv_response == nil) then
                if (get_cmd == false) then
                    MsgC(Tip4serv.Colors.red,"Tip4serv API is temporarily unavailable, maybe you are making too many requests. Please try again later\n") return    
                end
                return
            end                
            -- Tip4serv connect
            if (get_cmd == false) then
                MsgC(Tip4serv.Colors.green,tip4serv_response.."\n") return
            end    
            -- Check for error
            local json_decoded = util.JSONToTable(tip4serv_response)        
            if (json_decoded == nil) then
                if string.match(tip4serv_response, "No pending payments found") then
                    file.Delete(Tip4serv.response_path)
                    return                
                elseif string.match(tip4serv_response, "Tip4serv") then
                    MsgC(Tip4serv.Colors.green,tip4serv_response.."\n") 
                    return
                end    
            end
            -- Clear old json infos
            file.Delete(Tip4serv.response_path)
            -- Loop customers
            local new_json = {}
            -- Build a hash map about the current customers
            customers = Tip4serv.checkifPlayerIsLoaded(json_decoded);
            -- Loop all payments
            for k,infos in ipairs(json_decoded) do
                local new_obj = {} local new_cmds = {}
                new_obj["date"] = os.date("%c")
                new_obj["action"] = infos["action"]
                -- Check if player is online and get username
                local player_infos =  customers[infos["steamid"]]
                if player_infos  then
                    -- Order received text will always be 255 bytes or less because we've substracted it's length at startup
                    Tip4serv.send_chat_message(Tip4serv.Config.data.order_received_text,player_infos)
                end
                -- Execute commands for player
                if type(infos["cmds"]) == "table" then                  
                    for k,cmd in ipairs(infos["cmds"]) do
                        -- Do not run this command if the player must be online
                        if (player_infos == nil and (string.match(cmd["str"], "{") or cmd["state"] == 1)) then
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
            -- Save the new json file for API
            file.Write(Tip4serv.response_path,util.TableToJSON(new_json))
        end, function(message) end, { ['Authorization'] = MAC })          
    end    
    
    -- Verify if the secret key is valid
    Tip4serv.check_api_key_validity = function() 
        local missing_key = "[Tip4serv error] Please set key to a valid API key in data/tip4serv/config.json then restart tip4serv resource. Make sure you have copied the entire key on Tip4serv.com (CTRL+A then CTRL+C)"
        local key_arr = {} 
        local i = 0
        for info in string.gmatch(Tip4serv.Config.data.key, '([^.]+)') do key_arr[i] = info i = i+1 end
        if (i ~= 3) then
            MsgC(Tip4serv.Colors.red,missing_key.."\n")
            return false
        end  
        return key_arr
    end
    
    -- Sends the thank you message to player
    Tip4serv.send_chat_message = function(msg,ply)
        if rawget(Tip4serv.MessageCache,ply:SteamID64()) == nil then 
            ply:ChatPrint(Tip4serv.Config.data.order_received_text) --Message is already limited to 230 characters so no overflow can happen
            Tip4serv.MessageCache[ply:SteamID64()] = true --player won't receive any message anymore...
        end
    end
    
    -- Characters to hexadecimal (used for URL ENCODING)
    Tip4serv.char_to_hex = function(c)
        return string.format("%%%02X", string.byte(c))
    end 
    
    -- Returns every steam id that are currently waiting for their purchases
    Tip4serv.getCustomers = function ( data )
        local customers = {} --hashmap of customers (will store player object)
        for k,infos in ipairs(data) do 
            customers[infos["steamid"]] = 1 --give them a random value
        end
        return customers
    end

    -- Set all the connected flags to the customers who are currently waiting their delivery
    Tip4serv.checkifPlayerIsLoaded = function(data) 
        local tip4Customers = Tip4serv.getCustomers(data) -- this object only store steam id and will be deleted after
        local customers = {} --Hashmap <SteamID64,Player> 
        for i,connectedPlayer in ipairs(player.GetAll()) do
            if rawget(tip4Customers,connectedPlayer:SteamID64()) ~= nil then -- We use rawget for optimisation purposes
                customers[connectedPlayer:SteamID64()] = connectedPlayer -- We set the player for connected
            end
        end
        return customers
    end

    -- Custom Base64 encode for tip4serv
    Tip4serv.base64_encode = function ( data )
        -- We are using Tip4serv.base64_encode because it is slightly different than 
        -- utils.Base64 encoding algorithm so the result between this function and ours will be differents
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
        url = url:gsub("([^%w ])", Tip4serv.char_to_hex)
        url = url:gsub(" ", "+")
        return url
    end
    
    -- Execute commands on the server
    Tip4serv.exe_command = function(cmd)        
        MsgC(Tip4serv.Colors.green,"[Tip4serv] execute command: "..cmd.."\n")
        local argv_gmod = string.Split(cmd," ")
        local main_cmd = argv_gmod[1] -- Index starts at 1 -- 
        table.remove(argv_gmod,1)
        RunConsoleCommand(main_cmd,unpack(argv_gmod))
    end
end

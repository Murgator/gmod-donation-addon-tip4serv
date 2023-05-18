include("tip4serv/file_manager.lua")
include("tip4serv/sha256.lua")

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

    -- MAIN FUNCTIONS
    
    -- Retrieve transactions, handle transactions & send transaction status
    Tip4serv.check_pending_commands = function (server_id,private_key,public_key,timestamp,get_cmd)
        -- MAC calculation        
        local MAC = Tip4serv.calculateHMAC(server_id, public_key, private_key, timestamp)
        -- Get last infos json file
        local response = File_manager.load_resource_file(Tip4serv.response_path)
        local json_encoded = ""
        if (response) then
            json_encoded = Tip4serv.urlencode(response)
        end
        -- Request Tip4serv
        
        --build get_cmd query param
        local get_cmd_tip4serv = "no"
        if(get_cmd == true) then
            get_cmd_tip4serv="yes"
        end 
        local statusUrl = "https://api.tip4serv.com/payments_api_v2.php?id="..server_id.."&time="..timestamp.."&json="..json_encoded.."&get_cmd="..get_cmd_tip4serv
          
        http.Fetch(statusUrl,function(tip4serv_response,size,headers,statusCode)
    
            if (statusCode ~= 200 or tip4serv_response == nil) then
                if (get_cmd == false) then
                    MsgC(Color(0,255,0),"Tip4serv API is temporarily unavailable, maybe you are making too many requests. Please try again later\n") return    
                end
                return
            end                
            -- Tip4serv connect
            if (get_cmd == false) then
                MsgC(Color(0,255,0),tip4serv_response) return
            end    
            -- Check for error
            local json_decoded = util.JSONToTable(tip4serv_response)        
            if (json_decoded == nil) then
                if string.match(tip4serv_response, "No pending payments found") then
                    file.write(Tip4serv.response_path,"")
                    return                
                elseif string.match(tip4serv_response, "Tip4serv") then
                    MsgC(Color(0,255,0),tip4serv_response) 
                    return
                end    
            end
            -- Clear old json infos
            file.write(Tip4serv.response_path,"");
            -- Loop customers
            local new_json = {}
            ---build a hash map about the current customers
            local customers = Tip4serv.getCustomers(json_decoded) 
            customers = Tip4serv.checkifPlayerIsLoaded(customers);
            for k,infos in ipairs(json_decoded) do
                local new_obj = {} local new_cmds = {}
                new_obj["date"] = os.date("%c")
                new_obj["action"] = infos["action"]
                -- Check if player is online and get username
                player_infos =  customers[infos["steamid"]]
                if player_infos == false then
                    player_infos = nil
                end

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
            file.write(Tip4serv.response_path,util.TableToJSON(new_json))
        end, function(message) end, { ['Authorization'] = MAC })          
    end    
    
    -- Characters to hexadecimal (used for URL ENCODING)
    local char_to_hex = function(c)
        return string.format("%%%02X", string.byte(c))
    end 
    
    --Returns every steam id that are currently waiting for their purchases
    Tip4serv.getCustomers = function ( data )
        local customers = {} --hashmap of customers where false mean disconnected 
        for k,infos in ipairs(data) do 
            customers[infos["steamid"]] = false  --initiate them all to false
        end
        return customers
    end

    -- Set all the connected flags to the customers who are currently waiting their delivery
    Tip4serv.checkifPlayerIsLoaded = function(customers) 
        for i,connectedPlayer in ipairs(player.getAll()) do
            if rawget(customers,connectedPlayer:OwnerSteamID64()) ~= nil then -- We use rawget for optimisation purposes
                customers[connectedPlayer:OwnerSteamID64()] = connectedPlayer --We set the player for connected
            end
        end
        return customers
    end
    -- Decrypt the secret key
    Tip4serv.calculateHMAC = function (server_id, public_key, private_key, timestamp)
        local datas = server_id..public_key..timestamp
        return util.Base64Encode(sha256.hmac_sha256(private_key, datas))
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
        MsgC(Color(0,255,0),"[Tip4serv] execute command: "..cmd.."\n")
        argv_gmod =   cmd.split(" ")
        main_cmd = argv_gmod[0]
        argv_gmod[0] =nil
        RunConsoleCommand(main_cmd,unpack(argv_gmod))
    end
end

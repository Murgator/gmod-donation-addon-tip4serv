Tip4serv.enabled = true
Tip4serv.ready = false 
-- CLASS METHODS

-- Checks if a purchase has been made every x minutes
local function Tip4serv_checkPayment_every_x_min()
    local key_arr = Tip4serv.check_api_key_validity()
    if key_arr == false then return end
	
    Tip4serv.check_pending_commands(key_arr[0], key_arr[1], key_arr[2], os.time(os.date("!*t")),true)
end

-- Check Tip4serv connection on script start
local function Tip4serv_CheckConnection()
	if not Tip4serv.enabled then
		return
	end
	
	-- If we're all connected and enabled, run code
	if not timer.Exists( "Tip4serv_CheckPaymentLoop" ) then
		timer.Create( "Tip4serv_CheckPaymentLoop", tonumber(Tip4serv.Config.data.request_interval_in_minutes)*60, 0, function()
			Tip4serv_checkPayment_every_x_min()
		end )
	end

	local key_arr = Tip4serv.check_api_key_validity()
	if key_arr  == false then
		return
	end
	Tip4serv.check_pending_commands(key_arr[0], key_arr[1], key_arr[2], os.time(os.date("!*t")),false)
end
Tip4serv.config_sql_write = function() 
	local config_file =  {
		["key"] =Tip4serv.Config.data.key,
		["request_interval_in_minutes"] = Tip4serv.Config.data.request_interval_in_minutes,
		["order_received_text"] = Tip4serv.Config.data.order_received_text,
		["mysql_host"]="127.0.0.1",
		["mysql_username"] = "root",
		["mysql_password"] = "",
		["mysql_db"]="YOUR_DB_NAME",
		["mysql_enabled"]=false
	}
	Tip4serv.Config.data.mysql_host = "127.0.0.1"
	Tip4serv.Config.data.mysql_username = "root"
	Tip4serv.Config.data.mysql_password= ""
	Tip4serv.Config.data.mysql_db="YOUR_DB_NAME"
	Tip4serv.Config.data.mysql_enabled=false 
	 file.Write( "tip4serv/config.json", util.TableToJSON( config_file,true ) )


end
-- Load config files for tip4serv
Tip4serv.Load = function()
	file.AsyncRead( "tip4serv/config.json", "DATA", function( fileName, gamePath, status, data )
		if ( status == FSASYNC_OK ) then
			Tip4serv.Config.data = util.JSONToTable(data)
			
			-- Type verification of config file
			if not isstring( Tip4serv.Config.data.key ) then 
				MsgC(Tip4serv.Colors.red,Tip4serv.prefix_msgc.." Config.Key should be a string\n")
				Tip4serv.enabled = false
			end
			
			if not isnumber( Tip4serv.Config.data.request_interval_in_minutes ) then
				if tonumber(Tip4serv.Config.data.request_interval_in_minutes) == nil then -- Allow string (for compatibility with the old config file)
					MsgC(Tip4serv.Colors.red,Tip4serv.prefix_msgc.." Config.request_interval_in_minutes should be a number\n")
					Tip4serv.enabled = false
				end
			end

			if not isstring( Tip4serv.Config.data.order_received_text ) then
				MsgC(Tip4serv.Colors.red,Tip4serv.prefix_msgc.." Config.order_received_text should be a string\n")
				Tip4serv.enabled = false
			end
			
			-- Handle order received message if it is bigger than 255 bytes
			if string.len(Tip4serv.Config.data.order_received_text) > 255 then
				Tip4serv.Config.data.order_received_text = string.sub(Tip4serv.Config.data.order_received_text,1,255)
				MsgC(Tip4serv.Colors.red,Tip4serv.prefix_msgc.." Order Received text is too long please make a shorter message\n")
			end
			
			-- Load DB Data
			if Tip4serv.Config.data.mysql_host == nil and Tip4serv.Config.data.mysql_username ==nil and Tip4serv.Config.data.mysql_password == nil and Tip4serv.Config.data.mysql_db == nil then 
				Tip4serv.config_sql_write()
			end
			if not isstring(Tip4serv.Config.data.mysql_host) then 
				MsgC(Tip4serv.Colors.red,Tip4serv.prefix_msgc.." Config.mysql_host should be a string\n")
				Tip4serv.enabled=false
			end

			if not isstring(Tip4serv.Config.data.mysql_username) then 
				MsgC(Tip4serv.Colors.red,Tip4serv.prefix_msgc.." Config.mysql_username should be a string\n")
				Tip4serv.enabled=false
			end

			if not isstring(Tip4serv.Config.data.mysql_password) then 
				MsgC(Tip4serv.Colors.red,Tip4serv.prefix_msgc.." Config.mysql_password should be a string\n")
				Tip4serv.enabled=false
			end
			
			if not isstring(Tip4serv.Config.data.mysql_db) then 
				MsgC(Tip4serv.Colors.red,Tip4serv.prefix_msgc.." Config.mysql_db should be a string\n")
				Tip4serv.enabled=false
			end
			if not isbool(Tip4serv.Config.data.mysql_enabled) then 
				MsgC(Tip4serv.Colors.red,Tip4serv.prefix_msgc.." Config.mysql_enabled should be a boolean\n")
				Tip4MySQL.Config.data.mysql_enabled = false
			end
			Tip4serv.load_my_sql()
			if Tip4serv.Config.data.mysql_db ~= nil  and  Tip4serv.Config.data.mysql_db ~= "YOUR_DB_NAME" and Tip4serv.Config.data.mysql_enabled == true then 
				Tip4MySQL.check_connection(Tip4serv.Config.data.mysql_host,
				Tip4serv.Config.data.mysql_username,
				Tip4serv.Config.data.mysql_password,
				Tip4serv.Config.data.mysql_db)
			else 
				Tip4MySQL.enabled=false
				if Tip4serv.ready == false then
					Tip4serv.ready = true
				end
			end
			-- Check our connection
			Tip4serv_CheckConnection()
	
		else
			MsgC(Tip4serv.Colors.red,Tip4serv.prefix_msgc.." Config file not found for Tip4serv\n")
		end
	end)
end

-- MAIN FUNCTIONS

Tip4serv.load_my_sql = function()
	if Tip4serv.Config.data.mysql_enabled == true then 
		include("tip4serv/tip4mysql.lua")
		include("tip4serv/tip4storage.lua")
	end

end

-- Retrieve transactions, handle transactions & send transaction status
Tip4serv.call_api = function(server_id,timestamp,get_cmd,MAC,json_encoded)
	local get_cmd_tip4serv = "no"
		if(get_cmd == true) then
			get_cmd_tip4serv="yes"
		end
		-- Request Tip4serv        
		local statusUrl = "https://api.tip4serv.com/payments_api_v2.php?version="..Tip4serv.version.."&id="..server_id.."&time="..timestamp.."&json="..json_encoded.."&get_cmd="..get_cmd_tip4serv          
		http.Fetch(statusUrl,function(tip4serv_response,size,headers,statusCode)
			if (statusCode ~= 200 or tip4serv_response == nil) then
				if (get_cmd == false) then
					MsgC(Tip4serv.Colors.red,Tip4serv.prefix_msgc.." Tip4serv API is temporarily unavailable, maybe you are making too many requests. Please try again later\n") return    
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
			file.Write(Tip4serv.response_path,"{}")
			
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
						-- If Tip4Serv ask us to delete events with expire 
						if cmd["expire"] ~= nil then 
					
							--delete them using the identifier 
							Tip4Storage.delete_event(cmd["expire"],infos["steamid"])
							new_cmds[tostring(cmd["id"])] = 3 -- everything is ok
						else 
							--If there is events then also push events 
							if cmd["state"] > 1 then 	
								
								if player_infos == nil or not Tip4MySQL.enabled then 
									new_obj["status"]=14
								end
								if Tip4MySQL.enabled then 
									Tip4Storage.push_event(cmd["str"],infos["steamid"],cmd["state"])
								end
							end
							-- Do not run this command if the player must be online
							if (player_infos == nil and (string.match(cmd["str"], "{") or cmd["state"] >0)) then
									new_obj["status"]=14
							else
								-- Replace option by player username
								if (player_infos and string.match(cmd["str"], "{gmod_username}")) then
									cmd["str"] = string.gsub(cmd["str"], "{gmod_username}", player_infos:Nick())
								end
								if cmd["state"] >= 2 then 
									if Tip4MySQL.enabled then 
										Tip4serv.exe_command(cmd["str"])      
										new_cmds[tostring(cmd["id"])] = 3
									end
								else
									Tip4serv.exe_command(cmd["str"])      
									new_cmds[tostring(cmd["id"])] = 3
								end
							end
						end
					end
					new_obj["cmds"] = new_cmds
					if new_obj["status"] == nil then new_obj["status"] = 3 end
					new_json[infos["id"]] = new_obj
				end
			end

			-- Save the new json file for API
			file.Write( Tip4serv.response_path, util.TableToJSON( new_json ) )
			
		end, function(message) end, { ['Authorization'] = MAC })
end
Tip4serv.check_pending_commands = function (server_id,public_key,private_key,timestamp,get_cmd)
    -- MAC calculation      
    local MAC = Tip4serv.calculateHMAC(server_id, private_key, public_key, timestamp)
	
	local json_encoded = "{}"
	local response = file.Read( Tip4serv.response_path, "DATA" )
	if response ~= nil then 
		if (string.len(response)>0) then
			json_encoded = Tip4serv.urlencode(response)
		end
	end
	Tip4serv.call_api(server_id,timestamp,get_cmd,MAC,json_encoded)
end    

-- Verify if the secret key is valid
Tip4serv.check_api_key_validity = function()
    local missing_key = Tip4serv.prefix_msgc.." Set KEY to a valid API key in data/tip4serv/config.json then type: tip4serv connect (Find your key here: https://tip4serv.com/dashboard/my-servers)"
    local key_arr = {}
	local i = 0
	
	for info in string.gmatch(Tip4serv.Config.data.key, '([^.]+)') do
		key_arr[i] = info
		i = i+1
	end
	
	if (i ~= 3) then
        MsgC(Tip4serv.Colors.red,missing_key.."\n")
        return false
    end

    return key_arr
end

-- Sends the thank you message to player
Tip4serv.send_chat_message = function(msg,ply)
    if rawget(Tip4serv.MessageCache,ply:SteamID64()) == nil then 
		ply:ChatPrint(Tip4serv.Config.data.order_received_text) -- Message is already limited to 255 characters so no overflow can happen
        Tip4serv.MessageCache[ply:SteamID64()] = true -- Player won't receive any message anymore...
	end
end

-- Characters to hexadecimal (used for URL ENCODING)
Tip4serv.char_to_hex = function(c)
    return string.format("%%%02X", string.byte(c))
end 

-- Returns every steam id that are currently waiting for their purchases
Tip4serv.getCustomers = function( data )
    local customers = {} -- Hashmap of customers (will store player object)
	
    for k,infos in ipairs(data) do 
        customers[infos["steamid"]] = 1 -- Give them a random value
    end
	
    return customers
end

-- Set all the connected flags to the customers who are currently waiting their delivery
Tip4serv.checkifPlayerIsLoaded = function(data) 
    local tip4Customers = Tip4serv.getCustomers(data) -- This object only store steam id and will be deleted after
    local customers = {} -- Hashmap <SteamID64,Player> 
    for i,connectedPlayer in ipairs(player.GetAll()) do
        if rawget(tip4Customers,connectedPlayer:SteamID64()) ~= nil then -- We use rawget for optimisation purposes
            customers[connectedPlayer:SteamID64()] = connectedPlayer -- We set the player for connected
        end
    end
    
	return customers
end

-- Custom Base64 encode for Tip4serv
Tip4serv.base64_encode = function( data )
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
    MsgC(Tip4serv.Colors.green,Tip4serv.prefix_msgc.." execute command: "..cmd.."\n")
    local argv_gmod = string.Split(cmd," ")
    local main_cmd = argv_gmod[1] -- Index starts at 1
	
    table.remove(argv_gmod,1)
	
    RunConsoleCommand(main_cmd,unpack(argv_gmod))
end

-- Create and load config
local function Tip4serv_InitializeAddon()
	-- Generate the config file
	local config_file =  {
		["key"] = "YOUR_API_KEY",
		["request_interval_in_minutes"] = 1,
		["order_received_text"] = "Thank you for your purchase :)",
		["mysql_host"]="127.0.0.1",
		["mysql_username"] = "root",
		["mysql_password"] = "",
		["mysql_db"]="YOUR_DB_NAME",
		["mysql_enabled"]=false 
	}
	
	if not file.IsDir( "tip4serv", "DATA" ) then
		file.CreateDir( "tip4serv", "DATA" )
	end
	
	if not file.Exists( "tip4serv/config.json", "DATA" ) then 
        file.Write( "tip4serv/config.json", util.TableToJSON( config_file,true ) )
    end
	-- 0 second timer is required or else it will throw a ISteamHTTP isn't available error on startup.
	timer.Simple( 0, function()
		Tip4serv.Load()
	end )
end
hook.Add( "InitPostEntity", "Tip4serv_InitializeAddon", Tip4serv_InitializeAddon )


Tip4Storage.has_connection_orders = function(user_id) 
    for i, v in pairs(Tip4Storage.connection_queue) do  -- This array will be relatively small we can allow ourselves to make loop here 
        if v == user_id then 
            local ply = Player(user_id)

            if ply ~= nil then
                Tip4Storage.get_user_id(ply:SteamID64(),function(results)
                    Tip4Storage.player_received_cmds(results,Tip4Storage.Events.connect)
                end)
            end 
            table.remove(Tip4Storage.connection_queue,i)
            return
        end
    end
end
Tip4Storage.has_spawn_orders = function(user_id) 
    local ply = Player(user_id)
    if ply ~= nil then 
        Tip4Storage.get_user_id(ply:SteamID64(),function(results)
            Tip4Storage.player_received_cmds(results,Tip4Storage.Events.spawn)
        end)
    end
end

Tip4Storage.get_user_id = function(steam_id,callback)
    local sql_str = "SELECT * FROM tip4serv_users WHERE STEAMID='"..steam_id.."'"
    Tip4MySQL.query(sql_str,callback)
end

--When a player id has been received fetch the commands
Tip4Storage.player_received_cmds = function(results,type) 
    if results ~= nil then 
        local ply_tip4serv_id = results[1]["USER_ID"]
        Tip4Storage.get_cmds(ply_tip4serv_id,type)
    end
end

--Get all cmds to execute for an event & user 
Tip4Storage.get_cmds = function(user_id,type) 
    local sql_str = [[SELECT COMMAND,tip4serv_users.STEAMID AS STEAMID 
FROM tip4serv_orders 
INNER JOIN tip4serv_users
WHERE tip4serv_users.USER_ID=USER_LINK AND TYPE=]]..type..[[ AND USER_LINK=]]..user_id
.. " ORDER BY ID ASC "

    Tip4MySQL.query(sql_str,Tip4Storage.run_event_cmds)
end
Tip4Storage.push_connection_verify = function(user_id)
    table.insert(Tip4Storage.connection_queue,user_id)
end

--  This callback function is called when we retrieved a user and we want to push the user order
Tip4Storage.player_received_push = function(results,steam_id) 
    if results == nil then 
        Tip4Storage.push_new_user(steam_id,
        function()
            --once the user has been pushed just go back to the original point 
            Tip4Storage.get_user_id(steam_id,function(results_get)
                -- now results[1]["USER_ID"] is defined so just push the new order
                Tip4Storage.player_received_push(results_get,steam_id) 
            end)
        end)     
    else  
        Tip4Storage.push_new_order(results[1]["USER_ID"],steam_id)
    end
end

Tip4Storage.push_new_order = function(user_id,steam_id) 
    local cmd_storage = {}

    for k,v in pairs(Tip4Storage.cmds_queue[steam_id]) do 
        -- v correspond to this type of object [cmd, type] 
        local cmd = v[1]
        local type = v[2]
        local cmd_id = cmd..":"..type
        if cmd_storage[cmd_id] == nil then
            cmd_storage[cmd_id]=true
            --check if command already exist 
            Tip4MySQL.query([[SELECT * FROM tip4serv_orders INNER JOIN tip4serv_users 
            WHERE tip4serv_users.STEAMID="]]..steam_id..[[" AND USER_LINK=tip4serv_users.USER_ID AND COMMAND="]]..Tip4MySQL.escape(cmd)..[["]],
            function(results) 
                if results == nil or #results == 0 then --if no command push them
                    local sql_str = [[INSERT INTO tip4serv_orders (USER_LINK,COMMAND,TYPE) 
                    VALUES(']]..user_id..[[',']]..Tip4MySQL.escape(cmd)..[[',']]..type..[[')]]
                    
                    Tip4MySQL.query(sql_str,nil,function(err)
                        MsgC(Tip4serv.Colors.red,Tip4serv.prefix_msgc.." Failed to push order in tip4serv_orders for user :  "
                        ..steam_id.."\nError: "..err.."\n")
                    end)
                end
            end)
        end 
    end
    Tip4Storage.cmds_queue[steam_id]=nil
end

Tip4Storage.push_new_user = function(steam_id,callback) 
    local sql_str = "INSERT INTO tip4serv_users (STEAMID) VALUES ('"..steam_id.."')"
    --add an error 
    Tip4MySQL.query(sql_str,callback,function(err) 
        MsgC(Tip4serv.Colors.red,Tip4serv.prefix_msgc.." Failed to push user : "
        ..steam_id .." In the tip4serv_users table!\nError : "..err)
    end)
end

--After an event has been executed and we retrieved some events, execute those events
Tip4Storage.run_event_cmds = function(results) 
    if results ~= nil then 
        for i, row in pairs(results) do 
            local cmd = row["COMMAND"]
            if(string.gmatch(cmd,"{gmod_username}")) then
                local ply = player.GetBySteamID64(row["STEAMID"])
                cmd = string.gsub(cmd,"{gmod_username}",ply:Nick())
            end
            Tip4serv.exe_command(cmd)
        end
    end
end
Tip4Storage.add_cmd = function(cmd,type,steam_id) 
    if Tip4Storage.cmds_queue[steam_id]==nil then 
        Tip4Storage.cmds_queue[steam_id] = {}
    end
    table.insert(Tip4Storage.cmds_queue[steam_id],{cmd,type})
end

--function which is called to add a new order 
Tip4Storage.push_event= function(cmd,steam_id,type)

    if Tip4Storage.cmds_queue[steam_id] ~= nil then -- We are already fetching a user id so don't fetch twice  just add the command for later 
        Tip4Storage.add_cmd(cmd,type,steam_id)
        return 
    end

    Tip4Storage.add_cmd(cmd,type,steam_id) -- Push a new user and a new cmd  
    Tip4Storage.get_user_id(steam_id,function(results)
        Tip4Storage.player_received_push(results,steam_id)
    end)
end
Tip4Storage.delete_event = function(cmd,steam_id)
   local sql_str = [[DELETE tip4serv_orders FROM tip4serv_orders 
   INNER JOIN tip4serv_users
   WHERE tip4serv_users.STEAMID=']]..steam_id..[[' AND USER_LINK=tip4serv_users.USER_ID 
   AND COMMAND=']]..Tip4MySQL.escape(cmd)..[[']]
    Tip4MySQL.query(sql_str)
end
Tip4Storage.connection_queue = {}
Tip4Storage.cmds_queue = {}


-- Event Hooks 

gameevent.Listen("player_connect")
hook.Add("player_connect","TriggerOnConnectStorage",function(ply)
    if not Tip4MySQL.enabled then 
        return 
    end 
    Tip4Storage.push_connection_verify(ply.userid)

end)
gameevent.Listen("player_spawn")
hook.Add("player_spawn","TriggerOnSpawnStorage",function(ply)
    if not Tip4MySQL.enabled then 
        return 
    end 
    Tip4Storage.has_connection_orders(ply.userid)
    Tip4Storage.has_spawn_orders(ply.userid)
end)

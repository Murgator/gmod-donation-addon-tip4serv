-- This files provide extensional commands for ulx & DarkRp commands
-- it mainly focuses for extending ulx & darkrp commands which only accept username
-- we make them accept steam id now

-- Fix arguments for STEAMID format
Tip4serv.fixArgv = function(argv)
	if string.find(argv[2],"\"") == nil and string.find(argv[2],"STEAM_") ~= nil then     
		-- unite the steam id in one single string
		if #argv >= 6 then
			steam_id = table.concat(argv,"",2,6)
			res = {}
			table.insert(res,argv[1])
			table.insert(res,steam_id)
			for i=7,#argv do
				table.insert(res,argv[i])
			end
			return res
		end
	end
	return argv
end

-- Entry point for every commands
Tip4serv.runTip4serv = function(argv)
	if #argv >= 2 then
		argv = Tip4serv.fixArgv(argv)
	end
	if argv[1] == "giveid" then
		Tip4serv.giveid(argv)
	elseif argv[1] == "jobid" then 
		Tip4serv.jobid(argv)
	elseif argv[1] == "addmoneyid" then 
		Tip4serv.addmoneyid(argv)
	 elseif argv[1] == "say" then 
		Tip4serv.say(argv)
	else 
		MsgC(Tip4serv.Colors.red,"tip4serv: Not enough arguments! Available commands are: giveid, jobid, addmoneyid or say\n")
	end
end

Tip4serv.say = function(argv) 
	if #argv < 2 then 
		MsgC(Tip4serv.Colors.red,"tip4serv: Not enough arguments")
		return 
	end
	
	local msg = ""
	for i=2,#argv do 
		if argv[i] ~= "'" and argv[i] ~= "\"" and argv[i] ~= ":" then
			msg = msg..argv[i].." "
		else 
			msg = string.sub(msg,1,-2) -- remove last space
			msg = msg..argv[i]
		end
	end
	
	Tip4serv.SendChatMessageToAllPlayers(msg)
end
Tip4serv.SendChatMessageToAllPlayers = function(msg) 
	for _, ply in ipairs( player.GetAll() ) do 
		ply:ChatPrint( msg )    
	end 
end

-- Add DarkRP money to player
Tip4serv.addmoneyid = function(argv) 
	-- tip4serv addmoneyid <Player> <amount>
	if DarkRP == nil then 
		MsgC(Tip4serv.Colors.red,"tip4serv addmoneyid: DarkRP is not installed!\n")
		return
	end
	if #argv < 3 then 
		MsgC(Tip4serv.Colors.red,"tip4serv jobid: Not enough arguments!\n")
		return
	end
	local ply = Tip4serv.findPlayer(argv[2])
	if ply == nil then 
		MsgC(Tip4serv.Colors.red,"tip4serv addmoneyid: Player is disconnected!\n")
		return
	end
   Tip4serv.addmoney(ply,argv[3])
end

-- Edit DarkRP job of a player
Tip4serv.jobid = function(argv) 
	-- tip4serv jobid <Player> <Job>
	if DarkRP == nil then 
		MsgC(Tip4serv.Colors.red,"tip4serv jobid: DarkRP is not installed!\n")
		return
	end
	if #argv < 3 then 
		MsgC(Tip4serv.Colors.red,"tip4serv jobid: Not enough arguments!\n")
		return
	end
	local ply = Tip4serv.findPlayer(argv[2])
	if ply == nil then 
		MsgC(Tip4serv.Colors.red,"tip4serv jobid: Player is disconnected!\n")
		return
	end
	Tip4serv.ChangeJob(ply,argv[3])
end

-- Give entity to a player
Tip4serv.giveid = function(argv)
	--Tip4serv giveid <player> <item> <quantity=default=1)
	if #argv < 3 then 
		MsgC(Tip4serv.Colors.red,"tip4serv giveid: Not enough arguments has been provided!\n")
		return
	end
	local ply = Tip4serv.findPlayer(argv[2])
	if(ply == nil) then
		MsgC(Tip4serv.Colors.red,"tip4serv giveid: Player is disconnected!\n")
		return
	end
	if (not ply:Alive()) then 
		MsgC(Tip4serv.Colors.red,"tip4serv giveid: "..ply:Nick().." is dead!\n") 
	elseif ply:IsFrozen() then 
		MsgC(Tip4serv.Colors.red,"tip4serv giveid: "..ply:Nick().." is frozen!\n")
	elseif ply:InVehicle() then 
		MsgC(Tip4serv.Colors.red,"tip4serv giveid: "..ply:Nick().." is in a vehicle!\n")
	else 
		if argv[4] == nil then 
			argv[4] = 1
		end
		Tip4serv.giveItem(ply,argv[3],argv[4])
	end
end

-- Add money function
Tip4serv.addmoney = function(ply,amount) 
	ply:addMoney(amount)
	DarkRP.notify(ply,0,4,"You've received "..amount.."$")
end

-- Give item function
Tip4serv.giveItem = function(ply, item,quantity) 
	local itemEntity = ents.Create(item)
	-- test if item is valid
	if not IsValid(itemEntity) then
		MsgC(Tip4serv.Colors.red,"Tip4serv give: Invalid item name\n")
		return 
	end
	for i=0, quantity do 
		ply:Give(item)
	end
end

--Taken from DarkRP sv_jobs.lua
Tip4serv.ChangeJob = function(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
		return ""
	end

	if not GAMEMODE.Config.customjobs then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "/job", ""))
		return ""
	end

	local canChangeJob, message, replace = gamemode.Call("canChangeJob", ply, args)
	if canChangeJob == false then
		DarkRP.notify(ply, 1, 4, message or DarkRP.getPhrase("unable", "/job", ""))
		return ""
	end

	local job = replace or args
	DarkRP.notifyAll(2, 4, DarkRP.getPhrase("job_has_become", ply:Nick(), job))
	ply:updateJob(job)
	return ""
end

-- Find player object with steam id
Tip4serv.findPlayer = function(steam_id)
	if string.find(steam_id,"STEAM_") == nil then
		for i,connectedPlayer in ipairs(player.GetAll()) do
			if connectedPlayer:SteamID64() == steam_id and IsValid(connectedPlayer) and connectedPlayer:IsPlayer() then
				return connectedPlayer
			end
		end
	else
		for i,connectedPlayer in ipairs(player.GetAll()) do
			if connectedPlayer:SteamID() == steam_id and IsValid(connectedPlayer) and connectedPlayer:IsPlayer() then
				return connectedPlayer
			end
		end
	end
	
	return nil
end

-- This files provide extensional commands for ulx & DarkRp commands
-- it mainly focuses for extending ulx & darkrp commands which only accept username
-- we make them accept steam id now

if not Tip4extended then 

    -- Class Members 

    Tip4extended  = {}
    Tip4extended.Colors = {}
    Tip4extended.Colors.red = Color(255,0,0)

    --Class Methods 

    --Entry point for every commands
    Tip4extended.runTip4serv = function(argv)
        if argv[1] == "giveid" then
            Tip4extended.giveid(argv)
        elseif argv[1] == "jobid" then 
            Tip4extended.jobid(argv)
        elseif argv[1] == "addmoneyid" then 
            Tip4extended.addmoneyid(argv)
        else 
            MsgC(Tip4extended.Colors.red,"tip4serv: Unknown command!\n")
        end
    end
    Tip4extended.addmoneyid = function(argv) 
        --tip4serv addmoneyid <Player> <amount>
        if #argv < 3 then 
            MsgC(Tip4extended.Colors.red,"tip4serv jobid: Not enough arguments!\n")
            return
        end
        local player = Tip4extended.findPlayer(argv[2])
        if player == nil then 
            MsgC(Tip4extended.Colors.red,"tip4serv addmoneyid: player is disconnected!\n")
            return
        end
        if DarkRP == nil then 
            MsgC(Tip4extended.Colors.red,"tip4serv addmoneyid: DarkRP is not installed!\n")
            return
        end
       Tip4extended.addmoney(player,argv[3])
    end
    
    Tip4extended.jobid = function(argv) 
        --tip4serv jobid <Player> <Job>
        if #argv < 3 then 
            MsgC(Tip4extended.Colors.red,"tip4serv jobid: Not enough arguments!\n")
            return
        end
        local player  =Tip4extended.findPlayer(argv[2])
        if player == nil then 
            MsgC(Tip4extended.Colors.red,"tip4serv jobid: player is disconnected!\n")
            return
        end
        if DarkRP == nil then 
            MsgC(Tip4extended.Colors.red,"tip4serv jobid: DarkRP is not installed!\n")
            return
        end
       Tip4extended.ChangeJob(player,argv[3])
    end
    Tip4extended.giveid = function(argv)
        --Tip4serv giveid <player> <item> <quantity=default=1)
        if #argv < 3 then 
            MsgC(Tip4extended.Colors.red,"tip4serv giveid: Not enough arguments has been provided!\n")
            return
        end
        local player = Tip4extended.findPlayer(argv[2])
        if(player == nil) then
            MsgC(Tip4extended.Colors.red,"tip4serv giveid: Player is not online!\n")
            return
        end
        if (not player:Alive()) then 
            MsgC(Tip4extended.Colors.red,"tip4serv giveid: "..player:Nick().." is dead!\n") 
        elseif player:IsFrozen() then 
            MsgC(Tip4extended.Colors.red,"tip4serv giveid: "..player:Nick().." is frozen!\n")
        elseif player:InVehicle() then 
            MsgC(Tip4extended.Colors.red,"tip4serv giveid: "..player:Nick().." is in a vehicle!\n")
        else 
            if argv[4] == nil then 
                argv[4] = 1
            end
            Tip4extended.giveItem(player,argv[3],argv[4])
        end
    end
    Tip4extended.addmoney = function(player,amount) 
        player:addMoney(amount)
        DarkRP.notify(player,0,4,"You've received "..amount.."$")
    end
    Tip4extended.giveItem = function(player, item,quantity) 
        local itemEntity = ents.Create(item)
        --test if item is valid
        if not IsValid(itemEntity) then
            MsgC(Tip4extended.Colors.red,"Tip4serv give: Invalid item name\n")
            return 
        end
        for i=0, quantity do 
            player:Give(item)
        end
    end
    --Taken from DarkRP sv_jobs.lua
    Tip4extended.ChangeJob = function(ply, args)
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
    Tip4extended.findPlayer = function(steam_id)
        for i,connectedPlayer in ipairs(player.GetAll()) do 
            if connectedPlayer:SteamID64() == steam_id and  IsValid(connectedPlayer) and connectedPlayer:IsPlayer() then
                return connectedPlayer
            end
        end
        return nil
    end
end
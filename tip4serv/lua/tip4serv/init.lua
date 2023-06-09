-- Tip4serv connect command
concommand.Add("tip4serv",function(ply,cmd,args)
    -- Only allow commands directly from server
    if IsValid(ply) then return end
	
    if(args[1] == "connect") then
		Tip4serv.enabled = true
		
		MsgC(Tip4serv.Colors.green,"Connecting to Tip4Serv...\n")
		
        Tip4serv.Load()
    else
        Tip4serv.runTip4serv(args)
    end
end)

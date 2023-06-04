include("tip4serv/tip4serv.lua")
include ("tip4serv/tip4extended.lua")
-- Checks if a purchase has been made every x minutes
local function Tip4serv_checkPayment_every_x_min()
    local key_arr = Tip4serv.check_api_key_validity()
    if key_arr == false then return end
    Tip4serv.check_pending_commands(key_arr[0], key_arr[1], key_arr[2], os.time(os.date("!*t")),true)
end



Tip4serv.Config.CreateConfig()
Tip4serv.Config.Load()
-- Check Tip4serv connection on script start
if Tip4serv.enabled then
    timer.Simple(0,function()
        print(os.time(os.date("!*t")))
        timer.Create( "Tip4serv_CheckPaymentLoop", tonumber(Tip4serv.Config.data.request_interval_in_minutes)*60, 0, function() Tip4serv_checkPayment_every_x_min() end ) 
        local key_arr = Tip4serv.check_api_key_validity()
        if key_arr  == false then return end
        Tip4serv.check_pending_commands(key_arr[0], key_arr[1], key_arr[2], os.time(os.date("!*t")),false)
   end)
   -- Tip4serv connect command
    concommand.Add("tip4serv",function(ply,cmd,args)
     --Only allow commands directly from server
        if IsValid(ply) then return end         
        if(args[1] == "connect") then 
            Tip4serv.Config.CreateConfig()
            Tip4serv.Config.Load()
            MsgC(Tip4serv.Colors.green,"Connecting to Tip4Serv...\n")
            local key_arr = Tip4serv.check_api_key_validity()
            if key_arr == false then return end
                Tip4serv.check_pending_commands(key_arr[0], key_arr[1], key_arr[2], os.time(os.date("!*t")),false)
            else  --Tip4extended
                Tip4extended.runTip4serv(args)
            end
        end)
    concommand.Add("darkrp",function(ply,cmd,args)
        if IsValid(ply) then return end
        Tip4eaxtended.runTip4serv(args)
    end)
end

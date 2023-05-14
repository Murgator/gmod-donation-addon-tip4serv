-- Tip4serv plugin 1.2.1
include("tip4serv/tip4serv.lua")

-- Check Tip4serv connection on script start
timer.Simple(0,function()
    Tip4serv.Config.CreateConfig()
    Tip4serv.Config.Load()
    timer.Create( "Tip4serv_CheckPaymentLoop", tonumber(Tip4serv.Config.data.request_interval_in_minutes)*60, 0, function() Tip4serv_checkPayment_every_x_min() end ) 
    if Tip4serv_check_api_key_validity() == false then return end
    Tip4serv.check_pending_commands(key_arr[0], key_arr[1], key_arr[2], os.time(os.date("!*t")),false)
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
        Tip4serv.check_pending_commands(key_arr[0], key_arr[1], key_arr[2], os.time(os.date("!*t")),false)
    else 
        MsgC(Color(255,0,0),"Invalid Tip4serv command, correct use: tip4serv connect\n")
    end
end)

-- Checks if a purchase has been made every x minutes
function Tip4serv_checkPayment_every_x_min()
    if Tip4serv_check_api_key_validity() == false then return end
    Tip4serv.check_pending_commands(key_arr[0], key_arr[1], key_arr[2], os.time(os.date("!*t")),true)
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

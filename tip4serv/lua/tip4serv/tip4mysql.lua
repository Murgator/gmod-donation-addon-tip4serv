-- Is Tip4Serv vulnerable to SQL Injection ?
-- No, because each piece of data, like command payment id and so on...
-- Is verified from the Tip4Serv server.

Tip4MySQL = {} or {}
Tip4MySQL.type = "mysqloo"
Tip4MySQL.enabled = true 

Tip4MySQL.load_modules = function() 
    Tip4MySQL.enabled=true
    local MySQLOOSucc = pcall(require, "mysqloo")
    if MySQLOOSucc then 
        include("tip4serv/mysql_module/mysqloo.lua")
    else 
        MsgC(Tip4serv.Colors.red,Tip4serv.prefix_msgc.." MySQLOO is not installed, Please Install it to unlock the storage feature!\n")
        Tip4MySQL.enabled = false 
    end
end

Tip4MySQL.check_connection = function(host,username,password,db) 
    Tip4MySQL.load_modules()
    if  Tip4MySQL.enabled then 
        Tip4MySQL.connect_to_db(host,username,password,db)
    end
end

Tip4MySQL.init_tables = function() 
    Tip4MySQL.query([[
        CREATE TABLE IF NOT EXISTS `tip4serv_users` (
  `USER_ID` smallint(6) NOT NULL AUTO_INCREMENT,
  `STEAMID` varchar(20) NOT NULL,
  PRIMARY KEY (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]],nil,function(err) 
        MsgC(Tip4serv.Colors.red,Tip4serv.prefix_msgc.." Failed to create tip4serv_users table! Error: "..err.."\n")
        Tip4MySQL.enabled=false
    end,true)

    Tip4MySQL.query([[ 
        CREATE TABLE IF NOT EXISTS `tip4serv_orders`  (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `USER_LINK` smallint(6) NOT NULL,
  `TYPE` tinyint(4) NOT NULL,
  `COMMAND` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]],nil,function(err) 
        MsgC(Tip4serv.Colors.red,Tip4serv.prefix_msgc.." Failed to create tip4serv_orders table! Error"..err.."\n")
        Tip4MySQL.enabled=false
    end,true)
end

Tip4MySQL.escape = function(str) 
    return Tip4MySQL.db:escape(str)
end

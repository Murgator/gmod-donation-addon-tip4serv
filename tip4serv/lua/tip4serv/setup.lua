-- Storage Module

Tip4MySQL = Tip4MySQL or {}
Tip4MySQL.Config = Tip4MySQL.Config or {}

Tip4Storage = Tip4Storage or {}

-- Tip4serv Main Module 

Tip4serv = Tip4serv or {}

Tip4serv.Config = Tip4serv.Config or {}
Tip4serv.Colors = Tip4serv.Colors or {}
Tip4serv.MessageCache = Tip4serv.MessageCache or {}

Tip4serv.prefix_msgc = "[Tip4serv]"
Tip4serv.response_path = "tip4serv/response.json"
Tip4serv.version=1.4
-- Color Caching
Tip4serv.Colors.red = Color(255,0,0)
Tip4serv.Colors.green = Color(0,255,0)


-- Events Flag
Tip4Storage.Events = Tip4Storage.Events or {}
Tip4Storage.Events.connect = 2
Tip4Storage.Events.spawn = 3


-- File Manager class : handles the I/O for the data files --

if not File_manager then
    File_manager = {}
    -- Load transactions files
    File_manager.load_resource_file = function(path)
        if not file.Exists(path,"DATA") then 
            file.CreateDir("tip4serv")
            file.Write(path,"")
        end
        local data = file.Read(path,"DATA")
        if not data then MsgC(Color(255,0,0),"Error while trying to read Tip4serv file\n") return end
        return data
    end
end

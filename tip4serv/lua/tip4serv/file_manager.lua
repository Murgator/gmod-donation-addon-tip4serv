-- File Manager class : handles the I/O for the data files --

if not File_manager then
	File_manager = {}
	-- Load transactions files
	File_manager.load_resource_file = function(path,appendMode)
		if appendMode == true then
			if not file.Exists(path,"DATA") then 
				file.CreateDir("tip4serv")
				file.Write(path,"")
			end
		end
		local data = file.Read(path,"DATA")
		if not data then return "" end
		return data
	end
end

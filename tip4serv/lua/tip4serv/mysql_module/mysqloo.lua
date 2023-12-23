Tip4MySQL.db  = Tip4MySQL.db or {}
Tip4MySQL.connect_to_db = function(host,username,password,db_name) 
    Tip4MySQL.db = mysqloo.connect(host,username,password,db_name)

    function Tip4MySQL.db:onConnected(db) 
        MsgC(Tip4serv.Colors.green,Tip4serv.prefix_msgc.." Tip4Serv is connected to MySQL!\n")
        Tip4MySQL.init_tables()
    end

    function Tip4MySQL.db:onConnectionFailed(err,db)
        MsgC(Tip4serv.Colors.red,Tip4serv.prefix_msgc.." Failed to connect to database : "..err.."\n")
        Tip4MySQL.enabled=false
    end
    
    Tip4MySQL.db:connect()
    Tip4MySQL.db:wait()
end

Tip4MySQL.query = function(str,callback,error_callback,sync) 
    local sql_query = Tip4MySQL.db:query(str) 
    
    if callback ~= nil then 
        sql_query.onSuccess = function(q,results)
            if results[1] ~= nil then 
                callback(results)
            else 
                callback(nil)
            end
        end
    end
    if error_callback ~= nil then 
        sql_query.onError = function(data,err,query) 
            error_callback(err)
        end
    end

    sql_query:start()
    if sync ~= nil and sync == true then 
        sql_query:wait()
    end
end

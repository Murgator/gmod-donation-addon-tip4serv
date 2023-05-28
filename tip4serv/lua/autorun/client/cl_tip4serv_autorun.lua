local messageCache = nil

net.Receive("PaymentMessage", function()
    if messageCache == nil then --test
        local message = net.ReadString()
        messageCache = message --test2
        chat.AddText(message)
        return
    end
    chat.AddText(messageCache)
end)

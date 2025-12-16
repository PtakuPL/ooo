function translateNetworkError(errcode, connecting, errdesc)
    local text
    if errcode == 111 then
        text = tr("otclient_modules.net.tr_6")
    elseif errcode == 110 then
        text = tr("otclient_modules.net.tr_5")
    elseif errcode == 1 then
        text = tr("otclient_modules.net.tr_4")
    elseif connecting then
        text = tr("otclient_modules.net.tr_3")
    else
        text = tr("otclient_modules.net.tr_2")
    end
    text = text .. ' ' .. tr("otclient_modules.net.tr_1", errcode)
    return text
end

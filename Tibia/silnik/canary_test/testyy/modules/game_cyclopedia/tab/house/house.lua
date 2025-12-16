local UI = nil

function showHouse()
    UI = g_ui.loadUI("house", contentContainer)
    UI:show()
    UI.LateralBase.LayerScrollbar.decrementButton:setVisible(false)
    UI.LateralBase.LayerScrollbar.incrementButton:setVisible(false)
    UI.LateralBase.LayerScrollbar.sliderButton:setImageSource("")
    --[[
    g_ui.createWidget("MapLayerSelector", UI.LateralBase.LayerScrollbar.sliderButton)
    function UI.LateralBase.LayerScrollbar:onValueChange(value)
        local rect = {
            width = 14,
            height = 67,
            y = 0,
            x = Cyclopedia.ConvertLayer(value) * 14
        }

        UI.LateralBase.LayerIndicator:setImageClip(rect)
    end
    ]]--

    UI.LateralBase.LayerScrollbar:setValue(150)

    controllerCyclopedia.ui.CharmsBase:setVisible(false)
    controllerCyclopedia.ui.GoldBase:setVisible(true)
    controllerCyclopedia.ui.BestiaryTrackerButton:setVisible(false)
    if g_game.getClientVersion() >= 1410 then
        controllerCyclopedia.ui.CharmsBase1410:setVisible(false)
    end
    -- Cyclopedia.House.Data = json_data

    if not Cyclopedia.House.Loaded then
        for i = 1, #Cyclopedia.StateList do
            UI.TopBase.StatesOption:addOption(Cyclopedia.StateList[i].Title, i)
            UI.TopBase.StatesOption.onOptionChange = Cyclopedia.houseChangeState
        end

        for i = 0, #Cyclopedia.CityList do
            UI.TopBase.CityOption:addOption(Cyclopedia.CityList[i].Title, i)
            UI.TopBase.CityOption.onOptionChange = Cyclopedia.selectTown
        end

        for i = 1, #Cyclopedia.SortList do
            UI.TopBase.SortOption:addOption(Cyclopedia.SortList[i].Title, i)
            UI.TopBase.SortOption.onOptionChange = Cyclopedia.houseSort
        end

        Cyclopedia.House.Loaded = true
        Cyclopedia.houseFilter(UI.TopBase.HousesCheck)
    end

    UI.bidArea:setVisible(false)
    UI.ListBase:setVisible(true)
    Cyclopedia.selectTown({
        data = 0
    })
    UI.TopBase.StatesOption:setOption(tr("otclient_modules.house.tr_101"), true)
    UI.TopBase.CityOption:setOption(tr("otclient_modules.house.tr_100"), true)
    UI.TopBase.SortOption:setOption(tr("otclient_modules.house.tr_99"), true)

    Cyclopedia.House.lastTown = nil
end

Cyclopedia.House = {}
Cyclopedia.StateList = {
    { Title = tr("otclient_modules.house.tr_98") },
    { Title = tr("otclient_modules.house.tr_97") },
    { Title = tr("otclient_modules.house.tr_96") }
}

Cyclopedia.CityList = {
    [0] = { Title = "Own Houses" },
    { Title = "Ab'Dendriel" },
    { Title = "Ankrahmun" },
    { Title = "Carlin" },
    { Title = "Darashia" },
    { Title = "Edron" },
    { Title = "Farmine" },
    { Title = "Gray Beach" },
    { Title = "Issavi" },
    { Title = "Kazordoon" },
    { Title = "Liberty Bay" },
    { Title = "Moonfall" },
    { Title = "Port Hope" },
    { Title = "Rathleton" },
    { Title = "Silvertides" },
    { Title = "Svargrond" },
    { Title = "Thais" },
    { Title = "Venore" },
    { Title = "Yalahar" }
}

Cyclopedia.SortList = {
    { Title = tr("otclient_modules.house.tr_95") },
    { Title = tr("otclient_modules.house.tr_94") },
    { Title = tr("otclient_modules.house.tr_93") },
    { Title = tr("otclient_modules.house.tr_92") },
    { Title = tr("otclient_modules.house.tr_91") }
}

local function resetButtons()
    if UI.LateralBase:getChildById("bidButton") then
        UI.LateralBase:getChildById("bidButton"):destroy()
    end

    if UI.LateralBase:getChildById("transferButton") then
        UI.LateralBase:getChildById("transferButton"):destroy()
    end

    if UI.LateralBase:getChildById("moveOutButton") then
        UI.LateralBase:getChildById("moveOutButton"):destroy()
    end

    if UI.LateralBase:getChildById("cancelTransfer") then
        UI.LateralBase:getChildById("cancelTransfer"):destroy()
    end

    if UI.LateralBase:getChildById("acceptTransfer") then
        UI.LateralBase:getChildById("acceptTransfer"):destroy()
    end

    if UI.LateralBase:getChildById("rejectTransfer") then
        UI.LateralBase:getChildById("rejectTransfer"):destroy()
    end
end

local function resetSelectedInfo()
    UI.LateralBase.yourLimitBidGold:setVisible(false)
    UI.LateralBase.yourLimitBid:setVisible(false)
    UI.LateralBase.yourLimitLabel:setVisible(false)
    UI.LateralBase.highestBid:setVisible(false)
    UI.LateralBase.highestBidGold:setVisible(false)
    UI.LateralBase.subAuctionLabel:setVisible(false)
    UI.LateralBase.subAuctionText:setVisible(false)
    UI.LateralBase.transferLabel:setVisible(false)
    UI.LateralBase.transferValue:setVisible(false)
    UI.LateralBase.transferGold:setVisible(false)
end

function Cyclopedia.houseChangeState(widget)
    if Cyclopedia.House.Data then
        local onlyGuildHall = UI.TopBase.GuildhallsCheck:isChecked()
        local type = widget:getCurrentOption().data
        for _, data in ipairs(Cyclopedia.House.Data) do
            if onlyGuildHall then
                data.visible = data.gh
            elseif type == 3 then
                data.visible = data.rented or data.inTransfer
            elseif type == 2 then
                data.visible = not data.rented
            else
                data.visible = true
            end
        end

        Cyclopedia.reloadHouseList()
        Cyclopedia.House.lastChangeState = widget
    end
end

function Cyclopedia.houseMessage(houseId, type, message)
    local confirmWindow
    local function yesCallback()
        if confirmWindow then
            confirmWindow:destroy()
            confirmWindow = nil
            Cyclopedia.Toggle(true, false, 5)
        end
    end

    if type == 1 then
        if message == 0 then
            if not confirmWindow then
                confirmWindow = displayGeneralBox(tr("otclient_modules.house.tr_90"), tr("otclient_modules.house.tr_89"), {
                    {
                        text = tr("otclient_modules.house.tr_88"),
                        callback = yesCallback
                    },
                    anchor = AnchorHorizontalCenter
                }, yesCallback)

                UI.ListBase:setVisible(true)
                UI.bidArea:setVisible(false)
                Cyclopedia.Toggle(true, false)
            end
        elseif message == 17 then
            confirmWindow = displayGeneralBox(tr("otclient_modules.house.tr_87"), tr("otclient_modules.house.tr_86"),
                {
                    {
                        text = tr("otclient_modules.house.tr_85"),
                        callback = yesCallback
                    },
                    anchor = AnchorHorizontalCenter
                }, yesCallback)

            UI.ListBase:setVisible(true)
            UI.bidArea:setVisible(false)
            Cyclopedia.Toggle(true, false)
        end
    elseif type == 2 then
        if message == 0 then
            confirmWindow = displayGeneralBox(tr("otclient_modules.house.tr_84"), tr("otclient_modules.house.tr_83"), {
                {
                    text = tr("otclient_modules.house.tr_82"),
                    callback = yesCallback
                },
                anchor = AnchorHorizontalCenter
            }, yesCallback)

            UI.moveOutArea:setVisible(false)
            UI.ListBase:setVisible(true)
            Cyclopedia.Toggle(true, false)
        end
    elseif type == 3 then
        if message == 0 then
            confirmWindow = displayGeneralBox(tr("otclient_modules.house.tr_81"),
                tr("otclient_modules.house.tr_80"), {
                    {
                        text = tr("otclient_modules.house.tr_79"),
                        callback = yesCallback
                    },
                    anchor = AnchorHorizontalCenter
                }, yesCallback)

            UI.transferArea:setVisible(false)
            UI.ListBase:setVisible(true)
            Cyclopedia.Toggle(true, false)
        elseif message == 4 then
            confirmWindow = displayGeneralBox(tr("otclient_modules.house.tr_78"), tr("otclient_modules.house.tr_77"), {
                {
                    text = tr("otclient_modules.house.tr_76"),
                    callback = yesCallback
                },
                anchor = AnchorHorizontalCenter
            }, yesCallback)

            UI.transferArea:setVisible(false)
            UI.ListBase:setVisible(true)
            Cyclopedia.Toggle(true, false)
        end
    elseif type == 5 then
        if message == 0 then
            confirmWindow = displayGeneralBox(tr("otclient_modules.house.tr_75"), tr("otclient_modules.house.tr_74"), {
                {
                    text = tr("otclient_modules.house.tr_73"),
                    callback = yesCallback
                },
                anchor = AnchorHorizontalCenter
            }, yesCallback)

            UI.cancelHouseTransferArea:setVisible(false)
            UI.ListBase:setVisible(true)
            Cyclopedia.Toggle(true, false)
        end
    elseif type == 6 then
        if message == 0 then
            confirmWindow = displayGeneralBox(tr("otclient_modules.house.tr_72"), tr("otclient_modules.house.tr_71"), {
                {
                    text = tr("otclient_modules.house.tr_70"),
                    callback = yesCallback
                },
                anchor = AnchorHorizontalCenter
            }, yesCallback)

            UI.acceptTransferHouse:setVisible(false)
            UI.ListBase:setVisible(true)
            Cyclopedia.Toggle(true, false)
        end
    elseif type == 7 and message == 0 then
        confirmWindow = displayGeneralBox(tr("otclient_modules.house.tr_69"), tr("otclient_modules.house.tr_68"), {
            {
                text = tr("otclient_modules.house.tr_67"),
                callback = yesCallback
            },
            anchor = AnchorHorizontalCenter
        }, yesCallback)

        UI.rejectTransferHouse:setVisible(false)
        UI.ListBase:setVisible(true)
        Cyclopedia.Toggle(true, false)
    end
end

function Cyclopedia.rejectTransfer()
    UI.ListBase:setVisible(false)
    UI.rejectTransferHouse:setVisible(true)

    local house = Cyclopedia.House.lastSelectedHouse.data
    local time = os.date("%Y-%m-%d, %H:%M CET", house.paidUntil)
    local transferTime = os.date("%Y-%m-%d, %H:%M CET", house.transferTime)

    function UI.rejectTransferHouse.cancel.onClick()
        UI.rejectTransferHouse:setVisible(false)
        UI.ListBase:setVisible(true)
    end

    function UI.rejectTransferHouse.transfer:onClick()
        local confirmWindow
        local function yesCallback()
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
                Cyclopedia.Toggle(true, false, 5)
            end

            g_game.requestRejectHouseTransfer(house.id)

            Cyclopedia.House.ignore = true
            --[[
            if Cyclopedia.House.lastTown then
                g_game.requestShowHouses(Cyclopedia.House.lastTown)
            else
                g_game.requestShowHouses("")
            end
            ]]--

            UI.TopBase.StatesOption:setOption(tr("otclient_modules.house.tr_66"), true)
            UI.TopBase.SortOption:setOption(tr("otclient_modules.house.tr_65"), true)
        end

        local function noCallback()
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
                Cyclopedia.Toggle(true, false, 5)
            end
        end

        if not confirmWindow then
            confirmWindow = displayGeneralBox(tr("otclient_modules.house.tr_64"), tr("otclient_modules.house.tr_63", house.name, house.owner, house.owner), {
                {
                    text = tr("otclient_modules.house.tr_62"),
                    callback = yesCallback
                },
                {
                    text = tr("otclient_modules.house.tr_61"),
                    callback = noCallback
                },
                anchor = AnchorHorizontalCenter
            }, yesCallback, noCallback)

            Cyclopedia.Toggle(true, false)
        end
    end

    UI.rejectTransferHouse.name:setText(house.name .. "asdasd")
    UI.rejectTransferHouse.size:setText(house.sqm .. " sqm")
    UI.rejectTransferHouse.beds:setText(house.beds)
    UI.rejectTransferHouse.rent:setText((house.rent))
    UI.rejectTransferHouse.paid:setText(time)
    UI.rejectTransferHouse.owner:setText(house.transferName)
    UI.rejectTransferHouse.transferDate:setText(transferTime)
    UI.rejectTransferHouse.transferPrice:setText(comma_value(house.transferValue))
end

function Cyclopedia.acceptTransfer()
    UI.ListBase:setVisible(false)
    UI.acceptTransferHouse:setVisible(true)

    local house = Cyclopedia.House.lastSelectedHouse.data
    local time = os.date("%Y-%m-%d, %H:%M CET", house.paidUntil)
    local transferTime = os.date("%Y-%m-%d, %H:%M CET", house.transferTime)

    function UI.acceptTransferHouse.cancel.onClick()
        UI.acceptTransferHouse:setVisible(false)
        UI.ListBase:setVisible(true)
    end

    function UI.acceptTransferHouse.transfer:onClick()
        local confirmWindow

        local function yesCallback()
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
                Cyclopedia.Toggle(true, false, 5)
            end

            g_game.requestAcceptHouseTransfer(house.id)
            Cyclopedia.House.ignore = true

            -- g_game.requestShowHouses("")
            UI.TopBase.StatesOption:setOption(tr("otclient_modules.house.tr_60"), true)
            UI.TopBase.SortOption:setOption(tr("otclient_modules.house.tr_59"), true)
        end

        local function noCallback()
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
                Cyclopedia.Toggle(true, false, 5)
            end
        end

        if not confirmWindow then
            confirmWindow = displayGeneralBox(tr("otclient_modules.house.tr_58"), tr("otclient_modules.house.tr_57", house.owner, house.name, transferTime, comma_value(house.transferValue)), {
                {
                    text = tr("otclient_modules.house.tr_56"),
                    callback = yesCallback
                },
                {
                    text = tr("otclient_modules.house.tr_55"),
                    callback = noCallback
                },
                anchor = AnchorHorizontalCenter
            }, yesCallback, noCallback)

            Cyclopedia.Toggle(true, false)
        end
    end

    UI.acceptTransferHouse.name:setText(house.name .. "22222")
    UI.acceptTransferHouse.size:setText(house.sqm .. " sqm")
    UI.acceptTransferHouse.beds:setText(house.beds)
    UI.acceptTransferHouse.rent:setText((house.rent))
    UI.acceptTransferHouse.paid:setText(time)
    UI.acceptTransferHouse.owner:setText(house.transferName)
    UI.acceptTransferHouse.transferDate:setText(transferTime)
    UI.acceptTransferHouse.transferPrice:setText(comma_value(house.transferValue))
end

function Cyclopedia.cancelTransfer()
    UI.ListBase:setVisible(false)
    UI.cancelHouseTransferArea:setVisible(true)

    local house = Cyclopedia.House.lastSelectedHouse.data
    local time = os.date("%Y-%m-%d, %H:%M CET", house.paidUntil)
    local transferTime = os.date("%Y-%m-%d, %H:%M CET", house.transferTime)

    function UI.cancelHouseTransferArea.cancel.onClick()
        UI.cancelHouseTransferArea:setVisible(false)
        UI.ListBase:setVisible(true)
    end

    function UI.cancelHouseTransferArea.transfer:onClick()
        local confirmWindow

        local function yesCallback()
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
                Cyclopedia.Toggle(true, false, 5)
            end

            g_game.requestCancelHouseTransfer(house.id)

            Cyclopedia.House.ignore = true
            --[[
            if Cyclopedia.House.lastTown then
                g_game.requestShowHouses(Cyclopedia.House.lastTown)
            else
                g_game.requestShowHouses("")
            end
            ]]--

            UI.TopBase.StatesOption:setOption(tr("otclient_modules.house.tr_54"), true)
            UI.TopBase.SortOption:setOption(tr("otclient_modules.house.tr_53"), true)
        end

        local function noCallback()
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
                Cyclopedia.Toggle(true, false, 5)
            end
        end

        if not confirmWindow then
            confirmWindow = displayGeneralBox(tr("otclient_modules.house.tr_52"),
                tr("otclient_modules.house.tr_51", house.name, house.transferName, transferTime), {
                    {
                        text = tr("otclient_modules.house.tr_50"),
                        callback = yesCallback
                    },
                    {
                        text = tr("otclient_modules.house.tr_49"),
                        callback = noCallback
                    },
                    anchor = AnchorHorizontalCenter
                }, yesCallback, noCallback)

            Cyclopedia.Toggle(true, false)
        end
    end

    UI.cancelHouseTransferArea.name:setText(house.name .. "888")
    UI.cancelHouseTransferArea.size:setText(house.sqm .. " sqm")
    UI.cancelHouseTransferArea.beds:setText(house.beds)
    UI.cancelHouseTransferArea.rent:setText((house.rent))
    UI.cancelHouseTransferArea.paid:setText(time)
    UI.cancelHouseTransferArea.owner:setText(house.transferName)
    UI.cancelHouseTransferArea.transferDate:setText(transferTime)
    UI.cancelHouseTransferArea.transferPrice:setText(comma_value(house.transferValue))
end

function Cyclopedia.transferHouse()
    if UI.moveOutArea:isVisible() then
        UI.moveOutArea:setVisible(false)
    end

    local house = Cyclopedia.House.lastSelectedHouse.data
    local time = os.date("%Y-%m-%d, %H:%M CET", house.paidUntil)

    local function verify(widget, text, type)
        local timestemp = os.time({
            year = UI.transferArea.year:getCurrentOption().text,
            month = UI.transferArea.month:getCurrentOption().text,
            day = UI.transferArea.day:getCurrentOption().text
        })

        if timestemp < os.time(os.date("!*t")) then
            UI.transferArea.move:setEnabled(false)
            UI.transferArea.error:setVisible(true)
        else
            UI.transferArea.move:setEnabled(true)
            UI.transferArea.error:setVisible(false)
        end
    end

    local function verifyName(widget, text, oldText)
        if text ~= "" then
            UI.transferArea.errorName:setVisible(false)
            UI.transferArea.transfer:setEnabled(false)
        else
            UI.transferArea.transfer:setEnabled(true)
            UI.transferArea.errorName:setVisible(true)
        end
    end

    UI.ListBase:setVisible(false)
    UI.transferArea:setVisible(true)

    function UI.transferArea.cancel.onClick()
        UI.transferArea:setVisible(false)
        UI.ListBase:setVisible(true)
    end

    function UI.transferArea.transfer:onClick()
        local confirmWindow
        local transfer = UI.transferArea.owner:getText()
        local value = UI.transferArea.price:getText()
        local timestemp = os.time({
            year = UI.transferArea.year:getCurrentOption().text,
            month = UI.transferArea.month:getCurrentOption().text,
            day = UI.transferArea.day:getCurrentOption().text
        })

        local function yesCallback()
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
                Cyclopedia.Toggle(true, false, 5)
            end

            g_game.requestTransferHouse(house.id, transfer, tonumber(value))

            Cyclopedia.House.ignore = true
            --[[
            if Cyclopedia.House.lastTown then
                g_game.requestShowHouses(Cyclopedia.House.lastTown)
            else
                g_game.requestShowHouses("")
            end
            ]]--

            UI.TopBase.StatesOption:setOption(tr("otclient_modules.house.tr_48"), true)
            UI.TopBase.SortOption:setOption(tr("otclient_modules.house.tr_47"), true)
        end

        local function noCallback()
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
                Cyclopedia.Toggle(true, false, 5)
            end
        end

        if not confirmWindow then
            confirmWindow = displayGeneralBox(tr("otclient_modules.house.tr_46"), tr("otclient_modules.house.tr_45", house.name, transfer, os.date("%Y-%m-%d, %H:%M CET", timestemp), comma_value(value), transfer), {
                {
                    text = tr("otclient_modules.house.tr_44"),
                    callback = yesCallback
                },
                {
                    text = tr("otclient_modules.house.tr_43"),
                    callback = noCallback
                },
                anchor = AnchorHorizontalCenter
            }, yesCallback, noCallback)

            Cyclopedia.Toggle(true, false)
        end
    end

    UI.transferArea.name:setText(house.name .. "44444")
    UI.transferArea.size:setText(house.sqm .. " sqm")
    UI.transferArea.beds:setText(house.beds)
    UI.transferArea.rent:setText((house.rent))
    UI.transferArea.paid:setText(time)
    UI.transferArea.year:clearOptions()
    UI.transferArea.year.onOptionChange = verify

    local yearNumber = tonumber(os.date("%Y"))

    UI.transferArea.year:addOption(yearNumber, 1, true)
    UI.transferArea.year:addOption(yearNumber + 1, 2, true)
    UI.transferArea.month:clearOptions()
    UI.transferArea.month.onOptionChange = verify

    for i = 1, 12 do
        UI.transferArea.month:addOption(i, i, true)
    end

    UI.transferArea.day:clearOptions()
    UI.transferArea.day.onOptionChange = verify

    local days = tonumber(os.date("%d", os.time({
        day = 0,
        year = yearNumber,
        month = os.date("%m") + 1
    })))

    for i = 1, days do
        UI.transferArea.day:addOption(i, i, true)
    end

    UI.transferArea.month:setOption(tonumber(os.date("%m")), true)
    UI.transferArea.day:setOption(tonumber(os.date("%d") + 1), true)
    UI.transferArea.owner.onTextChange = verifyName
    UI.transferArea.owner:setText("")
    verifyName(UI.transferArea.owner, "", "")
    UI.transferArea.price:setText(0)

    function UI.transferArea.price:onTextChange(text, oldText)
        local convertedText = tonumber(text)
        if text ~= "" and type(convertedText) ~= "number" then
            self:setText(oldText)
        end

        if text == "" then
            UI.transferArea.transfer:setEnabled(false)
        elseif convertedText then
            UI.transferArea.transfer:setEnabled(true)
        end
    end
end

function Cyclopedia.moveOutHouse()
    if UI.transferArea:isVisible() then
        UI.transferArea:setVisible(false)
    end

    local house = Cyclopedia.House.lastSelectedHouse.data
    local time = os.date("%Y-%m-%d, %H:%M CET", house.paidUntil)

    local function verify(widget, text, type)
        local timestemp = os.time({
            year = UI.moveOutArea.year:getCurrentOption().text,
            month = UI.moveOutArea.month:getCurrentOption().text,
            day = UI.moveOutArea.day:getCurrentOption().text
        })

        if timestemp < os.time(os.date("!*t")) then
            UI.moveOutArea.move:setEnabled(false)
            UI.moveOutArea.error:setVisible(true)
        else
            UI.moveOutArea.move:setEnabled(true)
            UI.moveOutArea.error:setVisible(false)
        end
    end

    UI.ListBase:setVisible(false)
    UI.moveOutArea:setVisible(true)

    function UI.moveOutArea.cancel.onClick()
        UI.moveOutArea:setVisible(false)
        UI.ListBase:setVisible(true)
    end

    function UI.moveOutArea.move:onClick()
        local confirmWindow
        local timestemp = os.time({
            year = UI.moveOutArea.year:getCurrentOption().text,
            month = UI.moveOutArea.month:getCurrentOption().text,
            day = UI.moveOutArea.day:getCurrentOption().text
        })

        local function yesCallback()
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
                Cyclopedia.Toggle(true, false, 5)
            end

            g_game.requestMoveOutHouse(house.id)
        end

        local function noCallback()
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
                Cyclopedia.Toggle(true, false, 5)
            end
        end

        if not confirmWindow then
            confirmWindow = displayGeneralBox(tr("otclient_modules.house.tr_42"),
                tr("otclient_modules.house.tr_41", house.name, os.date("%Y-%m-%d, %H:%M CET", timestemp)), {
                    {
                        text = tr("otclient_modules.house.tr_40"),
                        callback = yesCallback
                    },
                    {
                        text = tr("otclient_modules.house.tr_39"),
                        callback = noCallback
                    },
                    anchor = AnchorHorizontalCenter
                }, yesCallback, noCallback)

            Cyclopedia.Toggle(true, false)
        end
    end

    UI.moveOutArea.name:setText(house.name .. "9999")
    UI.moveOutArea.size:setText(house.sqm .. " sqm")
    UI.moveOutArea.beds:setText(house.beds)
    UI.moveOutArea.rent:setText((house.rent))
    UI.moveOutArea.paid:setText(time)
    UI.moveOutArea.year:clearOptions()
    UI.moveOutArea.year.onOptionChange = verify

    local yearNumber = tonumber(os.date("%Y"))
    UI.moveOutArea.year:addOption(yearNumber, 1, true)
    UI.moveOutArea.year:addOption(yearNumber + 1, 2, true)
    UI.moveOutArea.month:clearOptions()
    UI.moveOutArea.month.onOptionChange = verify

    for i = 1, 12 do
        UI.moveOutArea.month:addOption(i, i, true)
    end

    UI.moveOutArea.day:clearOptions()
    UI.moveOutArea.day.onOptionChange = verify

    local days = tonumber(os.date("%d", os.time({
        day = 0,
        year = yearNumber,
        month = os.date("%m") + 1
    })))

    for i = 1, days do
        UI.moveOutArea.day:addOption(i, i, true)
    end

    UI.moveOutArea.month:setOption(tonumber(os.date("%m")), true)
    UI.moveOutArea.day:setOption(tonumber(os.date("%d") + 1), true)
end

function Cyclopedia.bidHouse(widget)
    if UI.transferArea:isVisible() then
        UI.transferArea:setVisible(false)
    end

    if UI.moveOutArea:isVisible() then
        UI.moveOutArea:setVisible(false)
    end

    local house = Cyclopedia.House.lastSelectedHouse.data
    local time = os.date("%Y-%m-%d, %H:%M CET", house.bidEnd)

    UI.ListBase:setVisible(false)
    UI.bidArea:setVisible(true)
    UI.bidArea.name:setText(house.name .. "99889")
    UI.bidArea.size:setText(house.sqm .. " sqm")
    UI.bidArea.beds:setText(house.beds)
    UI.bidArea.rent:setText((house.rent))

    local labels = {{
        id = "hightestBidder",
        name = "Highest Bidder: ",
        value = house.bidName
    }, {
        id = "endTime",
        name = "End Time: ",
        value = time
    }, {
        id = "highestBid",
        name = "Highest Bid: ",
        value = house.hightestBid
    }}

    for _, value in ipairs(labels) do
        local child = UI.bidArea:getChildById(value.id)
        if child then
            child:destroy()
            UI.bidArea:getChildById(value.id .. "_value"):destroy()

            if UI.bidArea:getChildById("highestBid_gold") then
                UI.bidArea:getChildById("highestBid_gold"):destroy()
            end
        end
    end

    if UI.bidArea:getChildById("yourLimit") then
        UI.bidArea:getChildById("yourLimit"):destroy()
        UI.bidArea:getChildById("yourLimit_value"):destroy()
        UI.bidArea:getChildById("yourLimit_gold"):destroy()
    end

    if house.hasBid then
        for index, data in ipairs(labels) do
            local label = g_ui.createWidget("Label", UI.bidArea)
            label:setId(data.id)
            label:setText(data.name .. "44242")
            label:setColor("#909090")
            label:setWidth(90)
            label:setHeight(15)
            label:setTextAlign(AlignRight)
            label:setMarginTop(2)

            if index == 1 then
                label:addAnchor(AnchorTop, "prev", AnchorBottom)
                label:addAnchor(AnchorLeft, "parent", AnchorLeft)
            else
                label:addAnchor(AnchorTop, labels[index - 1].id, AnchorBottom)
                label:addAnchor(AnchorLeft, "parent", AnchorLeft)
            end

            label:setMarginLeft(4)

            local value = g_ui.createWidget("Label", UI.bidArea)
            value:setId(data.id .. "_value")
            value:setText(data.value)
            value:setColor("#C0C0C0")
            value:addAnchor(AnchorTop, "prev", AnchorTop)
            value:addAnchor(AnchorLeft, "prev", AnchorRight)
            value:setMarginLeft(5)

            if data.id == "highestBid" then
                value:setWidth(90)
                value:setHeight(15)
                value:setMarginLeft(7)
                value:setTextAlign(AlignRight)

                local gold = g_ui.createWidget("UIWidget", UI.bidArea)
                gold:setId("highestBid_gold")
                gold:setImageSource("/game_cyclopedia/images/icon_gold")
                gold:addAnchor(AnchorTop, "prev", AnchorTop)
                gold:addAnchor(AnchorLeft, "prev", AnchorRight)
                gold:setMarginTop(2)
                gold:setMarginLeft(9)
            end
        end

        if house.bidHolderLimit then
            local label = g_ui.createWidget("Label", UI.bidArea)
            label:setId("yourLimit")
            label:setText(tr("otclient_modules.house.tr_38"))
            label:setColor("#909090")
            label:setWidth(90)
            label:setHeight(15)
            label:setTextAlign(AlignRight)
            label:setMarginTop(2)
            label:addAnchor(AnchorTop, "highestBid", AnchorBottom)
            label:addAnchor(AnchorLeft, "parent", AnchorLeft)

            local value = g_ui.createWidget("Label", UI.bidArea)
            value:setWidth(90)
            value:setHeight(15)
            value:setId("yourLimit_value")
            value:setText(comma_value(house.bidHolderLimit))
            value:setColor("#C0C0C0")
            value:addAnchor(AnchorTop, "prev", AnchorTop)
            value:addAnchor(AnchorLeft, "prev", AnchorRight)
            value:setMarginLeft(13)
            value:setTextAlign(AlignRight)

            local gold = g_ui.createWidget("UIWidget", UI.bidArea)
            gold:setId("yourLimit_gold")
            gold:setImageSource("/game_cyclopedia/images/icon_gold")
            gold:addAnchor(AnchorTop, "prev", AnchorTop)
            gold:addAnchor(AnchorLeft, "prev", AnchorRight)
            gold:setMarginTop(2)
            gold:setMarginLeft(7)
        end
    else
        if UI.bidArea:getChildById("soFar") then
            UI.bidArea:getChildById("soFar"):destroy()
        end

        local label = g_ui.createWidget("Label", UI.bidArea)
        label:setId("soFar")
        label:setText(tr("otclient_modules.house.tr_37"))
        label:setColor("#C0C0C0")
        label:addAnchor(AnchorTop, "prev", AnchorBottom)
        label:addAnchor(AnchorLeft, "parent", AnchorLeft)
        label:setMarginTop(2)
    end

    if UI.bidArea:getChildById("bidArea") then
        UI.bidArea:getChildById("bidArea"):destroy()
    end

    local bidArea = g_ui.createWidget("HouseBidArea", UI.bidArea)
    bidArea:setId("bidArea")
    bidArea:addAnchor(AnchorTop, "prev", AnchorBottom)
    bidArea:addAnchor(AnchorLeft, "parent", AnchorLeft)
    bidArea:addAnchor(AnchorRight, "parent", AnchorRight)
    bidArea:setMarginTop(5)

    if house.bidHolderLimit then
        bidArea.textEdit:setText(house.bidHolderLimit)
    else
        bidArea.textEdit:setText(0)
    end

    function bidArea.textEdit:onTextChange(text, oldText)
        local convertedText = tonumber(text)
        if text ~= "" and type(convertedText) ~= "number" then
            self:setText(oldText)
        end

        if text == "" then
            UI.bidArea.bid:setEnabled(false)
        elseif convertedText then
            UI.bidArea.bid:setEnabled(true)
        end
    end

    if house.hasBid then
        bidArea.information:setText(string.format(
            tr("otclient_modules.house.tr_36"),
            time, (house.rent)))
    else
        bidArea.information:setText(string.format(tr("otclient_modules.house.tr_35"), house.rent))
    end

    function UI.bidArea.cancel.onClick()
        UI.bidArea:setVisible(false)
        UI.ListBase:setVisible(true)
    end

    function UI.bidArea.bid:onClick()
        local value = tonumber(bidArea.textEdit:getText())
        if not value or value <= 0 then
            return
        end

        local confirmWindow
        local function yesCallback()
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
                Cyclopedia.Toggle(true, false, 5)
            end

            g_game.requestBidHouse(house.id, value)
        end

        local function noCallback()
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
                Cyclopedia.Toggle(true, false, 5)
            end
        end

        if not confirmWindow then
            confirmWindow = displayGeneralBox(tr("otclient_modules.house.tr_34"), tr("otclient_modules.house.tr_33", house.name, comma_value(value), (house.rent)), {
                {
                    text = tr("otclient_modules.house.tr_32"),
                    callback = yesCallback
                },
                {
                    text = tr("otclient_modules.house.tr_31"),
                    callback = noCallback
                },
                anchor = AnchorHorizontalCenter
            }, yesCallback, noCallback)

            Cyclopedia.Toggle(true, false)
        end
    end
end

function Cyclopedia.houseRefresh()
    if Cyclopedia.House.lastTown then
        -- g_game.requestShowHouses(Cyclopedia.House.lastTown)

        if Cyclopedia.House.lastChangeState then
            if Cyclopedia.House.refreshEvent then
                return
            end

            Cyclopedia.House.refreshEvent = scheduleEvent(function()
                Cyclopedia.houseChangeState(Cyclopedia.House.lastChangeState)
                Cyclopedia.House.refreshEvent = nil
            end, 100)
        end
    end
end

function Cyclopedia.houseSort(widget, text, type)
    if Cyclopedia.House.Data then
        if type == 1 then
            table.sort(Cyclopedia.House.Data, function(a, b)
                return a.name < b.name
            end)
        elseif type == 2 then
            table.sort(Cyclopedia.House.Data, function(a, b)
                return a.sqm < b.sqm
            end)
        elseif type == 3 then
            -- block empty
        elseif type == 4 then
            table.sort(Cyclopedia.House.Data, function(a, b)
                if a.hasBid and not b.hasBid then
                    return true
                elseif not a.hasBid and b.hasBid then
                    return false
                else
                    return false
                end
            end)
        elseif type == 5 then
            table.sort(Cyclopedia.House.Data, function(a, b)
                if a.hasBid and not b.hasBid then
                    return true
                elseif not a.hasBid and b.hasBid then
                    return false
                else
                    return false
                end
            end)
        end

        Cyclopedia.reloadHouseList()
    end
end

function Cyclopedia.houseFilter(widget)
    local id = widget:getId()
    local brother

    if id == "HousesCheck" then
        brother = UI.TopBase.GuildhallsCheck
    else
        brother = UI.TopBase.HousesCheck
    end

    brother:setChecked(false)
    widget:setChecked(true)

    if not table.empty(Cyclopedia.House.Data) then
        local onlyGuildHall = UI.TopBase.GuildhallsCheck:isChecked()
        for _, data in ipairs(Cyclopedia.House.Data) do
            if onlyGuildHall then
                data.visible = data.gh
            else
                data.visible = not data.gh
            end
        end

        Cyclopedia.reloadHouseList()
    end
end

-- Refreshes the house auction UI to reflect the current Cyclopedia.House.Data.
-- Populates the AuctionList with entries for each visible house, updates map/view controls and icons, and selects a default or previously selected house; when no house data exists, shows the no-house state and clears related UI elements.
function Cyclopedia.reloadHouseList()
    if not table.empty(Cyclopedia.House.Data) then
        UI.LateralBase.MapViewbase.noHouse:setVisible(false)
        UI.LateralBase.MapViewbase.houseImage:setVisible(false)
        UI.LateralBase.MapViewbase.reload:setVisible(true)
        UI.LateralBase.AuctionLabel:setVisible(true)
        UI.LateralBase.AuctionText:setVisible(true)
        UI.ListBase.AuctionList:destroyChildren()

        for _, data in ipairs(Cyclopedia.House.Data) do
            if data.visible then
                local widget = g_ui.createWidget("House", UI.ListBase.AuctionList)
                widget.data = data
                widget:setId(data.id)
                widget:setText(data.name)
                widget.size:setColoredText("{" .. tr("otclient_modules.house.tr_30") .. "     , #909090}" .. data.sqm .. " sqm")
                widget.beds:setColoredText("{" .. tr("otclient_modules.house.tr_29") .. " ,#909090} " .. data.beds)
                widget.rent:setColoredText(data.rent)

                if data.description ~= "" then
                    local icon = g_ui.createWidget("HouseIcon", widget.icons)
                    -- icon:setImageSource("/game_cyclopedia/images/house-description")
                    icon:setTooltip(data.description)
                end

                if data.state == 0 then
                    if data.hasBid then
                        local function format(timestamp)
                            local difference = timestamp - os.time()
                            local hour = math.floor(difference / 3600)
                            local minutes = math.floor(difference % 3600 / 60)
                            return string.format("%02dh %02dmin", hour, minutes)
                        end

                        widget.status:setColoredText("{" .. tr("otclient_modules.house.tr_28") .. "  , #909090}{" .. tr("otclient_modules.house.tr_27") .. ", #00F000} (" .. tr("otclient_modules.house.tr_26") .. " " ..
                                                         data.hightestBid .. " " .. tr("otclient_modules.house.tr_25") .. " " .. format(data.bidEnd) .. ")")
                    else
                        widget.status:setColoredText("{" .. tr("otclient_modules.house.tr_24") .. "  , #909090}{" .. tr("otclient_modules.house.tr_23") .. ", #00F000} (" .. tr("otclient_modules.house.tr_22") .. ")")
                    end
                elseif data.state == 2 then
                    widget.status:setColoredText("{" .. tr("otclient_modules.house.tr_21") .. "  , #909090}" .. tr("otclient_modules.house.tr_20") .. " " .. data.owner)
                end

                widget.onClick = Cyclopedia.selectHouse

                if data.isYourOwner then
                    local icon = g_ui.createWidget("HouseIcon", widget.icons)
                    -- icon:setImageSource("/game_cyclopedia/images/house-owner-icon")
                end

                if widget.data.isTransferOwner then
                    local icon = g_ui.createWidget("HouseIcon", widget.icons)
                    icon:setImageSource("/game_cyclopedia/images/pending-transfer-house")
                end

                if data.isYourOwner and data.inTransfer then
                    local icon = g_ui.createWidget("HouseIcon", widget.icons)
                    icon:setImageSource("/game_cyclopedia/images/transfer-house")
                end

                if data.shop then
                    local icon = g_ui.createWidget("HouseIcon", widget.icons)
                    -- icon:setImageSource("/game_cyclopedia/images/house-shop")
                    icon:setTooltip(tr("otclient_modules.house.tr_19"))
                end
            end
        end

        if Cyclopedia.House.lastSelectedHouse then
            local last = UI.ListBase.AuctionList:getChildById(Cyclopedia.House.lastSelectedHouse:getId())
            last = last or UI.ListBase.AuctionList:getChildByIndex(1)
            Cyclopedia.selectHouse(last)
        else
            Cyclopedia.selectHouse(UI.ListBase.AuctionList:getChildByIndex(1))
        end
    else
        UI.LateralBase.MapViewbase.noHouse:setVisible(true)
        UI.LateralBase.MapViewbase.reload:setVisible(false)
        UI.LateralBase.MapViewbase.houseImage:setVisible(false)
        UI.LateralBase.AuctionLabel:setVisible(false)
        UI.LateralBase.AuctionText:setVisible(false)
        UI.LateralBase.icons:destroyChildren()
        UI.LateralBase.yourLimitBidGold:setVisible(false)
        UI.LateralBase.yourLimitBid:setVisible(false)
        UI.LateralBase.yourLimitLabel:setVisible(false)
        UI.LateralBase.highestBid:setVisible(false)
        UI.LateralBase.highestBidGold:setVisible(false)
        UI.LateralBase.subAuctionLabel:setVisible(false)
        UI.LateralBase.subAuctionText:setVisible(false)
        UI.LateralBase.transferLabel:setVisible(false)
        UI.LateralBase.transferValue:setVisible(false)
        UI.LateralBase.transferGold:setVisible(false)
        resetButtons()
    end
end

function Cyclopedia.loadHouseList(data, other)
    if Cyclopedia.House.ignore then
        Cyclopedia.House.ignore = false
        return
    end

    local houses = {}

    if not table.empty(data) then
        for i = 0, #data do
            local value = data[i]
            local house = HOUSE[value.houseId]
            if house then
                local isGuildHall = house.GH > 0 and true or false
                local data_t = {
                    id = value.houseId,
                    name = house.name,
                    description = house.description,
                    rent = house.rent,
                    beds = house.beds,
                    sqm = house.sqm,
                    gh = isGuildHall,
                    shop = house.shop > 0 and true or false,
                    visible = not isGuildHall,
                    state = value.state,
                    owner = other[i].owner and other[i].owner or "?",
                    isYourBid = data[i].bidHolderLimit and data[i].bidHolderLimit > 0 and true or false,
                    hasBid = data[i].bidEnd and data[i].bidEnd > 0 and true or false,
                    bidEnd = data[i].bidEnd and data[i].bidEnd or nil,
                    hightestBid = data[i].hightestBid and data[i].hightestBid or nil,
                    bidName = other[i].bidName and other[i].bidName or nil,
                    bidHolderLimit = data[i].bidHolderLimit and data[i].bidHolderLimit or nil,
                    canBid = data[i].selfCanBid,
                    rented = data[i].state == 2 and true or false,
                    paidUntil = data[i].paidUntil and data[i].paidUntil or nil,
                    isYourOwner = other[i].owner and other[i].owner:lower() == g_game.getLocalPlayer():getName():lower() and
                        true or false,
                    inTransfer = data[i].state == 3 and true or false,
                    transferName = other[i].transferPlayer and other[i].transferPlayer or nil,
                    transferTime = data[i].time and data[i].time or 0,
                    transferValue = data[i].transferValue and data[i].transferValue or 0,
                    isTransferOwner = data[i].hasTransferOwner and data[i].hasTransferOwner > 0 and true or false,
                    canAcceptTransfer = data[i].canAcceptTransfer and data[i].canAcceptTransfer or 0
                }

                table.insert(houses, data_t)
            end
        end
    else
        UI.ListBase.AuctionList:destroyChildren()
    end

    table.sort(houses, function(a, b)
        return a.name < b.name
    end)

    Cyclopedia.House.Data = houses
    Cyclopedia.reloadHouseList()
end

function Cyclopedia.selectTown(widget, text, type)
    local name = text
    if type ~= 0 then
        -- g_game.requestShowHouses(name)
        Cyclopedia.House.lastTown = name
    else
        -- g_game.requestShowHouses("")
        Cyclopedia.House.lastTown = ""
    end
end

-- Selects a house entry and updates the right-hand panel to reflect that house's details, status, and available actions.
-- 
-- Updates icons (ownership, transfer, shop, description), auction or rental details, action buttons (Bid, Transfer, Move Out, Cancel/Accept/Reject Transfer) and the map image area to match the selected house. Marks the provided widget as selected and stores it as the last selected house.
-- @param widget The house list widget representing the house to select; if nil the function does nothing.
function Cyclopedia.selectHouse(widget)
    if not widget then
        return
    end

    local parent = widget:getParent()
    for i = 1, parent:getChildCount() do
        local child = parent:getChildByIndex(i)
        child:setChecked(false)
    end

    UI.LateralBase.icons:destroyChildren()

    if widget.data.isYourOwner then
        local icon = g_ui.createWidget("HouseIcon", UI.LateralBase.icons)
        -- icon:setImageSource("/game_cyclopedia/images/house-owner-icon")
    end

    if widget.data.isYourOwner and widget.data.inTransfer then
        local icon = g_ui.createWidget("HouseIcon", UI.LateralBase.icons)
        icon:setImageSource("/game_cyclopedia/images/transfer-house")
    end

    if widget.data.isTransferOwner then
        local icon = g_ui.createWidget("HouseIcon", UI.LateralBase.icons)
        icon:setImageSource("/game_cyclopedia/images/pending-transfer-house")
    end

    if widget.data.shop then
        local icon = g_ui.createWidget("HouseIcon", UI.LateralBase.icons)
        -- icon:setImageSource("/game_cyclopedia/images/house-shop")
        icon:setTooltip(tr("otclient_modules.house.tr_18"))
    end

    if widget.data.description ~= "" then
        local icon = g_ui.createWidget("HouseIcon", UI.LateralBase.icons)
        -- icon:setImageSource("/game_cyclopedia/images/house-description")
        icon:setTooltip(widget.data.description)
    end

    resetButtons()
    resetSelectedInfo()

    if widget.data.hasBid then
        UI.LateralBase.AuctionLabel:setText(tr("otclient_modules.house.tr_17"))

        local formattedDate = os.date("%b %d, %H:%M", widget.data.bidEnd)
        local date = string.format("%s %s", formattedDate, "CET")

        UI.LateralBase.AuctionText:setColoredText("{" .. tr("otclient_modules.house.tr_16") .. " , #909090}" .. widget.data.bidName ..
                                                      "\n{      " .. tr("otclient_modules.house.tr_15") .. " , #909090}" .. date ..
                                                      "\n{   " .. tr("otclient_modules.house.tr_14") .. " , #909090}")
        UI.LateralBase.highestBid:setVisible(true)
        UI.LateralBase.highestBidGold:setVisible(true)
        UI.LateralBase.highestBid:setText(comma_value(widget.data.hightestBid))

        if widget.data.isYourBid then
            UI.LateralBase.yourLimitLabel:setVisible(true)
            UI.LateralBase.yourLimitBid:setVisible(true)
            UI.LateralBase.yourLimitBid:setText(comma_value(widget.data.bidHolderLimit))
            UI.LateralBase.yourLimitBidGold:setVisible(true)
        end
    elseif widget.data.rented or widget.data.inTransfer then
        local formattedDate = os.date("%b %d, %H:%M", widget.data.paidUntil)
        local date = string.format("%s %s", formattedDate, "CET")

        UI.LateralBase.AuctionLabel:setText(tr("otclient_modules.house.tr_13"))
        UI.LateralBase.AuctionText:setColoredText("{            " .. tr("otclient_modules.house.tr_12") .. " , #909090}" .. widget.data.owner ..
                                                      "\n{         " .. tr("otclient_modules.house.tr_11") .. " , #909090}" .. date)

        if widget.data.inTransfer then
            formattedDate = os.date("%b %d, %H:%M", widget.data.transferTime)
            date = string.format("%s %s", formattedDate, "CET")

            UI.LateralBase.subAuctionLabel:setVisible(true)
            UI.LateralBase.subAuctionText:setVisible(true)
            UI.LateralBase.subAuctionText:setColoredText("{      " .. tr("otclient_modules.house.tr_10") .. "  , #909090}" .. widget.data.transferName ..
                                                             "\n{                " .. tr("otclient_modules.house.tr_9") .. "  , #909090}" .. date)
            UI.LateralBase.transferLabel:setVisible(true)
            UI.LateralBase.transferValue:setVisible(true)
            UI.LateralBase.transferGold:setVisible(true)
            UI.LateralBase.transferValue:setText(comma_value(widget.data.transferValue))
        end
    else
        UI.LateralBase.AuctionLabel:setText(tr("otclient_modules.house.tr_8"))
        UI.LateralBase.AuctionText:setText(tr("otclient_modules.house.tr_7"))
    end

    if widget.data.rented then
        if widget.data.isYourOwner then
            local button = g_ui.createWidget("Button", UI.LateralBase)
            button:setId("transferButton")
            button:setText(tr("otclient_modules.house.tr_6"))
            button:setColor("#C0C0C0")
            -- button:setFont("noto-12")
            button:setWidth(64)
            button:setHeight(20)
            button:addAnchor(AnchorBottom, "parent", AnchorBottom)
            button:addAnchor(AnchorRight, "parent", AnchorRight)
            button:setMarginRight(7)
            button:setMarginBottom(7)
            button.onClick = Cyclopedia.transferHouse
            button = g_ui.createWidget("Button", UI.LateralBase)
            button:setId("moveOutButton")
            button:setText(tr("otclient_modules.house.tr_5"))
            button:setColor("#C0C0C0")
            -- button:setFont("noto-12")
            button:setWidth(64)
            button:setHeight(20)
            button:addAnchor(AnchorTop, "prev", AnchorTop)
            button:addAnchor(AnchorRight, "prev", AnchorLeft)
            button:setMarginRight(5)
            button.onClick = Cyclopedia.moveOutHouse
        end
    elseif widget.data.inTransfer and not widget.data.isTransferOwner then
        local button = g_ui.createWidget("Button", UI.LateralBase)
        button:setId("cancelTransfer")
        button:setText(tr("otclient_modules.house.tr_4"))
        button:setColor("#C0C0C0")
        -- button:setFont("noto-12")
        button:setWidth(86)
        button:setHeight(20)
        button:addAnchor(AnchorBottom, "parent", AnchorBottom)
        button:addAnchor(AnchorRight, "parent", AnchorRight)
        button:setMarginRight(7)
        button:setMarginBottom(7)
        button.onClick = Cyclopedia.cancelTransfer
    elseif widget.data.isTransferOwner then
        local button = g_ui.createWidget("Button", UI.LateralBase)
        button:setId("rejectTransfer")
        button:setText(tr("otclient_modules.house.tr_3"))
        button:setColor("#C0C0C0")
        -- button:setFont("noto-12")
        button:setWidth(86)
        button:setHeight(20)
        button:addAnchor(AnchorBottom, "parent", AnchorBottom)
        button:addAnchor(AnchorRight, "parent", AnchorRight)
        button:setMarginRight(7)
        button:setMarginBottom(7)
        button:setTextOffset(topoint(0 .. " " .. 0))
        button.onClick = Cyclopedia.rejectTransfer

        local transferButton = g_ui.createWidget("Button", UI.LateralBase)
        transferButton:setId("acceptTransfer")
        transferButton:setText(tr("otclient_modules.house.tr_2"))
        transferButton:setColor("#C0C0C0")
        -- transferButton:setFont("noto-12")
        transferButton:setWidth(86)
        transferButton:setHeight(20)
        transferButton:addAnchor(AnchorTop, "prev", AnchorTop)
        transferButton:addAnchor(AnchorRight, "prev", AnchorLeft)
        transferButton:setMarginRight(5)
        transferButton:setTextOffset(topoint(0 .. " " .. 0))
        transferButton.onClick = Cyclopedia.acceptTransfer

        if widget.data.canAcceptTransfer ~= 0 then
            transferButton:setEnabled(false)
        else
            transferButton:setEnabled(true)
        end
    else
        local button = g_ui.createWidget("Button", UI.LateralBase)
        button:setId("bidButton")
        button:setText(tr("otclient_modules.house.tr_1"))
        button:setColor("#C0C0C0")
        -- button:setFont("noto-12")
        button:setWidth(64)
        button:setHeight(20)
        button:addAnchor(AnchorBottom, "parent", AnchorBottom)
        button:addAnchor(AnchorRight, "parent", AnchorRight)
        button:setMarginRight(7)
        button:setMarginBottom(7)
        button.onClick = Cyclopedia.bidHouse

        if widget.data.canBid == 0 then
            button:setEnabled(true)
            button:setTooltip("")
        elseif widget.data.canBid == 11 then
            button:setTooltip(
                "A character of your account already holds the highest bid for \nanother house. You may olny bid for one house at the same time.")
            button:setTooltipAlign(AlignTopLeft)
            button:setEnabled(false)
        else
            button:setEnabled(false)
            button:setTooltip("")
        end
    end

    widget:setChecked(true)
    UI.LateralBase.MapViewbase.noHouse:setVisible(false)
    UI.LateralBase.MapViewbase.reload:setVisible(true)
    UI.LateralBase.MapViewbase.houseImage:setVisible(false)

    local imagePath = string.format("/game_cyclopedia/images/houses/%s.png", widget.data.id)
    if g_resources.fileExists(imagePath) then
        UI.LateralBase.MapViewbase.noHouse:setVisible(false)
        UI.LateralBase.MapViewbase.reload:setVisible(false)
        UI.LateralBase.MapViewbase.houseImage:setVisible(true)
        UI.LateralBase.MapViewbase.houseImage:setImageSource(imagePath)
    end

    --[[
    UI.LateralBase.MapViewbase.houseImage:setVisible(true)
    HTTP.downloadImage("https://next-stage.pl/images/houses/A%20Horse%20farm.jpeg", function(path, err)
        if err then g_logger.warning("HTTP error: " .. err .. " - ") return end
        UI.LateralBase.MapViewbase.houseImage:setImageSource(path)
      end)
    ]]--

    Cyclopedia.House.lastSelectedHouse = widget
end
local notificationsRegistred = {}

function add(player, message, notificationType, time, priority, tickSended)
    if (not message or type(message) ~= 'string') then
        return false, error('['..getResourceName(getThisResource())..'] Defina uma mensagem para o anúncio', 2)
    end

    if (not notificationType or type(notificationType) ~= 'string') then
        return false, error('['..getResourceName(getThisResource())..'] Defina um tipo de notificação', 2)
    end

    triggerClientEvent(player, 'notification:add', resourceRoot, message, notificationType, time, priority, tickSended)
end

function addToAllPlayers(message, notificationType, time)
    if (not message) then
        return false, error('['..getResourceName(getThisResource())..'] Defina uma mensagem para o anúncio', 2)
    end

    if (not notificationType or type(notificationType) ~= 'string') then
        return false, error('['..getResourceName(getThisResource())..'] Defina um tipo de notificação', 2)
    end

    table.insert(notificationsRegistred, 1, {
        message = message,
        type = notificationType,
        time = (time or 5000),

        priority = true,

        tickSended = getTickCount();
    })

    triggerClientEvent(root, 'notification:add', resourceRoot, message, notificationType, time, true)
end

--

addEventHandler('onResourceStart', resourceRoot, function()
    setTimer(function()
        for i, v in ipairs(getElementsByType('player')) do
            triggerClientEvent(v, 'notification:tickVariation', resourceRoot, getTickCount())
        end
    end, 500, 1)
end)

addEventHandler('onPlayerLogin', root, function()
    setTimer(function(player)
        if (not isElement(player)) then
            return
        end

        triggerClientEvent(player, 'notification:tickVariation', resourceRoot, getTickCount())

        for i = 1, #notificationsRegistred do
            local v = notificationsRegistred[#notificationsRegistred - (i - 1)]
    
            if ((getTickCount() - v.tickSended) >= v.time) then
                table.remove(notificationsRegistred, i)
            else
                triggerClientEvent(player, 'notification:add', resourceRoot, v.message, v.type, v.time, v.priority, v.tickSended)
            end
        end    
    end, 1000, 1, source)
end)
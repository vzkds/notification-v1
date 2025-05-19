Notification = {}

function Notification:constructor()
    self.rendering = false
    self.theme = Theme:get()

    self.parent = {x = respc(20), y = respc(26)}

    self.tickVariation = 0

    self.notifications = {
        count = 0;
        
        list = {};
    }

    self.events = {
        render = function()
            self:render()
        end;
    }

    self.font = {
        title = dxCreateFont('public/font/RobotoCondensed-Regular.ttf', respc(11));
        message = dxCreateFont('public/font/RobotoCondensed-Regular.ttf', respc(9.5));
    }
    
    self.font.height = dxGetFontHeight(1, self.font.message)
end

function Notification:render()
    local y = self.parent.y

    local backgroundColor = {
        r = lerp:create('bg_r', self.theme.background[1], self.theme.background[1], 0.1);
        g = lerp:create('bg_g', self.theme.background[2], self.theme.background[2], 0.1);
        b = lerp:create('bg_b', self.theme.background[3], self.theme.background[3], 0.1);
        a = lerp:create('bg_a', self.theme.background[4], self.theme.background[4], 0.1);
    }

    local textColor = {
        r = lerp:create('text_r', self.theme.text[1], self.theme.text[1], 0.1);
        g = lerp:create('text_g', self.theme.text[2], self.theme.text[2], 0.1);
        b = lerp:create('text_b', self.theme.text[3], self.theme.text[3], 0.1);
        a = lerp:create('text_a', self.theme.text[4], self.theme.text[4], 0.1);
    }

    local divColor = {
        r = lerp:create('div_r', self.theme.div[1], self.theme.div[1], 0.1);
        g = lerp:create('div_g', self.theme.div[2], self.theme.div[2], 0.1);
        b = lerp:create('div_b', self.theme.div[3], self.theme.div[3], 0.1);
        a = lerp:create('div_a', self.theme.div[4], self.theme.div[4], 0.1);
    }

    local defaultTypeColor = {
        r = lerp:create('defaultType_r', self.theme.defaultType[1], self.theme.defaultType[1], 0.1);
        g = lerp:create('defaultType_g', self.theme.defaultType[2], self.theme.defaultType[2], 0.1);
        b = lerp:create('defaultType_b', self.theme.defaultType[3], self.theme.defaultType[3], 0.1);
    }

    for i = #self.notifications.list, 1, -1 do
        local v = self.notifications.list[i]

        if (v.cache.alpha[2] == 0 and (getTickCount() - v.cache.alpha[3]) > 800) then
            table.remove(self.notifications.list, i)

            if (#self.notifications.list == 0) then
                self.rendering = false
                
                removeEventHandler('onClientRender', root, self.events.render)
            end
        else
            if (y < screen.y) then
                local bgHeight = ((v.cache.height * respc(self.font.height)) + respc(39 + 57))

                if ((getTickCount() - v.cache.tick) >= v.time and v.cache.alpha[2] == 1) then
                    v.cache.alpha[2] = 0
                    v.cache.alpha[3] = getTickCount()
        
                    v.cache.position.x[2] = 0
                    v.cache.position.x[3] = getTickCount()
                end
        
                if (v.cache.position.y[2] ~= y) then
                    if (v.cache.position.y[1] == 0) then
                        v.cache.position.y[1] = y
                    end
        
                    v.cache.position.y[2] = y
                    v.cache.position.y[3] = getTickCount()
                end
        
                local alpha = interpolateBetween(v.cache.alpha[1], 0, 0, v.cache.alpha[2], 0, 0, (getTickCount() - v.cache.alpha[3]) / 300, 'Linear')
                local xPosition = interpolateBetween(v.cache.position.x[1], 0, 0, v.cache.position.x[2], 0, 0, (getTickCount() - v.cache.position.x[3]) / 500, 'OutQuad')
                local yPosition = interpolateBetween(v.cache.position.y[1], 0, 0, v.cache.position.y[2], 0, 0, (getTickCount() - v.cache.position.y[3]) / 500, 'OutQuad')
    
                local countAlpha = interpolateBetween(v.cache.count.alpha[1], 0, 0, v.cache.count.alpha[2], 0, 0, (getTickCount() - v.cache.count.alpha[3]) / 500, 'Linear')
        
                if (v.cache.alpha[2] == alpha) then
                    v.cache.alpha[1] = alpha
                end
        
                if (v.cache.position.x[2] == xPosition) then
                    v.cache.position.x[1] = xPosition
                end
        
                if (v.cache.position.y[2] == yPosition) then
                    v.cache.position.y[1] = yPosition
                end
    
                if (v.cache.count.alpha[2] == countAlpha) then
                    v.cache.count.alpha[1] = countAlpha
                end
        
                local xNotification, yNotification = (self.parent.x * xPosition), yPosition
        
                dxDrawSvgRectangle(xNotification, yNotification, respc(378), bgHeight, respc(12), rgba(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a * alpha))
        
                dxDrawImage(xNotification + respc(338), yNotification + respc(8), respc(30), respc(34), 'public/image/count.png', 0, 0, 0, rgba((v.type.accentColor and v.type.accentColor[1] or defaultTypeColor.r), (v.type.accentColor and v.type.accentColor[2] or defaultTypeColor.g), (v.type.accentColor and v.type.accentColor[3] or defaultTypeColor.b), (0.65 * countAlpha) * alpha))
                if (v.cache.count.number > 999) then
                    dxDrawText('+999x', xNotification + respc(338), yNotification + respc(8), respc(30), respc(34), rgba(255, 255, 255, countAlpha * alpha), 1, self.font.message, 'center', 'center')
                else
                    dxDrawText(v.cache.count.number..'x', xNotification + respc(338), yNotification + respc(8), respc(30), respc(34), rgba(255, 255, 255, countAlpha * alpha), 1, self.font.message, 'center', 'center')
                end
                
                dxDrawText(v.type.title, xNotification + respc(20), yNotification + respc(18), respc(315), respc(26), rgba((v.type.accentColor and v.type.accentColor[1] or defaultTypeColor.r), (v.type.accentColor and v.type.accentColor[2] or defaultTypeColor.g), (v.type.accentColor and v.type.accentColor[3] or defaultTypeColor.b), alpha), 1, self.font.title, 'left', 'top', false, true)
                dxDrawText(v.message, xNotification + respc(20), yNotification + respc(40), respc(315), respc(v.cache.height * self.font.height), rgba(textColor.r, textColor.g, textColor.b, textColor.a * alpha), 1, self.font.message, 'left', 'top', false, true)
        
                dxDrawRectangle(xNotification + respc(20), yNotification + respc(40 + (v.cache.height * self.font.height) + 18), respc(334), 1, rgba(divColor.r, divColor.g, divColor.b, divColor.a * alpha))
        
                dxDrawText(calcTimeBasedOnOsTime(v.cache.time), xNotification + respc(20), yNotification + respc(40 + (v.cache.height * self.font.height) + 18 + 10), respc(334), 1, rgba(textColor.r, textColor.g, textColor.b, textColor.a * alpha), 1, self.font.message, 'left', 'top', false, true)
                dxDrawImage(xNotification + respc(20), yNotification + respc(40 + (v.cache.height * self.font.height) + 18 + 34), respc(338), respc(4), 'public/image/bar.png', 0, 0, 0, rgba((v.type.accentColor and v.type.accentColor[1] or defaultTypeColor.r), (v.type.accentColor and v.type.accentColor[2] or defaultTypeColor.g), (v.type.accentColor and v.type.accentColor[3] or defaultTypeColor.b), 0.35 * alpha))
                
                local barProgress = math.min(respc(338 * ((getTickCount() - v.cache.tick) / v.time)), respc(338))
                dxDrawImageSection(xNotification + respc(20), yNotification + respc(40 + (v.cache.height * self.font.height) + 18 + 34), barProgress, respc(4), 0, 0, barProgress, respc(4), 'public/image/bar.png', 0, 0, 0, rgba((v.type.accentColor and v.type.accentColor[1] or defaultTypeColor.r), (v.type.accentColor and v.type.accentColor[2] or defaultTypeColor.g), (v.type.accentColor and v.type.accentColor[3] or defaultTypeColor.b), 1 * alpha))
                
                y = y + (bgHeight + respc(14))    
            end
        end
    end
end

function Notification:updateTheme(theme)
    self.theme = theme
end

function Notification:setTickVariation(tickServer)
    self.tickVariation = (getTickCount() - tickServer)
end

function Notification:add(message, notificationType, time, priority, tickSended)
    if (not message or type(message) ~= 'string') then
        return false, error('['..getResourceName(getThisResource())..'] Defina uma mensagem para o anúncio', 2)
    end

    if (not notificationType or type(notificationType) ~= 'string') then
        return false, error('['..getResourceName(getThisResource())..'] Defina um tipo de notificação', 2)
    end

    if (settings.stackNotifications) then
        for i, v in pairs(self.notifications.list) do
            if (v.message == message and v.type.title == (settings.types[notificationType] and settings.types[notificationType].title or notificationType)) then
                v.cache.count.number = (v.cache.count.number + 1)

                if (v.cache.count.alpha[2] == 0) then
                    v.cache.count.alpha[2] = 1
                    v.cache.count.alpha[3] = getTickCount()
                end
                
                return
            end
        end
    end

    table.insert(self.notifications.list, (priority and 1 or (#self.notifications.list + 1)), {
        message = message;
        type = (settings.types[notificationType] or {title = notificationType});
        time = (time or 5000);
        
        cache = {
            count = {number = 1, alpha = {0, 0, getTickCount()}};

            height = math.floor(dxGetTextWidth(message, 1, self.font.message) / respc(315)) + 1;

            tick = (tickSended and (tickSended + self.tickVariation) or getTickCount());
            time = (tickSended and os.time() - ((getTickCount() - (tickSended + self.tickVariation)) / 1000) or os.time());

            alpha = {0, 1, getTickCount()};
            position = {
                x = {0, 1, getTickCount()};
                y = {0, 0, getTickCount()};
            };
        };
    })

    if (not self.rendering) then
        self.rendering = true
        
        addEventHandler('onClientRender', root, self.events.render)
    end
end

--

addCommandHandler('teste', function()
    for i, v in pairs(settings.types) do
        Notification:add('Notificação de teste', i, 10000)
    end

    Notification:add('Notificação de teste', 'Padrão', 10000)
end)

addCommandHandler('tema', function()
    return Theme:set('next')
end)

--

addEventHandler('onClientResourceStart', resourceRoot, function()
    return Theme:constructor(), Notification:constructor()
end)

function add(...)
    return Notification:add(...)
end
addEvent('notification:add', true)
addEventHandler('notification:add', root, add)

addEvent('notification:tickVariation', true)
addEventHandler('notification:tickVariation', root, function(...)
    return Notification:setTickVariation(...)
end)
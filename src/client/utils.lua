screen = Vector2(guiGetScreenSize())

local scale = math.min(math.max (0.25, (screen.y / 1080)), 2)

local textures = {}

-- // --

function respc(v)
    return (v * scale)
end

-- // --

local _dxDrawImage = dxDrawImage
function dxDrawImage(x, y, w, h, path, ...)   
    local function createTexture(path)
        if (not path) then
            return error('Defina o diretório correto da imagem.', 2)
        end
    
        if (not textures[path]) then
            textures[path] = (type(path) == 'string' and dxCreateTexture(path) or path)
        end

        return textures[path]
    end

    return _dxDrawImage(x, y, w, h, createTexture(path), ...)
end

_dxDrawText = dxDrawText
function dxDrawText(text, x, y, w, h, color, scale, font, alignX, alignY, ...)
    return _dxDrawText(text, x, y, (w + x), (y + h), color, scale, font, alignX, alignY, ...)
end

-- // --

function rgba(r, g, b, a)
    return tocolor(math.min(255, math.max(0, r)), math.min(255, math.max(0, g)), math.min(255, math.max(0, b)), math.min(255, math.max(0, (a * 255))))
end

-- // --

local svgRectangles = {}

function dxDrawSvgRectangle(x, y, w, h, radius, ...)
    if (not svgRectangles[w]) then
        svgRectangles[w] = {}
    end

    if (not svgRectangles[w][h]) then
        svgRectangles[w][h] = {}
    end

    if (not svgRectangles[w][h][radius]) then
        local raw = [[
            <svg width=']]..w..[[' height=']]..h..[[' fill='none'>
                <mask id='path_inside' fill='white' >
                    <rect width=']]..w..[[' height=']]..h..[[' rx=']]..radius..[[' />
                </mask>
                <rect width=']]..w..[[' height=']]..h..[[' rx=']]..radius..[[' fill='white' mask='url(#path_inside)'/>
            </svg>
        ]]

        svgRectangles[w][h][radius] = svgCreate(w, h, raw, function(e)
            if (not e or not isElement(e)) then 
                return
            end

            dxSetTextureEdge(e, 'border')
        end)
    end

    if (svgRectangles[w][h][radius]) then
        dxDrawImage(x, y, w, h, svgRectangles[w][h][radius], 0, 0, 0, ...)
    end
end

--

lerp = {
    lerps = {};

    lerp = function(self, a, b, t)
        return (a * (1 - t) + b * t)
    end;

    create = function(self, index, start, finish, duration)
        if (not self.lerps[index]) then
            self.lerps[index] = start
        end

        self.lerps[index] = self:lerp(self.lerps[index], finish, duration)
        
        return self.lerps[index]
    end;
}

--

local cacheCalcTime = {}

function calcTimeBasedOnOsTime(lastTime)
    local result = (os.time() - lastTime)

    if (not cacheCalcTime[result]) then
        local hours = math.floor(result / 3600)
        local minutes = math.floor((result - (hours * 3600)) / 60)
        local seconds = math.floor(result - (hours * 3600) - (minutes * 60))

        local text = ''

        if (hours > 0) then
            text = text..hours..'h '
        end

        if (minutes > 0) then
            text = text..minutes..'m '
        end

        if (seconds > 0 or #text == 0) then
            text = text..seconds..'s'
        end

        cacheCalcTime[result] = text
    end

    return cacheCalcTime[result]
end
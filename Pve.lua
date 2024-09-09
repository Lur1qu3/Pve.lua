

setDefaultTab("Pve")
UI.Label('-- [UP] --'):setColor('green')

storage.widgetPos = storage.widgetPos or {};

local antiRedTimeWidget = setupUI([[
UIWidget
  background-color: black
  opacity: 0.8
  padding: 0 5
  focusable: true
  phantom: false
  draggable: true
]], g_ui.getRootWidget());

local isMobile = modules._G.g_app.isMobile();
g_keyboard = g_keyboard or modules.corelib.g_keyboard;

local isDragKeyPressed = function()
  return isMobile and g_keyboard.isKeyPressed("F2") or g_keyboard.isCtrlPressed();
end

antiRedTimeWidget.onDragEnter = function(widget, mousePos)
  if (not isDragKeyPressed()) then return; end
  widget:breakAnchors();
  local widgetPos = widget:getPosition();
  widget.movingReference = {x = mousePos.x - widgetPos.x, y = mousePos.y - widgetPos.y};
  return true;
end

antiRedTimeWidget.onDragMove = function(widget, mousePos, moved)
  local parentRect = widget:getParent():getRect();
  local x = math.min(math.max(parentRect.x, mousePos.x - widget.movingReference.x), parentRect.x + parentRect.width - widget:getWidth());
  local y = math.min(math.max(parentRect.y - widget:getParent():getMarginTop(), mousePos.y - widget.movingReference.y), parentRect.y + parentRect.height - widget:getHeight());   
  widget:move(x, y);
  storage.widgetPos.antiRedTime = {x = x, y = y};
  return true;
end

local name = "antiRedTime";
storage.widgetPos[name] = storage.widgetPos[name] or {};
antiRedTimeWidget:setPosition({x = storage.widgetPos[name].x or 50, y = storage.widgetPos[name].y or 50});



local refreshSpells = function()
  castingSpells = {};
  if (storage.comboSpells) then
    local split = storage.comboSpells:split(",");
    for _, spell in ipairs(split) do
      table.insert(castingSpells, spell:trim());
    end
  end
end


addTextEdit("Magias", storage.comboSpells or "magia1, magia2, magia3", function(widget, text)
  storage.comboSpells = text;
  refreshSpells();
end)

refreshSpells();


UI.Label('Area:')
addTextEdit("Area", storage.areaSpell or "Magia de Area", function(widget, text)
  storage.areaSpell = text;
end)

if (not getSpectators or #getSpectators(true) == 0) then
  getSpectators = function()
    local specs = {};
    local tiles = g_map.getTiles(posz());
    for i = 1, #tiles do
      local tile = tiles[i];
      local creatures = tile:getCreatures();
      for _, spec in ipairs(creatures) do
        table.insert(specs, creature);
      end
    end
    return specs;
  end
end

if (not storage.antiRedTime or storage.antiRedTime - 30000 > now) then
  storage.antiRedTime = 0;
end

local addAntiRedTime = function()
  storage.antiRedTime = now + 30000;
end

local toInteger = function(number)
  number = tostring(number);
  number = number:split(".");
  return tonumber(number[1]);
end

antidrop = macro(200, "Anti-Red", function()
  local pos, monstersCount = pos(), 0;
  if (player:getSkull() >= 3) then
    addAntiRedTime();
  end
  local specs = getSpectators(true);
  for _, spec in ipairs(specs) do
    local specPos = spec:getPosition();
    local floorDiff = math.abs(specPos.z - pos.z);
    if (floorDiff > 3) then 
      goto continue;
    end
    if (spec ~= player and spec:isPlayer() and spec:getEmblem() ~= 1 and spec:getShield() < 3) then
      addAntiRedTime();
      break
    elseif (floorDiff == 0 and spec:isMonster() and getDistanceBetween(specPos, pos) == 1) then
      monstersCount = monstersCount + 1;
    end
    ::continue::
  end
  if (storage.antiRedTime >= now) then
    antiRedTimeWidget:show();
    local diff = storage.antiRedTime - now;
    diff = diff / 1000;
    antiRedTimeWidget:setText(tr("Sem Area %ds.", toInteger(diff)));
    antiRedTimeWidget:setColor("red");
  elseif (not antiRedTimeWidget:isHidden()) then
    antiRedTimeWidget:hide();
  end
  if (monstersCount > 1 and storage.antiRedTime < now) then
    return say(storage.areaSpell);
  end
  if (not g_game.isAttacking()) then return; end
     for _, spell in ipairs(castingSpells) do
    say(spell);
  end
end)
addIcon("AntiRed", {item=12616, text="AntiRed"},antidrop)

UI.Separator()

UI.Label("Config % Mystic/kai")

UI.Label("Usar Hp Menor")
addTextEdit("Mystic defense", storage.mystichp or "Mystic defense", function(widget, text) storage.mystichp = text
end)

UI.Label("Tirar Com Hp Maior Que")
addTextEdit("Mystic kai", storage.mystichpkai or "Mystic kai", function(widget, text) storage.mystichpkai = text
end)



onTextMessage(function(mode, text)
        if not text:find('Warning!') then return; end
        say('VOCÊ FOI ELIMINADO PELO PROFESSOR')
    end)



Stairs = {}

excludeIds = {}

if type(storage.stairsIds) ~= "table" then
  storage.stairsIds = {
    1666, 6207, 1948, 435, 11661, 7771, 5542, 8657, 6264, 1646, 1648, 1678, 
    5291, 1680, 6905, 6262, 1664, 13296, 1067, 13861, 11931, 1949, 6896, 6205, 
    13926, 1947, 1968, 5111, 5102, 7725, 7727
  }
end

if type(storage.excludeIds) ~= "table" then
  storage.excludeIds = {} -- Inicializando a lista de IDs excluídos
end


stairsIds = {}
for index, id in ipairs(storage.stairsIds) do
    stairsIds[tostring(id)] = true
end

excludeIds = {}
for index, id in ipairs(storage.excludeIds) do
    excludeIds[tostring(id)] = true
end


local stairsContainer = UI.Container(function(widget, items)
  storage.stairsIds = {}
  for _, item in ipairs(items) do
    table.insert(storage.stairsIds, item.id)
    stairsIds[tostring(item.id)] = true
  end
end, true)
stairsContainer:setHeight(35)
stairsContainer:setItems(storage.stairsIds)


local excludeContainer = UI.Container(function(widget, items)
  storage.excludeIds = {}
  for _, item in ipairs(items) do
    table.insert(storage.excludeIds, item.id)
    excludeIds[tostring(item.id)] = true
  end
end, true)
excludeContainer:setHeight(35)
excludeContainer:setItems(storage.excludeIds)


Stairs.saveStatus = {}

Stairs.checkTile = function(tile)
    if not tile then
        return false
    end

    local tilePos = tile:getPosition()

    if not tilePos then
        return
    end

    local onString = Stairs.postostring(tilePos)

    local checkStatus = Stairs.saveStatus[onString]

    local itemsOnTile = tile:getItems()

    if checkStatus and ((type(checkStatus[1]) == "number" and #itemsOnTile == checkStatus[1]) or checkStatus[1] == true) then
        return checkStatus[2]
    end

    local topThing = tile:getTopUseThing()

    if not topThing then
        return false
    end

    for _, x in ipairs(itemsOnTile) do
        if excludeIds[tostring(x:getId())] then
            Stairs.saveStatus[onString] = {#itemsOnTile, false}
            return false
        end
    end

    if stairsIds[tostring(topThing:getId())] then
        Stairs.saveStatus[onString] = {true, true}
        return true
    end

    local cor = g_map.getMinimapColor(tile:getPosition())
    if cor >= 210 and cor <= 213 and not tile:isPathable() and tile:isWalkable() then
        Stairs.saveStatus[onString] = {true, true}
        return true
    else
        Stairs.saveStatus[onString] = {#itemsOnTile, false}
        return false
    end
end

Stairs.postostring = function(pos)
    return pos.x .. "," .. pos.y .. "," .. pos.z
end

function Stairs.accurateDistance(p1, p2)
    if type(p1) == "userdata" then
        p1 = p1:getPosition()
    end
    if type(p2) ~= "table" then
        p2 = pos()
    end
    return math.abs(p1.x - p2.x) + math.abs(p1.y - p2.y)
end

Stairs.getPosition = function(pos, dir)
    if dir == 0 then
        pos.y = pos.y - 1
    elseif dir == 1 then
        pos.x = pos.x + 1
    elseif dir == 2 then
        pos.y = pos.y + 1
    else
        pos.x = pos.x - 1
    end

    return pos
end

function table.reverse(t)
  local newTable = {}
  local j = 0
  for i = #t, 1, -1 do
    j = j + 1
    newTable[j] = t[i]
  end
  return newTable
end

function reverseDirection(dir)
  if dir == 0 then
    return 2
  elseif dir == 1 then
    return 3
  elseif dir == 2 then
    return 0
  elseif dir == 3 then
    return 1
  end
end

Stairs.goUse = function(pos)
    local playerPos = player:getPosition()
    local path = findPath(pos, playerPos)
    if not path then
        return
    end
    path = table.reverse(path)
    for i, v in ipairs(path) do
        if i > 5 then
            break
        end
        playerPos = Stairs.getPosition(playerPos, reverseDirection(v))
    end
    local tile = g_map.getTile(playerPos)
    local topThing = tile and tile:getTopUseThing()
    if topThing then
        g_game.use(topThing)
        if table.equals(tile:getPosition(), pos) then
            return delay(300)
        end
    end
end

Stairs.checkAll = function(n)
    n = n and n + 1 or 1
    if n > 9 then
        return
    end
    local pos = pos()
    local tiles = {}
    for x = -n, n do
        for y = -n, n do
            local stairPos = {x = pos.x + x, y = pos.y + y, z = pos.z}
            local tile = g_map.getTile(stairPos)
            if Stairs.checkTile(tile) and findPath(stairPos, pos) then
                table.insert(tiles, {tile = tile, distance = Stairs.accurateDistance(pos, stairPos)})
            end
        end
    end
    if #tiles == 0 then
        return Stairs.checkAll(n)
    end
    table.sort(
        tiles,
        function(a, b)
            return a.distance < b.distance
        end
    )
    return tiles[1].tile
end

stand = now
onPlayerPositionChange(
    function(newPos, oldPos)
        stand = now
        tryWalk = nil
        if newPos.z ~= oldPos.z or getDistanceBetween(oldPos, newPos) > 1 or table.equals(Stairs.pos, newPos) then
            Stairs.walk.setOff()
        end
        if Stairs.walk.isOff() then
            checked = nil
        end
    end
)

timeInPos = function()
    return now - stand
end

onAddThing(
    function(tile, thing)
        if type(Stairs.pos) == "table" then
            if table.equals(tile:getPosition(), Stairs.pos) then
                Stairs.bestTile = tile
            end
        end
    end
)

markOnThing = function(thing, color)
    if thing then
        if thing:getPosition() then
            local useThing = thing:getTopUseThing()
            if color == "#00FF00" then
                thing:setText("AQUI", "green")
            elseif color == "#FF0000" then
                thing:setText("AQUI", "red")
            else
                thing:setText("")
            end
            return true
        end
    end
    return false
end

Stairs.walk =
    macro(
    1,
    function()
        if modules.corelib.g_keyboard.isKeyPressed("Escape") then
            return Stairs.walk.setOff()
        end
        player:lockWalk(300)
        if tryWalk then
            return
        end
        markOnThing(Stairs.bestTile, "#00FF00")
        if Stairs.bestTile:isWalkable() then
            if not Stairs.bestTile:isPathable() then
                if autoWalk(Stairs.pos, 1) then
                    tryWalk = true
                    return
                end
            end
        end
        return Stairs.goUse(Stairs.pos)
    end
)

Stairs.walk.setOff()


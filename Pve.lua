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



local castBelowHp = 70 

mystic60 = macro(100, "Mystic Defense/Kai",  function()
  if (hppercent() < castBelowHp and not hasManaShield()) then
    say('Mystic Defense') 
  end
  if (hppercent() >= castBelowHp and hasManaShield()) then
    say('Mystic Kai')
  end
end,hpPanel5)



local panelName = "codPan"
local codPanel = setupUI([[
Panel
  id: healingPanel
  height: 50
  margin-top: 3

  Label
    id: label2
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    margin: 0 5 0 5
    text-align: center

  HorizontalScrollBar
    id: scroll1
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    minimum: 1
    maximum: 100
    step: 1

]])

if not storage[panelName] then
    storage[panelName] = {
        hpPercent = castBelowHp 
    }
end
    
codPanel.scroll1.onValueChange = function(scroll, value)
  castBelowHp = value 
  storage[panelName].hpPercent = value 
  codPanel.label2:setText("MYSTIC%" .. castBelowHp)
end


codPanel.scroll1:setValue(storage[panelName].hpPercent or castBelowHp)

addIcon("Def/kai", {item=672, movable=true, text = "Def/kai"}, mystic60)



onTextMessage(function(mode, text)
        if not text:find('Warning!') then return; end
        say('VOCÊ FOI ELIMINADO PELO PROFESSOR')
    end)


UI.Label('Ids Escadinhas')
addTextEdit("IDS, IDS...", storage.escadinhas or "IDS, IDS...", function(widget, text)
    storage.escadinhas = text
end)


UI.Label("[VIGIA]: Receber PM:")
UI.TextEdit(storage.nomeDoJogador or "Nome Para Receber", function(widget, text)
  storage.nomeDoJogador = text
  NomeDoJogador = text
end)

UI.Label('Stamina>Hora Pra usar')
addTextEdit("hora", storage.hora or "usar em", function(widget, text) 
storage.hora = text
end)
UI.Label('Id Da Stamina')
addTextEdit("id", storage.id or "id stamina", function(widget, text) 
storage.id = text
end)
UI.Separator()
UI.Label('Id Do Aol')
addTextEdit("idAOL", storage.idDoAol or "id do aol", function(widget, text) 
storage.idDoAol = text
end)
UI.Label('Comando>!bol/!jam')
addTextEdit("buyaol", storage.buyaol or "Comprar", function(widget, text) 
storage.buyaol = text
end)
UI.Separator()
UI.Label('Magia Stack')

addTextEdit("Magia Stack", storage.stackar or "Magia Stack", function(widget, text) 
storage.stackar = text
end)
UI.Separator()
UI.Label('%Nocaute Area%')

addTextEdit("Area1", storage.Area1 or "Area25%", function(widget, text) 
storage.Area1 = text
end)





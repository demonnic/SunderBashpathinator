snd = snd or {}
snd.paths = snd.paths or {}
snd.pathinator = snd.pathinator or {}
snd.pathinator.sortBy = snd.pathinator.sortBy or "sortByName"
snd.paths.custom = snd.paths.custom or {}
local filename = getMudletHomeDir() .. "/sunderPathinator.lua"
snd.pathinator.buttonStyle = Geyser.StyleSheet:new([[
  border-width: 2px;
  border-style: double;
  border-color: black;
  background-color: darkslategrey;
]])
local textColor = "cyan"
function snd.pathinator:browser()
  self.window = Geyser.UserWindow:new({
    name = "Sunder BashPathinator Window",
    font = getFont(),
    fontSize = getFontSize(),
    width = "90c",
    height = "25c"
  })
  self.hbox = Geyser.HBox:new({
    name = "Sunder BashPathinator HBox",
    height = "4%",
    width = "100%",
    x = 0,
    y = 0
  }, self.window)
  self.areaListButton = Geyser.Label:new({
    name = "Sunder BashPathinator Area List Button",
    message = "<center>Area List</center>",
    stylesheet = self.buttonStyle:getCSS(),
    fgColor = textColor,
    }, self.hbox)
  self.areaListButton:setClickCallback(function()
    self.expandedArea = ""
    self:displayAreaList()
  end)
  self.customPathButton = Geyser.Label:new({
    name = "Sunder BashPathinator Custom Path Button",
    message = "<center>Custom Path</center>",
    stylesheet = snd.pathinator.buttonStyle:getCSS(),
    fgColor = textColor,
  }, self.hbox)
  self.customPathButton:setClickCallback(function()
    self:displayCustomPathList()
  end)
  self.console = Geyser.MiniConsole:new({
    name = "Sunder BashPathinator Console",
    height = "96%",
    width = "100%",
    y = "4%",
    x = "0",
    color = "black",
  }, self.window)
  self:loadAreas()
  self:displayAreaList()
end

function snd.pathinator:load()
  local path = {}
  if io.exists(filename) then
    table.load(filename, path)
  end
  snd.paths.custom = path
end

function snd.pathinator:getLevelForSorting(level)
  local effectiveLevel
  effectiveLevel = level:match("^(%d+)%-%d+")
  if effectiveLevel then
    return tonumber(effectiveLevel)
  end
  effectiveLevel = level:match("^(%d+)%+?")
  if effectiveLevel then
    return tonumber(effectiveLevel)
  end
  local loweredLevel = level:lower()
  if loweredLevel == "newbie" then
    return 0
  end
  if table.contains({"good luck", "lolnope", "really high"}, loweredLevel) then
    return 600
  end
  if loweredLevel == "we're all fucking dead" then
    return 900
  end
  if loweredLevel == "quest" then
    return 1000
  end
  if loweredLevel == "globes only" then
    return 1100
  end
  return 1200
end

local function stripName(name)
  local newName = name:match("^[aA]n? (.+)")
  if newName then return newName end
  newName = name:match("^[tT]he (.+)")
  if newName then return newName end
  return name
end

function snd.pathinator:loadAreas()
  local areas = {}
  for _, area in ipairs(snd.areas) do
    local entry = {
      level = area.level,
      targets = area.targets,
      path = sunder_areaPaths[area.area] or {},
      items = area.items or {},
    }
    entry.sortingLevel = self:getLevelForSorting(entry.level)
    entry.sortingName = stripName(area.area)
    areas[area.area] = entry
  end
  self.areas = areas
end

function snd.pathinator:save()
  table.save(filename, snd.paths.custom or {})
end

function snd.pathinator.sortByName(t, a, b)
  return t[a].sortingName < t[b].sortingName
end

function snd.pathinator.sortByNameReverse(t, a, b)
  return t[a].sortingName > t[b].sortingName
end

function snd.pathinator.sortByLevel(t, a, b)
  return t[a].sortingLevel < t[b].sortingLevel
end

function snd.pathinator.sortByLevelReverse(t, a, b)
  return t[a].sortingLevel > t[b].sortingLevel
end

function snd.pathinator:echoHeader()
  local mc = self.console
  local nameTip = "Sort by area name"
  local levelTip = "Sort by level"
  if self.sortBy == "sortByName" then
    nameTip = nameTip .. " (reversed)"
  end
  if self.sortBy == "sortByLevel" then
    levelTip = levelTip .. " (reversed)"
  end
  mc:cechoLink(string.format("<green><b>%-25s<reset></b>", "Area"), function()
    if self.sortBy == "sortByName" then
      self.sortBy = "sortByNameReverse"
    else
      self.sortBy = "sortByName"
    end
    self:displayAreaList(self.expandedArea)
  end, nameTip, true)
  mc:cechoLink(string.format("<green><b>%-15s<reset></b>", "Level"), function()
    if self.sortBy == "sortByLevel" then
      self.sortBy = "sortByLevelReverse"
    else
      self.sortBy = "sortByLevel"
    end
    self:displayAreaList(self.expandedArea)
  end, levelTip, true)
  mc:cecho(string.format("<green><b>%-25s%-20s</b><reset>\n", "Targets", "Items"))
end

function snd.pathinator:displayAreaList(areaName)
  local mc = self.console
  mc:clear()
  self:echoHeader()
  if areaName then
    self.expandedArea = areaName
    self:displaySingleArea(areaName)
    scrollTo(mc.name)
  else
    self.expandedArea = nil
    for name, area in spairs(self.areas, self[self.sortBy]) do
      self:displaySingleArea(name, area)
    end
    self:echoHeader()
  end
end

function snd.pathinator:displaySingleArea(name, area)
  area = area or self.areas[name]
  local mc = self.console
  local level, targets, items = area.level, area.targets, area.items
  local index = table.index_of(snd.paths.custom, name)
  local color = index and "<green>" or "<red>"
  local displayName = area.sortingName:sub(1,24):title()
  local displayLevel = level:sub(1,14)
  local clickmsg = index and string.format("Remove %s from custom path", displayName) or string.format("Add %s to custom path", displayName)
  local expanded = self.expandedArea == name
  local toggleArea = function()
    if index then
      table.remove(snd.paths.custom, index)
    else
      snd.paths.custom[#snd.paths.custom + 1] = name
    end
    self:save()
    self:displayAreaList(expanded and name or nil)
  end
  mc:cechoLink(string.format("<i>%s%-25s</i>", color, displayName, name), toggleArea, clickmsg, true)
  mc:cecho(string.format("<i>%-15s</i>", displayLevel))
  if expanded then
    local target = targets[1] or ""
    local item = items[1] or ""
    local displayTarget = target:sub(1,24)
    local displayItem = item:sub(1,20)
    mc:cecho(string.format("<i>%-25s%-20s\n</i>", displayTarget, displayItem))
    local extraLines = #targets > #items and #targets or #items
    if extraLines > 1 then
      for i = 2, extraLines do
        target = targets[i] or ""
        item = items[i] or ""
        displayTarget = target:sub(1,20)
        displayItem = item:sub(1,20)
        mc:cecho(string.format("<i>%25s%15s%-25s%-20s\n</i>", "", "", displayTarget, displayItem))
      end
    end
  else
    local target = #targets
    local item = #items
    local expandDisplay = function()
      self:displayAreaList(name)
    end
    mc:cechoLink(string.format("%-25s", target), expandDisplay, "Shows only this area, with full target and item information", true)
    mc:cechoLink(string.format("%-20s", item), expandDisplay, "Shows only this area, with full target and item information", true)
  end
  mc:echo("\n")
end

function snd.pathinator:displayCustomPathList()
  local mc = self.console
  mc:clear()
  mc:cecho(string.format("<green><b>%-15s%-25s%-15s%-15s<reset></b>\n", "Index", "Area Name", "Level", "# of targets"))
  for index, name in ipairs(snd.paths.custom) do
    self:displaySinglePathItem(index, name)
  end
end

function snd.pathinator:displaySinglePathItem(index, name)
  local mc = snd.pathinator.console
  local top = function()
    table.top(snd.paths.custom, index)
    self:save()
    self:displayCustomPathList()
  end
  local bottom = function()
    table.bottom(snd.paths.custom, index)
    self:save()
    self:displayCustomPathList()
  end
  local raise = function()
    table.raise(snd.paths.custom, index)
    self:save()
    self:displayCustomPathList()
  end
  local lower = function()
    table.lower(snd.paths.custom, index)
    self:save()
    self:displayCustomPathList()
  end
  local info = self.areas[name]
  local numTargets = #info.targets
  local level = self.areas[name].level:sub(1,14)
  local displayName = stripName(name):sub(1,24):title()
  local totalPaths = #snd.paths.custom
  local previousIndex = index - 1
  if previousIndex == 0 then
    previousIndex = 1
  end
  local nextIndex = index + 1
  if nextIndex > totalPaths then
    nextIndex = totalPaths
  end
  mc:cechoLink("<red><<", top, "Move to first", true)
  mc:echo(" ")
  mc:cechoLink("<red><", raise, "Move up to " .. previousIndex, true)
  mc:echo(" ")
  mc:cechoLink("<red>>", lower, "Move down to " .. nextIndex, true)
  mc:echo(" ")
  mc:cechoLink("<red>>>", bottom, "Move to last", true)
  mc:echo(" ")
  mc:cecho(string.format("%-5s%-25s%-15s%-15s\n", index, displayName, level, numTargets))
end

if table.is_empty(snd.paths.custom) then
  snd.pathinator:load()
end
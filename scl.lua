local io = require('io')

local Pitch = {}
Pitch.__index = Pitch

function Pitch.new(n, d)
  local o = { n, d or 1 }
  return setmetatable(o, Pitch)
end

function Pitch:__tostring()
  return tostring(self[1]) .. '/' .. tostring(self[2])
end

function Pitch.parse(str)
  -- scala pitch line syntax
  local p = string.match(str, "([%d-./]+)")
  if p == nil then
    return nil
  end
  -- lame double match to detect ratio syntax
  local n, d = string.match(p, "([%d.-]+)/([%d.-]+)")
  if n ~= nil then
    return Pitch.new(tonumber(n), tonumber(d))
  end

  return Pitch.new(tonumber(p))
end

--
--
--

local Scale = {}
Scale.__index = Scale

function Scale.new(pitches, description)
  local o = setmetatable({}, Scale)
  o.pitches = pitches
  o.description = description or ""
  return o
end

local function is_comment(line)
  return string.find(line, "^!")
end

function Scale.load(path)
  local pitches = {}
  local lines = io.lines(path)
  local l = nil

  -- implicit base pitch
  table.insert(pitches, Pitch.new(1,1))

  -- skip initial comments
  repeat l = lines() until not is_comment(l)

  -- header
  local description = l
  local pitch_count = tonumber(lines())

  -- intermediate comments
  repeat l = lines() until not is_comment(l)

  -- pitches
  repeat
    local p = Pitch.parse(l)
    if p ~= nil then
      table.insert(pitches, p)
    end
    l = lines()
  until l == nil

  return Scale.new(pitches, description)
end

return {
  Scale = Scale,
  Pitch = Pitch,
}


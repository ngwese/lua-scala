local io = require('io')
local math = require('math')

---
--- Pitch
---

local Pitch = {}
Pitch.__index = Pitch

function Pitch.new(n, d)
  local o = { n, d or 1 }
  return setmetatable(o, Pitch)
end

function Pitch:__tostring()
  return tostring(self[1]) .. '/' .. tostring(self[2])
end

function Pitch:__call()
  return self[1] / self[2]
end

function Pitch:__mul(n)
  local d = self[2]
  local m = (n * d) / d
  return Pitch.new(self[1] * m, d)
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
    -- FIXME: should error on negative ratios
    return Pitch.new(tonumber(n), tonumber(d))
  end

  return Pitch.new(tonumber(p), 1200)
end

--
-- Scale
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

function Scale:multiplier(degree)
  -- this seems dumb, should be simplier?
  if degree == 0 then
    return 0
  end
  local s = #self.pitches
  local octave_r = self.pitches[s]()
  local n = math.floor(degree / s)
  local d = 0
  local r = nil
  if degree < 0 then
    d = math.abs(degree) % s
    r = -self.pitches[d]
  else
    d = degree % s
    r = self.pitches[d]
  end
  if r then r = r() else r = 0 end
  return (octave_r * n) + r
end



--
-- Mapping
--

local Mapping = {}
Mapping.__index = Mapping

local DEFAULT_MAPPING = {}
for i=0,11 do table.insert(DEFAULT_MAPPING, i) end

function Mapping.new(props)
  props = props or {}
  local o = setmetatable(props, Mapping)
  o.size = props.size or 12
  o.low = props.low or 0
  o.high = props.high or 127
  o.base = props.base or 60
  o.ref_note = props.ref_note or 69
  o.ref_hz = props.ref_hz or 440.0
  o.map = props.map or DEFAULT_MAPPING
  -- computed?
  o.scale_degree = #o.map -- FIXME: update on mapping change?
  o.baze_hz = 1111
  return o
end

function Mapping.load(path)
end

function Mapping:to_hz(note, scale)
  local degree = (note - self.base) % self.size
  local r = scale.pitches[degree + 1] -- 1's baseds
end

return {
  Scale = Scale,
  Pitch = Pitch,
  Mapping = Mapping,
}


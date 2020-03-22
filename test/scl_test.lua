T = require('luaunit')
scl = dofile('scl.lua')

--
-- Pitch tests
--

function test_pitch_error_negative_ratio()
  T.assertErrorMsgContains("numerator", scl.Pitch.new, -2)
  T.assertErrorMsgContains("denominator", scl.Pitch.new, 1, -3)
end

function test_pitch_parse_ratio()
  -- no whitespace
  local p = scl.Pitch.parse('81/64')
  T.assertEquals(p[1], 81)
  T.assertEquals(p[2], 64)

  local p = scl.Pitch.parse('   81/64   ')
  T.assertEquals(p[1], 81)
  T.assertEquals(p[2], 64)

  local p = scl.Pitch.parse(' 81 /64')
  T.assertEquals(p[1], 81)
  T.assertEquals(p[2], 64)

  local p = scl.Pitch.parse('81/  64')
  T.assertEquals(p[1], 81)
  T.assertEquals(p[2], 64)

  local p = scl.Pitch.parse('81/64    C3 stuff')
  T.assertEquals(p[1], 81)
  T.assertEquals(p[2], 64)
end

function test_pitch_parse_number()
  -- lone integer is ratio
  local p = scl.Pitch.parse("2")
  T.assertEquals(p[1], 2)
  T.assertEquals(p[2], 1)

  local p = scl.Pitch.parse("   2")
  T.assertEquals(p[1], 2)
  T.assertEquals(p[2], 1)

  local p = scl.Pitch.parse("2  ")
  T.assertEquals(p[1], 2)
  T.assertEquals(p[2], 1)

  -- decimal point indicates cents value
  local p = scl.Pitch.parse(" 102.")
  T.assertEquals(p[1], 102.0)
  T.assertEquals(p[2], 1200)

  local p = scl.Pitch.parse(" 102.124324")
  T.assertEquals(p[1], 102.124324)
  T.assertEquals(p[2], 1200)

  local p = scl.Pitch.parse(" 102.124324   cents")
  T.assertEquals(p[1], 102.124324)
  T.assertEquals(p[2], 1200)
end

function test_pitch_call()
  local p = scl.Pitch.new(2, 1)
  T.assertIsNumber(p())
  T.assertEquals(p(), 2.0)
end

--
-- Scale tests
--


os.exit(T.LuaUnit.run())
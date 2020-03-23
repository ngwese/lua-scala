T = require('luaunit')
scl = dofile('../scl.lua')

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
end

function test_pitch_parse_ratio_surrounding_whitespace()
  local p = scl.Pitch.parse('   81/64   ')
  T.assertEquals(p[1], 81)
  T.assertEquals(p[2], 64)
end

function test_pitch_parse_ratio_interior_whitespace()
  local p = scl.Pitch.parse(' 81 /64')
  T.assertEquals(p[1], 81)
  T.assertEquals(p[2], 64)

  local p = scl.Pitch.parse('81/  64')
  T.assertEquals(p[1], 81)
  T.assertEquals(p[2], 64)
end

function test_pitch_parse_annotated_ratio()
  local p = scl.Pitch.parse('81/64    C3 stuff')
  T.assertEquals(p[1], 81)
  T.assertEquals(p[2], 64)
end

function test_pitch_parse_number()
  local p = scl.Pitch.parse("2")
  T.assertEquals(p[1], 2)
  T.assertEquals(p[2], 1)
end

function test_pitch_parse_number_leading_space()
  local p = scl.Pitch.parse("   2")
  T.assertEquals(p[1], 2)
  T.assertEquals(p[2], 1)
end

function test_pitch_parse_number_trailing_space()
  local p = scl.Pitch.parse("2  ")
  T.assertEquals(p[1], 2)
  T.assertEquals(p[2], 1)
end

function test_pitch_parse_number_tailing_decimal()
  -- decimal point indicates cents value
  local p = scl.Pitch.parse(" 102.")
  T.assertEquals(p[1], 102.0)
  T.assertEquals(p[2], 1200)
end

function test_pitch_parse_number_decimal()
  local p = scl.Pitch.parse(" 102.124324")
  T.assertEquals(p[1], 102.124324)
  T.assertEquals(p[2], 1200)
end

function test_pitch_parse_number_annotated_decimal()
  local p = scl.Pitch.parse(" 102.124324   cents")
  T.assertEquals(p[1], 102.124324)
  T.assertEquals(p[2], 1200)
end

function test_pitch_parse_negative_number()
-- parse negative
  T.assertErrorMsgContains("numerator", scl.Pitch.parse, " -5.0")
end

function test_pitch_call()
  local p = scl.Pitch.new(2, 1)
  T.assertIsNumber(p())
  T.assertEquals(p(), 2.0)
end

--
-- Scale tests
--

function test_scale_load()
  local s = scl.Scale.load("test.scl")
  T.assertEquals(s.degrees, 8)
  T.assertEquals(s.octave_interval, scl.Pitch.new(5, 4)())
  T.assertEquals(s.description, "description of test.scl")
  T.assertEquals(#s.pitches, s.degrees)

  local p1 = s.pitches[1]
  T.assertEquals(p1[1], 81)
  T.assertEquals(p1[2], 64)

  local p6 = s.pitches[6]
  T.assertEquals(p6[1], 100.0)
  T.assertEquals(p6[2], 1200)
end

function test_scale_of()
  local s = scl.Scale.of{
    description = "test", -- optional
    25/24, 1.06, {14, 9}, 2
  }
  T.assertEquals(s.degrees, 4)
  T.assertEquals(s:pitch_class(1)(), 25/24)
  T.assertEquals(s:pitch_class(2)(), 1.06)
  T.assertEquals(s:pitch_class(3)(), 14/9)

  T.assertEquals(s.description, "test")
end

function test_scale_tet()
  local s = scl.Scale.equal_temperment(5)
  T.assertEquals(s.degrees, 5)
  T.assertEquals(s:ratio(0), 1.0)
  T.assertEquals(s:ratio(s.degrees), 2.0)
  T.assertEquals(s:ratio(-s.degrees), 0.5)

  local p1 = s:pitch_class(1)
  local p3 = s:pitch_class(3)
  local p4 = s:pitch_class(4)
  T.assertAlmostEquals(p3() - p1(), (p4() - p3()) * 2, 0.000001)
end

function test_scale_pitch_class()
  local degrees = 12
  local s = scl.Scale.equal_temperment(degrees)
  T.assertEquals(s:pitch_class(0), s.pitches[0])
   -- positive wrap around
  T.assertEquals(s:pitch_class(degrees), s.pitches[0])
  T.assertEquals(s:pitch_class(degrees + 2), s.pitches[2])
  -- negative wrap around
  T.assertEquals(s:pitch_class(-degrees), s.pitches[0])
  T.assertEquals(s:pitch_class(-1), s.pitches[degrees - 1])
end

function test_scale_ratio()
  local degrees = 6
  local s = scl.Scale.equal_temperment(degrees)
  T.assertEquals(s:ratio(0), 1.0)
  T.assertEquals(s:ratio(3), 1.5)
  T.assertEquals(s:ratio(degrees), 2.0)
  T.assertEquals(s:ratio(degrees * 2), 4.0)
  T.assertEquals(s:ratio(-3), 0.75)
  T.assertEquals(s:ratio(-degrees), 0.5)
  T.assertEquals(s:ratio(-degrees * 2), 0.25)
end

os.exit(T.LuaUnit.run())
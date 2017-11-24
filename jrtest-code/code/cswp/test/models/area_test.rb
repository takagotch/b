#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'test_helper'

class AreaTest < MiniTest::Test

  def setup
    @length = 3.0
    @width = 4.0
    @base = 5.0
    @height = 2.0
    @abase = 6.0
    @bbase = 7.0
  end

  def test_areas
    assert_equal(12, Rectangle.area(@length, @width))
    assert_equal(5, Triangle.area(@base, @height))
    assert_equal(13, Trapezoid.area(@abase, @bbase, @height))
  end

end

class AreaAndPerimeterTest < MiniTest::Test

  def setup
    @length = 3.0
    @width = 4.0
    @base = 5.0
    @height = 3.0
    @abase = 6.0
    @bbase = 7.0
    @a = 1.0
    @b = 2.0
    @c = 3.0
    @d = 4.0
  end

  def test_areas
    assert_equal(12, Rectangle.area(@length, @width))
    assert_equal(7.5, Triangle.area(@base, @height))
    assert_equal(19.5, Trapezoid.area(@abase, @bbase, @height))
  end

  def test_perimeters
    assert_equal(6, Rectangle.perimeter(@a, @b))
    assert_equal(6, Triangle.perimeter(@a, @b, @c))
    assert_equal(10, Trapezoid.perimeter(@a, @b, @c, @d))
  end

end

class RectangleTest < MiniTest::Test

  def setup
    @length = 3.0
    @width = 4.0
  end

  def test_area
    assert_equal(12, Rectangle.area(@length, @width))
  end

  def test_perimeter
    assert_equal(14, Rectangle.perimeter(@length, @width))
  end

end


class RectangleTest2 < MiniTest::Test

  def setup
    @length = 3.0
    @width = 4.0
    @height = 5.0
  end

  def test_area
    assert_equal(12, Rectangle.area(@length, @width))
  end

  def test_perimeter
    assert_equal(14, Rectangle.perimeter(@length, @width))
  end

  def test_volume
    @height = 5.0
    assert_equal(60, Rectangle.volume(@length, @width, @height))
  end

end

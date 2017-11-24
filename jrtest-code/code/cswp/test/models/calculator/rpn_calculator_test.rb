#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'test_helper'
require 'calculator/rpn_calculator'

class RPNCalculatorTest < MiniTest::Test

  def setup
    @calculator = RPNCalculator.new
  end

  def test_enter_single_number
    @calculator.push_operand(1.0)
    assert_equal(1.0, @calculator.result);
  end

  def test_enter_two_numbers
    @calculator.push_operand(1.0)
    @calculator.push_operand(2.0)
    assert_equal(2.0, @calculator.result);
  end

  def test_add_two_numbers
    @calculator.push_operand(1.0)
    @calculator.push_operand(2.0)
    @calculator.add
    assert_equal(3.0, @calculator.result);
  end

  def test_entering_threenumbers
    @calculator.push_operand(1.0)
    @calculator.push_operand(2.0)
    @calculator.push_operand(99.0)
    assert_equal(99.0, @calculator.result);
  end

  def test_entering_threenumbers_followed_by_a_plus
    @calculator.push_operand(1.0)
    @calculator.push_operand(2.0)
    @calculator.push_operand(3.0)
    @calculator.add
    assert_equal(5.0, @calculator.result);
  end

  def test_entering_plus_with_no_numbers
    @calculator.add
    assert_equal(0.0, @calculator.result);
  end

  def test_enter_single_number_followed_by_plus
    @calculator.push_operand(1.0)
    @calculator.add
    assert_equal(1.0, @calculator.result);
  end

end

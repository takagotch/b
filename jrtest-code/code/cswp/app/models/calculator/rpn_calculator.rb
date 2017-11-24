#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
class RPNCalculator

  attr_accessor :stack

  def initialize
    @stack = []
  end

  def result
    if @stack.count == 0
      return 0.0
    end
    @stack.last
  end

  def push_operand(operand)
    @stack.push(operand)
  end

  def add
    if @stack.count > 1
      @stack.push(stack.pop + stack.pop)
    end
  end

end

class RPNCalculator3

  attr_accessor :stack

  def initialize
    @stack = []
  end

  def result
    @stack.first
  end

  def push_operand(operand)
    @stack.push(operand)
  end

end

class RPNCalculator2

  attr_accessor :operand

  def initialize
    @operand = 0
  end

  def result
    @operand
  end

  def push_operand(operand)
    @operand = operand
  end

end
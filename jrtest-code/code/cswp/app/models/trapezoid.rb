#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
class Trapezoid

  def self.area(abase, bbase, height)
    return (abase + bbase) * height / 2
  end

  def self.perimeter(a, b, c, d)
    return a + b + c + d
  end
end
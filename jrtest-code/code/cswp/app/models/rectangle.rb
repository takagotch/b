#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
class Rectangle

  def self.area(length, width)
    return length * width
  end

  def self.perimeter(length, width)
    return 2*length + 2*width
  end

  def self.volume(length, width, height)
    return length*width*height
  end
end